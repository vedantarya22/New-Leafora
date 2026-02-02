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
    var id: UUID
    var name: String
    //    var cardColor: UIColorCodable
    var icon: String
    var plantCount : Int = 0 // default
    
    
}
