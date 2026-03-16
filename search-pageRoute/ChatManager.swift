//
//  ChatManager.swift
//  Leafora
//

import Foundation
import CoreData

final class ChatManager {

    static let shared = ChatManager()
    private init() {}

    // MARK: - CoreData Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatModel")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("❌ CoreData failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Room ID
    // Deterministic — same key regardless of who initiated
    func roomId(with otherUserId: String) -> String {
        [UserSession.shared.currentLoggedInUserID, otherUserId]
            .sorted()
            .joined(separator: "_")
    }

    // MARK: - Send  (saves locally + emits via socket)
    @discardableResult
    func sendMessage(to receiverId: String, text: String) -> MessageEntity {
        let msgId = UUID().uuidString

        // 1. Persist to CoreData immediately
        let entity        = MessageEntity(context: context)
        entity.id         = msgId
        entity.senderId   = UserSession.shared.currentLoggedInUserID
        entity.receiverId = receiverId
        entity.text       = text
        entity.timestamp  = Date()
        entity.isRead     = false
        entity.roomId     = roomId(with: receiverId)
        save()

        // 2. Relay to receiver via Socket.io
        ChatSocketManager.shared.sendMessage(to: receiverId, text: text, messageId: msgId)

        return entity
    }

    // MARK: - Save Incoming Socket Message
    // Called by ChatSocketManager when a message arrives from another user
    func saveIncoming(message: SocketMessage) {
        // Dedup — don't save the same messageId twice
        let check: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        check.predicate = NSPredicate(format: "id == %@", message.messageId)
        if let found = try? context.fetch(check), !found.isEmpty { return }

        let entity        = MessageEntity(context: context)
        entity.id         = message.messageId
        entity.senderId   = message.senderId
        entity.receiverId = message.receiverId
        entity.text       = message.text
        entity.timestamp  = message.timestamp
        entity.isRead     = false
        // roomId uses senderId because from our perspective, sender is "other user"
        entity.roomId     = roomId(with: message.senderId)
        save()
    }

    // MARK: - Fetch Conversation
    func fetchMessages(with otherUserId: String) -> [MessageEntity] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate       = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Last Message (People cell preview)
    func lastMessage(with otherUserId: String) -> MessageEntity? {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate       = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit      = 1
        return (try? context.fetch(request))?.first
    }

    // MARK: - Delete Single Message
    func deleteMessage(byId messageId: String) {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", messageId)
        if let results = try? context.fetch(request) {
            results.forEach { context.delete($0) }
            save()
        }
    }

    // MARK: - Delete Conversation
    func deleteConversation(with otherUserId: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        try? context.execute(NSBatchDeleteRequest(fetchRequest: request))
        save()
    }

    // MARK: - Formatted Timestamp (People cell)
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

    // MARK: - Save
    func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
