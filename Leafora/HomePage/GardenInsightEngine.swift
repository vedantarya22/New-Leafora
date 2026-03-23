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
          var maxOverdue = 0
          
          for plant in userPlants {
              guard let plantData = JSONLoader.plant(by: plant.plantId) else { continue }
              
              // Check watering
              if let lastWatered = plant.lastWatered {
                  let daysOverdue = daysSince(lastWatered) - plantData.careCycle.watering.days
                  if daysOverdue >= urgentThresholdDays {
                      urgentCount += plant.quantity
                      maxOverdue = max(maxOverdue, daysOverdue)
                  }
              }
              
              // Check fertilizing
              if let lastFertilized = plant.lastFertilized {
                  let daysOverdue = daysSince(lastFertilized) - plantData.careCycle.fertilizing.days
                  if daysOverdue >= urgentThresholdDays {
                      urgentCount += plant.quantity
                      maxOverdue = max(maxOverdue, daysOverdue)
                  }
              }
              
              // Check pruning
              if let lastPruned = plant.lastPruned {
                  let daysOverdue = daysSince(lastPruned) - plantData.careCycle.pruning.days
                  if daysOverdue >= urgentThresholdDays {
                      urgentCount += plant.quantity
                      maxOverdue = max(maxOverdue, daysOverdue)
                  }
              }
              
              // Check repotting
              if let lastRepotted = plant.lastRepotted {
                  let daysOverdue = daysSince(lastRepotted) - plantData.careCycle.repotting.days
                  if daysOverdue >= urgentThresholdDays {
                      urgentCount += plant.quantity
                      maxOverdue = max(maxOverdue, daysOverdue)
                  }
              }
          }
          
          if urgentCount > 0 {
              insights.append(TaskOverviewInsight(
                  icon: "exclamationmark.triangle.fill",
                  title: "Urgent Care Needed",
                  message: "\(urgentCount) plant\(urgentCount == 1 ? "" : "s") are past their schedule",
                  level: .critical,
                  route: "Urgent"
              ))// plant or plants
          }
      }
      
    
    // MARK: - 2. Missed Tasks (1-2 days overdue)
        
        private func generateMissedTaskInsight(userPlants: [UserPlant], insights: inout [TaskOverviewInsight]) {
            var missedCount = 0
            
            for plant in userPlants {
                guard let plantData = JSONLoader.plant(by: plant.plantId) else { continue }
                
                var hasMissedTask = false
                
                // Check watering
                if let lastWatered = plant.lastWatered {
                    let daysOverdue = daysSince(lastWatered) - plantData.careCycle.watering.days
                    if daysOverdue > 0 && daysOverdue < urgentThresholdDays {
                        hasMissedTask = true
                    }
                }
                
                // Check fertilizing
                if !hasMissedTask, let lastFertilized = plant.lastFertilized {
                    let daysOverdue = daysSince(lastFertilized) - plantData.careCycle.fertilizing.days
                    if daysOverdue > 0 && daysOverdue < urgentThresholdDays {
                        hasMissedTask = true
                    }
                }
                
                // Check pruning
                if !hasMissedTask, let lastPruned = plant.lastPruned {
                    let daysOverdue = daysSince(lastPruned) - plantData.careCycle.pruning.days
                    if daysOverdue > 0 && daysOverdue < urgentThresholdDays {
                        hasMissedTask = true
                    }
                }
                
                // Check repotting
                if !hasMissedTask, let lastRepotted = plant.lastRepotted {
                    let daysOverdue = daysSince(lastRepotted) - plantData.careCycle.repotting.days
                    if daysOverdue > 0 && daysOverdue < urgentThresholdDays {
                        hasMissedTask = true
                    }
                }
                
                if hasMissedTask {
                    missedCount += plant.quantity
                }
            }
            
            if missedCount > 0 {
                insights.append(TaskOverviewInsight(
                    icon: "clock.badge.exclamationmark.fill",
                    title: "Missed Tasks",
                    message: "\(missedCount) plant\(missedCount == 1 ? "" : "s") need attention soon",
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
