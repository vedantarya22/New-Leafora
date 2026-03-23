////
////  Plant.swift
////  PlantApp
////
////  Created by SDC-USER on 24/11/25.
////
//
//import Foundation
//import UIKit
//
//enum CareType:   String , Codable {
//    case watering
//    case trimming
//    case repotting
//    case fertilizing 
//}
//
////struct Plant {
////    let id: String = UUID().uuidString
////    let name: String
////    let subtitle: String
////    let imageName: String
////    let careType: CareType
////    var wateringDone: Bool = false
////    var sunlightDone: Bool = false
////    var fertilizingDone: Bool = false
//////    let space: String
////}
//extension CareType {
//
//    var displayName: String {
//        switch self {
//        case .watering:
//            return "Watering"
//        case .trimming:
//            return "Pruning"
//        case .repotting:
//            return "Repotting"
//        case .fertilizing:
//            return "Fertilizing"
//        }
//    }
//
//    var icon: UIImage? {
//        switch self {
//        case .watering:
//            return UIImage(systemName: "drop.fill")
//        case .trimming:
//            return UIImage(systemName: "scissors")
//        case .repotting:
//            return UIImage(systemName: "arrow.up.bin.fill")
//        case .fertilizing:
//            return UIImage(systemName: "leaf.fill")
//        }
//    }
//}
