import UIKit

class GardeningPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let user = UserSession.shared.currentUser
    
    // local editable state
    private var tempPreferences: GardeningPreferences!
    private var originalPreferences: GardeningPreferences!
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        // keep top labels aligned with this screen layout
        
        if let user = user {
            nameLabel.text = user.name
            emailLabel.text = "Gardening & Plant Care"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gardening Preferences"
        
        // app theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        // initialize local state from datastore
        originalPreferences = HomeDataStore.shared.gardeningPreferences
        tempPreferences = originalPreferences
        
        setupUI()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupUI() {
        
        viewForIcon?.backgroundColor = .clear
        
        // use session user image if available
        if let user = user {
            profileImage.configureImage(with: user.profileImageString)
        } else {
            // fallback placeholder
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            profileImage.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        }
        
        // circular profile image
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    private func setupNavigationBar() {
        // save button
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(saveTapped))
        // tint color #377D29
        saveButton.tintColor = UIColor(red: 0x37/255.0, green: 0x7D/255.0, blue: 0x29/255.0, alpha: 1.0)
        navigationItem.rightBarButtonItem = saveButton
        
        // custom back button to catch unsaved changes
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func saveTapped() {
        // save to datastore
        HomeDataStore.shared.gardeningPreferences = tempPreferences
        
        // trigger recommendation engine
        print("GardeningPreferences changed. Running Recommendation Engine...")
        
        // load plants then run engine in background
        DispatchQueue.global(qos: .userInitiated).async {
//            let allPlants = JSONLoader.loadPlants(from: "plantData")
            let allPlants = PlantCatalogueCache.shared.plants
            
            // run engine
            let recommendedIDs = PlantRecommendationEngine.shared.generateRecommendedPlantIDs(
                plants: allPlants,
                preferences: self.tempPreferences,
                hasPets: false // pass pet setting when available
            )
            
            print("Recommendation Engine finished. Cached \(recommendedIDs.count) plants.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func backTapped() {
        if tempPreferences != originalPreferences {
            showUnsavedChangesAlert()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func showUnsavedChangesAlert() {
        let alert = UIAlertController(title: "Unsaved Changes", message: "Your preferences haven't been saved.", preferredStyle: .actionSheet)
        
        let discardAction = UIAlertAction(title: "Discard Changes", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            self?.saveTapped()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(discardAction)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    // MARK: - TableView Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempPreferences.preferences.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = tempPreferences.preferences[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // show value on the right using content configuration
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.value
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = tempPreferences.preferences[indexPath.row]
        
        // open option picker
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OptionSelectionViewController") as? OptionSelectionViewController {
            vc.hidesBottomBarWhenPushed = true
            vc.preferenceType = item.type
            vc.currentValue = item.value
            
            // update temp state from selection callback
            vc.onSelectionChanged = { [weak self] newValue in
                self?.tempPreferences.preferences[indexPath.row].value = newValue
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
