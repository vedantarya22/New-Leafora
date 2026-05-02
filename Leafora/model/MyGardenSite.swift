////
////  MyGardenSite.swift
////  PlantApp
////
////  Created by SDC-USER on 12/12/25.
////
//
//
////to be used later, not implemented right now,dont del rn

import UIKit
import Foundation

struct MyGardenSite: Identifiable, Codable {
    var id: UUID = UUID()       // local SwiftUI only
    var mongoId: String?        // MongoDB's _id
    var name: String
    var icon: String
    var plantCount: Int = 0

    enum CodingKeys: String, CodingKey {
        case mongoId    = "_id"
        case name
        case icon
        // id and plantCount NOT included — not in MongoDB response
    }
}
