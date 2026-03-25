
import UIKit

class PlantIdentificationResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Data (injected after storyboard instantiation)
    var plantImage: UIImage!
    var suggestions: [PlantSuggestion]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gradientLayer = CAGradientLayer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBotanicalBackground()
        setupBackButton()
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupBackButton() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 20
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(blurView)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            blurView.widthAnchor.constraint(equalToConstant: 40),
            blurView.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: blurView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.bringSubviewToFront(blurView)
        view.bringSubviewToFront(backButton)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // Register XIB cells
        collectionView.register(UINib(nibName: "PlantResultHeroCell", bundle: nil), forCellWithReuseIdentifier: "PlantResultHeroCell")
        collectionView.register(UINib(nibName: "PlantResultInfoCell", bundle: nil), forCellWithReuseIdentifier: "PlantResultInfoCell")
        collectionView.register(UINib(nibName: "PlantResultButtonCell", bundle: nil), forCellWithReuseIdentifier: "PlantResultButtonCell")
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: - Compositional Layout (mirrors PlantDetailViewController)
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let spacing: CGFloat = 16
            
            switch sectionIndex {
            case 0: // Hero Image
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item]))
                section.contentInsets = .init(top: 10, leading: spacing, bottom: 20, trailing: spacing)
                return section
                
            case 1, 2, 3, 4: // Info Cards (about, description, taxonomy, other matches)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 20, trailing: spacing)
                return section
                
            default: // Button
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 20, trailing: spacing)
                return section
            }
        }
    }
    
    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6 // hero, about, description, taxonomy, other matches, button
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let topSuggestion = suggestions.first else { return 0 }
        
        switch section {
        case 0: return 1 // hero
        case 1: return 1 // about (name + confidence)
        case 2: return 1 // description
        case 3: // taxonomy
            return topSuggestion.plantDetails?.taxonomy != nil ? 1 : 0
        case 4: // other matches
            return suggestions.count > 1 ? 1 : 0
        case 5: return 1 // button
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let topSuggestion = suggestions.first else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0: // Hero Image
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultHeroCell", for: indexPath) as! PlantResultHeroCell
            cell.configure(with: plantImage)
            return cell
            
        case 1: // About (name, confidence, common names)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultInfoCell", for: indexPath) as! PlantResultInfoCell
            let commonNames = topSuggestion.plantDetails?.commonNames?.joined(separator: ", ")
            cell.configureAbout(
                name: topSuggestion.plantName,
                confidence: Int(topSuggestion.probability * 100),
                commonNames: commonNames
            )
            return cell
            
        case 2: // Description
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultInfoCell", for: indexPath) as! PlantResultInfoCell
            let text = topSuggestion.plantDetails?.description?.value ?? "No description available."
            cell.configureDescription(text: text)
            return cell
            
        case 3: // Taxonomy
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultInfoCell", for: indexPath) as! PlantResultInfoCell
            if let taxonomy = topSuggestion.plantDetails?.taxonomy {
                var rows: [(label: String, value: String)] = []
                if let family = taxonomy.family { rows.append((label: "Family", value: family)) }
                if let genus = taxonomy.genus { rows.append((label: "Genus", value: genus)) }
                if let cls = taxonomy.class { rows.append((label: "Class", value: cls)) }
                cell.configureTaxonomy(rows: rows)
            }
            return cell
            
        case 4: // Other Matches
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultInfoCell", for: indexPath) as! PlantResultInfoCell
            let otherSuggestions = Array(suggestions.dropFirst().prefix(3))
            cell.configureOtherMatches(suggestions: otherSuggestions)
            return cell
            
        case 5: // Button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantResultButtonCell", for: indexPath) as! PlantResultButtonCell
            cell.configure(title: "Go to Plant")
            cell.onTap = { [weak self] in
                self?.goToPlantTapped()
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    // MARK: - Actions
    private func goToPlantTapped() {
        guard let topSuggestion = suggestions.first else {
            showPlantNotFoundAlert()
            return
        }
        
        let allPlants = PlantCatalogueCache.shared.plants
        
        let mlName = topSuggestion.plantName.lowercased()
        let mlCommonNames = topSuggestion.plantDetails?.commonNames?.map { $0.lowercased() } ?? []
        let mlDescription = topSuggestion.plantDetails?.description?.value?.lowercased() ?? ""
        
        let matchingPlant = allPlants.first { plant in
            let catalogName = plant.plantName.lowercased()
            
            if catalogName == mlName || mlName.contains(catalogName) { return true }
            if mlCommonNames.contains(where: { $0.contains(catalogName) || catalogName.contains($0) }) { return true }
            if mlDescription.contains(catalogName) { return true }
            
            return false
        }
        
        if let foundPlant = matchingPlant {
            print("Plant found in Catalogue: \(foundPlant.plantName)")
            navigateToPlantDetail(plantId: foundPlant.plantId)
        } else {
            print("Plant not found in Catalogue: \(topSuggestion.plantName)")
            showPlantNotFoundAlert()
        }
    }
    
    private func navigateToPlantDetail(plantId: String) {
        dismiss(animated: true) { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantDetailVC = storyboard.instantiateViewController(withIdentifier: "PlantDetailViewController") as? PlantDetailViewController {
                plantDetailVC.plantId = plantId
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController as? UINavigationController {
                    rootVC.pushViewController(plantDetailVC, animated: true)
                } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let window = windowScene.windows.first,
                          let tabBarVC = window.rootViewController as? UITabBarController,
                          let navController = tabBarVC.selectedViewController as? UINavigationController {
                    navController.pushViewController(plantDetailVC, animated: true)
                }
            }
        }
    }
    
    private func showPlantNotFoundAlert() {
        let alert = UIAlertController(
            title: "Plant Not Available",
            message: "This plant is not currently in our database. We're continuously adding new plants!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.dismiss(animated: true)
                }
            }
        })
        
        present(alert, animated: true)
    }
}
