import Foundation
internal import Combine
import UIKit

// MARK: - Notification Names
extension Notification.Name {
    static let plantsDidChange = Notification.Name("plantsDidChange")
}

final class PlantStore: ObservableObject {

    static let shared = PlantStore()

    func setPlants(_ newPlants: [UserPlant]) {
        plants = newPlants
        
        // Notify observers that plant data has changed
        NotificationCenter.default.post(name: .plantsDidChange, object: nil)
        print("📢 Posted plantsDidChange notification")
    }

    // MARK: - Published Data
    @Published private(set) var plants: [UserPlant] = [] {
        didSet { savePlantsAsync() }  //  Now async to prevent main thread blocking
    }
    
    // MARK: - Async Save Debouncing
    private var saveWorkItem: DispatchWorkItem?

    // MARK: - File Storage URL
    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savedPlants.json")
    }

    // MARK: - Init
    private init() {
        loadPlants()
        performMigrationIfNeeded()
    }
    
    // MARK: - One-time Migration
    private func performMigrationIfNeeded() {
        let migrationKey = "didMigrateImageDataToCloudinary_v1"
        
        // Check if migration already done
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            print(" Migration already completed")
            return
        }
        
        print("🔄 Starting one-time migration: Cleaning up local imageData...")
        
        // Clear all imageData from plants (they're already transient now)
        var didChange = false
        for i in 0..<plants.count {
            if plants[i].imageData != nil {
                plants[i].imageData = nil
                didChange = true
            }
        }
        
        if didChange {
            // Force immediate synchronous save to persist migration
            savePlants()
            print(" Migration complete: Removed imageData from \(plants.count) plants")
        } else {
            print(" Migration complete: No imageData found")
        }
        
        // Mark migration as done
        UserDefaults.standard.set(true, forKey: migrationKey)
    }

    // MARK: - Add / Update Plant
    func addPlant(_ plant: UserPlant) {
        print("➡️ ADD REQUEST: plantId=\(plant.plantId), siteID=\(plant.siteID), qty=\(plant.quantity)")
        plants.append(plant)
        print("🆕 NEW ENTRY CREATED: ID=\(plant.id), qty=\(plant.quantity)")
        
        // Schedule notifications for the newly added plant (debounced)
        PlantNotificationManager.shared.scheduleAllCareNotificationsDebounced()
    }

    // MARK: - Stats
    var totalPlants: Int {
        plants.reduce(0) { $0 + $1.quantity }
    }

    var totalSpaces: Int {
        Set(plants.map { $0.siteName }).count
    }

    // MARK: - Fetch

    // Legacy — local UUID (kept for compatibility)
    func plants(for siteID: UUID) -> [UserPlant] {
        plants.filter { $0.siteID == siteID }
    }

    // MongoDB siteId string
    func plants(forMongoSiteId mongoSiteId: String) -> [UserPlant] {
        plants.filter { $0.mongoSiteId == mongoSiteId }
    }

    // siteName fallback
    func plants(forSiteName siteName: String) -> [UserPlant] {
        plants.filter { $0.siteName == siteName }
    }

    //  Smart fetch — mongoSiteId first, siteName fallback
    func plants(for site: MyGardenSite) -> [UserPlant] {
        if let mongoId = site.mongoId {
            let result = plants.filter { $0.mongoSiteId == mongoId }
            if !result.isEmpty { return result }
        }
        return plants.filter { $0.siteName == site.name }
    }

    // MARK: - Grouped Plants

    //  Smart grouped — uses site object
    func groupedPlants(for site: MyGardenSite) -> [(plant: UserPlant, count: Int)] {
        return makeGrouped(from: plants(for: site))
    }

    // Legacy siteName grouped (kept for compatibility)
    func groupedPlants(forSiteName siteName: String) -> [(plant: UserPlant, count: Int)] {
        return makeGrouped(from: plants(forSiteName: siteName))
    }

    // Legacy UUID grouped (kept for compatibility)
    func groupedPlants(for siteID: UUID) -> [(plant: UserPlant, count: Int)] {
        return makeGrouped(from: plants(for: siteID))
    }

    private func makeGrouped(from sitePlants: [UserPlant]) -> [(plant: UserPlant, count: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var grouped: [String: [UserPlant]] = [:]
        for plant in sitePlants {
            let dateKey = formatter.string(from: plant.createdAt)
            let groupKey = "\(plant.plantId)_\(dateKey)"
            grouped[groupKey, default: []].append(plant)
        }

        return grouped.values.compactMap { group -> (plant: UserPlant, count: Int)? in
            guard let first = group.first else { return nil }
            return (plant: first, count: group.reduce(0) { $0 + $1.quantity })
        }.sorted { $0.plant.createdAt > $1.plant.createdAt }
    }

    // MARK: - Get All Plants
    func allPlants() -> [UserPlant] {
        return plants
    }

    // MARK: - Get Plant by ID
    func getPlant(by id: UUID) -> UserPlant? {
        return plants.first(where: { $0.id == id })
    }

    // MARK: - Update Plant
    func updatePlant(_ updatedPlant: UserPlant) {
        guard let index = plants.firstIndex(where: { $0.id == updatedPlant.id }) else {
            print(" Plant not found for update")
            return
        }
        plants[index] = updatedPlant
        print(" Plant updated: ID=\(updatedPlant.id)")
    }

    // MARK: - Persistence
    private func savePlants() {
        do {
            let data = try JSONEncoder().encode(plants)
            try data.write(to: fileURL, options: [.atomic])
            print("💾 Saved \(plants.count) plant entries")
        } catch {
            print(" Failed to save plants:", error)
        }
    }
    
    // MARK: - Async Save with Debouncing
    private func savePlantsAsync() {
        // Cancel any pending save to debounce rapid changes
        saveWorkItem?.cancel()
        
        // Schedule new save after 0.5 second delay
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            // Perform actual save on background thread
            DispatchQueue.global(qos: .utility).async {
                self.savePlants()
            }
        }
        saveWorkItem = workItem
        
        // Execute after delay (debounce window)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    private func loadPlants() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("📂 No saved plants file found")
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            plants = try JSONDecoder().decode([UserPlant].self, from: data)
            print(" Loaded \(plants.count) plant entries")
        } catch {
            print(" Failed to load plants:", error)
        }
    }

    // MARK: - Task Completion
    func markTaskDone(userPlantID: UUID, taskType: String) {
        guard let index = plants.firstIndex(where: { $0.id == userPlantID }) else {
            print(" Plant not found with ID:", userPlantID)
            return
        }
        switch taskType.lowercased() {
        case "watering":    plants[index].lastWatered    = Date()
        case "pruning":     plants[index].lastPruned     = Date()
        case "fertilizing": plants[index].lastFertilized = Date()
        case "repotting":   plants[index].lastRepotted   = Date()
        default: print("⚠️ Unknown task type:", taskType)
        }
        
        // Reschedule notifications with updated due dates (debounced)
        PlantNotificationManager.shared.scheduleAllCareNotificationsDebounced()
    }

    // MARK: - Remove Plants

    func removePlant(by id: UUID) {
        plants.removeAll { $0.id == id }
    }

    //  mongoSiteId first, siteName fallback
    func removeAllPlants(for site: MyGardenSite) {
        if let mongoId = site.mongoId {
            plants.removeAll { $0.mongoSiteId == mongoId }
        } else {
            plants.removeAll { $0.siteName == site.name }
        }
    }

    func removeAllPlants(plantId: String, siteID: UUID) {
        plants.removeAll { $0.plantId == plantId && $0.siteID == siteID }
    }

    func removeAllPlants(plantId: String, siteName: String) {
        plants.removeAll { $0.plantId == plantId && $0.siteName == siteName }
    }

    func removeAllPlants(for siteID: UUID) {
        plants.removeAll { $0.siteID == siteID }
    }

    func removeAllPlants(forSiteName siteName: String) {
        plants.removeAll { $0.siteName == siteName }
    }
}

// MARK: - Helpers
extension JSONLoader {
    static func plant(by id: String) -> Plant? {
        loadPlants(from: "plantData").first { $0.plantId == id }
    }
}

extension PlantStore {
    func hasUserAddedPlant(plantId: String) -> Bool {
        plants.contains { $0.plantId == plantId }
    }

    func removeOnePlant(plantId: String, siteID: UUID) {
        if let index = plants.firstIndex(where: {
            $0.plantId == plantId && $0.siteID == siteID
        }) {
            plants.remove(at: index)
            print("🗑️ Removed one plant of type:", plantId)
        }
    }
}
