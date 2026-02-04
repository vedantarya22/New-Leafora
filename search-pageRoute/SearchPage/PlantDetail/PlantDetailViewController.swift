import UIKit

class PlantDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var plantId: String?
    var plants: [Plant] = []
    var currentPlant: Plant? { plants.first }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Pure white background
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
        
        let storyboard = UIStoryboard(name: "AddPlant", bundle: nil)
        if let addPlantVC = storyboard.instantiateInitialViewController() as? PlantSiteViewController {
            addPlantVC.plantId = plantId
            navigationController?.pushViewController(addPlantVC, animated: true)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil), forCellWithReuseIdentifier: "HeroImageCell")
        collectionView.register(UINib(nibName: "PlantInfoCardCell", bundle: nil), forCellWithReuseIdentifier: "PlantInfoCardCell")
        collectionView.register(UINib(nibName: "PlantActionButtonCell", bundle: nil), forCellWithReuseIdentifier: "PlantActionButtonCell")
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let spacing: CGFloat = 16
            
            switch sectionIndex {
            case 0: // Hero Image
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item]))
                section.contentInsets = .init(top: 10, leading: 16, bottom: 20, trailing: 16)
                return section
                
            case 1: // Merged About & Info
                // Increased estimated height and bottom inset to ensure shadow visibility
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(220))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 20, trailing: spacing)
                return section
                
            case 2, 3, 4: // Care, Soil, Issues
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 20, trailing: spacing)
                return section
                
            default: // AR Button
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
                section.contentInsets = .init(top: 10, leading: spacing, bottom: 40, trailing: spacing)
                return section
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6 // Image, Merged About, Care, Soil, Issues, Button
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return 1 }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let plant = currentPlant else { return UICollectionViewCell() }
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroImageCell", for: indexPath) as! HeroImageCell
            cell.plantImageView.image = UIImage(named: plant.imageName)
            return cell
            
        case 1: // Merged: About + Characteristics
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let petStatus = plant.petFriendly ? "Pet Friendly" : "Toxic to Pets"
            let combinedText = """
            \(plant.description)
            
            • Light: \(plant.lightRequired)
            • Difficulty: \(plant.careDifficulty.capitalized)
            • \(petStatus)
            """
            cell.configure(title: "About", text: combinedText, iconName: "info.circle.fill", iconColor: .systemBlue)
            return cell
            
        case 2: // Care Cycle
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            let careText = """
            • Water: \(plant.careCycle.watering.display)
            • Fertilizer: \(plant.careCycle.fertilizing.display)
            • Repotting: \(plant.careCycle.repotting.display)
            • Pruning: \(plant.careCycle.pruning.display)
            """

            cell.configure(
                title: "Care Cycle",
                text: careText,
                iconName: "drop.fill",
                iconColor: .systemCyan
            )

            return cell

            
        case 3: // Soil Type
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let soilText = "• Mix: \(plant.soilType.soilUsed)\n• Features: \(plant.soilType.characteristics)"
            cell.configure(title: "Soil Type", text: soilText, iconName: "circle.grid.cross.fill", iconColor: .systemBrown)
            return cell

        case 4: // Common Issues
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantInfoCardCell", for: indexPath) as! PlantInfoCardCell
            let issuesText = plant.commonIssues.map { "• \($0)" }.joined(separator: "\n")
            cell.configure(title: "Common Issues", text: issuesText, iconName: "exclamationmark.triangle.fill", iconColor: .systemOrange)
            return cell
            
        case 5: // AR Button
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
