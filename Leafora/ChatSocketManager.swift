//
//  ChatSocketManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 14/03/26.
//



import Foundation
import SocketIO

// Payload we send and receive
struct SocketMessage {
    let messageId:  String
    let senderId:   String
    let receiverId: String
    let text:       String
    let timestamp:  Date
}

final class ChatSocketManager {
    static let shared = ChatSocketManager()
    private init() {}

    // MARK: - Socket setup
    private var manager: SocketManager?
    private var socket:  SocketIOClient?

  
    var onMessageReceived: ((SocketMessage) -> Void)?

    // MARK: - Connect
    
    func connect(userId: String) {
        let serverURL = URL(string: "https://plantappbackend-933m.onrender.com")!

        manager = SocketManager(socketURL: serverURL, config: [
            .log(false),
            .compress,
            .reconnects(true),
            .reconnectWait(3)
        ])

        socket = manager?.defaultSocket

        //MARK: Event handlers
        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            print(" Socket connected")
            // Tell server who we are so it can route messages to us
            self?.socket?.emit("register", userId)
        }

        socket?.on(clientEvent: .disconnect) { _, _ in
            print(" Socket disconnected")
        }

        socket?.on(clientEvent: .error) { data, _ in
            print(" Socket error: \(data)")
        }

        // Incoming message from another user
        socket?.on("receiveMessage") { [weak self] data, _ in
            guard let payload = data.first as? [String: Any] else { return }
            guard
                let messageId  = payload["messageId"]  as? String,
                let senderId   = payload["senderId"]   as? String,
                let receiverId = payload["receiverId"] as? String,
                let text       = payload["text"]       as? String,
                let tsString   = payload["timestamp"]  as? String
            else {
                print(" Failed to parse incoming message: \(payload)")
                return
            }

            let ts  = ISO8601DateFormatter().date(from: tsString) ?? Date()
            let msg = SocketMessage(messageId: messageId, senderId: senderId,
                                    receiverId: receiverId, text: text, timestamp: ts)

            // Save to CoreData so it persists
            ChatManager.shared.saveIncoming(message: msg)

            // Notify ChatViewController if it's open
            DispatchQueue.main.async {
                self?.onMessageReceived?(msg)
            }
        }

        socket?.connect()
    }

    // MARK: - Send
    func sendMessage(to receiverId: String, text: String, messageId: String) {
        guard socket?.status == .connected else {
            print(" Socket not connected — cannot send")
            return
        }
        let payload: [String: Any] = [
            "messageId":  messageId,
            "senderId":   UserSession.shared.currentLoggedInUserID,
            "receiverId": receiverId,
            "text":       text,
            "timestamp":  ISO8601DateFormatter().string(from: Date())
        ]
        socket?.emit("sendMessage", payload)
    }

    // MARK: - Disconnect
    func disconnect() {
        socket?.disconnect()
        socket    = nil
        manager   = nil
    }
}
