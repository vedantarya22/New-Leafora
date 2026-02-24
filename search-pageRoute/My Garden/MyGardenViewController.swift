import UIKit
internal import _LocationEssentials

class MyGardenViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var currentWeather: PlantWeatherInfo?
    private var isLoadingWeather = true
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    @IBOutlet weak var myGardenCollectionView: UICollectionView!
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No sites yet.\nAdd plants to get started "
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let siteStore = SiteStore.shared
   

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
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
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Set the frame immediately
        gradientLayer.frame = view.bounds
        
        // Create a container view for the gradient to act as the background
        let backgroundContainer = UIView(frame: view.bounds)
        backgroundContainer.layer.insertSublayer(gradientLayer, at: 0)
        
        // Assign this to the collection view's backgroundView
        // This ensures the gradient is ALWAYS behind the cells
        myGardenCollectionView.backgroundView = backgroundContainer
    }

    private func setupCollectionView() {
        myGardenCollectionView.delegate = self
        myGardenCollectionView.dataSource = self
        myGardenCollectionView.backgroundColor = .clear
            myGardenCollectionView.backgroundView?.backgroundColor = .clear
        // Configure flow layout
        if let flowLayout = myGardenCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 16
            flowLayout.minimumLineSpacing = 16
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
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
        myGardenCollectionView.isHidden = isEmpty
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
            
            cell.iconButton.setImage(UIImage(systemName: site.icon), for: .normal)
            cell.siteNameLabel.text = site.name
            
            let plantsInSite = PlantStore.shared.plants(for: site.id)
            let totalCount = plantsInSite.reduce(0) { $0 + $1.quantity }
            cell.plantCountLabel.text = "\(totalCount) plant\(totalCount == 1 ? "" : "s")"
            
            return cell
        }
    }

    // MARK: - Layout Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            // Full Width Weather Card
            let width = collectionView.bounds.width - 32 // 16pt padding on each side
            return CGSize(width: width, height: 100)
        } else {
            // 2-Column Garden Boxes
            let totalHorizontalPadding: CGFloat = 32 // 16pt on left + 16pt on right
            let interItemSpacing: CGFloat = 16 // spacing between the two columns
            let availableWidth = collectionView.bounds.width - totalHorizontalPadding - interItemSpacing
            let itemWidth = floor(availableWidth / 2)
            return CGSize(width: itemWidth, height: 120)
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
        return section == 0 ? 0 : 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return section == 0 ? 0 : 16
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
