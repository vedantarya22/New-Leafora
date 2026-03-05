//
//  PlantStore.swift
//  PlantApp
//
//  Created by SDC-USER on 12/12/25.
//

import Foundation
internal import Combine
import UIKit

final class PlantStore: ObservableObject {

    static let shared = PlantStore()
    
    func setPlants(_ newPlants: [UserPlant]) {
        plants = newPlants
    }

    // MARK: - Published Data

    @Published private(set) var plants: [UserPlant] = [] {
        didSet { savePlants() }
    }

    // MARK: - File Storage URL

    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("savedPlants.json")
    }

    // MARK: - Init

    private init() {
        loadPlants()
    }

    // MARK: - Add / Update Plant

    func addPlant(_ plant: UserPlant) {
        print("➡️ ADD REQUEST: plantId=\(plant.plantId), siteID=\(plant.siteID), qty=\(plant.quantity)")
        
        // CHANGED: Always add as new entry with unique ID
        // No longer merging - each plant gets its own UUID
        plants.append(plant)
        print("🆕 NEW ENTRY CREATED: ID=\(plant.id), qty=\(plant.quantity)")
    }

    // MARK: - Stats

    var totalPlants: Int {
        // Count total quantity across all plants
        plants.reduce(0) { $0 + $1.quantity }
    }

    var totalSpaces: Int {
        Set(plants.map { $0.siteID }).count
    }

    // MARK: - Fetch

    func plants(for siteID: UUID) -> [UserPlant] {
        plants.filter { $0.siteID == siteID }
    }
    
    // MARK: - Get All Plants (for Care Tasks)
    
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
            print("❌ Plant not found for update")
            return
        }
        plants[index] = updatedPlant
        print("✅ Plant updated: ID=\(updatedPlant.id)")
    }
    
    // MARK: - Group Plants by Type (for Display)
    
    func groupedPlants(for siteID: UUID) -> [(plant: UserPlant, count: Int)] {
        let sitePlants = plants.filter { $0.siteID == siteID }
        
        // Group by plantId + date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var grouped: [String: [UserPlant]] = [:]
        for plant in sitePlants {
            let dateKey = formatter.string(from: plant.createdAt)
            let groupKey = "\(plant.plantId)_\(dateKey)"
            if grouped[groupKey] == nil {
                grouped[groupKey] = []
            }
            grouped[groupKey]?.append(plant)
        }
        
        // Return first plant of each group with total count
        let groupedTuples = grouped.values.compactMap { group -> (plant: UserPlant, count: Int)? in
            guard let first = group.first else { return nil }
            let totalCount = group.reduce(0) { $0 + $1.quantity }
            return (plant: first, count: totalCount)
        }
        
        // Sort by creation date descending (newest first)
        return groupedTuples.sorted(by: { $0.plant.createdAt > $1.plant.createdAt })
    }

    // MARK: - Persistence (Disk)

    private func savePlants() {
        do {
            let data = try JSONEncoder().encode(plants)
            try data.write(to: fileURL, options: [.atomic])
            print("💾 Saved \(plants.count) plant entries")
        } catch {
            print("❌ Failed to save plants:", error)
        }
    }

    private func loadPlants() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("📂 No saved plants file found")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            plants = try JSONDecoder().decode([UserPlant].self, from: data)
            print("✅ Loaded \(plants.count) plant entries")
        } catch {
            print("❌ Failed to load plants:", error)
        }
    }

    // MARK: - Task Completion

    func markTaskDone(userPlantID: UUID, taskType: String) {
        guard let index = plants.firstIndex(where: { $0.id == userPlantID }) else {
            print("❌ Plant not found with ID:", userPlantID)
            return
        }

        switch taskType.lowercased() {
        case "watering":
            plants[index].lastWatered = Date()
            print("✅ Watered plant ID:", userPlantID)
            
        case "pruning":
            plants[index].lastPruned = Date()
            print("✅ Pruned plant ID:", userPlantID)
            
        case "fertilizing":
            plants[index].lastFertilized = Date()
            print("✅ Fertilized plant ID:", userPlantID)
            
        case "repotting":
            plants[index].lastRepotted = Date()
            print("✅ Repotted plant ID:", userPlantID)
            
        default:
            print("⚠️ Unknown task type:", taskType)
            break
        }
    }
    
    // MARK: - Remove Plants
    
    func removePlant(by id: UUID) {
        plants.removeAll { $0.id == id }
        print("🗑️ Removed plant with ID:", id)
    }
    
    func removeAllPlants(plantId: String, siteID: UUID) {
        let beforeCount = plants.count
        plants.removeAll { $0.plantId == plantId && $0.siteID == siteID }
        let removedCount = beforeCount - plants.count
        print("🗑️ Removed \(removedCount) plants of type:", plantId)
    }
    
    func removeAllPlants(for siteID: UUID) {
        plants.removeAll { $0.siteID == siteID }
        print("🗑️ Removed all plants for site:", siteID)
    }
  

}

//
// MARK: - Helpers
//

extension JSONLoader {
    static func plant(by id: String) -> Plant? {
        loadPlants(from: "plantData").first { $0.plantId == id }  // ✅ Fixed
    }
}

extension PlantStore {
    func hasUserAddedPlant(plantId: String) -> Bool {
        plants.contains { $0.plantId == plantId }
    }
    
    // DEPRECATED: Use removePlant(by:) instead
    func removeOnePlant(plantId: String, siteID: UUID) {
        // Find first matching plant and remove it
        if let index = plants.firstIndex(where: {
            $0.plantId == plantId && $0.siteID == siteID
        }) {
            plants.remove(at: index)
            print("🗑️ Removed one plant of type:", plantId)
        }
    }
    
   

}
