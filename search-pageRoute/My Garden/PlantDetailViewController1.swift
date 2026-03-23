import UIKit
import SDWebImage

class PlantDetailViewController_New: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var userPlant: UserPlant?
    var plantImage: UIImage?
    
    private var expandedCareIndex: IndexPath?
    let gradientLayer = CAGradientLayer()
    
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
    
    private var statsData: [(icon: String, title: String, value: String, color: UIColor)] = []
    private var careItems: [(icon: String, title: String, steps: String, color: UIColor)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        gradientLayer.frame = view.bounds
        collectionView.backgroundColor = .clear
        loadPlantData()
        setupCollectionView()
        collectionView.backgroundView = nil
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let plantID = userPlant?.id,
           let updated = PlantStore.shared.getPlant(by: plantID) {
            userPlant = updated
            loadPlantData()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Load Plant Data
    private func loadPlantData() {
        let allPlants = PlantCatalogueCache.shared.plants
        
        guard let userPlant = userPlant else {
            print("⚠️ No userPlant provided")
            return
        }
        
        // ✅ Match by mongoId — userPlant.plantId stores MongoDB ObjectId
        plantData = allPlants.first(where: { $0.mongoId == userPlant.plantId })
        
        guard let plant = plantData else {
            print("⚠️ Could not find plant data for plantId: \(userPlant.plantId)")
            return
        }
        
        print("✅ Loaded plant data for: \(plant.plantName)")
        
        let count = countPlantsOfType(plantId: userPlant.plantId)
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, yyyy"
        let dateStr = displayFormatter.string(from: userPlant.createdAt)

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
             value: plant.difficulty.displayName,
             color: UIColor.systemGreen),
            
            (icon: "calendar",
             title: "Date Added",
             value: dateStr,
             color: UIColor.systemTeal)
        ]
        
        careItems = [
            (icon: "drop.fill",         title: "Watering",    steps: buildWateringSteps(from: plant),    color: UIColor(red: 0.42, green: 0.71, blue: 0.84, alpha: 1.0)),
            (icon: "leaf.fill",          title: "Fertilizing", steps: buildFertilizingSteps(from: plant), color: UIColor(red: 0.52, green: 0.71, blue: 0.42, alpha: 1.0)),
            (icon: "arrow.up.bin.fill",  title: "Repotting",   steps: buildRepottingSteps(from: plant),  color: UIColor(red: 0.85, green: 0.65, blue: 0.38, alpha: 1.0)),
            (icon: "scissors",           title: "Pruning",     steps: buildPruningSteps(from: plant),     color: UIColor(red: 0.82, green: 0.47, blue: 0.38, alpha: 1.0))
        ]
    }

    // MARK: - Build Care Steps
    private func buildWateringSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.watering.display
        if let steps = plant.careCycle.watering.steps {
            return "Schedule: \(schedule)\n\n" + steps.map { "• \($0)" }.joined(separator: "\n")
        }
        let method = plant.careCycle.watering.method ?? "moderate"
        let methodDescription: String
        switch method.lowercased() {
        case "spray":    methodDescription = "• Use spray bottle for misting\n• Keep leaves lightly moist"
        case "light":    methodDescription = "• Water lightly around the base\n• Avoid overwatering"
        case "deep":     methodDescription = "• Deep soak until water drains freely\n• Ensure soil is fully saturated"
        case "bottom":   methodDescription = "• Place pot in water tray\n• Let roots absorb from bottom"
        default:         methodDescription = "• Water thoroughly until it drains\n• Allow soil to dry between waterings"
        }
        return "Schedule: \(schedule)\n\n\(methodDescription)\n• Check soil moisture before watering\n• Reduce watering in winter months"
    }

    private func buildFertilizingSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.fertilizing.display
        if let steps = plant.careCycle.fertilizing.steps {
            return "Schedule: \(schedule)\n\n" + steps.map { "• \($0)" }.joined(separator: "\n")
        }
        let method = plant.careCycle.fertilizing.method ?? "balanced"
        let methodDescription: String
        switch method.lowercased() {
        case "light":    methodDescription = "• Use diluted liquid fertilizer\n• Apply at 1/4 strength"
        case "heavy":    methodDescription = "• Use full-strength fertilizer\n• Heavy feeders need regular feeding"
        case "organic":  methodDescription = "• Use organic compost or worm castings\n• Apply as top dressing"
        default:         methodDescription = "• Use balanced liquid fertilizer\n• Apply at recommended strength"
        }
        return "Schedule: \(schedule)\n\n\(methodDescription)\n• Apply during growing season (spring/summer)\n• Reduce or skip in winter"
    }

    private func buildRepottingSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.repotting.display
        if let steps = plant.careCycle.repotting.steps {
            return "Schedule: \(schedule)\n\n" + steps.map { "• \($0)" }.joined(separator: "\n")
        }
        let method = plant.careCycle.repotting.method ?? "refresh"
        let methodDescription: String
        switch method.lowercased() {
        case "check":    methodDescription = "• Check if roots are crowding\n• Look for roots growing through drainage holes"
        case "upgrade":  methodDescription = "• Use pot 2\" larger than current\n• Ensure good drainage"
        case "division": methodDescription = "• Divide root ball into sections\n• Plant each division separately"
        default:         methodDescription = "• Replace old soil with fresh mix\n• Can use same size pot"
        }
        return "Schedule: \(schedule)\n\n\(methodDescription)\n• Use well-draining soil mix\n• Best done in spring season"
    }

    private func buildPruningSteps(from plant: Plant) -> String {
        let schedule = plant.careCycle.pruning.display
        if let steps = plant.careCycle.pruning.steps {
            return "Schedule: \(schedule)\n\n" + steps.map { "• \($0)" }.joined(separator: "\n")
        }
        let method = plant.careCycle.pruning.method ?? "trim"
        let methodDescription: String
        switch method.lowercased() {
        case "shape":  methodDescription = "• Shape to maintain desired form\n• Cut above leaf nodes"
        case "heavy":  methodDescription = "• Cut back significantly for renewal\n• Remove up to 1/3 of growth"
        case "pinch":  methodDescription = "• Pinch back growing tips\n• Encourages bushier growth"
        default:       methodDescription = "• Remove dead or brown leaves\n• Light maintenance trimming"
        }
        return "Schedule: \(schedule)\n\n\(methodDescription)\n• Use clean, sharp tools\n• Dispose of diseased material properly"
    }

    // MARK: - Count Plants
    private func countPlantsOfType(plantId: String) -> Int {
        guard let userPlant = userPlant else { return 1 }

        let plantsInSite: [UserPlant]
        if let mongoSiteId = userPlant.mongoSiteId {
            plantsInSite = PlantStore.shared.plants(forMongoSiteId: mongoSiteId)
        } else {
            plantsInSite = PlantStore.shared.plants(forSiteName: userPlant.siteName)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: userPlant.createdAt)

        return plantsInSite.filter {
            $0.plantId == plantId &&
            formatter.string(from: $0.createdAt) == dateKey
        }.count
    }
    
    // MARK: - Background
    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = plantData?.plantName ?? "Plant Details"
        navigationController?.navigationBar.prefersLargeTitles = false
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItem = editButton
    }

    // MARK: - Edit
    @objc private func editButtonTapped() {
        guard let userPlant = userPlant else { return }

        var session = PlantQuestionSession(plantId: userPlant.plantId)
        session.isEditMode = true
        
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

        if let site = SiteStore.shared.sites.first(where: { $0.id == userPlant.siteID }) {
            session.siteIcon = site.icon
        }

        let storyboard = UIStoryboard(name: "AddPlant", bundle: nil)
        if let siteVC = storyboard.instantiateViewController(withIdentifier: "PlantSiteView") as? PlantSiteViewController {
            siteVC.session = session
            siteVC.plantId = userPlant.plantId
            navigationController?.pushViewController(siteVC, animated: true)
        }
    }

    // MARK: - Collection View Setup
    private func setupCollectionView() {
        guard collectionView != nil else { return }
        collectionView.register(UINib(nibName: "DeletePlantFooterView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "DeleteFooter")
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil),    forCellWithReuseIdentifier: "HeroImageCell")
        collectionView.register(UINib(nibName: "StatCardCell", bundle: nil),     forCellWithReuseIdentifier: "StatCardCell")
        collectionView.register(UINib(nibName: "CareTaskCell1", bundle: nil),    forCellWithReuseIdentifier: "CareTaskCell1")
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeaderView")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return section == Section.careGuide.rawValue ? CGSize(width: collectionView.bounds.width, height: 100) : .zero
    }
    
    // MARK: - Delete Options
    private func showDeleteOptions() {
        guard let userPlant = userPlant else { return }
        let count = countPlantsOfType(plantId: userPlant.plantId)
        
        if count == 1 {
            let alert = UIAlertController(title: "Remove Plant", message: "Are you sure you want to remove this plant?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
                guard let mongoId = userPlant.mongoId else { return }
                NetworkManager.shared.removePlant(mongoId: mongoId) { success in
                    guard success else { print("❌ Failed to delete plant"); return }
                    PlantStore.shared.removePlant(by: userPlant.id)
                    DispatchQueue.main.async { self?.navigationController?.popViewController(animated: true) }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        } else {
            let alert = UIAlertController(title: "Remove Plant", message: "Choose an action", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remove 1 Plant", style: .default) { [weak self] _ in
                guard let mongoId = userPlant.mongoId else { return }
                NetworkManager.shared.removePlant(mongoId: mongoId) { success in
                    guard success else { print("❌ Failed to delete plant"); return }
                    PlantStore.shared.removePlant(by: userPlant.id)
                    DispatchQueue.main.async { self?.navigationController?.popViewController(animated: true) }
                }
            })
            alert.addAction(UIAlertAction(title: "Remove All (\(count))", style: .destructive) { [weak self] _ in
                guard let mongoSiteId = userPlant.mongoSiteId else { return }
                NetworkManager.shared.removeAllPlantsOfType(plantId: userPlant.plantId, siteId: mongoSiteId) { success in
                    guard success else { print("❌ Failed to delete all plants"); return }
                    PlantStore.shared.removeAllPlants(plantId: userPlant.plantId, siteName: userPlant.siteName)
                    DispatchQueue.main.async { self?.navigationController?.popViewController(animated: true) }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] (sectionIndex, _) -> NSCollectionLayoutSection? in
            guard let self = self, let sectionType = Section(rawValue: sectionIndex) else { return nil }
            switch sectionType {
            case .hero:      return self.createHeroSection()
            case .stats:     return self.createStatsSection()
            case .careGuide: return self.createCareGuideSection()
            }
        }
    }
    
    private func createHeroSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.4)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    private func createStatsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(100)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 24, trailing: 8)
        return section
    }
    
    private func createCareGuideSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 32, trailing: 16)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)),
            elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100)),
            elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
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
        case .hero:      return 1
        case .stats:     return statsData.count
        case .careGuide: return careItems.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionType {
        case .hero:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroImageCell", for: indexPath) as! HeroImageCell
            if let data = userPlant?.imageData, let customImage = UIImage(data: data) {
                cell.plantImageView.image = customImage
            } else if let urlString = userPlant?.imageUrl, let url = URL(string: urlString) {
                // ✅ Cloudinary URL from userPlant
                cell.plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill"))
            } else if let plant = plantData, let url = URL(string: plant.imageName) {
                // ✅ Fallback to catalogue image
                cell.plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill"))
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
            cell.configure(icon: item.icon, title: item.title, steps: item.steps, isExpanded: expandedCareIndex == indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DeleteFooter", for: indexPath) as! DeletePlantFooterView
            footer.onDeleteTapped = { [weak self] in self?.showDeleteOptions() }
            return footer
        }
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let sectionType = Section(rawValue: indexPath.section),
              !sectionType.title.isEmpty else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        header.titleLabel.text = sectionType.title
        return header
    }
}

// MARK: - Delegate
extension PlantDetailViewController_New: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionType = Section(rawValue: indexPath.section),
              sectionType == .careGuide else { return }
        toggleCareCard(at: indexPath)
    }
    
    private func toggleCareCard(at indexPath: IndexPath) {
        var indexPathsToReload: [IndexPath] = [indexPath]
        
        // If there's already an expanded card and it's different from the tapped one,
        // add it to the reload list so it collapses visually
        if let previouslyExpanded = expandedCareIndex, previouslyExpanded != indexPath {
            indexPathsToReload.append(previouslyExpanded)
        }
        
        // Toggle: collapse if tapping same card, expand if new card
        expandedCareIndex = (expandedCareIndex == indexPath) ? nil : indexPath
        
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: indexPathsToReload)
        }, completion: { _ in
            if let expanded = self.expandedCareIndex {
                self.collectionView.scrollToItem(at: expanded, at: .centeredVertically, animated: true)
            }
        })
    }
}
