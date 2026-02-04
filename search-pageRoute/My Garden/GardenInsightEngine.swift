import Foundation

final class GardenInsightEngine {

    static let shared = GardenInsightEngine()
    private init() {}

    func generateInsights(from userPlants: [UserPlant]) -> [GardenInsight] {

        var insights: [GardenInsight] = []

        for userPlant in userPlants {

            guard let plant = JSONLoader.plant(by: userPlant.plantId) else { continue }

            generateTaskInsight(
                plantName: plant.plantName,
                taskName: "Watering",
                lastDate: userPlant.lastWatered,
                frequency: plant.careCycle.watering.days,
                goodIcon: "💧",
                insights: &insights
            )

            generateTaskInsight(
                plantName: plant.plantName,
                taskName: "Pruning",
                lastDate: userPlant.lastPruned,
                frequency: plant.careCycle.pruning.days,
                goodIcon: "✂️",
                insights: &insights
            )

            generateTaskInsight(
                plantName: plant.plantName,
                taskName: "Fertilizing",
                lastDate: userPlant.lastFertilized,
                frequency: plant.careCycle.fertilizing.days,
                goodIcon: "🌱",
                insights: &insights
            )

            generateTaskInsight(
                plantName: plant.plantName,
                taskName: "Repotting",
                lastDate: userPlant.lastRepotted,
                frequency: plant.careCycle.repotting.days,
                goodIcon: "🪴",
                insights: &insights
            )
        }

        generateLocationInsights(plants: userPlants, insights: &insights)

        return insights.sorted { $0.level.priority > $1.level.priority }
    }

    // MARK: - Core logic

    private func generateTaskInsight(
        plantName: String,
        taskName: String,
        lastDate: Date?,
        frequency: Int,
        goodIcon: String,
        insights: inout [GardenInsight]
    ) {

        let daysPassed = daysSince(lastDate)
        let remaining = frequency - daysPassed

        if remaining <= 0 {
            insights.append(
                GardenInsight(
                    icon: "⚠️",
                    message: "\(taskName) overdue for \(plantName) by \(abs(remaining)) days",
                    level: remaining < -3 ? .critical : .warning
                )
            )
        } else {
            insights.append(
                GardenInsight(
                    icon: goodIcon,
                    message: "\(plantName): next \(taskName.lowercased()) in \(remaining) days",
                    level: .good
                )
            )
        }
    }

    // MARK: - Location insight

    private func generateLocationInsights(
        plants: [UserPlant],
        insights: inout [GardenInsight]
    ) {

        let grouped = Dictionary(grouping: plants, by: { $0.siteID })

        for (_, sitePlants) in grouped {

            let overdueWaterings = sitePlants.filter {
                daysSince($0.lastWatered) > 7
            }.count

            if overdueWaterings >= 3 {
                insights.append(
                    GardenInsight(
                        icon: "🌞",
                        message: "Plants in this area may need more sunlight or closer care",
                        level: .critical
                    )
                )
            }
        }
    }

    // MARK: - Date helper

    private func daysSince(_ date: Date?) -> Int {
        guard let date else { return Int.max }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? Int.max
    }
}
