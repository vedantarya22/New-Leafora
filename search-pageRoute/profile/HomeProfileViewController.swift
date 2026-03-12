import UIKit

class HomeProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewForIcon: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
   
    private var user: User?
    private let sections = HomeDataStore.shared.profileSections
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        user = UserSession.shared.currentUser
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        guard let user = user else { return }
        
        nameLabel?.text = user.name
        emailLabel?.text = user.handle
        
        profileImage?.configureImage(with: user.profileImageString)
        profileImage?.layer.cornerRadius = (profileImage?.frame.height ?? 0) / 2
        profileImage?.clipsToBounds = true
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
            // 1. Wipe the keychain tokens securely
            KeychainManager.shared.clearAll()
            
            // 2. Dismiss the Profile modal then transition window to Login
            self.dismiss(animated: true) {
                guard let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first else { return }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
                let navVC = UINavigationController(rootViewController: loginVC)
                navVC.isNavigationBarHidden = true
                window.rootViewController = navVC
                
                // Add a cross-fade transition
                UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
            }
        }
    }
    
}
