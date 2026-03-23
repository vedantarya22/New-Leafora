import Foundation
import UserNotifications

final class PlantNotificationManager {

    static let shared = PlantNotificationManager()
    private init() {}

    private let notificationCenter = UNUserNotificationCenter.current()
    private let categoryPrefix = "plantCare_"

    // MARK: - Permission

    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print(" Notification permission granted")
            } else if let error = error {
                print(" Notification permission error: \(error.localizedDescription)")
            } else {
                print(" Notification permission denied")
            }
        }
    }

    // MARK: - Schedule All

    func scheduleAllCareNotifications() {
        // Clear existing plant-care notifications first
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(self.categoryPrefix) }
                .map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
            
            // Also remove the daily reminder
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: ["plantCare_dailyReminder"])

            // Schedule task-specific notifications
            self.scheduleFromStore()
            
            // Schedule daily 8 AM reminder if any tasks are due
            self.scheduleDailyReminder()
        }
    }
    
    // MARK: - Daily 8 AM Reminder
    
    private func scheduleDailyReminder() {
        let allPlants = PlantStore.shared.allPlants()
        print("[Notifications] Total plants in store: \(allPlants.count)")
        
        let calendar = Calendar.current
        let today = Date()
        
        var scheduledCount = 0
        
        // Pre-calculate due counts for the next 14 days so the notification string is always accurate
        for dayOffset in 0..<14 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            var dueCount = 0
            for plant in allPlants {
                if TaskDueEngine.isDue(plant, task: .watering, targetDate: targetDate) { dueCount += plant.quantity }
                if TaskDueEngine.isDue(plant, task: .pruning, targetDate: targetDate) { dueCount += plant.quantity }
                if TaskDueEngine.isDue(plant, task: .fertilizing, targetDate: targetDate) { dueCount += plant.quantity }
                if TaskDueEngine.isDue(plant, task: .repotting, targetDate: targetDate) { dueCount += plant.quantity }
            }
            
            if dueCount > 0 {
                let content = UNMutableNotificationContent()
                content.title = "Your plants need you!"
                content.body = "You have \(dueCount) care \(dueCount == 1 ? "task" : "tasks") waiting. Open Leafora to keep your plants happy."
                content.sound = .default
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
                dateComponents.hour = 8
                dateComponents.minute = 0
                
                // If today and it's already past 8 AM, iOS handles skipping it gracefully since it's in the past
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let id = "plantCare_dailyReminder_day\(dayOffset)"
                
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                notificationCenter.add(request)
                
                scheduledCount += 1
            }
        }
        
        print("[Notifications] Pre-scheduled \(scheduledCount) daily reminders for the upcoming 14 days.")
    }

    // MARK: - Cancel All

    func cancelAllNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(self.categoryPrefix) }
                .map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: idsToRemove)
            print("Cancelled all plant care notifications")
        }
    }

    // MARK: - Internal Scheduling

    private func scheduleFromStore() {
        let userPlants = PlantStore.shared.allPlants()
        let catalogue = PlantCatalogueCache.shared.plants

        // Build a lookup for catalogue data
        let catalogueMap = Dictionary(uniqueKeysWithValues: catalogue.map { ($0.mongoId ?? $0.plantId, $0) })

        struct PendingNotification {
            let identifier: String
            let title: String
            let body: String
            let fireDate: Date
        }

        var pending: [PendingNotification] = []

        for plant in userPlants {
            guard let plantData = catalogueMap[plant.plantId] else { continue }
            let plantName = plantData.plantName

            // Check each care task
            let tasks: [(CareTask, String, Date?, Int, String, String)] = [
                (.watering, "watering", plant.lastWatered,
                 plantData.careCycle.watering.days,
                 " Time to Water!",
                 "Your \(plantName) is ready for a drink."),

                (.pruning, "pruning", plant.lastPruned,
                 plantData.careCycle.pruning.days,
                 " Time to Prune!",
                 "Your \(plantName) could use a trim today."),

                (.fertilizing, "fertilizing", plant.lastFertilized,
                 plantData.careCycle.fertilizing.days,
                 " Time to Fertilize!",
                 "Your \(plantName) is due for some nutrients."),

                (.repotting, "repotting", plant.lastRepotted,
                 plantData.careCycle.repotting.days,
                 " Time to Repot!",
                 "Your \(plantName) might need a bigger pot.")
            ]

            for (_, taskName, lastDate, frequency, title, body) in tasks {
                // Use lastActionDate if available, otherwise use createdAt as baseline
                let baselineDate = lastDate ?? plant.createdAt

                let nextDueDate = Calendar.current.date(
                    byAdding: .day,
                    value: frequency,
                    to: baselineDate
                )!

                // Only schedule if the due date is in the future
                guard nextDueDate > Date() else { continue }

                let id = "\(categoryPrefix)\(plant.id.uuidString)_\(taskName)"
                pending.append(PendingNotification(
                    identifier: id,
                    title: title,
                    body: body,
                    fireDate: nextDueDate
                ))
            }
        }

       
        pending.sort { $0.fireDate < $1.fireDate }
        let capped = Array(pending.prefix(60))

        for item in capped {
            // Fire at 8:00 AM on the due date
            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day], from: item.fireDate
            )
            dateComponents.hour = 8
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: false
            )

            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: item.identifier,
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    print(" Failed to schedule notification: \(error.localizedDescription)")
                }
            }
        }

        print(" Scheduled \(capped.count) plant care notifications")
    }
}
