import UIKit

class PlantDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var plantId: String?
    var plants: [Plant] = []
    var currentPlant: Plant? { plants.first }
    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Pure white background
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .clear
        setupBotanicalBackground()
        loadSpecificPlant()
        setupCollectionView()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        navigateToAddPlantQuestionnaire()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Section 5 is the AR Button section
            if indexPath.section == 5 {
                print("AR Button Tapped at section 5")
                navigateToAR()
            }
        }
    private func navigateToAR() {
        // If your storyboard file is named "Main.storyboard", use "Main"
        let storyboard = UIStoryboard(name: "ARlightmeter", bundle: nil)
        
        // This identifier MUST match the Storyboard ID you just typed in the inspector
        if let arVC = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ARViewController {
            arVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(arVC, animated: true)
        }
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
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let section = NSCollectionLayoutSection(group: NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]))
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
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
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            let petStatus = plant.petFriendly ? "Pet Friendly" : "Toxic to Pets"

            let combinedText = """
            \(plant.description)

            • Light: \(plant.lightRequirement.displayName)
            • Difficulty: \(plant.difficulty.displayName)
            • \(petStatus)
            """

            cell.configure(
                title: "About",
                text: combinedText,
                iconName: "info.circle.fill",
                iconColor: .systemBlue
            )

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
