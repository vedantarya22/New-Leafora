//
//  SiteDetailViewController.swift
//  PlantApp
//
//  Updated by AI Assistant on 05/02/26.
//

import UIKit

class SiteDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var gradientLayer = CAGradientLayer()
    @IBOutlet weak var collectionView: UICollectionView!
    
    var site: MyGardenSite?
    var userPlants: [UserPlant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        guard let site = site else {
            print("❌ No site data received")
            return
        }
        
        print("✅ SiteDetailViewController loaded for:", site.name)
        
        setupUI(with: site)
        loadPlantsForSite()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload plants when returning from detail view
        loadPlantsForSite()
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureGridLayout()
    }
    
    // MARK: - Setup
    
    private func setupUI(with site: MyGardenSite) {
        self.title = site.name
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cell
        let nib = UINib(nibName: "SearchPageCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: SearchPageCollectionViewCell.identifier)
        // Setup layout for 2 columns
        configureGridLayout()
    }
    
    private func configureGridLayout() {
        let itemSize = NSCollectionLayoutSize(
                  widthDimension: .fractionalWidth(1.0),
                  heightDimension: .estimated(130)
              )
               let item = NSCollectionLayoutItem(layoutSize: itemSize)
       
          // Group
              let groupSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                 heightDimension: itemSize.heightDimension
              )
              let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       
           // Section
              let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = -2.8 // Small standard gap between list items
      
               // Padding around the section content
              section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
      
              let layout = UICollectionViewCompositionalLayout(section: section)
              collectionView.collectionViewLayout = layout
    }
    
    private func loadPlantsForSite() {
        guard let siteID = site?.id else { return }
        
        // Use new grouping method
        let grouped = PlantStore.shared.groupedPlants(for: siteID)
        
        // Convert to display format
        userPlants = grouped.map { $0.plant }
        
        print("✅ Showing \(userPlants.count) plant types with total \(grouped.reduce(0) { $0 + $1.count }) plants")
        
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        if userPlants.isEmpty {
            // Show empty state
            let emptyLabel = UILabel()
            emptyLabel.text = "No plants added yet"
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.textColor = .systemGray
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            
            collectionView.backgroundView = emptyLabel
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchPageCollectionViewCell.identifier,
            for: indexPath
        ) as? SearchPageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let userPlant = userPlants[indexPath.item]
        
        // Configure cell with user plant data (this loads plant details from JSON)
        cell.configure(userPlant: userPlant)
        
        // Check if there are multiple plants of the same type in this site
        let allPlantsInSite = PlantStore.shared.plants(for: site!.id)
        let sameTypePlants = allPlantsInSite.filter { $0.plantId == userPlant.plantId }
        
        // If multiple plants of same type, show count in the label
        if sameTypePlants.count > 1 {
            let allPlants = JSONLoader.loadPlants(from: "plantData")
            if let plantName = allPlants.first(where: { $0.plantId == userPlant.plantId })?.plantName {
                cell.plantLabel.text = "\(plantName) (×\(sameTypePlants.count))"
            }
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUserPlant = userPlants[indexPath.item]
        
        print("✅ Tapped plant:", selectedUserPlant.plantId)
        
        // Navigate to NEW plant detail view
        navigateToPlantDetail(for: selectedUserPlant)
    }
    
    // MARK: - Navigation
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
    
    private func navigateToPlantDetail(for userPlant: UserPlant) {
        let storyboard = UIStoryboard(name: "MyGarden", bundle: nil)
         let detailVC = storyboard.instantiateViewController(withIdentifier: "PlantDetailViewController_New") as! PlantDetailViewController_New
         
         detailVC.userPlant = userPlant
         
         // Hide tab bar when pushing
         detailVC.hidesBottomBarWhenPushed = true
         
         navigationController?.pushViewController(detailVC, animated: true)
         
         print("✅ Navigating to PlantDetailViewController")
    }
}
