import Foundation

final class GardenInsightEngine {

    static let shared = GardenInsightEngine()
    private init() {}
    
    private let urgentThresholdDays = 3
    
    // MARK: - Task Overview (for Home Screen)
      
      func generateTaskOverview(from userPlants: [UserPlant]) -> [TaskOverviewInsight] {
          var insights: [TaskOverviewInsight] = []
          
          // 1. Urgent Tasks (overdue by 3+ days then only it appears)
          generateUrgentTaskInsight(userPlants: userPlants, insights: &insights)
          
          // 2. Missed Tasks (overdue by 1-2 days same as urgent)
          generateMissedTaskInsight(userPlants: userPlants, insights: &insights)
          
          return insights
      }
      
    
    // MARK: - 1. Urgent Tasks (3+ days overdue)
      
      private func generateUrgentTaskInsight(userPlants: [UserPlant], insights: inout [TaskOverviewInsight]) {
          var urgentCount = 0
          let catalogue = PlantCatalogueCache.shared.plants
          
          for plant in userPlants {
              // Try to find plant in cache first, then fallback to JSONLoader
              let plantData = catalogue.first { $0.mongoId == plant.plantId || $0.plantId == plant.plantId }
                            ?? JSONLoader.plant(by: plant.plantId)
              
              guard let data = plantData else {
                  print("DEBUG: GardenInsightEngine - Skip plant \(plant.plantId): No plant data found in cache or JSON")
                  continue
              }
              
              var isUrgent = false
              let tasks: [(Date?, Int)] = [
                  (plant.lastWatered, data.careCycle.watering.days),
                  (plant.lastFertilized, data.careCycle.fertilizing.days),
                  (plant.lastPruned, data.careCycle.pruning.days),
                  (plant.lastRepotted, data.careCycle.repotting.days)
              ]
              
              for (lastDate, cycleDays) in tasks {
                  let effectiveDate = lastDate ?? plant.createdAt
                  let daysOverdue = daysSince(effectiveDate) - cycleDays
                  if daysOverdue >= urgentThresholdDays {
                      isUrgent = true
                      break
                  }
              }
              
              if isUrgent {
                  urgentCount += plant.quantity
              }
          }
          
          if urgentCount > 0 {
              insights.append(TaskOverviewInsight(
                  icon: "exclamationmark.triangle.fill",
                  title: "Urgent Care Needed",
                  message: "\(urgentCount) \(urgentCount == 1 ? "plant is" : "plants are") significantly past schedule",
                  level: .critical,
                  route: "Urgent"
              ))
          }
      }
      
    
    // MARK: - 2. Missed Tasks (1-2 days overdue)
        
        private func generateMissedTaskInsight(userPlants: [UserPlant], insights: inout [TaskOverviewInsight]) {
            var missedCount = 0
            let catalogue = PlantCatalogueCache.shared.plants
            
            for plant in userPlants {
                let plantData = catalogue.first { $0.mongoId == plant.plantId || $0.plantId == plant.plantId }
                              ?? JSONLoader.plant(by: plant.plantId)
                
                guard let data = plantData else { continue }
                
                var isMissed = false
                var isAlreadyUrgent = false
                
                let tasks: [(Date?, Int)] = [
                    (plant.lastWatered, data.careCycle.watering.days),
                    (plant.lastFertilized, data.careCycle.fertilizing.days),
                    (plant.lastPruned, data.careCycle.pruning.days),
                    (plant.lastRepotted, data.careCycle.repotting.days)
                ]
                
                for (lastDate, cycleDays) in tasks {
                    let effectiveDate = lastDate ?? plant.createdAt
                    let daysOverdue = daysSince(effectiveDate) - cycleDays
                    
                    if daysOverdue >= urgentThresholdDays {
                        isAlreadyUrgent = true
                        break
                    } else if daysOverdue > 0 {
                        isMissed = true
                    }
                }
                
                if isMissed && !isAlreadyUrgent {
                    missedCount += plant.quantity
                }
            }
            
            if missedCount > 0 {
                insights.append(TaskOverviewInsight(
                    icon: "clock.badge.exclamationmark.fill",
                    title: "Missed Tasks",
                    message: "\(missedCount) \(missedCount == 1 ? "plant needs" : "plants need") attention soon",
                    level: .warning,
                    route: "Missed"
                ))
            }
        }
    
    

    // MARK: - Core logic
    //for task comming in plant list view controller

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
                    icon: "",
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
                        icon: "",
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
