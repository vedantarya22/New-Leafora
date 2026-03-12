import UIKit

class GardeningPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let user = UserSession.shared.currentUser
    
    // Transactional state
    private var tempPreferences: GardeningPreferences!
    private var originalPreferences: GardeningPreferences!
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        // Hide name and email labels if not needed for this screen, or keep them if part of design.
        // Based on user request: "circular profile picture at the top. Below that... list"
        
        if let user = user {
            nameLabel.text = user.name
            emailLabel.text = "Gardening & Plant Care"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gardening Preferences"
        
        // ✅ App theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        // Initialize temp state from DataStore
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
        
        // ✅ Use UserSession as single source of truth for profile image
        if let user = user {
            let imageName = UserSession.shared.profileImageString(for: user.id)
            profileImage.configureImage(with: imageName)
        } else {
            // Fallback placeholder
            let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
            profileImage.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        }
        
        // Ensure image is circular
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    private func setupNavigationBar() {
        // Right Tick Button (Save)
        let saveButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(saveTapped))
        // tint color #377D29
        saveButton.tintColor = UIColor(red: 0x37/255.0, green: 0x7D/255.0, blue: 0x29/255.0, alpha: 1.0)
        navigationItem.rightBarButtonItem = saveButton
        
        // Custom Back Button to intercept navigation
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func saveTapped() {
        // Save changes to DataStore
        HomeDataStore.shared.gardeningPreferences = tempPreferences
        
        // ---------------------------------------------------------
        // Trigger Recommendation Engine
        // ---------------------------------------------------------
        print("🌱 GardeningPreferences changed. Running Recommendation Engine...")
        
        // 1. Load all plants (Ensure this is not on main thread if heavy, 
        // but for this dataset size it's likely fine, or dispatch async)
        DispatchQueue.global(qos: .userInitiated).async {
//            let allPlants = JSONLoader.loadPlants(from: "plantData")
            let allPlants = PlantCatalogueCache.shared.plants
            
            // 2. Run Engine
            let recommendedIDs = PlantRecommendationEngine.shared.generateRecommendedPlantIDs(
                plants: allPlants,
                preferences: self.tempPreferences,
                hasPets: false // TODO: if we have a pet setting, pass it. Defaulting to false for now based on available data.
            )
            
            print("✅ Recommendation Engine finished. Cached \(recommendedIDs.count) plants.")
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
        
        // Add detail label for the value
        // The default "cell" in the storyboard might be effectively "Basic".
        // To show "Title ......... Value", we ideally need a "Right Detail" or "Value 1" style.
        // Since we are reusing the cell from the storyboard which seemed to be custom or basic,
        // we might not have a detailTextLabel unless we change the style in storyboard or code.
        // However, looking at PersonalInfoTableViewCell, it had a TextField.
        // The duplicate VC likely uses the same cell prototype "cell".
        // If it's a standard cell, we can try using a configuration or just text.
        // But the user asked for "showing the selected value on the right".
        // If the storyboard cell style is "Basic", detailTextLabel won't show.
        // Let's assume we can configure it or it's a Value1 style.
        // If not, we might need to modify the storyboard to set the cell style to "Right Detail".
        // For now, let's try setting detailTextLabel.
        
        // WORKAROUND: If the cell is the `PersonalInfoTableViewCell` (from the copy), it has a textField.
        // But this VC was duplicated from HomeProfileViewController, which had a basic cell.
        
        // Let's create a simpler cell logic:
        // Use Swift's modern content configuration if available (iOS 14+)
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
        
        // Navigate to OptionSelectionViewController
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OptionSelectionViewController") as? OptionSelectionViewController {
            vc.preferenceType = item.type
            vc.currentValue = item.value
            
            // Set callback to update temp state
            vc.onSelectionChanged = { [weak self] newValue in
                self?.tempPreferences.preferences[indexPath.row].value = newValue
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
