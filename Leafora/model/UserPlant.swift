//
//  PlantApp
//
//  Created by SDC-USER on 12/12/25.
//
import Foundation
struct UserPlant: Codable, Identifiable {
    var id: UUID = UUID()           // local SwiftUI only
    var mongoId: String?            // MongoDB _id
    var mongoSiteId: String?        // MongoDB siteId
    var plantName: String?
    var plantId: String = ""
    var siteName: String = ""
    var siteID: UUID = UUID()       // local only

    var imageData: Data?            // local only
    var imageUrl: String?           //  Cloudinary URL from MongoDB

    var lightRequirement: String?
    var watering: String?
    var repotting: String?
    var quantity: Int = 1
    var isAddedToGarden: Bool = true
    var createdAt: Date = Date()

    var lastWatered: Date?
    var lastPruned: Date?
    var lastFertilized: Date?
    var lastRepotted: Date?

    enum CodingKeys: String, CodingKey {
        case mongoId        = "_id"
        case plantId        = "plantId"       //  matches JSON
        case plantName      = "plantName"  
        case mongoSiteId    = "siteId"        //  matches JSON
        case siteName       = "siteName"      //  matches JSON
        case imageUrl       = "imageData"     //  Cloudinary URL stored as imageData in MongoDB
        case lightRequirement
        case watering
        case repotting
        case quantity
        case isAddedToGarden
        case createdAt
        case lastWatered
        case lastPruned
        case lastFertilized
        case lastRepotted
        //  id, siteID, imageData (Data) excluded — local only
    }
}
