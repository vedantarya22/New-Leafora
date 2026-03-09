//
//  SearchViewController.swift
//  SearchPage
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - UI Components

    // Custom Search Bar (Fixed at top)
    private let searchBar = UISearchBar()
    
    // Filter Button (Fixed at top)
    private let filterButton = UIButton()

    // Collection View
    private var collectionView: UICollectionView!
    
    // Background Gradient Layer
    private let gradientLayer = CAGradientLayer()

    // MARK: - Lifecycle

    // MARK: - Data Properties
//
//    private let dataProvider = JSONLoader()
    private var allPlants: [Plant] = []
    private var filteredPlants: [Plant] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        //view.backgroundColor = .systemBackground
        
        setupUI()
//        setupGradient() // Add gradient
        setupFixedHeaderAndCollectionView()
        
        loadData()
        
        // Optional: Dismiss keyboard on tap outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
//    private func setupGradient() {
//        // 1. Define the Colors
//        let topColor = UIColor(red: 0.80, green: 0.93, blue: 0.80, alpha: 1.0).cgColor
//        let bottomColor = UIColor.white.cgColor
//
//        // 2. Setup the Layer
//        gradientLayer.colors = [topColor, bottomColor]
//        gradientLayer.locations = [0.0, 0.6] // Green stops at 60%, rest is white
//        gradientLayer.frame = view.bounds
//
//        // 3. Add it behind everything
//        view.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    private func loadData() {
        PlantCatalogueCache.shared.getPlants { [weak self] plants in
            guard let self = self else { return }
            self.allPlants = plants
            self.filteredPlants = plants
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    
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
    
    
    private func setupUI() {
        // Configure Search Bar
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage() // Remove background
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        let searchTextField = searchBar.searchTextField
        searchTextField.backgroundColor = .systemGray6 // Light gray
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        
        // Configure Filter Button
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "slider.horizontal.3")
        config.baseForegroundColor = .label
        
        filterButton.configuration = config
        filterButton.addTarget(self, action: #selector(didTapFilter), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Collection View
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register Cell
        let nib = UINib(nibName: "SearchPageCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: SearchPageCollectionViewCell.identifier)
    }
    
    // MARK: - Layout Generator (User Provided)
    
    private func createLayout() -> UICollectionViewLayout {
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
        section.interGroupSpacing = -2.8// Small standard gap between list items
        
        // Padding around the section content
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupFixedHeaderAndCollectionView() {
        // Add Subviews
        view.addSubview(searchBar)
        view.addSubview(filterButton)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            // 1. Search Bar (Top Left)
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // 2. Filter Button (Top Right)
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44), // Adjusted for icon only
            
            // Pin Search Bar trailing to Filter Button leading
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: 6),
            
            // 3. Collection View (Below Header)
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20), // Gap below search bar
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // 1. Get the correct plant from the UI-backed array
        let selectedPlant = filteredPlants[indexPath.row]
          print(" Tapped: \(selectedPlant.plantName)")
          print("PlantId: \(selectedPlant.plantId)")
          navigateToPlantDetail(with: selectedPlant.plantId)
        
    
    }
    
    private func navigateToPlantDetail(with plantId: String) {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let detailVC = storyboard.instantiateViewController(
                withIdentifier: "PlantDetailViewController"
            ) as? PlantDetailViewController {

                // CORRECT WAY:
                // Pass the ID string. Let the Detail VC handle the loading/filtering.
                detailVC.plantId = plantId
                
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }

    
    // MARK: - Actions
    
    @objc func didTapFilter() {
        print("Opening Filter Modal...")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let filterVC = storyboard.instantiateViewController(withIdentifier: "CategoriesViewController") as? categoriesViewController {
            
            // Inject Data: Get dynamic categories from the data provider
            // filterVC.categories = dataProvider.getAllCategories() // No longer needed as CategoryVC has static list
            
            // Set selection handler
            filterVC.selectionHandler = { [weak self] selectedCategory in
                guard let self = self else { return }
                self.applyFilter(category: selectedCategory)
            }
            
            present(filterVC, animated: true)
        } else {
            print("Error: Could not instantiate CategoriesViewController. Check Storyboard ID.")
        }
    }
    
    // MARK: - Filter Logic
    
    // MARK: - Filter Logic
    
    private func applyFilter(category: String) {
        print("Applying filter for category: \(category)")
        
        if category == "recommended_plant" {
            // ---------------------------------------------------------
            // RECOMMENDED PLANTS LOGIC
            // ---------------------------------------------------------
            
            // 1. Check if preferences are set (Safety check)
            if !HomeDataStore.shared.arePreferencesSet() {
                // Clear the list just in case, but no alert (handled by modal)
                filteredPlants = []
                collectionView.reloadData()
                return 
            }
            
            if let cachedIDs = RecommendedPlantsCache.shared.get() {
                print("✨ Loading \(cachedIDs.count) recommended plants from cache.")
                
                let plantsMap = Dictionary(uniqueKeysWithValues: allPlants.map { ($0.plantId, $0) })
                filteredPlants = cachedIDs.compactMap { plantsMap[$0] }
                
            } else {
                print("⚠️ No recommended plants in cache (but prefs set). Triggering engine or showing empty.")
                // If prefs are set but no cache (e.g. migration), we could trigger engine here or show empty.
                // For now showing empty as per safety rules (no engine in UI).
                filteredPlants = [] 
            }
            
        } else if category == "all_plants" || category == "all" { // Assuming 'all' or similar key exists
             filteredPlants = allPlants
        } else {
            // Basic filtering logic: Check if the plant's category array contains the selected category
            filteredPlants = allPlants.filter { plant in
                plant.category.contains(where: { $0.caseInsensitiveCompare(category) == .orderedSame })
            }
        }
        
        // If no results (or "All"), maybe reset? For now strict filtering.
        // If you want "All" to reset, handle that case.
        // Assuming strict filter for now.
        
        collectionView.reloadData()
    }
    
    // MARK: - Search Logic
    
    func filterContentForSearchText(_ searchText: String) {
        if searchText.isEmpty {
            filteredPlants = allPlants
        } else {
            filteredPlants = allPlants.filter { (plant: Plant) -> Bool in
                return plant.plantName.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searching for: \(searchText)")
        filterContentForSearchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchPageCollectionViewCell.identifier, for: indexPath) as? SearchPageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let plant = filteredPlants[indexPath.row]
        cell.configure(with: plant)
        return cell
    }
}
// MARK: - Helper Methods

extension SearchViewController {
    // Helper methods moved to HomeDataStore and categoriesViewController
}

// MARK: - Quick Add

extension SearchViewController {

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let plant = filteredPlants[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let addAction = UIAction(
                title: "Add to Garden",
                image: UIImage(systemName: "plus.circle.fill"),
                attributes: []
            ) { [weak self] _ in
                self?.showSitePickerForQuickAdd(plant: plant)
            }
            return UIMenu(title: plant.plantName, children: [addAction])
        }
    }

    private func showSitePickerForQuickAdd(plant: Plant) {
        let sites = SiteStore.shared.sites
        let sheet = UIAlertController(
            title: "Add \(plant.plantName) to...",
            message: nil,
            preferredStyle: .actionSheet
        )
        if sites.isEmpty {
            sheet.message = "You have no sites yet. Go to My Garden to add one."
        } else {
            for site in sites {
                sheet.addAction(UIAlertAction(title: site.name, style: .default) { [weak self] _ in
                    self?.quickAddPlant(plant, to: site)
                })
            }
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    private func quickAddPlant(_ plant: Plant, to site: MyGardenSite) {
        // ✅ Must use mongoId — not plantId string
        guard let plantMongoId = plant.mongoId else {
            print("❌ Plant missing mongoId — cannot quick add")
            return
        }

        guard let siteMongoId = site.mongoId else {
            print("❌ Site missing mongoId — cannot quick add")
            return
        }

        // ✅ Save locally with mongoId so TaskDueEngine can find it
        let userPlant = UserPlant(
            id: UUID(),
            plantId: plantMongoId,        // ✅ was plant.plantId
            siteName: site.name,
            siteID: site.id,
            imageData: nil,
            lightRequirement: nil,
            watering: nil,
            repotting: nil,
            quantity: 1,
            isAddedToGarden: true,
            createdAt: Date(),
            lastWatered: nil,
            lastPruned: nil,
            lastFertilized: nil,
            lastRepotted: nil
        )
        PlantStore.shared.addPlant(userPlant)

        // ✅ Sync to MongoDB
        NetworkManager.shared.addUserPlant(
            plantId:          plantMongoId,
            plantName:        plant.plantName,
            siteId:           siteMongoId,
            siteName:         site.name,
            imageData:        plant.imageName,   // use catalogue image as fallback
            lightRequirement: nil,
            watering:         nil,
            repotting:        nil,
            quantity:         1,
            lastWatered:      nil,
            lastRepotted:     nil
        ) { mongoId in
            if let mongoId = mongoId {
                print("✅ Quick-added \(plant.plantName) synced to MongoDB: \(mongoId)")
                // ✅ Refresh from MongoDB so local store is consistent
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.loadAppData()
                }
            } else {
                print("❌ Failed to sync quick-add to MongoDB")
            }
        }

        print("✅ Quick-added \(plant.plantName) to \(site.name)")
        showQuickAddSuccess(plantName: plant.plantName, siteName: site.name)
    }

    private func showQuickAddSuccess(plantName: String, siteName: String) {
        let alert = UIAlertController(
            title: "🌿 Plant Added!",
            message: "\(plantName) has been added to \(siteName).\n\nVisit the plant in My Garden to answer care questions.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .default))
        present(alert, animated: true)
    }
}
