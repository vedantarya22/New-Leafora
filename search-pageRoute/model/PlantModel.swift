import Foundation
import UIKit

struct PlantData: Codable {
    let plants: [Plant]
}

struct Plant: Codable {
    let mongoId: String?
    let plantId: String
    let plantName: String
    let scientificName: String
    let description: String
    let category: [String]
    let tags: [String]
    let imageName: String //full cloudinary url
    let careCycle: CareCycle
    let soilType: SoilType
    let benefits: [String]
    let petFriendly: Bool
    let toxic: Bool
    let lightRequirement: LightRequirement
    let difficulty: CareDifficulty
    let commonIssues: [String]
    
    enum CodingKeys: String, CodingKey {
        case mongoId = "_id"
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
        case lightRequirement = "light_required"
        case difficulty = "care_difficulty"
        case commonIssues = "common_issues"
    }
}

// MARK: - Enums for Type Safety

enum LightRequirement: String, Codable {
    case lowLight = "low_light"
    case lowToMedium = "low_to_medium"
    case lowToBrightIndirect = "low_to_bright_indirect"
    case mediumLight = "medium_light"
    case brightIndirect = "bright_indirect"
    case partialSunlight = "partial_sunlight"
    case fullSunlight = "full_sunlight"
    
    var displayName: String {
        switch self {
        case .lowLight: return "Low light"
        case .lowToMedium: return "Low to medium"
        case .lowToBrightIndirect: return "Low to bright indirect"
        case .mediumLight: return "Medium light"
        case .brightIndirect: return "Bright indirect"
        case .partialSunlight: return "Partial sunlight"
        case .fullSunlight: return "Full sunlight"
        }
    }
}

enum CareDifficulty: String, Codable {
    case easy
    case moderate
    case advanced
    
    var displayName: String {
        return rawValue.capitalized
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
    let method: String?
    let steps: [String]? // ✅ Changed to array of strings
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
