// PlantCatalogueCache.swift
import Foundation

class PlantCatalogueCache {
    static let shared = PlantCatalogueCache()
    
    private(set) var plants: [Plant] = []
    private var isFetched = false       // prevents repeated API calls
    
    private init() {}
    
    func setPlants(_ plants: [Plant]) {
           self.plants = plants
           self.isFetched = true
       }
    // ✅ Fetches once, returns cached after that
    func getPlants(completion: @escaping ([Plant]) -> Void) {
        if isFetched && !plants.isEmpty {
            print("📦 Returning \(plants.count) plants from cache")
            completion(plants)
            return
        }
        
        NetworkManager.shared.fetchAllPlants { [weak self] fetchedPlants in
            guard let self = self, let fetchedPlants = fetchedPlants else {
                print("❌ Failed to fetch plants from backend")
                completion([])
                return
            }
            self.plants = fetchedPlants
            self.isFetched = true
            print("✅ Fetched \(fetchedPlants.count) plants from MongoDB, cached")
            completion(fetchedPlants)
        }
    }
    
    // ✅ Same as JSONLoader.plant(by:) — used by TaskDueEngine etc
    func getPlant(by id: String) -> Plant? {
        return plants.first { $0.plantId == id }
    }
    
    // ✅ Call this to force refresh if needed
    func invalidate() {
        isFetched = false
        plants = []
    }
}


//timer of cache
