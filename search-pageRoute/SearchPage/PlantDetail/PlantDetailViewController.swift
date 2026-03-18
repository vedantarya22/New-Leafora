import UIKit
import SDWebImage

class PlantDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var plantId: String?
    var plants: [Plant] = []
    var currentPlant: Plant? { plants.first }
    var gradientLayer = CAGradientLayer()
    var onTap: (() -> Void)?
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
    @IBAction func buttonTapped(_ sender: UIButton) {
        onTap?()
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
        if let addPlantVC = storyboard.instantiateViewController(withIdentifier: "PlantSiteView") as? PlantSiteViewController {
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
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(350))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: spacing, bottom: 20, trailing: spacing)
                return section
                
            case 2, 3, 4: // Care, Soil, Issues
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(280))
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
//            cell.plantImageView.image = UIImage(named: plant.imageName)
            if let url = URL(string: plant.imageName) {
                   cell.plantImageView.sd_setImage(
                       with: url,
                       placeholderImage: UIImage(systemName: "leaf.fill")
                   )
               }
            return cell
            
        case 1: // About
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            let petStatus = plant.petFriendly ? "Pet Friendly" : "Toxic to Pets"

            cell.configureAbout(
                description: plant.description,
                light: plant.lightRequirement.displayName,
                difficulty: plant.difficulty.displayName,
                petStatus: petStatus,
                isPetFriendly: plant.petFriendly
            )

            return cell

        case 2: // Care Cycle
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            cell.configureDetailRows(
                title: "Care Cycle",
                iconName: "arrow.2.circlepath",
                iconColor: .systemCyan,
                rows: [
                    (icon: "drop.fill",             label: "Water",      value: plant.careCycle.watering.display),
                    (icon: "leaf.fill",             label: "Fertilizer", value: plant.careCycle.fertilizing.display),
                    (icon: "arrow.up.bin.fill",           label: "Repotting",  value: plant.careCycle.repotting.display),
                    (icon: "scissors",              label: "Pruning",    value: plant.careCycle.pruning.display)
                ]
            )

            return cell

        case 3: // Soil Type
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            cell.configureDetailRows(
                title: "Soil Type",
                iconName: "circle.grid.cross.fill",
                iconColor: .systemBrown,
                rows: [
                    (icon: "bag.fill", label: "Mix",      value: plant.soilType.soilUsed),
                    (icon: "star.fill",            label: "Features", value: plant.soilType.characteristics)
                ]
            )

            return cell

        case 4: // Common Issues
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantInfoCardCell",
                for: indexPath
            ) as! PlantInfoCardCell

            cell.configureIssueList(
                title: "Common Issues",
                issues: plant.commonIssues
            )

            return cell
            
        case 5: // AR Button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantActionButtonCell", for: indexPath) as! PlantActionButtonCell
            cell.configure(type: .visualizeAR)
            cell.onTap = { [weak self] in
                    self?.navigateToAR()
                }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func loadSpecificPlant() {
       
        
        PlantCatalogueCache.shared.getPlants { [weak self] plants in
            guard let self = self else { return }
            
            print(" Cache has \(plants.count) plants")
            
            if let found = plants.first(where: { $0.plantId == self.plantId }) {
                print("✅ Found plant: \(found.plantName)")
                print("🖼️ Image URL: \(found.imageName)")
                print("💡 Light: \(found.lightRequirement.displayName)")
                print("🌱 Difficulty: \(found.difficulty.displayName)")
                self.plants = [found]
            } else {
                print("⚠️ Plant not found, loading first plant as fallback")
                self.plants = [plants[0]]
            }
            
            self.title = self.currentPlant?.plantName
            self.collectionView.reloadData()
        }
    }
}
