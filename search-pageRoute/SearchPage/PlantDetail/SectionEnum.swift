//
//  SectionEnum.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

enum PlantDetailSection: Int, CaseIterable {
    case heroImage
//    case titleInfo
    case about
    case feature
    case care
    case soil
    case issues
    case buttons

    var hasHeader: Bool {
        return  self == .about || self == .care || self == .soil || self == .issues
    }

    var headerTitle: String {
        switch self {
        case .about: return "About the Plant"
        case .care: return "Care Cycle"
        case .soil: return "Soil Requirement"
        case .issues: return "Common Issues"
        default: return ""
        }
    }
}


enum FeatureType {
    case light
    case petFriendly
    case toxic
}
