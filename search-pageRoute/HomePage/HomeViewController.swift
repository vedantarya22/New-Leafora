//
//  ViewController.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

struct GardenMemory {
    let image: UIImage
    let timestamp: Date
}

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Gradient Layer (Moved inside the class)
    let gradientLayer = CAGradientLayer()
    
    // Data Array for Photos
    var memories: [GardenMemory] = []
    
    // Data Models for Tasks
    struct Task { let name: String; let icon: String; let count: Int }
    let tasks = [
        Task(name: "Watering", icon: "drop.fill", count: 5),
        Task(name: "Pruning", icon: "scissors", count: 2),
        Task(name: "Fertilizing", icon: "leaf.fill", count: 0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set the Title to "Good Morning" (Replaces the old text cell)
//        self.title = "Good Morning"
//        self.tabBarItem.title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 2. Setup Gradient
        setupGradient()
        
        // 3. Register XIBs
        // Removed "HomeHeaderCell" since we don't need it anymore
        let cells = ["CareTaskCell", "InsightCell", "MemoryCell"]
        cells.forEach { name in
            collectionView.register(UINib(nibName: name, bundle: nil), forCellWithReuseIdentifier: name)
        }
        
        // Register Header
        collectionView.register(UINib(nibName: "HomeSectionHeaderView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "HomeSectionHeaderView")
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 4. Attach Layout
        collectionView.collectionViewLayout = createLayout()
    }

    // Ensure gradient resizes if screen rotates
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    func setupGradient() {
        // 1. Define the Colors
        let topColor = UIColor(red: 0.80, green: 0.93, blue: 0.80, alpha: 1.0).cgColor
        let bottomColor = UIColor.white.cgColor
        
        // 2. Setup the Layer
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 0.6]
        gradientLayer.frame = view.bounds
        
        // 3. Remove old layers to avoid stacking
        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Actions
    func openCamera() {
        let alert = UIAlertController(title: "Add Memory", message: "Choose a photo source", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.showImagePicker(source: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let galleryAction = UIAlertAction(title: "Photo Gallery", style: .default) { _ in
            self.showImagePicker(source: .photoLibrary)
        }
        alert.addAction(galleryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    func showImagePicker(source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true)
    }

    // MARK: - Compositional Layout
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            switch sectionIndex {
            // FIXED INDICES:
            case 0: return self.listLayout(env)     // Was 1, Now 0 (Tasks)
            case 1: return self.gridLayout()        // Was 2, Now 1 (Insights)
            case 2: return self.scrollLayout()      // Was 3, Now 2 (Memories)
            default: return nil
            }
        }
    }
    
    // DELETED: func headerLayout() -> NSCollectionLayoutSection { ... } (Not needed)

    // Layout 0: Tasks
    func listLayout(_ env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        config.backgroundColor = .clear
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    // Layout 1: Grid
    func gridLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(100)))
        item.contentInsets = .init(top: 0, leading: 5, bottom: 0, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 15, bottom: 20, trailing: 15)
        addHeader(to: section)
        return section
    }
    
    // Layout 2: Memories
    func scrollLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        // Card Size
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(180)), subitems: [item])
        
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 10, leading: 20, bottom: 30, trailing: 20)
        
        addHeader(to: section)
        return section
    }
    
    func addHeader(to section: NSCollectionLayoutSection) {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        // Move text down slightly to create space
        header.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: -5, trailing: 0)
        
        section.boundarySupplementaryItems = [header]
    }
    
    // MARK: - Helper for Date Formatting
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if seconds < 60 { return "Just now" }
        else if minutes < 60 { return "\(minutes) min ago" }
        else if hours < 24 { return "\(hours) hr ago" }
        else { return "\(days) days ago" }
    }

    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // Tasks, Insights, Memories
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return tasks.count          // Tasks
        case 1: return 2                    // Insights
        case 2: return memories.count + 1   // Memories (+1 for Add Button)
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
        case 0: // Tasks (Was 1)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell", for: indexPath) as! CareTaskCell
            let task = tasks[indexPath.row]
            cell.titleLabel.text = task.name
            cell.countLabel.text = "\(task.count)"
            cell.iconImageView.image = UIImage(systemName: task.icon)
            cell.iconImageView.contentMode = .scaleAspectFill
            
            if task.name == "Watering" { cell.iconImageView.tintColor = .systemTeal }
            else if task.name == "Pruning" { cell.iconImageView.tintColor = .systemOrange }
            else { cell.iconImageView.tintColor = UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0) }
            
            cell.iconImageView.contentMode = .scaleAspectFit
                
                cell.titleLabel.text = task.name
                cell.countLabel.text = "\(task.count)"
            return cell
            
        case 1: // Insights (Was 2)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InsightCell", for: indexPath) as! InsightCell
            if indexPath.row == 0 {
                cell.titleLabel.text = "Total Plants"
                cell.valueLabel.text = "16"
            } else {
                cell.titleLabel.text = "Pending Tasks"
                cell.valueLabel.text = "5"
            }
            // Style
            cell.contentView.backgroundColor = UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.masksToBounds = true
            return cell
            
        case 2: // Memories (Was 3)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
            
            // LOGIC: Is this the first cell?
            if indexPath.row == 0 {
                // --- SHOW ADD BUTTON ---
                // NOTE: The CENTERING constraints for this button should be in MemoryCell.swift!
                cell.imageView.image = UIImage(systemName: "plus.circle.fill")
                cell.imageView.tintColor = UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0)
                cell.imageView.contentMode = .center
                cell.imageView.backgroundColor = .white
                cell.dateLabel.text = "Add New"
            } else {
                // --- SHOW PHOTO ---
                let memory = memories[indexPath.row - 1]
                cell.imageView.image = memory.image
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.backgroundColor = .clear
                
                let timeInterval = Date().timeIntervalSince(memory.timestamp)
                cell.dateLabel.text = formatTimeInterval(timeInterval)
            }
            // Common Style
            cell.imageView.layer.cornerRadius = 12
            cell.imageView.clipsToBounds = true
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    // MARK: - Click Handling
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let taskName = tasks[indexPath.row].name // "Watering", "Pruning", etc.
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantListVC = storyboard.instantiateViewController(withIdentifier: "PlantListViewController") as? PlantListViewController {
                plantListVC.taskType = taskName
                navigationController?.pushViewController(plantListVC, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeSectionHeaderView", for: indexPath) as! HomeSectionHeaderView
        
        header.chevronButton.isHidden = true
        header.didTapSeeAll = nil
        
        switch indexPath.section {
        case 0: header.titleLabel.text = "Care Tasks"
        case 1: header.titleLabel.text = "Garden Insights"
        case 2:
            header.titleLabel.text = "Memories"
            header.chevronButton.isHidden = false
            header.didTapSeeAll = { [weak self] in
                self?.openAllMemories()
            }
        default: header.titleLabel.text = ""
        }
        
        return header
    }
    
    func openAllMemories() {
        // Assuming you have this Controller created
         let galleryVC = GalleryViewController()
         galleryVC.memories = self.memories
         present(galleryVC, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            let newMemory = GardenMemory(image: image, timestamp: Date())
            memories.insert(newMemory, at: 0)
            
            // Reload Section 2 (Memories)
            collectionView.reloadSections(IndexSet(integer: 2))
        }
        dismiss(animated: true)
    }
}

//// MARK: - Image Picker Logic
//extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//   
//}
