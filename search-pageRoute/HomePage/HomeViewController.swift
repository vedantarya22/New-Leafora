import UIKit

struct GardenMemory {
    let image: UIImage
    let timestamp: Date
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    
    
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let wateringBlue = UIColor(red: 0.00, green: 0.75, blue: 1.00, alpha: 1.0)
    let pruningRed = UIColor(red: 1.00, green: 0.07, blue: 0.33, alpha: 1.0)
    let fertilizingGreen = UIColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1.0)
    let repottingOrange = UIColor(red: 1.00, green: 0.62, blue: 0.04, alpha: 1.0)
    
    
    
   
    
    
    let gradientLayer = CAGradientLayer()
    var memories: [GardenMemory] = []
    
//    struct Task { let name: String; let icon: String; let count: Int }
//    let tasks = [
//        Task(name: "Watering", icon: "drop.fill", count: 5),
//        Task(name: "Pruning", icon: "scissors", count: 2),
//        Task(name: "Fertilizing", icon: "leaf.fill", count: 0),
//        Task(name: "Repotting", icon: "arrow.triangle.2.circlepath", count: 1)
//    ]
    
    
        // will put it in modals later
    
    struct Task {
        let name: String
        let icon: String
        let count: Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Good Morning"
        
        // Register XIBs
        let cells = ["CareTaskCell", "InsightCell", "MemoryCell"]
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    func getCareTasks() -> [Task] {

        let allPlants = PlantStore.shared.plants

        // ✅ Count pending tasks (Done == false)
        // ✅ Include quantity properly

        let wateringCount = allPlants
            .filter { $0.wateringDone == false }
            .reduce(0) { $0 + $1.quantity }

        let pruningCount = allPlants
            .filter { $0.pruningDone == false }
            .reduce(0) { $0 + $1.quantity }

        let fertilizingCount = allPlants
            .filter { $0.fertilizingDone == false }
            .reduce(0) { $0 + $1.quantity }

        let repottingCount = allPlants
            .filter { $0.repottingDone == false }
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
            case 0: return self.careGridLayout()
            case 1: return self.gridLayout()
            case 2: return self.scrollLayout()
            default: return nil
            }
        }
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
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0)
        
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
        // Standard width for all items since the "Add" button is always present
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    


    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 3 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return  getCareTasks().count
        case 1: return 2
        case 2: return memories.count + 1 // Always photos + 1 for the Add Button
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
            
        case 0:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell", for: indexPath) as! CareTaskCell
            let task = getCareTasks()[indexPath.row]
                    
                    cell.titleLabel.text = task.name
                    cell.countLabel.text = "\(task.count)"
                    
                    // Apply the specific Fitness color based on the task name
                    let taskColor: UIColor
                    switch task.name {
                    case "Watering":
                        taskColor = wateringBlue
                    case "Pruning":
                        taskColor = pruningRed
                    case "Fertilizing":
                        taskColor = fertilizingGreen
                    case "Repotting":
                        taskColor = repottingOrange
                    default:
                        taskColor = .systemGray
                    }
                    
                    // Update label color to match the Fitness style
                    cell.countLabel.textColor = taskColor
                    
                    // Configure the Progress Ring
                    // Assuming 5 is the 'goal' for the day to calculate percentage
                  
                    
                    return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as! InsightCell
            cell.titleLabel.text = indexPath.row == 0 ? "Total Plants" : "Pending Tasks"
            cell.valueLabel.text = indexPath.row == 0 ? "16" : "5"
            cell.contentView.backgroundColor = UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 16
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
            let isAddButton = indexPath.row == memories.count
            
            if isAddButton {
                cell.configure(with: nil, isAddButton: true)
            } else {
                cell.configure(with: memories[indexPath.row], isAddButton: false)
            }
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
            let taskName = getCareTasks()[indexPath.row].name

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
                plantListVC.taskType = taskName
                navigationController?.pushViewController(plantListVC, animated: true)
            }
        case 2:
            // Check if the user tapped the trailing Add Button
            if indexPath.row == memories.count {
                self.openCamera()
            } else {
                print("Viewing memory at index: \(indexPath.row)")
            }
        default: break
        }
    }

    // MARK: - Photo Actions
    func openCamera() {
        let alert = UIAlertController(title: "Add Garden Memory", message: "Capture a moment or choose from your gallery", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.showImagePicker(source: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.showImagePicker(source: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
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
            // We append to the end so photos appear left-to-right, followed by the button
            memories.append(GardenMemory(image: image, timestamp: Date()))
            collectionView.reloadSections(IndexSet(integer: 2))
            
            // Scroll to the end to show the new photo and the shifted Add Button
            let lastItem = IndexPath(item: memories.count, section: 2)
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
            header.titleLabel.text = "Care Tasks"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in self?.openCareTasksDetail() }
        case 1:
            header.titleLabel.text = "Garden Insights"
        case 2:
            header.titleLabel.text = "Memories"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in self?.openAllMemories() }
        default: break
        }
        return header
    }

    func openCareTasksDetail() {
        // 1. Get the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 2. Instantiate the VC (Make sure the Identifier in Storyboard is "PlantListViewController")
        if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
            
            // 3. Set the title or task type
            plantListVC.taskType = "All Tasks"
            
            // 4. Push it onto the navigation stack
            navigationController?.pushViewController(plantListVC, animated: true)
        }
    }
    func openAllMemories() { /* Navigate to gallery */ }
}
