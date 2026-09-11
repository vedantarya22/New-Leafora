import UIKit

class HomeProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
   
    private var user: User?
    private let sections = HomeDataStore.shared.profileSections
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        user = UserSession.shared.currentUser
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // app theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupUI() {
        
        viewForIcon?.backgroundColor = .clear
        
        guard let user = user else { return }
        
        nameLabel?.text = user.name
        emailLabel?.text = user.handle
        
        profileImage?.configureImage(with: user.profileImageString)
        profileImage?.layer.cornerRadius = (profileImage?.frame.height ?? 0) / 2
        profileImage?.clipsToBounds = true
        
        tableView.backgroundColor = .clear
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textAlignment = .left
        
        if item.title == "Sign Out" {
            cell.textLabel?.textColor = .systemRed
        } else if item.title == "Delete Account" {
            cell.textLabel?.textColor = .systemRed
        } else {
            cell.textLabel?.textColor = .label
        }
        
        cell.accessoryType = item.showsChevron ? .disclosureIndicator : .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        if item.title == "Personal Info" {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(
                withIdentifier: "Personal_InfoViewController"
            ) as! Personal_InfoViewController

            vc.title = "Personal Info"

            navigationController?.pushViewController(vc, animated: true)


        }
        if item.title == "Gardening Preferences" {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "GardeningPreferencesViewController") as? GardeningPreferencesViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if item.title == "Sign Out" {
            // clear auth tokens
            KeychainManager.shared.clearAll()
            
            // close profile then go to login
            self.dismiss(animated: true) {
                guard let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first else { return }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
                let navVC = UINavigationController(rootViewController: loginVC)
                navVC.isNavigationBarHidden = true
                window.rootViewController = navVC
                
                // cross-fade transition
                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
            }
        }
        
        if item.title == "Delete Account" {
            showDeleteAccountConfirmation()
        }
    }
    
    // MARK: - Delete Account
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? All your data, plants, and posts will be permanently removed. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performAccountDeletion()
        })
        
        present(alert, animated: true)
    }
    
    private func performAccountDeletion() {
        // Show a loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Deleting account...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: loadingAlert.view.centerYAnchor),
            indicator.leadingAnchor.constraint(equalTo: loadingAlert.view.leadingAnchor, constant: 20)
        ])
        present(loadingAlert, animated: true)
        
        NetworkManager.shared.deleteAccount { [weak self] success in
            loadingAlert.dismiss(animated: true) {
                if success {
                    // Navigate to login
                    self?.dismiss(animated: true) {
                        guard let window = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first else { return }
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
                        let navVC = UINavigationController(rootViewController: loginVC)
                        navVC.isNavigationBarHidden = true
                        window.rootViewController = navVC
                        
                        UIView.transition(with: window,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: nil,
                                          completion: nil)
                    }
                } else {
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to delete account. Please try again later.",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(errorAlert, animated: true)
                }
            }
        }
    }
    
}
