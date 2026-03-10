import UIKit

class PlantListViewController: UIViewController,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var taskType: String = ""
    var filteredPlants: [UserPlant] = []
    var allPlants: [Plant] = []

    // MARK: - UI Components
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = taskType

        // Register Cell XIB
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")

        collectionView.dataSource = self
        collectionView.delegate = self

        setupBotanicalBackground()

        // Hide empty state initially
        emptyStateView?.isHidden = true

        //  Load JSON once - reuse everywhere
        allPlants = JSONLoader.loadPlants(from: "plantData")
        
        if allPlants.isEmpty {
                print("⚠️ WARNING: No plants loaded from JSON! Check if 'plantData.json' exists in bundle")
               } else {
                   print(" Loaded \(allPlants.count) plant types from JSON")
           }
           
        setupMarkAllDoneButton()
    }
    
    // MARK: - Navigation Bar UI
    private func setupMarkAllDoneButton() {
        let markAllButton = UIBarButtonItem(
            title: "Mark All Done",
            style: .done,
            target: self,
            action: #selector(markAllAsDoneTapped)
        )
        // Make the button match the botanical theme slightly
        markAllButton.tintColor = UIColor(red: 0.18, green: 0.49, blue: 0.20, alpha: 1.0)
        navigationItem.rightBarButtonItem = markAllButton
    }
    
    @objc private func markAllAsDoneTapped() {
        guard !filteredPlants.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Mark All As Done?",
            message: "This will check off the \(taskType.lowercased()) task for all \(filteredPlants.count) plants in this list.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Mark All", style: .default, handler: { [weak self] _ in
            self?.executeMarkAllDone()
        }))
        
        present(alert, animated: true)
    }
    
    private func executeMarkAllDone() {
        // Iterate over all currently displayed items
        for plant in filteredPlants {
            PlantStore.shared.markTaskDone(userPlantID: plant.id, taskType: taskType)
        }
        
        // Remove visually
        let totalItems = filteredPlants.count
        filteredPlants.removeAll()
        
        // Batch animate wiping the collection view clean
        var indexPaths: [IndexPath] = []
        for i in 0..<totalItems {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteItems(at: indexPaths)
        } completion: { _ in
            // Re-check visibility logic
            self.loadAndFilterData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndFilterData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - UI Setup

    private func setupBotanicalBackground() {
        // A soft, off-white to very pale sage green
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: 90)
    }

    // MARK: - DataSource

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

        //  Get correct UserPlant
        let userPlant = filteredPlants[indexPath.row]

        //  Configure cell
        cell.configure(
              with: userPlant,
              task: taskType,
              allPlants: allPlants
          )


        //  Swipe Done Closure
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

    // MARK: - Swipe Hint Animation

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !filteredPlants.isEmpty {
            showSwipeHint()
        }
    }

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
            taskType: taskType
        )
    }
    
    
    // MARK: - Load + Filter Pending Plants

    func loadAndFilterData() {
           //  Get ALL individual plants (no grouping)
           let allUserPlants = PlantStore.shared.allPlants()

           //  Filter plants that have tasks due
           filteredPlants = allUserPlants.filter { userPlant in
               let isDue: Bool

               switch taskType.lowercased() {
               case "watering":
                   isDue = TaskDueEngine.isDue(userPlant, task: .watering)

               case "pruning":
                   isDue = TaskDueEngine.isDue(userPlant, task: .pruning)

               case "fertilizing":
                   isDue = TaskDueEngine.isDue(userPlant, task: .fertilizing)

               case "repotting":
                   isDue = TaskDueEngine.isDue(userPlant, task: .repotting)
                   

               default:
                   isDue = true
               }

               return isDue
           }

           print(" Filtered \(filteredPlants.count) plants needing \(taskType)")
           
           // Toggle Empty State Visibility
           if filteredPlants.isEmpty {
               collectionView.isHidden = true
               emptyStateView?.isHidden = false
           } else {
               collectionView.isHidden = false
               emptyStateView?.isHidden = true
           }
           
           collectionView.reloadData()
       }
    
 



}
