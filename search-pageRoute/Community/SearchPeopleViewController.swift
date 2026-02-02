import UIKit

class SearchPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Data Variables
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isSearching: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //allows the view to extend under the nav bar, preventing the "jump" or black gap
        self.extendedLayoutIncludesOpaqueBars = true
        
        setupTableView()
        setupSearchController()
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }

    func loadData() {
        UserSession.shared.fetchAllUsers { [weak self] users in
            let currentUserID = UserSession.shared.currentLoggedInUserID
            guard let self = self else { return }
            self.allUsers = users.filter { $0.id != currentUserID }
            self.tableView.reloadData()
        }
    }
    // MARK: - Setup Functions
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        
        // 4. Connect Delegate to fix the dismiss glitch
        searchController.delegate = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search people..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        // Force the Navigation Bar to relayout itself immediately
        UIView.animate(withDuration: 0.1) {
            self.navigationController?.view.setNeedsLayout()
            self.navigationController?.view.layoutIfNeeded()
        }
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        
        let nib = UINib(nibName: "PeopleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PeopleTableViewCell")
    }
    
    //Search Logic
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredUsers = allUsers.filter { user in
            return user.name.lowercased().contains(searchText.lowercased()) ||
                   user.username.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }

    //TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredUsers.count : allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        
        let user = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.messageLabel.text = user.searchSubtitle
        
        let imageName = UserSession.shared.profileImageString(for: user.id)
        cell.avatarImageView.configureImage(with: imageName)
        cell.avatarImageView.tintColor = .label

        
        cell.timeLabel.isHidden = true
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // Nav
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        performSegue(withIdentifier: "ShowUserProfile", sender: selectedUser)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUserProfile",
           let profileVC = segue.destination as? ProfileViewController,
           let user = sender as? User {
            profileVC.user = user
        }
    }
}
