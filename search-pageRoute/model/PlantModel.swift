//
//  Plant.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//



import Foundation
import UIKit

struct PlantData: Codable {
    let plants: [Plant]
}

struct Plant: Codable {
    let plantId: String
    let plantName: String
    let scientificName: String
    let description: String
    let category: [String]
    let tags: [String]
    let imageName: String
    let careCycle: CareCycle
    let soilType: SoilType
    let benefits: [String]
    let petFriendly: Bool
    let toxic:Bool
    let lightRequired: String
    let careDifficulty: String
    let commonIssues: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case plantId = "plant_id"
                case plantName = "plant_name"
                case scientificName = "scientific_name"
                case description
                case category
                case tags
                case imageName = "image_name"
                case careCycle = "care_cycle"
                case soilType = "soil_type"
                case benefits
                case petFriendly = "pet_friendly"
                case toxic
                case lightRequired = "light_required"
                case careDifficulty = "care_difficulty"
                case commonIssues = "common_issues"
    }
}

struct CareCycle: Codable {
    let watering: CareFrequency
    let repotting: CareFrequency
    let fertilizing: CareFrequency
    let pruning: CareFrequency
}

struct CareFrequency: Codable {
    let display: String
    let days: Int
}



struct SoilType: Codable {
    let characteristics: String
    let soilUsed: String
    
    enum CodingKeys: String, CodingKey {
        case characteristics
        case soilUsed = "soil_used"
    }
}

// MARK: - Category Models
struct Category: Decodable {
    let id: String
    let title: String
    let normalizedKey: String
    let assetName: String
    let gradient: Gradient
    
    enum CodingKeys: String, CodingKey {
        case id, title, gradient
        case normalizedKey = "normalizedKey"
        case assetName = "asset_name"
    }
}

struct Gradient: Decodable {
    let top: String
    let bottom: String
    
    func toUIColor() -> (top: UIColor, bottom: UIColor) {
        return (UIColor(hex: top), UIColor(hex: bottom))
    }
}

// MARK: - Extensions
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6 {
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
