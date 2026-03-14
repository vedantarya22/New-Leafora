//
//  ChatManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 14/03/26.
//

//  Singleton that owns all CoreData chat operations.
//  No network — messages live on-device only (WhatsApp model).
//

import Foundation
import CoreData
import UIKit

final class ChatManager {

    static let shared = ChatManager()
    private init() {}

    // MARK: - CoreData Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatModel") // must match .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ CoreData failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Room ID
    // Deterministic — same key regardless of who initiated the chat
    func roomId(with otherUserId: String) -> String {
        let myId = UserSession.shared.currentLoggedInUserID
        return [myId, otherUserId].sorted().joined(separator: "_")
    }

    // MARK: - Send Message
    @discardableResult
    func sendMessage(to receiverId: String, text: String) -> MessageEntity {
        let msg            = MessageEntity(context: context)
        msg.id             = UUID().uuidString
        msg.senderId       = UserSession.shared.currentLoggedInUserID
        msg.receiverId     = receiverId
        msg.text           = text
        msg.timestamp      = Date()
        msg.isRead         = false
        msg.roomId         = roomId(with: receiverId)
        save()
        return msg
    }

    // MARK: - Fetch Messages for a Conversation
    func fetchMessages(with otherUserId: String) -> [MessageEntity] {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate  = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Last Message (for People cell preview)
    func lastMessage(with otherUserId: String) -> MessageEntity? {
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate      = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit     = 1
        return (try? context.fetch(request))?.first
    }

    // MARK: - Unread Count
    func unreadCount(with otherUserId: String) -> Int {
        let myId = UserSession.shared.currentLoggedInUserID
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "roomId == %@ AND receiverId == %@ AND isRead == false",
            roomId(with: otherUserId), myId
        )
        return (try? context.count(for: request)) ?? 0
    }

    // MARK: - Mark All Read
    func markAllRead(with otherUserId: String) {
        let myId = UserSession.shared.currentLoggedInUserID
        let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "roomId == %@ AND receiverId == %@ AND isRead == false",
            roomId(with: otherUserId), myId
        )
        let unread = (try? context.fetch(request)) ?? []
        unread.forEach { $0.isRead = true }
        save()
    }

    // MARK: - Delete Conversation
    func deleteConversation(with otherUserId: String) {
        let request: NSFetchRequest<NSFetchRequestResult> = MessageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "roomId == %@", roomId(with: otherUserId))
        let batch = NSBatchDeleteRequest(fetchRequest: request)
        try? context.execute(batch)
        save()
    }

    // MARK: - Formatted Timestamp
    func formattedTime(for date: Date?) -> String {
        guard let date = date else { return "" }
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let f = DateFormatter()
            f.dateFormat = "dd/MM/yy"
            return f.string(from: date)
        }
    }

    // MARK: - Save
    private func save() {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
