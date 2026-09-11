//
//  UrgentMissedViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 09/02/26.
//

import UIKit

class UrgentMissedViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private let DEBUG_FORCE_OVERDUE = false

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var urgencyLevel: String = "" // "Urgent" or "Missed"
    private var filteredPlants: [UserPlant] = []
    private var allPlantData: [Plant] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        loadPlantData()
     
        registerCell()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterPlants()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show swipe hint animation
        if !filteredPlants.isEmpty {
            showSwipeHint()
        }
    }
    
    private func setupUI() {
        self.title = urgencyLevel
        let botanicalGreen = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0)
        view.backgroundColor = botanicalGreen
        collectionView.backgroundColor = botanicalGreen
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func loadPlantData() {
        // Load all plant data from JSON or cache
        self.allPlantData = PlantCatalogueCache.shared.plants
        
        if allPlantData.isEmpty {
            print("⚠️ [UrgentMissedVC] No plant data loaded from Cache/JSON!")
            showAlert(title: "Error", message: "Could not load plant data. Please wait for the catalog to load.")
        } else {
            print(" [UrgentMissedVC] Loaded \(allPlantData.count) plant types")
        }
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")
    }
    
    private func filterPlants() {
        let allUserPlants = PlantStore.shared.allPlants()
        
        switch urgencyLevel.lowercased() {
        case "urgent":
            filteredPlants = getUrgentPlants(from: allUserPlants)
            
        case "missed":
            filteredPlants = getMissedPlants(from: allUserPlants)
            
        default:
            filteredPlants = []
            print(" Unknown urgency level: \(urgencyLevel)")
        }
        
        print(" [UrgentMissedVC] Filtered \(filteredPlants.count) \(urgencyLevel) plants")
        collectionView.reloadData()
    }
    
    /// Get plants that are 3+ days overdue on ANY task
    private func getUrgentPlants(from plants: [UserPlant]) -> [UserPlant] {
        return plants.filter { plant in
            guard let plantData = getPlantData(for: plant) else { return false }
            
            // Check all tasks for 3+ days overdue
            let w = isTaskUrgent(lastDate: plant.lastWatered, cycleDays: plantData.careCycle.watering.days, createdAt: plant.createdAt)
            let p = isTaskUrgent(lastDate: plant.lastPruned, cycleDays: plantData.careCycle.pruning.days, createdAt: plant.createdAt)
            let f = isTaskUrgent(lastDate: plant.lastFertilized, cycleDays: plantData.careCycle.fertilizing.days, createdAt: plant.createdAt)
            let r = isTaskUrgent(lastDate: plant.lastRepotted, cycleDays: plantData.careCycle.repotting.days, createdAt: plant.createdAt)
            
            return w || p || f || r
        }
    }
    
    
    /// Get plants that are 1-2 days overdue on ANY task
    private func getMissedPlants(from plants: [UserPlant]) -> [UserPlant] {
        return plants.filter { plant in
            guard let plantData = getPlantData(for: plant) else { return false }
            
            // Check all tasks for 1-2 days overdue
            let w = isTaskMissed(lastDate: plant.lastWatered, cycleDays: plantData.careCycle.watering.days, createdAt: plant.createdAt)
            let p = isTaskMissed(lastDate: plant.lastPruned, cycleDays: plantData.careCycle.pruning.days, createdAt: plant.createdAt)
            let f = isTaskMissed(lastDate: plant.lastFertilized, cycleDays: plantData.careCycle.fertilizing.days, createdAt: plant.createdAt)
            let r = isTaskMissed(lastDate: plant.lastRepotted, cycleDays: plantData.careCycle.repotting.days, createdAt: plant.createdAt)
            
            return w || p || f || r
        }
    }
    
    private func getPlantData(for userPlant: UserPlant) -> Plant? {
        return allPlantData.first { $0.mongoId == userPlant.plantId || $0.plantId == userPlant.plantId }
    }
    
    /// Check if a single task is 3+ days overdue
    private func isTaskUrgent(lastDate: Date?, cycleDays: Int, createdAt: Date) -> Bool {
        let effectiveDate = lastDate ?? createdAt
        let daysSince = daysBetween(from: effectiveDate, to: Date())
        let daysOverdue = daysSince - cycleDays
        
        return daysOverdue >= 3
    }
    
    
    /// Check if a single task is 1-2 days overdue
    private func isTaskMissed(lastDate: Date?, cycleDays: Int, createdAt: Date) -> Bool {
        let effectiveDate = lastDate ?? createdAt
        let daysSince = daysBetween(from: effectiveDate, to: Date())
        let daysOverdue = daysSince - cycleDays
        
        return daysOverdue >= 1 && daysOverdue < 3
    }
    
    /// Calculate days between two dates
    private func daysBetween(from startDate: Date, to endDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
    private func getMostOverdueTask(for userPlant: UserPlant) -> String {
        guard let plantData = getPlantData(for: userPlant) else { return "Watering" }
        
        var mostOverdueTask = "Watering"
        var maxOverdue = 0
        
        // Check watering
        let lastWateredDate = userPlant.lastWatered ?? userPlant.createdAt
        let waterOverdue = daysBetween(from: lastWateredDate, to: Date()) - plantData.careCycle.watering.days
        if waterOverdue > maxOverdue {
            maxOverdue = waterOverdue
            mostOverdueTask = "Watering"
        }
        
        // Check fertilizing
        let lastFertilizedDate = userPlant.lastFertilized ?? userPlant.createdAt
        let fertOverdue = daysBetween(from: lastFertilizedDate, to: Date()) - plantData.careCycle.fertilizing.days
        if fertOverdue > maxOverdue {
            maxOverdue = fertOverdue
            mostOverdueTask = "Fertilizing"
        }
        
        // Check pruning
        let lastPrunedDate = userPlant.lastPruned ?? userPlant.createdAt
        let pruneOverdue = daysBetween(from: lastPrunedDate, to: Date()) - plantData.careCycle.pruning.days
        if pruneOverdue > maxOverdue {
            maxOverdue = pruneOverdue
            mostOverdueTask = "Pruning"
        }
        
        // Check repotting
        let lastRepottedDate = userPlant.lastRepotted ?? userPlant.createdAt
        let repotOverdue = daysBetween(from: lastRepottedDate, to: Date()) - plantData.careCycle.repotting.days
        if repotOverdue > maxOverdue {
            maxOverdue = repotOverdue
            mostOverdueTask = "Repotting"
        }
        
        return mostOverdueTask
    }
    
    
    private func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        collectionView.collectionViewLayout = layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return filteredPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PlantRowCell",
            for: indexPath
        ) as! PlantRowCell
        
        let userPlant = filteredPlants[indexPath.row]
        let mostOverdueTask = getMostOverdueTask(for: userPlant)
        
        // Configure cell with plant data
        cell.configure(
            with: userPlant,
            task: mostOverdueTask,
            allPlants: allPlantData
        )
        
        // Setup swipe-to-complete
        cell.onDone = { [weak self, weak cell] in
            guard let self = self,
                  let currentCell = cell,
                  let currentIndexPath = self.collectionView.indexPath(for: currentCell)
            else { return }
            
            let completedPlant = self.filteredPlants[currentIndexPath.row]
            
            //  Mark task completed in PlantStore
            self.markTaskDone(for: completedPlant)
            
            //  Remove from list instantly
            self.filteredPlants.remove(at: currentIndexPath.row)
            
            //  Animate deletion
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [currentIndexPath])
            })
        }
        return cell
    }
    
    
    
    //    private func handleTaskCompletion(at indexPath: IndexPath) {
    //          guard indexPath.row < filteredPlants.count else { return }
    //
    //           let completedPlant = filteredPlants[indexPath.row]
    //           let taskToComplete = getMostOverdueTask(for: completedPlant)
    //
    //           // Mark task as done in PlantStore
    //           PlantStore.shared.markTaskDone(
    //               userPlantID: completedPlant.id,
    //              taskType: taskToComplete
    //          )
    //
    //          // Remove from filtered list
    //          filteredPlants.remove(at: indexPath.row)
    //
    //          // Animate deletion
    //          collectionView.performBatchUpdates({
    //              collectionView.deleteItems(at: [indexPath])
    //          }, completion: { _ in
    //              // Optional: Show message if list is now empty
    //             if self.filteredPlants.isEmpty {
    //                  self.showEmptyState()
    //             }
    //         })
    //
    //          print("Completed \(taskToComplete) for \(completedPlant.plantId)")
    //      }
    //
    private func showSwipeHint() {
        
        guard let firstCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
        ) as? PlantRowCell else { return }
        
        UIView.animate(
            withDuration: 0.7,
            delay: 0.5,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: {
                
                firstCell.mainContainerView.transform =
                CGAffineTransform(translationX: -60, y: 0)
                
                firstCell.doneBackgroundView.alpha = 1.0
                
            }) { _ in
                
                UIView.animate(withDuration: 0.5,
                               delay: 0.2,
                               options: [.curveEaseIn],
                               animations: {
                    
                    firstCell.mainContainerView.transform = .identity
                    firstCell.doneBackgroundView.alpha = 0
                    
                })
            }
    }
    // MARK: - Task Completion
    
    func markTaskDone(for userPlant: UserPlant) {
        PlantStore.shared.markTaskDone(
            userPlantID: userPlant.id,
            taskType: getMostOverdueTask(for: userPlant)
        )
        
        NotificationCenter.default.post(
              name: .plantTaskDidUpdate,
              object: nil
          )
    }
    
    private func showEmptyState() {
        let message = urgencyLevel == "Urgent"
        ? " No urgent tasks! Your plants are happy!"
        : " All caught up on missed tasks!"
        
        let alert = UIAlertController(
            title: "Great Job!",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Utilities
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension Notification.Name {
    static let plantTaskDidUpdate = Notification.Name("plantTaskDidUpdate")
}

