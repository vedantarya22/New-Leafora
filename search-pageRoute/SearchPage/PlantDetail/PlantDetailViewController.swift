import UIKit

class PlantDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var plantId: String?
    var plants: [Plant] = []
    var currentPlant: Plant? { plants.first }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .clear
        
        loadSpecificPlant()
        setupCollectionView()
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        navigateToAddPlantQuestionnaire()
       
    }
    
    
    
    
    func navigateToAddPlantQuestionnaire() {
        guard let plantId = currentPlant?.plantId else {
            print("❌ No plant ID available")
            return
        }
        
        // Instantiate the AddPlant storyboard
        let storyboard = UIStoryboard(name: "AddPlant", bundle: nil)
        
        // Get the initial view controller
        if let addPlantVC = storyboard.instantiateInitialViewController() as? PlantSiteViewController {
            
            // Pass the plant ID
            addPlantVC.plantId = plantId
            
            // Navigate
            navigationController?.pushViewController(addPlantVC, animated: true)
            
            print("✅ Navigating to Add Plant Questionnaire with Plant ID: \(plantId)")
        } else {
            print("❌ Could not instantiate AddPlant storyboard")
        }
    }
    
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register all cells
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil), forCellWithReuseIdentifier: "HeroImageCell")
        collectionView.register(UINib(nibName: "PlantInfoCardCell", bundle: nil), forCellWithReuseIdentifier: "PlantInfoCardCell")
        collectionView.register(UINib(nibName: "PlantActionButtonCell", bundle: nil), forCellWithReuseIdentifier: "PlantActionButtonCell")
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let spacing: CGFloat = 16
            
            switch sectionIndex {
            case 0: // 1. Hero Image Frame
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item]))
                section.contentInsets = .init(top: 10, leading: 16, bottom: 20, trailing: 16)
                return section
                
            case 1, 2, 3, 4, 5: // 2. All Info Cards (About, Char, Care, Soil, Issues)
                // We use fractionalWidth(1.0) here to make the About card and others "big"
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 12, trailing: spacing)
                return section
                
            default: // 6. Action Button
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
                section.contentInsets = .init(top: 20, leading: spacing, bottom: 40, trailing: spacing)
                return section
            }
        }
    }

    // UPDATED: Return 7 sections (Image + 5 Cards + Button)
    func numberOfSections(in collectionView: UICollectionView) -> Int { return 7 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let plant = currentPlant else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0: // Hero Image
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroImageCell", for: indexPath) as! HeroImageCell
            cell.configure(with: plant)
            return cell
            
        case 1: // About
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            cell.configure(title: "About", text: plant.description, iconName: "info.circle.fill", iconColor: .systemBlue)
            return cell
            
        case 2: // Characteristics
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let petStatus = plant.petFriendly ? "Pet Friendly" : "Toxic to Pets"
            let charText = "• Light: \(plant.lightRequired)\n• Difficulty: \(plant.careDifficulty.capitalized)\n• \(petStatus)"
            cell.configure(title: "Characteristics", text: charText, iconName: "leaf.fill", iconColor: .systemGreen)
            return cell
            
        case 3: // Care Cycle
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let careText = "• Water: \(plant.careCycle.watering)\n• Fertilizer: \(plant.careCycle.fertilizing)\n• Repotting: \(plant.careCycle.repotting)"
            cell.configure(title: "Care Cycle", text: careText, iconName: "drop.fill", iconColor: .systemCyan)
            return cell
            
        case 4: // Soil Type
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let soilText = "• Mix: \(plant.soilType.soilUsed)\n• Features: \(plant.soilType.characteristics)"
            cell.configure(title: "Soil Type", text: soilText, iconName: "circle.grid.cross.fill", iconColor: .systemBrown)
            return cell
            
        case 5: // Common Issues
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let issuesText = plant.commonIssues.map { "• \($0)" }.joined(separator: "\n")
            cell.configure(title: "Common Issues", text: issuesText, iconName: "exclamationmark.triangle.fill", iconColor: .systemOrange)
            return cell
            
        case 6: // AR Button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantActionButtonCell", for: indexPath) as! PlantActionButtonCell
            cell.configure(type: .visualizeAR)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func loadSpecificPlant() {
        let allPlants = JSONLoader.loadPlants(from: "plantData")
        self.plants = [allPlants.first(where: { $0.plantId == plantId }) ?? allPlants[0]]
        self.title = currentPlant?.plantName
        collectionView.reloadData()
    }
}
