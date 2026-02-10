import UIKit

struct GardenMemory {
    let image: UIImage
    let timestamp: Date
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Original Colors
    // Natural, Earthy Plant Care Colors
    let wateringBlue = UIColor(red: 0.42, green: 0.71, blue: 0.84, alpha: 1.0)      // Soft water blue
    let pruningRed = UIColor(red: 0.82, green: 0.47, blue: 0.38, alpha: 1.0)       // Terracotta/clay
    let fertilizingGreen = UIColor(red: 0.52, green: 0.71, blue: 0.42, alpha: 1.0) // Sage green
    let repottingOrange = UIColor(red: 0.85, green: 0.65, blue: 0.38, alpha: 1.0)  // Warm sand/pot
    
    let gradientLayer = CAGradientLayer()
    var memories: [GardenMemory] = []
    
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
        
        // Register XIBs
        let cells = ["CareTaskCell", "InsightCell", "MemoryCell", "UrgentCareCell"]
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
        // Recalculate data & refresh UI
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

//            if insights.isEmpty {
//                return [
//                    TaskOverviewInsight(
//                        icon: "checkmark.seal.fill", title: "All Plants Healthy",
//                        message: "Everything is well cared  ",
//                        level: .good,
//                        route: ""
//                    )
//                ]
//            }
        
        return [
                TaskOverviewInsight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Urgent Care Needed",
                    message: "2 plants need attention now",
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

            return insights
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
            Task(name: "Repotting", icon: "arrow.triangle.2.circlepath", count: repottingCount)
        ]
    }
    
    // MARK: - Layout Logic
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            switch sectionIndex {
            case 0: return self.urgentCardsLayout()
            case 1: return self.careGridLayout()
            case 2: return self.gridLayout()
            case 3: return self.scrollLayout()
            default: return nil
            }
        }
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
        section.contentInsets = .init(top: -15, leading: 0, bottom: 28, trailing: 0)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 0)

        section.boundarySupplementaryItems = [header]
        return section
    }

    
    func careGridLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 20, trailing: 14)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func gridLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(100)))
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 8, leading: 20, bottom: 20, trailing: 8)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(35))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func scrollLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 15, leading: 20, bottom: 30, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    
    
   

    
    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4  // Section 0: Urgent/Missed, Section 1: Care Tasks, Section 2: Memories
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return taskInsightsForHome().count
        case 1:
            return getCareTasks().count
        case 2:
            return 2
        case 3:
            return memories.count + 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "UrgentCareCell",
                for: indexPath
            ) as! UrgentCareCell

            let insights = taskInsightsForHome()
            let insight = insights[indexPath.row]

            cell.configure(with: insight)

            // ⬇️ Hide chevron for healthy state
            cell.setChevronHidden(insight.level == .good)

            return cell
            
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell", for: indexPath) as! CareTaskCell
            let task = getCareTasks()[indexPath.row]
            cell.titleLabel.text = task.name
            cell.countLabel.text = "\(task.count)"
            
            let taskColor: UIColor
            switch task.name {
            case "Watering": taskColor = wateringBlue
            case "Pruning": taskColor = pruningRed
            case "Fertilizing": taskColor = fertilizingGreen
            case "Repotting": taskColor = repottingOrange
            default: taskColor = .systemGray
            }
            cell.countLabel.textColor = taskColor
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as! InsightCell
            cell.titleLabel.text = indexPath.row == 0 ? "Total Plants" : "Pending Tasks"
            cell.valueLabel.text = indexPath.row == 0 ? "\(PlantStore.shared.plants.count)" : "5"
            cell.contentView.backgroundColor = UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 16
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
            let isAddButton = indexPath.row == memories.count
            cell.configure(with: isAddButton ? nil : memories[indexPath.row], isAddButton: isAddButton)
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    
    // MARK: - Delegate (Click Handling)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        switch indexPath.section {
        case 0:
            // Tapped Urgent or Missed card
            let allPlants = PlantStore.shared.allPlants()
            let taskInsights = GardenInsightEngine.shared.generateTaskOverview(from: allPlants)
            
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
            
        case 1: // Care Tasks
            let taskName = getCareTasks()[indexPath.row].name
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
                plantListVC.taskType = taskName
                navigationController?.pushViewController(plantListVC, animated: true)
            }
            
        case 3: // Memories
            if indexPath.row == memories.count {
                self.openCamera()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Photo Actions
    func openCamera() {
        let alert = UIAlertController(title: "Add Garden Memory", message: "Capture a moment or choose from your gallery", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in self.showImagePicker(source: .camera) })
        }
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in self.showImagePicker(source: .photoLibrary) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            memories.append(GardenMemory(image: image, timestamp: Date()))
            collectionView.reloadData()
            let lastItem = IndexPath(item: memories.count, section: 3)
            collectionView.scrollToItem(at: lastItem, at: .right, animated: true)
        }
        dismiss(animated: true)
    }
    
    // MARK: - Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeSectionHeaderView", for: indexPath) as! HomeSectionHeaderView
        header.chevronButton.isHidden = true
        
        switch indexPath.section {
        case 0:
            header.titleLabel.text = "" // No header for the alert box
        case 1:
            header.titleLabel.text = "Care Tasks"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in self?.openCareTasksDetail() }
        case 2:
            header.titleLabel.text = "Garden Insights"
        case 3:
            header.titleLabel.text = "Memories"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in self?.openAllMemories() }
        default: break
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
    func openAllMemories() { /* Navigate to gallery */ }
}
