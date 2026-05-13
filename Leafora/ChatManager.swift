//  ChatManager.swift
//  Leafora
//
//  Single source of truth for chat.
//  Replaced CoreData with MongoDB (via REST) + in-memory caches.
//  All encryption/decryption is handled here — ViewControllers always get plaintext.

import Foundation

// MARK: - Models

struct ChatMessage {
    let id:          String
    let senderId:    String
    let receiverId:  String
    let roomId:      String
    let text:        String   // always plaintext — decrypted before reaching here
    let timestamp:   Date
    let isRead:      Bool
    let isDelivered: Bool
}

struct ChatPreview {
    let text:      String    // plaintext last message snippet
    let timestamp: Date
    let senderId:  String
}

// MARK: - ChatManager

final class ChatManager {
    static let shared = ChatManager()
    private init() { bindSocket() }

    // ChatViewController sets this to receive real-time messages
    var onNewMessage: ((ChatMessage) -> Void)?

    // MARK: - Caches
    private var publicKeyCache: [String: String]      = [:] // userId → base64 pubkey
    private var previewCache:   [String: ChatPreview] = [:] // otherUserId → last msg preview

    // Active conversation state
    private var activeRoomId:    String?
    private var activeOtherUser: String?

    // Update to match your Render backend URL
    private let baseURL = "https://plantappbackend-933m.onrender.com/api/messages"

    // MARK: - Socket Binding
    private func bindSocket() {
        // Real-time message from an online sender
        ChatSocketManager.shared.onMessageReceived = { [weak self] socketMsg in
            self?.handleIncoming(socketMsg)
        }

        // Offline queue — batch of messages the server held while we were disconnected
        ChatSocketManager.shared.onPendingMessages = { [weak self] messages in
            messages.forEach { self?.handleIncoming($0) }
        }
    }

    // Decrypt and dispatch an incoming socket message
    private func handleIncoming(_ socketMsg: SocketMessage) {
        let senderId = socketMsg.senderId

        getPublicKey(for: senderId) { [weak self] pubKey in
            guard let self = self, let pubKey = pubKey else { return }

            let plaintext = (try? E2EEManager.shared.decrypt(socketMsg.text,
                                                              otherUserPublicKeyBase64: pubKey)) ?? "[message unavailable]"
            let chatMsg = ChatMessage(
                id:          socketMsg.id,
                senderId:    senderId,
                receiverId:  socketMsg.receiverId,
                roomId:      socketMsg.roomId,
                text:        plaintext,
                timestamp:   socketMsg.timestamp,
                isRead:      socketMsg.isRead,
                isDelivered: socketMsg.isDelivered
            )

            // Update preview cache for People screen
            self.previewCache[senderId] = ChatPreview(
                text:      plaintext,
                timestamp: socketMsg.timestamp,
                senderId:  senderId
            )

            DispatchQueue.main.async {
                self.onNewMessage?(chatMsg)
                NotificationCenter.default.post(name: .didSendMessage, object: nil,
                                                userInfo: ["userId": senderId])
            }
        }
    }

    // MARK: - Open Conversation
    // Called by ChatViewController on viewDidLoad.
    // Returns (roomId, decrypted messages).
    func openConversation(with otherUserId: String,
                          completion: @escaping (String?, [ChatMessage]) -> Void) {
        activeOtherUser = otherUserId

        // Step 1: find or create the room
        findOrCreateRoom(with: otherUserId) { [weak self] roomId in
            guard let self = self, let roomId = roomId else {
                DispatchQueue.main.async { completion(nil, []) }
                return
            }
            self.activeRoomId = roomId

            // Step 2: get other user's public key (needed for decryption)
            self.getPublicKey(for: otherUserId) { pubKey in
                guard let pubKey = pubKey else {
                    DispatchQueue.main.async { completion(roomId, []) }
                    return
                }

                // Step 3: fetch + decrypt message history
                self.fetchMessages(roomId: roomId, otherPublicKey: pubKey) { messages in
                    // Seed preview from last message so People screen is up to date
                    if let last = messages.last {
                        self.previewCache[otherUserId] = ChatPreview(
                            text:      last.text,
                            timestamp: last.timestamp,
                            senderId:  last.senderId
                        )
                    }
                    DispatchQueue.main.async { completion(roomId, messages) }
                }
            }
        }
    }

    // MARK: - Send Message
    // Encrypts plaintext, then emits via socket.
    func sendMessage(to receiverId: String, text: String, roomId: String?) {
        getPublicKey(for: receiverId) { [weak self] pubKey in
            guard let pubKey = pubKey else {
                print("ChatManager: no public key for \(receiverId) — cannot encrypt")
                return
            }
            guard let ciphertext = try? E2EEManager.shared.encrypt(text,
                                                                     recipientPublicKeyBase64: pubKey) else {
                print("ChatManager: encryption failed")
                return
            }

            ChatSocketManager.shared.sendMessage(to: receiverId,
                                                  encryptedText: ciphertext,
                                                  roomId: roomId)

            // Optimistically update preview so People screen reflects the sent message
            let myId = UserSession.shared.currentLoggedInUserID
            self?.previewCache[receiverId] = ChatPreview(
                text:      text,
                timestamp: Date(),
                senderId:  myId
            )
        }
    }

    // MARK: - Close Conversation
    func closeConversation() {
        activeRoomId    = nil
        activeOtherUser = nil
        onNewMessage    = nil
    }

    // MARK: - People Screen: load inbox previews
    // Fetches all rooms from the server, decrypts lastMessage for each,
    // and populates previewCache so PeopleViewController can show last-message rows.
    func loadRooms(completion: @escaping () -> Void) {
        request("/rooms") { [weak self] data in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let rooms = json["rooms"] as? [[String: Any]] else {
                DispatchQueue.main.async { completion() }
                return
            }

            let myId = UserSession.shared.currentLoggedInUserID

            for room in rooms {
                guard let participants = room["participants"] as? [[String: Any]],
                      let lastMsgDict  = room["lastMessage"] as? [String: Any],
                      let ciphertext   = lastMsgDict["text"] as? String,
                      let senderId     = lastMsgDict["senderId"] as? String,
                      let tsString     = lastMsgDict["timestamp"] as? String else { continue }

                // Find the other participant (not current user)
                guard let other        = participants.first(where: { ($0["_id"] as? String) != myId }),
                      let otherUserId  = other["_id"] as? String,
                      let otherPubKey  = other["publicKey"] as? String else { continue }

                // Cache the public key while we have it
                self.publicKeyCache[otherUserId] = otherPubKey

                let timestamp = ISO8601DateFormatter().date(from: tsString) ?? Date()
                let plaintext = (try? E2EEManager.shared.decrypt(ciphertext,
                                                                   otherUserPublicKeyBase64: otherPubKey)) ?? "..."

                self.previewCache[otherUserId] = ChatPreview(
                    text:      plaintext,
                    timestamp: timestamp,
                    senderId:  senderId
                )
            }

            DispatchQueue.main.async { completion() }
        }
    }

    // MARK: - People Screen: last message preview
    func lastPreview(with otherUserId: String) -> ChatPreview? {
        previewCache[otherUserId]
    }

    // Cosmetic: wipe preview from inbox (doesn't touch MongoDB)
    func clearPreview(for otherUserId: String) {
        previewCache.removeValue(forKey: otherUserId)
    }

    // MARK: - Register Public Key with Server
    // Called once per session (idempotent — server just overwrites the field).
    func registerPublicKey(completion: @escaping (Bool) -> Void) {
        let myId   = UserSession.shared.currentLoggedInUserID
        let pubKey = E2EEManager.shared.publicKeyBase64(for: myId)

        request("/keys/register", method: "POST", body: ["publicKey": pubKey]) { data in
            let success = data != nil
            if success { print("E2EE: public key registered with server") }
            DispatchQueue.main.async { completion(success) }
        }
    }

    // MARK: - Formatted Time (People screen)
    func formattedTime(for date: Date?) -> String {
        guard let date = date else { return "" }
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let f = DateFormatter(); f.dateFormat = "h:mm a"
            return f.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        }
        let f = DateFormatter(); f.dateFormat = "dd/MM/yy"
        return f.string(from: date)
    }

    // MARK: - Private: Networking

    private func findOrCreateRoom(with receiverId: String, completion: @escaping (String?) -> Void) {
        request("/rooms/\(receiverId)", method: "POST") { data in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let room = json["room"] as? [String: Any],
                  let id   = room["_id"] as? String else {
                completion(nil); return
            }
            completion(id)
        }
    }

    private func fetchMessages(roomId: String, otherPublicKey: String,
                               completion: @escaping ([ChatMessage]) -> Void) {
        request("/rooms/\(roomId)/messages") { data in
            guard let data   = data,
                  let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let arr    = json["messages"] as? [[String: Any]] else {
                completion([]); return
            }

            let messages = arr.compactMap { dict -> ChatMessage? in
                guard let id         = dict["_id"]        as? String,
                      let senderId   = dict["senderId"]   as? String,
                      let receiverId = dict["receiverId"] as? String,
                      let roomId     = dict["roomId"]     as? String,
                      let cipher     = dict["text"]       as? String,
                      let tsString   = dict["timestamp"]  as? String else { return nil }

                let timestamp = ISO8601DateFormatter().date(from: tsString) ?? Date()

                // Same shared secret decrypts messages in both directions
                let plaintext = (try? E2EEManager.shared.decrypt(cipher,
                                                                   otherUserPublicKeyBase64: otherPublicKey)) ?? "[encrypted]"
                return ChatMessage(
                    id:          id,
                    senderId:    senderId,
                    receiverId:  receiverId,
                    roomId:      roomId,
                    text:        plaintext,
                    timestamp:   timestamp,
                    isRead:      dict["isRead"]      as? Bool ?? false,
                    isDelivered: dict["isDelivered"] as? Bool ?? false
                )
            }
            completion(messages)
        }
    }

    private func getPublicKey(for userId: String, completion: @escaping (String?) -> Void) {
        if let cached = publicKeyCache[userId] { completion(cached); return }

        request("/keys/\(userId)") { [weak self] data in
            guard let data   = data,
                  let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let pubKey = json["publicKey"] as? String else {
                completion(nil); return
            }
            self?.publicKeyCache[userId] = pubKey
            completion(pubKey)
        }
    }

    // Shared URLSession helper — reads JWT from Keychain automatically
    private func request(_ path: String,
                          method: String = "GET",
                          body:   [String: Any]? = nil,
                          completion: @escaping (Data?) -> Void) {
        guard let token = KeychainManager.shared.getToken(),
              let url   = URL(string: "\(baseURL)\(path)") else {
            completion(nil); return
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        URLSession.shared.dataTask(with: req) { data, _, _ in
            completion(data)
        }.resume()
    }
}
