//  ChatSocketManager.swift
//  Leafora
//
//  Thin socket layer — emits/receives raw socket events.
//  All ciphertext passes through here. Decryption happens in ChatManager.

import Foundation
import SocketIO

// MARK: - SocketMessage
// Mirrors the MongoDB Message document emitted by the server.
// `text` is always ciphertext — ChatManager decrypts it.
struct SocketMessage {
    let id:          String
    let senderId:    String
    let receiverId:  String
    let roomId:      String
    let text:        String   // ciphertext (base64 AES-GCM)
    let timestamp:   Date
    let isRead:      Bool
    let isDelivered: Bool
}

// MARK: - ChatSocketManager
final class ChatSocketManager {
    static let shared = ChatSocketManager()
    private init() {}

    private var manager: SocketManager?
    private var socket:  SocketIOClient?

    // MARK: Callbacks (set by ChatManager)
    var onMessageReceived:  ((SocketMessage)   -> Void)?  // real-time delivery
    var onPendingMessages:  (([SocketMessage]) -> Void)?  // offline queue flush
    var onMessageSent:      ((SocketMessage)   -> Void)?  // server ack after save
    var onMessagesRead:     ((String, String)  -> Void)?  // roomId, readBy
    var onUserTyping:       ((String, String)  -> Void)?  // senderId, roomId
    var onUserStopTyping:   ((String, String)  -> Void)?  // senderId, roomId

    // Update this to match your Render URL
    private let baseURL = "https://plantappbackend-933m.onrender.com/api"

    // MARK: - Connect
    func connect(userId: String) {
        manager = SocketManager(socketURL: URL(string: baseURL)!,
                                config: [.log(false), .compress, .reconnects(true)])
        socket = manager?.defaultSocket

        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            print("ChatSocket: connected")
            self?.socket?.emit("register", userId)
        }

        socket?.on(clientEvent: .disconnect) { _, _ in
            print("ChatSocket: disconnected")
        }

        socket?.on(clientEvent: .error) { data, _ in
            print("ChatSocket error: \(data)")
        }

        // Real-time message from another online user
        socket?.on("receiveMessage") { [weak self] data, _ in
            guard let msg = self?.parseMessage(from: data) else { return }
            DispatchQueue.main.async { self?.onMessageReceived?(msg) }
        }

        // Batch of messages saved while this user was offline
        socket?.on("pendingMessages") { [weak self] data, _ in
            guard let arr = data.first as? [[String: Any]] else { return }
            let msgs = arr.compactMap { self?.parseMessageDict($0) }
            DispatchQueue.main.async { self?.onPendingMessages?(msgs) }
        }

        // Server ack: message was persisted (contains MongoDB _id + server timestamp)
        socket?.on("messageSent") { [weak self] data, _ in
            guard let msg = self?.parseMessage(from: data) else { return }
            DispatchQueue.main.async { self?.onMessageSent?(msg) }
        }

        // Other participant read our messages
        socket?.on("messagesRead") { [weak self] data, _ in
            guard let dict   = data.first as? [String: Any],
                  let roomId = dict["roomId"] as? String,
                  let readBy = dict["readBy"] as? String else { return }
            DispatchQueue.main.async { self?.onMessagesRead?(roomId, readBy) }
        }

        // Typing indicators
        socket?.on("userTyping") { [weak self] data, _ in
            guard let dict     = data.first as? [String: Any],
                  let senderId = dict["senderId"] as? String,
                  let roomId   = dict["roomId"] as? String else { return }
            DispatchQueue.main.async { self?.onUserTyping?(senderId, roomId) }
        }

        socket?.on("userStopTyping") { [weak self] data, _ in
            guard let dict     = data.first as? [String: Any],
                  let senderId = dict["senderId"] as? String,
                  let roomId   = dict["roomId"] as? String else { return }
            DispatchQueue.main.async { self?.onUserStopTyping?(senderId, roomId) }
        }

        socket?.connect()
    }

    // MARK: - Emit

    /// Send an encrypted message. `encryptedText` is base64 AES-GCM ciphertext.
    func sendMessage(to receiverId: String, encryptedText: String, roomId: String?) {
        var payload: [String: Any] = [
            "senderId":   UserSession.shared.currentLoggedInUserID,
            "receiverId": receiverId,
            "text":       encryptedText
        ]
        if let roomId = roomId { payload["roomId"] = roomId }
        socket?.emit("sendMessage", payload)
    }

    func markRead(roomId: String) {
        socket?.emit("markRead", [
            "roomId": roomId,
            "userId": UserSession.shared.currentLoggedInUserID
        ])
    }

    func sendTyping(to receiverId: String, roomId: String) {
        socket?.emit("typing", [
            "senderId":   UserSession.shared.currentLoggedInUserID,
            "receiverId": receiverId,
            "roomId":     roomId
        ])
    }

    func sendStopTyping(to receiverId: String, roomId: String) {
        socket?.emit("stopTyping", [
            "senderId":   UserSession.shared.currentLoggedInUserID,
            "receiverId": receiverId,
            "roomId":     roomId
        ])
    }

    func disconnect() { socket?.disconnect() }

    // MARK: - Parsing

    private func parseMessage(from data: [Any]) -> SocketMessage? {
        guard let dict = data.first as? [String: Any] else { return nil }
        return parseMessageDict(dict)
    }

    private func parseMessageDict(_ dict: [String: Any]) -> SocketMessage? {
        guard let senderId   = extractString(dict, key: "senderId"),
              let receiverId = extractString(dict, key: "receiverId"),
              let text       = dict["text"] as? String,
              let roomId     = extractString(dict, key: "roomId") else { return nil }

        let id = extractString(dict, key: "_id") ?? UUID().uuidString

        let timestamp: Date
        if let tsString = dict["timestamp"] as? String {
            timestamp = ISO8601DateFormatter().date(from: tsString) ?? Date()
        } else {
            timestamp = Date()
        }

        return SocketMessage(
            id:          id,
            senderId:    senderId,
            receiverId:  receiverId,
            roomId:      roomId,
            text:        text,
            timestamp:   timestamp,
            isRead:      dict["isRead"]      as? Bool ?? false,
            isDelivered: dict["isDelivered"] as? Bool ?? false
        )
    }

    // Mongoose ObjectId serializes to a plain string via socket.io,
    // but guard against the { "$oid": "..." } form just in case.
    private func extractString(_ dict: [String: Any], key: String) -> String? {
        if let str = dict[key] as? String { return str }
        if let oid = dict[key] as? [String: Any], let str = oid["$oid"] as? String { return str }
        return nil
    }
}
