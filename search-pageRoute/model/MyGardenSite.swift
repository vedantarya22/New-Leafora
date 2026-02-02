////
////  MyGardenSite.swift
////  PlantApp
////
////  Created by SDC-USER on 12/12/25.
////
//
//
////to be used later, not implemented right now,dont del rn
//
//import UIKit
//import Foundation
//
//struct MyGardenSite: Identifiable, Codable {
//    var id: UUID
//    var name: String
//    //    var cardColor: UIColorCodable
//    var icon: String
//    var plantCount : Int = 0 // default
//    
//    
//}
//
//struct UIColorCodable: Codable {
//    var color: UIColor
//    
//    init(_ color: UIColor) {
//        self.color = color
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case red, green, blue, alpha
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var a: CGFloat = 0
//        color.getRed(&r, green: &g, blue: &b, alpha: &a)
//        
//        try container.encode(Double(r), forKey: .red)
//        try container.encode(Double(g), forKey: .green)
//        try container.encode(Double(b), forKey: .blue)
//        try container.encode(Double(a), forKey: .alpha)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let r = try container.decode(Double.self, forKey: .red)
//        let g = try container.decode(Double.self, forKey: .green)
//        let b = try container.decode(Double.self, forKey: .blue)
//        let a = try container.decode(Double.self, forKey: .alpha)
//        color = UIColor(red: r, green: g, blue: b, alpha: a)
//    }
//}
//
