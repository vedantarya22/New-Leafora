
import Foundation

class HomeDataStore {
    static let shared = HomeDataStore()
    
    var profileSections: [ProfileSection] = [
        ProfileSection(title: "Account", items: [
            ProfileItem(title: "Personal Info", showsChevron: true),
            ProfileItem(title: "Gardening Preferences", showsChevron: true)
        ]),
        ProfileSection(title: "Settings", items: [
            ProfileItem(title: "Notifications", showsChevron: true),
            ProfileItem(title: "Privacy", showsChevron: true)
        ]),
        ProfileSection(title: "Account Actions", items: [
            ProfileItem(title: "Sign Out", showsChevron: false)
        ])
    ]

    
    var gardeningPreferences: GardeningPreferences = GardeningPreferences(
        preferences: [
            GardeningPreferenceItem(type: .plantTypes, value: "Not Set"),
            GardeningPreferenceItem(type: .experienceLevel, value: "Not Set"),
            GardeningPreferenceItem(type: .checkRoutine, value: "Not Set"),
            GardeningPreferenceItem(type: .careSkills, value: "Not Set"),
            GardeningPreferenceItem(type: .localClimate, value: "Not Set"),
            GardeningPreferenceItem(type: .sunlightExposure, value: "Not Set")
        ]
    )

    private init() {}
    
    func arePreferencesSet() -> Bool {
        // true when at least one preference is set
        let prefs = gardeningPreferences.preferences
        let isAnySet = prefs.contains { $0.value != "Not Set" }
        return isAnySet
    }
}



struct ProfileSection {
    let title: String
    let items: [ProfileItem]
}

struct ProfileItem {
    let title: String
    let showsChevron: Bool
}

struct PersonalInfoSection {
    let title: String
    var items: [PersonalInfoItem]
}

struct PersonalInfoItem {
    let title: String
    var value: String?
    let showsChevron: Bool
}

struct GardeningPreferences: Equatable {
    var preferences: [GardeningPreferenceItem]
}

struct GardeningPreferenceItem: Equatable {
    let type: GardeningPreferenceType
    var value: String
    
    var title: String {
        return type.rawValue
    }
    
    static func == (lhs: GardeningPreferenceItem, rhs: GardeningPreferenceItem) -> Bool {
        return lhs.type == rhs.type && lhs.value == rhs.value
    }
}

enum GardeningPreferenceType: String {
    case plantTypes = "Plant Types"
    case experienceLevel = "Experience Level"
    case checkRoutine = "Plant Check Routine"
    case careSkills = "Care Skills"
    case localClimate = "Local Climate"
    case sunlightExposure = "Sunlight Exposure"
    
    var options: [String] {
        switch self {
        case .plantTypes:
            return ["Succulents", "Tropical", "Herbs", "Vegetables", "Flowers", "Ferns"]
        case .experienceLevel:
            return ["Beginner", "Intermediate", "Expert", "Master Gardener"]
        case .checkRoutine:
            return ["Daily", "Weekly", "Bi-weekly", "Monthly"]
        case .careSkills:
            return ["Basic: Watering", "Intermediate: Pruning", "Advanced: All Skills"]
        case .localClimate:
            return ["Tropical", "Dry/Arid", "Temperate", "Cold/Alpine"]
        case .sunlightExposure:
            return ["Low Light", "Partial Shade", "Full Sun", "Direct Sunlight"]
        }
    }
}
