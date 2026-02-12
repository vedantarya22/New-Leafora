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
        
        let imageName = user.profileImageString
        profileImage?.image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
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
        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .left
        
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

    }
    
}
