//
//  SiteDetailViewController.swift
//  PlantApp
//
//  Updated by AI Assistant on 05/02/26.
//

import UIKit

class SiteDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var site: MyGardenSite?
    var userPlants: [UserPlant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        collectionView.register(
            UINib(nibName: "SiteDetailCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SiteDetailCell"
        )
        
        // Setup layout for 2 columns
        configureGridLayout()
    }
    
    private func configureGridLayout() {
        let layout = UICollectionViewFlowLayout()
        
        let spacing: CGFloat = 16
        let columns: CGFloat = 2
        let horizontalPadding: CGFloat = 16
        
        let totalSpacing = (columns - 1) * spacing + (horizontalPadding * 2)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let itemWidth = floor(availableWidth / columns)
        
        // Adjust height to your card design (image + label)
        let itemHeight: CGFloat = itemWidth + 30 // Image square + label space
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: horizontalPadding, bottom: 16, right: horizontalPadding)
        
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SiteDetailCell",
            for: indexPath
        ) as! SiteDetailCollectionViewCell
        
        let userPlant = userPlants[indexPath.item]
        
        let allPlantsInSite = PlantStore.shared.plants(for: site!.id)
        let sameTypePlants = allPlantsInSite.filter { $0.plantId == userPlant.plantId }
        
        // Configure cell with user plant data
        cell.configure(userPlant: userPlant)
        
        if sameTypePlants.count > 1 {
            let allPlants = JSONLoader.loadPlants(from: "plantData")
            let plantName = allPlants.first(where: { $0.plantId == userPlant.plantId })?.plantName ?? "Unknown"
            cell.nameLabel.text = "\(plantName) (×\(sameTypePlants.count))"
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
    
    private func navigateToPlantDetail(for userPlant: UserPlant) {
        let detailVC = PlantDetailViewController1()
        detailVC.userPlant = userPlant
        
        // Hide tab bar when pushing
        detailVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailVC, animated: true)
        
        print("✅ Navigating to PlantDetailViewController")
    }
}
