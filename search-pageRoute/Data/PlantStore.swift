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

        print("➡️ ADD REQUEST: plantId=\(plant.plantId), siteID=\(plant.siteID)")

        if let index = plants.firstIndex(where: {
            $0.plantId == plant.plantId && $0.siteID == plant.siteID
        }) {

            let oldQty = plants[index].quantity
            plants[index].quantity += plant.quantity
            print("✅ UPDATED: qty \(oldQty) → \(plants[index].quantity)")

            if plant.imageData != nil {
                plants[index].imageData = plant.imageData
            }

        } else {
            plants.append(plant)
            print("🆕 NEW ENTRY CREATED: qty=\(plant.quantity)")
        }
    }

    // MARK: - Stats

    var totalPlants: Int {
        plants.count
    }

    var totalSpaces: Int {
        Set(plants.map { $0.siteID }).count
    }

    // MARK: - Fetch

    func plants(for siteID: UUID) -> [UserPlant] {
        plants.filter { $0.siteID == siteID }
    }

    // MARK: - Persistence (Disk)

    private func savePlants() {
        do {
            let data = try JSONEncoder().encode(plants)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("❌ Failed to save plants:", error)
        }
    }

    private func loadPlants() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            plants = try JSONDecoder().decode([UserPlant].self, from: data)
        } catch {
            print("❌ Failed to load plants:", error)
        }
    }

    // MARK: - Task Completion

    func markTaskDone(userPlantID: UUID, taskType: String) {

        guard let index = plants.firstIndex(where: { $0.id == userPlantID }) else { return }

        switch taskType.lowercased() {
        case "watering":
            plants[index].wateringDone = true
        case "pruning":
            plants[index].pruningDone = true
        case "fertilizing":
            plants[index].fertilizingDone = true
        case "repotting":
            plants[index].repottingDone = true
        default:
            break
        }

        print("✅ Task marked done in PlantStore")
    }
}

//
// MARK: - Helpers
//

extension JSONLoader {

    static func plant(by id: String) -> Plant? {
        loadPlants().first { $0.plantId == id }
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
            if plants[index].quantity > 1 {
                plants[index].quantity -= 1
            } else {
                plants.remove(at: index)
            }
        }
    }

    func removeAllPlants(plantId: String, siteID: UUID) {
        plants.removeAll {
            $0.plantId == plantId && $0.siteID == siteID
        }
    }
}
