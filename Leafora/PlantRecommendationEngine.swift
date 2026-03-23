//
//  PlantRecommendationEngine.swift
//  search-pageRoute
//
//  Created by SDC-USER on 17/02/26.
//

import Foundation

// MARK: - Recommendation Engine

final class PlantRecommendationEngine {

    static let shared = PlantRecommendationEngine()
    private init() {}

    // MARK: - Public API

//    - run after onboarding
//    - run when preferences change
//    - run when plant data updates
    func generateRecommendedPlantIDs(
        plants: [Plant],
        preferences: GardeningPreferences,
        hasPets: Bool = false, // pass real value when available
        limit: Int = 20
    ) -> [String] {

        let userProfile = normalizeUserPreferences(preferences, hasPets: hasPets)

        let scoredPlants = plants.map { plant in
            (plant.plantId, scorePlant(plant: plant, user: userProfile))
        }

        // keep positive scores and sort high to low
        let recommended = scoredPlants
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
        
        // cache results
        RecommendedPlantsCache.shared.save(plantIDs: Array(recommended))
        
        return Array(recommended)
    }

    // MARK: - User Normalization

    private func normalizeUserPreferences(
        _ preferences: GardeningPreferences,
        hasPets: Bool
    ) -> NormalizedUserProfile {

        func value(for type: GardeningPreferenceType) -> String? {
            preferences.preferences.first { $0.type == type }?.value
        }
        
        // normalize selected values for scoring
        return NormalizedUserProfile(
            plantType: value(for: .plantTypes)?.lowercased(),
            experienceLevel: value(for: .experienceLevel)?.lowercased(),
            checkRoutineDays: routineDays(from: value(for: .checkRoutine)),
            careSkillLevel: value(for: .careSkills)?.lowercased(),
            climate: value(for: .localClimate)?.lowercased(),
            sunlight: normalizeSunlight(value(for: .sunlightExposure)),
            hasPets: hasPets
        )
    }

    private func routineDays(from value: String?) -> Int? {
        guard let value = value?.lowercased() else { return nil }
        if value.contains("daily") { return 1 }
        if value.contains("weekly") { return 7 }
        if value.contains("bi-weekly") { return 14 }
        if value.contains("monthly") { return 30 }
        return nil
    }

    private func normalizeSunlight(_ value: String?) -> String? {
        // map UI sunlight labels to normalized keys
        
        switch value?.lowercased() {
            case "low light": return "low_light"
            case "partial shade": return "partial_sunlight" // fallback mapping
            case "full sun", "direct sunlight": return "full_sunlight"
            default: return nil
        }
    }

    // MARK: - Scoring

    private func scorePlant(
        plant: Plant,
        user: NormalizedUserProfile
    ) -> Double {

        // hard constraint: pet safety
        if user.hasPets && !plant.petFriendly {
            return -1000
        }
        
        // hard constraint: toxicity
        if user.hasPets && plant.toxic {
             return -1000
        }

        var score: Double = 0

        score += sunlightScore(plant, user) * 3.0
        score += experienceScore(plant, user) * 3.0
        score += careSkillScore(plant, user) * 2.5
        score += routineScore(plant, user) * 2.0
        score += plantTypeScore(plant, user) * 2.0
        score += climateScore(plant, user) * 1.5
        score += tagScore(plant) * 0.5

        return score
    }

    // MARK: - Matching Rules

    private func sunlightScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let pref = user.sunlight else { return 0 }
        
        // plant light enum raw value
        let plantLight = plant.lightRequirement.rawValue

        // exact match
        if pref == plantLight { return 3 }
        
        // partial matches
        if pref == "partial_sunlight" && (plantLight == "low_to_medium" || plantLight == "medium_light") { return 1 }
        if pref == "full_sunlight" && plantLight == "bright_indirect" { return -1 } // direct sun can burn bright-indirect plants
        
        return 0
    }

    private func experienceScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let level = user.experienceLevel else { return 0 }

        // difficulty enum: easy/moderate/advanced
        let difficulty = plant.difficulty

        switch (level, difficulty) {
        case ("beginner", .easy): return 3
        case ("beginner", .moderate): return 1
        case ("beginner", .advanced): return -5 
        case ("intermediate", .moderate): return 3
        case ("intermediate", .easy): return 2
        case ("expert", .advanced): return 3
        case ("expert", .moderate): return 2
        case ("master gardener", .advanced): return 3
        default: return 0
        }
    }

    private func careSkillScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let skill = user.careSkillLevel else { return 0 }

        // examples: basic/intermediate/advanced
        
        if skill.contains("basic") && plant.difficulty == .easy { return 3 }
        if skill.contains("advanced") && plant.difficulty == .advanced { return 3 }
        return 0
    }

    private func routineScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let routine = user.checkRoutineDays else { return 0 }

        let diff = abs(routine - plant.careCycle.watering.days)

        if diff <= 2 { return 3 }
        if diff <= 5 { return 1 }
        return -1
    }

    private func plantTypeScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let type = user.plantType else { return 0 }

        // try category first, then tags
        if plant.category.contains(where: { $0.lowercased().contains(type) }) { return 3 }
        if plant.tags.contains(where: { $0.lowercased().contains(type) }) { return 1 }
        
        return 0
    }

    private func climateScore(_ plant: Plant, _ user: NormalizedUserProfile) -> Double {
        guard let climate = user.climate else { return 0 }

        // climate match via tags
        if plant.tags.contains(where: { $0.lowercased().contains(climate) }) {
            return 2
        }
        return 0
    }

    private func tagScore(_ plant: Plant) -> Double {
        var boost = 0.0

        if plant.tags.contains(where: { $0.lowercased().contains("best seller") }) {
            boost += 0.5
        }
        
        if plant.tags.contains(where: { $0.lowercased().contains("low maintenance") }) {
            boost += 0.5
        }

        return min(boost, 2)
    }
}

// MARK: - Internal User Profile

private struct NormalizedUserProfile {
    let plantType: String?
    let experienceLevel: String?
    let checkRoutineDays: Int?
    let careSkillLevel: String?
    let climate: String?
    let sunlight: String?
    let hasPets: Bool
}
