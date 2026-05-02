//
//  RecommendedPlantsCache.swift
//  search-pageRoute
//
//  Created by SDC-USER on 18/02/26.
//

import Foundation

final class RecommendedPlantsCache {
    
    static let shared = RecommendedPlantsCache()
    
    private let key = "recommended_plant_ids_cache"
    
    private init() {}
    
    // Savess a list of plant IDs to UserDefaults
    func save(plantIDs: [String]) {
        UserDefaults.standard.set(plantIDs, forKey: key)
        print(" RecommendedPlantsCache: Saved \(plantIDs.count) plant IDs.")
    }
    
    // Retrieves the cached list of plant IDs
    func get() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key)
    }

    // Clears the cache
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
        print(" RecommendedPlantsCache: Cache cleared.")
    }
    
    // Checks if cache exists
    var hasCache: Bool {
        return UserDefaults.standard.stringArray(forKey: key) != nil
    }
}
