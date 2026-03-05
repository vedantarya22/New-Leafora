//
//  Plant(dummy).swift
//  PlantApp
//
//  Created by SDC-USER on 12/12/25.
//
import Foundation
struct UserPlant: Codable, Identifiable {
    let id : UUID
    let plantId: String
    var siteName: String
    var siteID: UUID
    var imageData: Data?
    var lightRequirement: String?
    var watering: String?
    var repotting: String?
    var quantity: Int = 1 // number of plants added
    
    
    // Garden-only (mutable, user specific)
    var isAddedToGarden: Bool
//    var wateringDone: Bool
//    var pruningDone: Bool
//    var fertilizingDone: Bool
//    var repottingDone: Bool
    
    //date created at
    let createdAt: Date
    
    var lastWatered: Date?
       var lastPruned: Date?
       var lastFertilized: Date?
       var lastRepotted: Date?
}
