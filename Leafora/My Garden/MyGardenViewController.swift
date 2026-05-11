import UIKit
internal import _LocationEssentials

class MyGardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var currentWeather: PlantWeatherInfo?
    private var isLoadingWeather = true
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    @IBOutlet weak var myGardenCollectionView: UICollectionView!
    private let holdTipLabel: UILabel = {
        let label = UILabel()
        label.text = "Hold & press a site to remove it"
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.6)
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No sites yet.\nAdd plants to get started"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 0.8)
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let siteStore = SiteStore.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        setupHoldTipLabel()
        setupBotanicalBackground()
        setupCollectionView()
        setupEmptyStateLabel()
        updateEmptyState()
        fetchWeatherData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myGardenCollectionView.reloadData()
        updateEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAndShowTutorial()
    }
    
    private func checkAndShowTutorial() {
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenGardenTutorial")
        let isGardenEmpty = siteStore.sites.isEmpty
        
        if !hasSeenTutorial && isGardenEmpty {
            showTutorialOverlay()
        }
    }
    
    private func showTutorialOverlay() {
        // Create overlay
        let overlay = TutorialOverlayView(frame: view.bounds) {
            UserDefaults.standard.set(true, forKey: "hasSeenGardenTutorial")
        }
        
        // Add to the window so it covers the tab bar too
        if let window = view.window {
            window.addSubview(overlay)
            overlay.show()
        }
    }
    private func setupHoldTipLabel() {
        view.addSubview(holdTipLabel)
        NSLayoutConstraint.activate([
            holdTipLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            holdTipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func fetchWeatherData() {
        isLoadingWeather = true
        
        // Tell the collection view to show the "Updating..." state
        myGardenCollectionView.reloadSections(IndexSet(integer: 0))
        
        LocationService.shared.requestLocation { [weak self] location in
            guard let self = self else { return }
            
            if let location = location {
                // API Call using coordinates
                WeatherService.shared.fetchWeather(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ) { result in
                    self.handleWeatherResult(result)
                }
            } else {
                // Fallback to a default city if location is off
                WeatherService.shared.fetchWeather(city: "Pune") { result in
                    self.handleWeatherResult(result)
                }
            }
        }
    }
    
    private func handleWeatherResult(_ result: Result<PlantWeatherInfo, Error>) {
        // UI updates must be on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoadingWeather = false
            
            switch result {
            case .success(let weather):
                self.currentWeather = weather
            case .failure(let error):
                print("Weather error: \(error)")
                self.currentWeather = nil
            }
            
            self.myGardenCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    
    private func setupBotanicalBackground() {
        // The gradientLayer is already inserted in view.layer in viewDidLoad
        // We just need to make sure the view's background doesn't interfere
        view.backgroundColor = .white // Fallback
    }
    
    private func setupCollectionView() {
        myGardenCollectionView.delegate = self
        myGardenCollectionView.dataSource = self
        myGardenCollectionView.backgroundColor = .clear
        myGardenCollectionView.backgroundView?.backgroundColor = .clear
        // Configure flow layout
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        myGardenCollectionView.addGestureRecognizer(longPress)
        if let flowLayout = myGardenCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 12
            flowLayout.minimumLineSpacing = 12
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
            flowLayout.estimatedItemSize = .zero
        }
        
        // Register existing garden cell
        myGardenCollectionView.register(UINib(nibName: "MyGardenCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyGardenCell")
        
        // Register the Weather Cell
        myGardenCollectionView.register(UINib(nibName: "WeatherTipCell", bundle: nil), forCellWithReuseIdentifier: "WeatherTipCell")
        
        // NOTE: Header registration removed to delete the "Rooms" heading
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func updateEmptyState() {
        let isEmpty = siteStore.sites.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        holdTipLabel.isHidden = isEmpty
        // Keep collection view visible so the weather section or background stays
        myGardenCollectionView.isHidden = false 
    }
    
    // MARK: - Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2 // Section 0: Weather, Section 1: Garden Boxes
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : siteStore.sites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherTipCell", for: indexPath) as! WeatherTipCell
            if isLoadingWeather {
                cell.showLoading() // Maybe show a spinner
            } else if let weather = currentWeather {
                cell.configure(with: weather) // Set the temp and advice
            } else {
                cell.showError() // Show "Weather unavailable"
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGardenCell", for: indexPath) as! MyGardenCollectionViewCell
            let site = siteStore.sites[indexPath.item]
            
            let plantsInSite = PlantStore.shared.plants(for: site)
            let totalCount = plantsInSite.reduce(0) { $0 + $1.quantity }
            
            cell.configure(name: site.name, icon: site.icon, plantCount: totalCount, index: indexPath.item)
            
            return cell
        }
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: myGardenCollectionView)
        guard let indexPath = myGardenCollectionView.indexPathForItem(at: point),
              indexPath.section == 1 else { return }
        
        if let cell = myGardenCollectionView.cellForItem(at: indexPath) as? MyGardenCollectionViewCell {
            cell.startWobble()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { cell.stopWobble() }
        }
        
        let site = siteStore.sites[indexPath.item]
        let plantCount = PlantStore.shared.plants(for: site).count
        
        if plantCount == 0 {
            let alert = UIAlertController(title: "Delete \(site.name)?", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let mongoId = site.mongoId else { return }
                
                //  1. Remove locally instantly
                PlantStore.shared.removeAllPlants(for: site)
                self?.siteStore.sites.removeAll { $0.id == site.id }
                DispatchQueue.main.async {
                    self?.myGardenCollectionView.reloadData()
                    self?.updateEmptyState()
                }
                
                //  2. Delete from MongoDB in background
                NetworkManager.shared.deleteSite(siteId: mongoId) { success in
                    if !success { print(" Failed to delete site on backend") }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            
        } else {
            let alert = UIAlertController(
                title: "Delete \(site.name)?",
                message: "This site has \(plantCount) plant\(plantCount == 1 ? "" : "s"). Deleting it will remove all plants inside.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Delete Anyway", style: .destructive) { [weak self] _ in
                guard let mongoId = site.mongoId else { return }
                
                //  1. Remove locally instantly
                PlantStore.shared.removeAllPlants(for: site)
                self?.siteStore.sites.removeAll { $0.id == site.id }
                DispatchQueue.main.async {
                    self?.myGardenCollectionView.reloadData()
                    self?.updateEmptyState()
                }
                
                //  2. Delete site + all its plants from MongoDB in background
                NetworkManager.shared.removeSiteWithPlants(siteId: mongoId) { success in
                    if !success { print(" Failed to delete site and plants on backend") }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Layout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            // Full Width Weather Card
            let width = collectionView.bounds.width - 32 // 16pt padding on each side
            return CGSize(width: width, height: 100)
        } else {
            // 3-Column Garden Tiles
            let numberOfColumns: CGFloat = 3
            let totalHorizontalPadding: CGFloat = 32
            let interItemSpacing: CGFloat = 12 * (numberOfColumns - 1)
            let availableWidth = collectionView.bounds.width - totalHorizontalPadding - interItemSpacing
            let itemWidth = floor(availableWidth / numberOfColumns)
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            // Padding for the weather card
            return UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        } else {
            // Padding for the boxes section (immediately following weather)
            return UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 12
    }
    
    // MARK: - Navigation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let selectedSite = siteStore.sites[indexPath.item]
            navigateToSiteDetail(for: selectedSite)
        }
    }
    
    private func navigateToSiteDetail(for site: MyGardenSite) {
        let storyboard = UIStoryboard(name: "MyGarden", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SiteDetailViewController") as? SiteDetailViewController else { return }
        vc.site = site
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func setupEmptyStateLabel() {
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
}


extension UICollectionViewCell {
    func startWobble() {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
        wobble.values = [0, -0.03, 0.03, -0.03, 0.03, 0]
        wobble.duration = 0.4
        wobble.repeatCount = .infinity
        layer.add(wobble, forKey: "wobble")
    }
    
    func stopWobble() {
        layer.removeAnimation(forKey: "wobble")
    }
}
