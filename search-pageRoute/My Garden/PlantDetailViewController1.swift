import UIKit

class PlantDetailViewController_New: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var userPlant: UserPlant?
    var plantImage: UIImage?
    
    // Tracks which care card is currently open
    private var expandedCareIndex: IndexPath?
    let gradientLayer = CAGradientLayer()
    
    // Data loaded from JSON
    private var plantData: Plant?
    private var allPlants: [Plant] = []
    
    // MARK: - Section Management
    enum Section: Int, CaseIterable {
        case hero = 0
        case stats = 1
        case careGuide = 2
        
        var title: String {
            switch self {
            case .hero: return ""
            case .stats: return ""
            case .careGuide: return "Care Guide"
            }
        }
    }
    
    // Stats and care data - populated from JSON
    private var statsData: [(icon: String, title: String, value: String, color: UIColor)] = []
    private var careItems: [(icon: String, title: String, steps: String, color: UIColor)] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        gradientLayer.frame = view.bounds
        collectionView.backgroundColor = .clear
        
        //  Load plant data from JSON
        loadPlantData()
        
        setupCollectionView()
        collectionView.backgroundView = nil
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✏️ Refresh userPlant data after returning from edit questionnaire
        if let plantID = userPlant?.id,
           let updated = PlantStore.shared.getPlant(by: plantID) {
            userPlant = updated
            loadPlantData()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Load Plant Data from JSON
    private func loadPlantData() {
        // Load all plants from JSON
        allPlants = JSONLoader.loadPlants(from: "plantData")
        
        guard let userPlant = userPlant else {
            print("⚠️ No userPlant provided")
            return
        }
        
        // Find matching plant by plantId
        plantData = allPlants.first(where: { $0.plantId == userPlant.plantId })
        
        guard let plant = plantData else {
            print("⚠️ Could not find plant data for plantId: \(userPlant.plantId)")
            return
        }
        
        print(" Loaded plant data for: \(plant.plantName)")
        
        let count = countPlantsOfType(plantId: userPlant.plantId ?? "")
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        let dateStr = userPlant != nil ? displayFormatter.string(from: userPlant.createdAt) : ""

        //  FIXED: Correct tuple order (title, value)
        statsData = [
            (icon: "drop.fill",
             title: "Water",
             value: plant.careCycle.watering.display,
             color: UIColor.systemBlue),
            
            (icon: "leaf",
             title: "Quantity",
             value: "\(count) plant\(count > 1 ? "s" : "")",
             color: UIColor.systemYellow),
            
            (icon: "leaf.fill",
             title: "Difficulty",
             value: plant.difficulty.displayName,  //  Use displayName
             color: UIColor.systemGreen),
            
            (icon: "calendar",
             title: "Date Added",
             value: dateStr,
             color: UIColor.systemTeal)
        ]
        
        //  Populate care items from plant data
        careItems = [
            (
                icon: "drop.fill",
                title: "Watering",
                steps: buildWateringSteps(from: plant),
                color: UIColor.systemBlue
            ),
            (
                icon: "leaf.fill",
                title: "Fertilizing",
                steps: buildFertilizingSteps(from: plant),
                color: UIColor.systemGreen
            ),
            (
                icon: "arrow.triangle.2.circlepath",
                title: "Repotting",
                steps: buildRepottingSteps(from: plant),
                color: UIColor.systemOrange
            ),
            (
                icon: "scissors",
                title: "Pruning",
                steps: buildPruningSteps(from: plant),
                color: UIColor.systemPurple
            )
        ]
    }
    // MARK: - Build Care Steps from Plant Data
    
    // MARK: - Build Care Steps from Plant Data

    private func buildWateringSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.watering.display
        
        //  Use steps from JSON if available
        if let steps = plant.careCycle.watering.steps {
            let bulletPoints = steps.map { "• \($0)" }.joined(separator: "\n")
            return "Schedule: \(schedule)\n\n\(bulletPoints)"
        }
        
        // Fallback: build from method
        let method = plant.careCycle.watering.method ?? "moderate"
        let methodDescription: String
        switch method.lowercased() {
        case "spray":
            methodDescription = "• Use spray bottle for misting\n• Keep leaves lightly moist"
        case "light":
            methodDescription = "• Water lightly around the base\n• Avoid overwatering"
        case "moderate":
            methodDescription = "• Water thoroughly until it drains\n• Allow soil to dry between waterings"
        case "deep":
            methodDescription = "• Deep soak until water drains freely\n• Ensure soil is fully saturated"
        case "bottom":
            methodDescription = "• Place pot in water tray\n• Let roots absorb from bottom"
        default:
            methodDescription = "• Water thoroughly until it drains\n• Allow soil to dry between waterings"
        }
        
        return """
        Schedule: \(schedule)
        
        \(methodDescription)
        • Check soil moisture before watering
        • Reduce watering in winter months
        """
    }

    private func buildFertilizingSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.fertilizing.display
        
        if let steps = plant.careCycle.fertilizing.steps {
            let bulletPoints = steps.map { "• \($0)" }.joined(separator: "\n")
            return "Schedule: \(schedule)\n\n\(bulletPoints)"
        }
        
        let method = plant.careCycle.fertilizing.method ?? "balanced"
        let methodDescription: String
        switch method.lowercased() {
        case "light":
            methodDescription = "• Use diluted liquid fertilizer\n• Apply at 1/4 strength"
        case "balanced":
            methodDescription = "• Use balanced liquid fertilizer\n• Apply at recommended strength"
        case "heavy":
            methodDescription = "• Use full-strength fertilizer\n• Heavy feeders need regular feeding"
        case "organic":
            methodDescription = "• Use organic compost or worm castings\n• Apply as top dressing"
        default:
            methodDescription = "• Use balanced liquid fertilizer\n• Apply at recommended strength"
        }
        
        return """
        Schedule: \(schedule)
        
        \(methodDescription)
        • Apply during growing season (spring/summer)
        • Reduce or skip in winter
        """
    }

    private func buildRepottingSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.repotting.display
        
        if let steps = plant.careCycle.repotting.steps {
            let bulletPoints = steps.map { "• \($0)" }.joined(separator: "\n")
            return "Schedule: \(schedule)\n\n\(bulletPoints)"
        }
        
        let method = plant.careCycle.repotting.method ?? "refresh"
        let methodDescription: String
        switch method.lowercased() {
        case "check":
            methodDescription = "• Check if roots are crowding\n• Look for roots growing through drainage holes"
        case "upgrade":
            methodDescription = "• Use pot 2\" larger than current\n• Ensure good drainage"
        case "refresh":
            methodDescription = "• Replace old soil with fresh mix\n• Can use same size pot"
        case "division":
            methodDescription = "• Divide root ball into sections\n• Plant each division separately"
        default:
            methodDescription = "• Use pot 2\" larger than current\n• Replace with fresh soil"
        }
        
        return """
        Schedule: \(schedule)
        
        \(methodDescription)
        • Use well-draining soil mix
        • Best done in spring season
        """
    }

    private func buildPruningSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.pruning.display
        
        if let steps = plant.careCycle.pruning.steps {
            let bulletPoints = steps.map { "• \($0)" }.joined(separator: "\n")
            return "Schedule: \(schedule)\n\n\(bulletPoints)"
        }
        
        let method = plant.careCycle.pruning.method ?? "trim"
        let methodDescription: String
        switch method.lowercased() {
        case "trim":
            methodDescription = "• Remove dead or brown leaves\n• Light maintenance trimming"
        case "shape":
            methodDescription = "• Shape to maintain desired form\n• Cut above leaf nodes"
        case "heavy":
            methodDescription = "• Cut back significantly for renewal\n• Remove up to 1/3 of growth"
        case "pinch":
            methodDescription = "• Pinch back growing tips\n• Encourages bushier growth"
        default:
            methodDescription = "• Remove dead or brown leaves\n• Light maintenance trimming"
        }
        
        return """
        Schedule: \(schedule)
        
        \(methodDescription)
        • Use clean, sharp tools
        • Dispose of diseased material properly
        """
    }
    


    
    private func countPlantsOfType(plantId: String) -> Int {
        guard let site = userPlant?.siteID, let createdAt = userPlant?.createdAt else { return 1 }
        let plantsInSite = PlantStore.shared.plants(for: site)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: createdAt)
        
        return plantsInSite.filter { 
            $0.plantId == plantId && 
            formatter.string(from: $0.createdAt) == dateKey 
        }.count
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
        //  Use plant name from JSON
        if let plant = plantData {
            title = plant.plantName
        } else {
            title = "Plant Details"
        }
        navigationController?.navigationBar.prefersLargeTitles = false

        // ✏️ Edit button in nav bar
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Edit Questionnaire
    @objc private func editButtonTapped() {
        guard let userPlant = userPlant else { return }

        // Build a session from existing UserPlant data
        var session = PlantQuestionSession(plantId: userPlant.plantId)
        session.isEditMode = true
        
        // 📦 Batch Tracking
        let currentBatchSize = countPlantsOfType(plantId: userPlant.plantId)
        session.originalBatchSize = currentBatchSize
        session.plantCount = currentBatchSize
        session.editingBatchSiteID = userPlant.siteID
        session.editingBatchCreatedAt = userPlant.createdAt
        
        session.siteName = userPlant.siteName
        session.plantLight = userPlant.lightRequirement
        session.wateringAnswer = userPlant.watering
        session.repottingAnswer = userPlant.repotting
        session.imageData = userPlant.imageData
        session.lastWateredDate = userPlant.lastWatered
        session.lastRepottedDate = userPlant.lastRepotted
        session.lastPrunedDate = userPlant.lastPruned
        session.lastFertilizedDate = userPlant.lastFertilized

        // Find the site icon from SiteStore
        if let site = SiteStore.shared.sites.first(where: { $0.id == userPlant.siteID }) {
            session.siteIcon = site.icon
        }

        // Open questionnaire from AddPlant storyboard
        let storyboard = UIStoryboard(name: "AddPlant", bundle: nil)
        if let siteVC = storyboard.instantiateViewController(withIdentifier: "PlantSiteView") as? PlantSiteViewController {
            siteVC.session = session
            siteVC.plantId = userPlant.plantId
            navigationController?.pushViewController(siteVC, animated: true)
        }
    }

    private func setupCollectionView() {
        guard collectionView != nil else { return }
        collectionView.register(
            UINib(nibName: "DeletePlantFooterView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "DeleteFooter"
        )
        // Register all cells
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil),
                               forCellWithReuseIdentifier: "HeroImageCell")
        collectionView.register(UINib(nibName: "StatCardCell", bundle: nil),
                               forCellWithReuseIdentifier: "StatCardCell")
        collectionView.register(UINib(nibName: "CareTaskCell1", bundle: nil),
                               forCellWithReuseIdentifier: "CareTaskCell1")
        
        // Register headers
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil),
                               forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                               withReuseIdentifier: "SectionHeaderView")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        // Only show footer on the last section
        if section == Section.careGuide.rawValue {
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
        return .zero
    }
    
    private func showDeleteOptions() {
        guard let userPlant = userPlant else { return }
        
        let count = countPlantsOfType(plantId: userPlant.plantId)
        
        //  Only 1 plant — show simple confirmation instead of action sheet
        if count == 1 {
            let alert = UIAlertController(title: "Remove Plant", message: "Are you sure you want to remove this plant?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                PlantStore.shared.removePlant(by: userPlant.id)
                if let index = SiteStore.shared.sites.firstIndex(where: { $0.id == userPlant.siteID }) {
                    SiteStore.shared.sites[index].plantCount = PlantStore.shared.plants(for: userPlant.siteID).count
                }
                self?.navigationController?.popViewController(animated: true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        //  Multiple plants — show action sheet with options
        let alert = UIAlertController(title: "Remove Plant", message: "Choose an action", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove 1 Plant", style: .default) { [weak self] _ in
            PlantStore.shared.removePlant(by: userPlant.id)
            if let index = SiteStore.shared.sites.firstIndex(where: { $0.id == userPlant.siteID }) {
                SiteStore.shared.sites[index].plantCount = PlantStore.shared.plants(for: userPlant.siteID).count
            }
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Remove All (\(count))", style: .destructive) { [weak self, count] _ in
            PlantStore.shared.removeAllPlants(plantId: userPlant.plantId, siteID: userPlant.siteID)
            if let index = SiteStore.shared.sites.firstIndex(where: { $0.id == userPlant.siteID }) {
                SiteStore.shared.sites[index].plantCount = PlantStore.shared.plants(for: userPlant.siteID).count
            }
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(100))
        
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
        section.boundarySupplementaryItems = [header, footer]
        
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
            
            //  Priority: User's custom photo > JSON image > System icon
            if let data = userPlant?.imageData, let customImage = UIImage(data: data) {
                cell.plantImageView.image = customImage
            } else if let plant = plantData, let assetImage = UIImage(named: plant.imageName) {
                cell.plantImageView.image = assetImage
            } else {
                cell.plantImageView.image = UIImage(systemName: "leaf.fill")
                cell.plantImageView.tintColor = .systemGreen
            }
            return cell
            
        case .stats:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatCardCell", for: indexPath) as! StatCardCell
            let stat = statsData[indexPath.item]
            cell.configure(icon: stat.icon, title: stat.title, value: stat.value, color: stat.color)
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
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeleteFooter", for: indexPath) as! DeletePlantFooterView
            
            footer.onDeleteTapped = { [weak self] in
                self?.showDeleteOptions()
            }
            return footer
        }
        
        
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
}
