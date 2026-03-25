import UIKit

class PlantListViewController: UIViewController,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var taskType: String = ""
    var filteredPlants: [UserPlant] = []
    var allPlants: [Plant] = []
    
    // App green accent
    private let appGreen = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Empty State View
    private lazy var emptyStateView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        
        let titleLabel = UILabel()
        titleLabel.text = "Hurray!"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = .systemGreen
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "No care needed in this section."
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = taskType
        
        //  Apply app green tint to navigation bar
        navigationController?.navigationBar.tintColor = appGreen
        
        // Custom Back button since leftBarButtonItem overrides the system back button
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        
        //  Native info button in nav bar
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(infoButtonTapped)
        )
        infoButton.tintColor = appGreen
        
        //  "Mark All as Done" bar button
        let markAllButton = UIBarButtonItem(
            title: "Mark as done",
            style: .plain,
            target: self,
            action: #selector(markAllAsDoneTapped)
        )
        // A noticeably darker green than appGreen (0.45, 0.70, 0.55)
        markAllButton.tintColor = UIColor(red: 0.25, green: 0.55, blue: 0.35, alpha: 1.0)
        
        // Place both Back and Info buttons on the left
        navigationItem.leftBarButtonItems = [backButton, infoButton]
        navigationItem.rightBarButtonItem = markAllButton
        
        // Register Cell XIB
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //  load from cache
        allPlants = PlantCatalogueCache.shared.plants
        
        if allPlants.isEmpty {
            print("WARNING: No plants loaded! Check catalogue cache")
        } else {
            print("Loaded \(allPlants.count) plant types from catalogue")
        }
        
        //  Add empty state view
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
        
        // Setup Pull to Refresh
        refreshControl.tintColor = appGreen
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        loadAndFilterData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndFilterData()
    }
    
    
    
    
    // MARK: - Collection Layout
    
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
        //  Update locally first (instant UI response)
        PlantStore.shared.markTaskDone(
            userPlantID: userPlant.id,
            taskType: taskType
        )
        
        //  Sync to MongoDB
        guard let mongoId = userPlant.mongoId else {
            print("No mongoId on userPlant — cannot sync task to backend")
            return
        }
        
        NetworkManager.shared.markTaskDone(mongoId: mongoId, taskType: taskType.lowercased()) { success in
            if success {
                print("Task '\(self.taskType)' synced to MongoDB for plant: \(mongoId)")
            } else {
                print("Failed to sync task to MongoDB — will be out of sync")
            }
        }
    }
    
    // MARK: - Mark All as Done
    
    @objc private func markAllAsDoneTapped() {
        guard !filteredPlants.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Mark All as Done",
            message: "Mark all \(filteredPlants.count) \(taskType.lowercased()) tasks as completed?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Mark All as Done", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            //  Mark each plant's task as done
            let plantsToMark = self.filteredPlants
            for plant in plantsToMark {
                self.markTaskDone(for: plant)
            }
            
            //  Clear the list and animate
            let indexPaths = (0..<self.filteredPlants.count).map { IndexPath(item: $0, section: 0) }
            self.filteredPlants.removeAll()
            
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: indexPaths)
            }) { _ in
                // Pop back after a brief moment so the user sees the empty state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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
        
        print("Filtered \(filteredPlants.count) plants needing \(taskType)")
        collectionView.reloadData()
        
        //  Show/hide empty state
        let isEmpty = filteredPlants.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
    }
    
    
    //        private func daysSince(_ date: Date?) -> Int {
    //            guard let date else { return Int.max }
    //            return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? Int.max
    //        }
    
    
    // MARK: - Info Button
    
    @objc private func infoButtonTapped() {
        let items = careItems(for: taskType)
        let infoVC = CareGuideViewController(taskType: taskType, items: items, tintColor: appGreen)
        let nav = UINavigationController(rootViewController: infoVC)
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(nav, animated: true)
    }
    
    private func careItems(for task: String) -> [(icon: String, term: String, detail: String)] {
        switch task.lowercased() {
        case "watering":
            return [
                ("humidity.fill",       "Spray misting",      "Mist leaves with a spray bottle to boost humidity"),
                ("drop",                "Light watering",      "Small amount of water when soil is fully dry"),
                ("drop.fill",           "Moderate watering",   "Water when the top 1–2 inches of soil feel dry"),
                ("drop.triangle.fill",  "Deep watering",       "Soak soil until water drains from the bottom"),
                ("cup.and.saucer.fill", "Bottom watering",     "Let roots absorb water from a tray underneath")
            ]
        case "fertilizing":
            return [
                ("eyedropper.halffull", "Light feeding",       "Diluted fertilizer for gentle nourishment"),
                ("scalemass",           "Balanced feeding",    "Standard all-purpose liquid feed"),
                ("bolt.fill",           "Heavy feeding",       "Full-strength fertilizer for heavy growers"),
                ("leaf.fill",           "Organic compost",     "Enrich the soil naturally with compost")
            ]
        case "pruning":
            return [
                ("scissors",            "Light trimming",      "Snip off dead or yellowing leaves"),
                ("leaf.arrow.triangle.circlepath", "Shape pruning", "Trim stems to maintain a compact shape"),
                ("tree.fill",           "Heavy pruning",       "Cut back hard to encourage fresh growth"),
                ("hand.pinch",          "Pinching back",       "Pinch soft tips so the plant branches out")
            ]
        case "repotting":
            return [
                ("magnifyingglass",     "Root check needed",   "Check if roots are circling the pot"),
                ("arrow.up.right.and.arrow.down.left", "Pot upgrade needed",  "Move to a pot 1–2 inches larger"),
                ("arrow.3.trianglepath", "Soil refresh needed", "Replace old, depleted soil with a fresh mix"),
                ("square.split.2x1",    "Division needed",     "Split an overcrowded plant into smaller ones")
            ]
        default:
            return [("leaf", "General care", "Follow the care instructions for your plant")]
        }
    }
}

// MARK: - Care Guide Presentation

private class CareGuideViewController: UITableViewController {
    
    private let taskType: String
    private let items: [(icon: String, term: String, detail: String)]
    private let tintColor: UIColor
    
    init(taskType: String, items: [(icon: String, term: String, detail: String)], tintColor: UIColor) {
        self.taskType = taskType
        self.items = items
        self.tintColor = tintColor
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(taskType) Guide"
        navigationController?.navigationBar.tintColor = tintColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelf))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc private func dismissSelf() { dismiss(animated: true) }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        config.image = UIImage(systemName: item.icon, withConfiguration: symbolConfig)
        config.imageProperties.tintColor = tintColor
        
        config.text = item.term
        config.textProperties.font = .systemFont(ofSize: 17, weight: .semibold)
        
        config.secondaryText = item.detail
        config.secondaryTextProperties.font = .systemFont(ofSize: 14)
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 0
        
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
