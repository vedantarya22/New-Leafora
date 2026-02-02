////
////  PlantStore.swift
////  PlantApp
////
////  Created by SDC-USER on 12/12/25.
////
//
//import Foundation
//internal import Combine
//import UIKit
//
//class PlantStore: ObservableObject {
//    
//    static let shared = PlantStore()
//    
//    
//
//
//    @Published private(set) var plants: [UserPlant] = [] {
//        didSet { savePlants() }
//    }
//
//
//    private let key = "savedPlants"
//
//    private init() {
//        loadPlants()
//    }
//
//    // MARK: Add a new plant
//    func addPlant(_ plant: UserPlant) {
//        
//        print("➡️ ADD REQUEST: plantId=\(plant.plantId), siteID=\(plant.siteID)")
//
//        if let index = plants.firstIndex(where: { $0.plantId == plant.plantId && $0.siteID == plant.siteID }) {
//            
//            let oldQty = plants[index].quantity
//              // Increase quantity instead of adding duplicate cell
//            plants[index].quantity += plant.quantity
//            print("✅ UPDATED: qty \(oldQty) -> \(plants[index].quantity)")
//
//
//              // Optional: update image if new one is provided
//              if plant.imageData != nil {
//                  plants[index].imageData = plant.imageData
//              }
//
//          } else {
//              // First time plant added in this site
//              plants.append(plant)
//              print("🆕 NEW ENTRY CREATED: qty=\(plant.quantity)")
//          }
//        
//    }
//    var totalPlants: Int {
//            plants.count
//        }
//    var totalSpaces: Int {
//        Set(plants.map { $0.siteID }).count
//    }
//
//
//    // MARK: Get plants for a specific site
//    func plants(for siteID: UUID) -> [UserPlant] {
//        return plants.filter { $0.siteID == siteID }
//    }
//
//    // MARK: Save
//    private func savePlants() {
//        if let encoded = try? JSONEncoder().encode(plants) {
//            UserDefaults.standard.set(encoded, forKey: key)
//        }
//    }
//
//        // MARK: Load
//        private func loadPlants() {
//            if let data = UserDefaults.standard.data(forKey: key),
//               let decoded = try? JSONDecoder().decode([UserPlant].self, from: data) {
//                plants = decoded
//            }
//        }
//    
//    
//    func markTaskDone(userPlantID: UUID, careType: CareType) {
//           guard let index = plants.firstIndex(where: { $0.id == userPlantID }) else { return }
//
//           switch careType {
//           case .watering:
//               plants[index].wateringDone = true
//           case .trimming:
//               plants[index].pruningDone = true
//           case .fertilizing:
//               plants[index].fertilizingDone = true
//           case .repotting:
//               plants[index].repottingDone = true
//           }
//       }
//    
//    
//    }
//
//extension JSONLoader {
//
//    static func plant(by id: String) -> Plant? {
//        return loadPlants().first { $0.plantId == id }
//    }
//}
//
//
//extension PlantStore {
//
//    func hasUserAddedPlant(plantId: String) -> Bool {
//        return plants.contains { $0.plantId == plantId }
//    }
//    
//    func removeOnePlant(plantId: String, siteID: UUID) {
//           if let index = plants.firstIndex(where: { $0.plantId == plantId && $0.siteID == siteID }) {
//
//               if plants[index].quantity > 1 {
//                   plants[index].quantity -= 1
//               } else {
//                   plants.remove(at: index)
//               }
//           }
//       }
//    
//    func removeAllPlants(plantId: String, siteID: UUID) {
//          plants.removeAll { $0.plantId == plantId && $0.siteID == siteID }
//      }
//}
//
