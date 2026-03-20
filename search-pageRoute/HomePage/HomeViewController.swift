import UIKit

//struct GardenMemory {
//    let image: UIImage
//    let timestamp: Date
//}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var tipTimer: Timer?
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Original Colors
    //clay colors
    // Natural, Earthy Plant Care Colors
    let wateringBlue = UIColor(red: 0.42, green: 0.71, blue: 0.84, alpha: 1.0)      // Soft water blue
    let pruningRed = UIColor(red: 0.82, green: 0.47, blue: 0.38, alpha: 1.0)       // Terracotta/clay
    let fertilizingGreen = UIColor(red: 0.52, green: 0.71, blue: 0.42, alpha: 1.0) // Sage green
    let repottingOrange = UIColor(red: 0.85, green: 0.65, blue: 0.38, alpha: 1.0)  // Warm sand/pot
    
    let gradientLayer = CAGradientLayer()
//    var memories: [GardenMemory] = []
    
    struct Task {
        let name: String
        let icon: String
        let count: Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Home"
        
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(handleTaskUpdate),
              name: .plantTaskDidUpdate,
              object: nil
          )
        func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            // Start timer: 30 seconds, repeats indefinitely
            tipTimer = Timer.scheduledTimer(timeInterval: 30.0,
                                           target: self,
                                           selector: #selector(updateGardenTip),
                                           userInfo: nil,
                                           repeats: true)
        }

        func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // Invalidate timer to prevent memory leaks and background processing
            tipTimer?.invalidate()
            tipTimer = nil
        }
        // Register XIB's
        let cells = ["CareTaskCell", "UrgentCareCell","GardenTipCell","ScanPlantCell"]
        cells.forEach { name in
            collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
        }
        
        collectionView.register(UINib(nibName: "HomeSectionHeaderView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HomeSectionHeaderView")
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        
        // DEBUG: List all JSON files in bundle
        JSONLoader.debugListBundleJSONFiles()
        
        
    }
    
    @objc private func handleTaskUpdate() {
        // refresh UI
        collectionView.reloadSections(IndexSet(integer: 0))
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fixed: Use reloadData to prevent section mismatch crashes on first load
        collectionView.reloadData()
    }
    @objc private func updateGardenTip() {
        // We only want to reload Section 0 (the Garden Tip section)
        // The cellForItemAt logic already calls GardenTip.randomTip(),
        // so reloading the section will naturally pick a new one.
        
        UIView.transition(with: collectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
    private func setupBotanicalBackground() {
        // A soft, off-white to very pale sage green
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        // Insert at index 0 so it stays behind the UICollectionView
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func taskInsightsForHome() -> [TaskOverviewInsight] {
            let allPlants = PlantStore.shared.allPlants()
            let insights = GardenInsightEngine.shared.generateTaskOverview(from: allPlants)


        
        return [
                TaskOverviewInsight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Urgent Care Needed",
                    message: "3 plants need attention now",
                    level: .critical,
                    route: "Urgent"
                ),
                TaskOverviewInsight(
                    icon: "clock.fill",
                    title: "Missed Tasks",
                    message: "3 plants need care soon",
                    level: .warning,
                    route: "Missed"
                )
            ]

//            return insights
        }
    
    
    
    
    func getCareTasks() -> [Task] {
        let allPlants = PlantStore.shared.plants
        
        let wateringCount = allPlants
            .filter { TaskDueEngine.isDue($0, task: .watering) }
            .reduce(0) { $0 + $1.quantity }
        
        let pruningCount = allPlants
            .filter { TaskDueEngine.isDue($0, task: .pruning) }
            .reduce(0) { $0 + $1.quantity }
        
        let fertilizingCount = allPlants
            .filter { TaskDueEngine.isDue($0, task: .fertilizing) }
            .reduce(0) { $0 + $1.quantity }
        
        let repottingCount = allPlants
            .filter { TaskDueEngine.isDue($0, task: .repotting) }
            .reduce(0) { $0 + $1.quantity }
        
        return [
            Task(name: "Watering", icon: "drop.fill", count: wateringCount),
            Task(name: "Pruning", icon: "scissors", count: pruningCount),
            Task(name: "Fertilizing", icon: "leaf.fill", count: fertilizingCount),
            Task(name: "Repotting", icon: "arrow.up.bin.fill", count: repottingCount)
        ]
    }
    
    // MARK: - Layout Logic
    
    //order of UI
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            switch sectionIndex {
            case 0: return self.gardenTipLayout()      // 1st: Tip (conditionally shown)
            case 1: return self.scanSectionLayout()    // 2nd: Scan
            case 2: return self.urgentCardsLayout()    // 3rd: Urgent Cards
            case 3: return self.careGridLayout()       // 4th: Care Tasks
            default: return nil
            }
        }
    }
    
    func scanSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
        return section
    }
    
    func gardenTipLayout() -> NSCollectionLayoutSection {
          let itemSize = NSCollectionLayoutSize(
             widthDimension: .fractionalWidth(1.0),
              heightDimension: .absolute(150)  // Fixed height instead of estimated
         )
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
          item.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
   
          let groupSize = NSCollectionLayoutSize(
               widthDimension: .fractionalWidth(1.0),
               heightDimension: .absolute(150)
           )
           let group = NSCollectionLayoutGroup.vertical(
               layoutSize: groupSize,
              subitems: [item]
           )
   
          let section = NSCollectionLayoutSection(group: group)
           section.contentInsets = .init(top: 12, leading: 0, bottom: 8, trailing: 0)
   
           return section
       }
    
    func urgentCardsLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(80)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)

        section.interGroupSpacing = 16   // ✅ THIS is the gap between cards
        section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)

        // Removed the empty header that was adding extra top space
        
        return section
    }

    func careGridLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(85))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 20, trailing: 14)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
//    func gridLayout() -> NSCollectionLayoutSection {
//        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(100)))
//        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = .init(top: 8, leading: 20, bottom: 20, trailing: 8)
//        
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        section.boundarySupplementaryItems = [header]
//        return section
//    }
    
//    func scrollLayout() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(200))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.orthogonalScrollingBehavior = .continuous
//        section.contentInsets = .init(top: 15, leading: 20, bottom: 30, trailing: 20)
//        
//        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
//        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
    
    
    
   

    
    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return PlantStore.shared.allPlants().count > 0 ? 1 : 0 // Garden Tip conditionally
        case 1: return 1 // Scan Your Plant
        case 2: return taskInsightsForHome().count // Urgent
        case 3: return getCareTasks().count // Care Tasks
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: // Garden Tip
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GardenTipCell", for: indexPath) as! GardenTipCell
            cell.configure(tip: GardenTip.randomTip())
            return cell
            
        case 1: // Scan Your Plant
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScanPlantCell", for: indexPath) as! ScanPlantCell
            return cell
            
        case 2: // Urgent Care
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UrgentCareCell", for: indexPath) as! UrgentCareCell
            let insights = taskInsightsForHome()
            let insight = insights[indexPath.row]
            cell.configure(with: insight)
            cell.setChevronHidden(insight.level == .good)
            return cell
            
        case 3: // Care Tasks
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell", for: indexPath) as! CareTaskCell
            let task = getCareTasks()[indexPath.row]
            
            let taskColor: UIColor
            switch task.name {
                case "Watering": taskColor = wateringBlue
                case "Pruning": taskColor = pruningRed
                case "Fertilizing": taskColor = fertilizingGreen
                case "Repotting": taskColor = repottingOrange
                default: taskColor = .systemGray
            }
            
            cell.configure(title: task.name, count: task.count, color: taskColor)
            return cell
                
        default:
            return UICollectionViewCell()
        }
    }
    
    
    // MARK: - Delegate (Click Handling)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        switch indexPath.section {
        case 0:
            // Garden Tip tapped
            print("Garden tip tapped")
            
        case 1:
            //scan feature
            self.openCameraForPlantScan()
            
        case 2:
            // Tapped Urgent or Missed card
            let taskInsights = self.taskInsightsForHome()
            
            if indexPath.row < taskInsights.count {
                let insight = taskInsights[indexPath.row]
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let urgentMissedVC = storyboard.instantiateViewController(
                    withIdentifier: "UrgentMissedView"
                ) as? UrgentMissedViewController {
                    urgentMissedVC.urgencyLevel = insight.route  // "Urgent" or "Missed"
                    navigationController?.pushViewController(urgentMissedVC, animated: true)
                }
            }
            
        case 3: // Care Tasks
            let taskName = getCareTasks()[indexPath.row].name
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
                plantListVC.taskType = taskName
                navigationController?.pushViewController(plantListVC, animated: true)
            }
            
        default:
            break
        }
    }
    
    // MARK: -  Plant Scanning Methods
    func openCameraForPlantScan() {
        let alert = UIAlertController(
            title: "Scan Plant",
            message: "Take a photo of the plant to identify it",
            preferredStyle: .actionSheet
        )
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.showImagePickerForPlantScan(source: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.showImagePickerForPlantScan(source: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showImagePickerForPlantScan(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(" Image picked, preparing to scan...")
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            print(" Got image, size: \(image.size)")
            
            // Dismiss the picker first
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                print(" Picker dismissed, showing scanning screen...")
                
                // Small delay to ensure smooth transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let scanningVC = PlantScanningViewController(image: image)
                    scanningVC.modalPresentationStyle = .overFullScreen
                    self.present(scanningVC, animated: true) {
                        print(" Scanning view controller presented")
                    }
                }
            }
        } else {
            print(" ERROR: Could not get image from picker")
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeSectionHeaderView", for: indexPath) as! HomeSectionHeaderView
        header.chevronButton.isHidden = true

        switch indexPath.section {
        case 0://garden tip
            header.titleLabel.text = ""
        case 1://scan plant
            header.titleLabel.text = ""
        case 2://urgent/missed
            header.titleLabel.text = ""
        case 3: // Care Tasks
            header.titleLabel.text = "Today's Plant Care"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in self?.openCareTasksDetail() }
        default:
            header.titleLabel.text = ""
        }
        return header
    }
    
    func openCareTasksDetail() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
            plantListVC.taskType = "All Tasks"
            navigationController?.pushViewController(plantListVC, animated: true)
        }
    }
   
}
