import Foundation

enum CareTask {
    case watering, pruning, fertilizing, repotting
}

struct TaskDueEngine {

    static func isDue(_ userPlant: UserPlant, task: CareTask) -> Bool {

        // ✅ Load plants using your proven method
        let allPlants = JSONLoader.loadPlants(from: "plantData")

        guard let plant = allPlants.first(where: {
            $0.plantId == userPlant.plantId
        }) else {
            return false
        }

        let frequency: Int
        let lastDate: Date?

        switch task {

        case .watering:
            frequency = plant.careCycle.watering.days
            lastDate = userPlant.lastWatered

        case .pruning:
            frequency = plant.careCycle.pruning.days
            lastDate = userPlant.lastPruned

        case .fertilizing:
            frequency = plant.careCycle.fertilizing.days
            lastDate = userPlant.lastFertilized

        case .repotting:
            frequency = plant.careCycle.repotting.days
            lastDate = userPlant.lastRepotted
        }

        let daysPassed = daysSince(lastDate)
        return daysPassed >= frequency
    }

    private static func daysSince(_ date: Date?) -> Int {
        guard let date else { return Int.max }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? Int.max
    }
}
