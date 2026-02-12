import UIKit

class PlantDetailViewController_New: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var userPlant: UserPlant?
    var plantImage: UIImage?
    // Tracks which care card is currently open
    private var expandedCareIndex: IndexPath?
    private var isBenefitsExpanded = false
    let gradientLayer = CAGradientLayer()
    // MARK: - Section Management
    enum Section: Int, CaseIterable {
        case hero = 0
        case stats = 1
//        case status = 2
        case benefits = 2
        case careGuide = 3
        
        var title: String {
            switch self {
            case .hero: return ""
            case .stats: return ""
//            case .status: return "Plant Health"
            case .benefits: return "Benefits"
            case .careGuide: return "Care Guide"
            }
        }
    }
    
    // MARK: - DUMMY DATA - Replace these with your real data later
    private var statsData: [(icon: String, title: String, value: String, color: UIColor)] = [
        (icon: "drop.fill", value: "Water", title: "Every 2 days", color: UIColor.systemBlue),
        (icon: "sun.max.fill", value: "Light", title: "Bright light", color: UIColor.systemYellow),
        (icon: "leaf.fill", value: "Difficulty", title: "Easy", color: UIColor.systemGreen),
        (icon: "leaf", value: "Quantity", title: "1 plant", color: UIColor.systemTeal)
    ]
    
    private var benefitsText: String = """
    A hardy succulent known for healing gel and minimal watering needs.
    
    • Heals burns and skin irritations
    • Easy care and low maintenance
    • Air purification properties
    • Perfect for beginners
    • Drought resistant
    
    ⚠️ Toxic to pets - keep away from animals
    """
    
    private var careItems: [(icon: String, title: String, steps: String, color: UIColor)] = [
        (
            icon: "drop.fill",
            title: "Watering",
            steps: """
            Schedule: Every 2–3 weeks
            
            • Check soil moisture before watering
            • Water thoroughly until it drains
            • Allow soil to dry completely between waterings
            • Reduce watering in winter months
            """,
            color: UIColor.systemBlue
        ),
        (
            icon: "leaf.fill",
            title: "Fertilizing",
            steps: """
            Schedule: Every 2 months
            
            • Use diluted liquid fertilizer
            • Apply during growing season (spring/summer)
            • Reduce or skip in winter
            • Follow package instructions carefully
            """,
            color: UIColor.systemGreen
        ),
        (
            icon: "arrow.triangle.2.circlepath",
            title: "Repotting",
            steps: """
            Schedule: Every 12 months
            
            • Check if roots are crowding the pot
            • Use pot 2" larger than current
            • Use well-draining cactus mix soil
            • Best done in spring season
            """,
            color: UIColor.systemOrange
        ),
        (
            icon: "scissors",
            title: "Pruning",
            steps: """
            Schedule: Every 6 months
            
            • Remove dead or brown leaves
            • Trim damaged or diseased parts
            • Use clean, sharp tools
            • Dispose of diseased material properly
            """,
            color: UIColor.systemPurple
        )
    ]
    
    // Dummy health data
    private var healthStatus = "Healthy"
    private var nextWateringText = "in 5 days"
    private var healthPercentage = 85

    override func viewDidLoad() {
        setupBotanicalBackground()
        gradientLayer.frame = view.bounds
        self.plantImage = UIImage(named: "areca_palm")
        super.viewDidLoad()
        collectionView.backgroundColor = .clear
        setupCollectionView()
        collectionView.backgroundView = nil
        setupNavigationBar()
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
    
    
    private func setupNavigationBar() {
        // TODO: Replace with real plant name
        title = "Areca palm"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupCollectionView() {
        guard collectionView != nil else { return }

        // Register all cells
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil),
                               forCellWithReuseIdentifier: "HeroImageCell")
        collectionView.register(UINib(nibName: "StatCardCell", bundle: nil),
                               forCellWithReuseIdentifier: "StatCardCell")
//        collectionView.register(UINib(nibName: "PlantStatusCell", bundle: nil),
//                               forCellWithReuseIdentifier: "PlantStatusCell")
        collectionView.register(UINib(nibName: "BenefitsCell", bundle: nil),
                               forCellWithReuseIdentifier: "BenefitsCell")
        collectionView.register(UINib(nibName: "CareTaskCell1", bundle: nil),
                               forCellWithReuseIdentifier: "CareTaskCell1")
        
        // Register headers
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil),
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "SectionHeaderView")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
//        collectionView.backgroundColor = .systemGroupedBackground
    }
    
    // MARK: - Layout Configuration
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, environment) -> NSCollectionLayoutSection? in
            guard let self = self, let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .hero:
                return self.createHeroSection()
            case .stats:
                return self.createStatsSection()
//            case .status:
//                return self.createStatusSection()
            case .benefits:
                return self.createBenefitsSection()
            case .careGuide:
                return self.createCareGuideSection()
            }
        }
    }
    
    // Hero image section - full width
    private func createHeroSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.4)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    // Stats cards section - 2x2 grid
    private func createStatsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 24, trailing: 8)
        return section
    }
    
    // Status section - single full-width card
    private func createStatusSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Benefits section - expandable
    private func createBenefitsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Care guide section
    private func createCareGuideSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(70)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(70)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Data Source
extension PlantDetailViewController_New: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .hero: return 1
        case .stats: return statsData.count
//        case .status: return 1
        case .benefits: return 1
        case .careGuide: return careItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sectionType {
        case .hero:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroImageCell", for: indexPath) as! HeroImageCell
            
            if let data = userPlant?.imageData {
                // Use the user's custom photo if available
                cell.plantImageView.image = UIImage(data: data)
            } else if let assetImage = UIImage(named: "areca_palm") {
                // REPLACE "YourAssetNameHere" with the name in your Assets.xcassets
                cell.plantImageView.image = assetImage
            } else {
                // Fallback to a system symbol if the asset is missing
                cell.plantImageView.image = UIImage(systemName: "leaf.fill")
                cell.plantImageView.tintColor = .systemGreen
            }
            return cell
            
        case .stats:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatCardCell", for: indexPath) as! StatCardCell
            let stat = statsData[indexPath.item]
            cell.configure(icon: stat.icon, title: stat.title, value: stat.value, color: stat.color)
            return cell
            
//        case .status:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantStatusCell", for: indexPath) as! PlantStatusCell
//            // TODO: Calculate real health data
//            cell.configure(status: healthStatus, nextWatering: nextWateringText, healthPercentage: healthPercentage)
//            return cell
//            
        case .benefits:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BenefitsCell", for: indexPath) as! BenefitsCell
            cell.configure(text: benefitsText, isExpanded: isBenefitsExpanded)
            cell.onToggle = { [weak self] in
                self?.toggleBenefits()
            }
            return cell
            
        case .careGuide:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell1", for: indexPath) as! CareTaskCell1
            let item = careItems[indexPath.item]
            let isExpanded = (expandedCareIndex == indexPath)
            cell.configure(icon: item.icon, title: item.title, steps: item.steps, isExpanded: isExpanded)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section),
              !sectionType.title.isEmpty else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeaderView",
            for: indexPath
        ) as! SectionHeaderView
        header.titleLabel.text = sectionType.title
        return header
    }
}

// MARK: - Delegate
extension PlantDetailViewController_New: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        // Only allow interaction on Care Guide section
        if sectionType == .careGuide {
            toggleCareCard(at: indexPath)
        }
    }
    
    private func toggleCareCard(at indexPath: IndexPath) {
        // Toggle expansion
        if expandedCareIndex == indexPath {
            expandedCareIndex = nil
        } else {
            expandedCareIndex = indexPath
        }
        
        // Animate the height change
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: { _ in
            if self.expandedCareIndex != nil {
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        })
    }
    
    private func toggleBenefits() {
        isBenefitsExpanded.toggle()
        
        let indexPath = IndexPath(item: 0, section: Section.benefits.rawValue)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
}

// MARK: - TODO: Replace Dummy Data with Real Data
/*
 
 HOW TO USE YOUR REAL DATA:
 
 1. Replace statsData array with your plant's real data:
    statsData = [
        (icon: "drop.fill", title: "Water", value: yourPlant.wateringSchedule, color: .systemBlue),
        (icon: "sun.max.fill", title: "Light", value: yourPlant.lightNeeds, color: .systemYellow),
        // ... etc
    ]
 
 2. Replace benefitsText with your plant's benefits:
    benefitsText = yourPlant.benefits
 
 3. Replace careItems with your plant's care instructions:
    careItems = [
        (icon: "drop.fill", title: "Watering", steps: yourPlant.wateringInstructions, color: .systemBlue),
        // ... etc
    ]
 
 4. Replace health data:
    healthStatus = calculateHealthStatus()
    nextWateringText = calculateNextWatering()
    healthPercentage = calculateHealthPercentage()
 
 5. Replace title:
    title = yourPlant.name
 
 You can do this in viewDidLoad() or create a configure(with plant:) method.
 
 */
