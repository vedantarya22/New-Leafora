import UIKit

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    

    // MARK: - Search & Data
    let searchController = UISearchController(searchResultsController: nil)
    
    var allUsers: [User] = []
    var filteredUsers: [User] = []
    
    // Computed property: Are we currently searching?
    var isSearching: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup TableView
        setupTableView()
        
        // 2. Setup Native Search (The Animation)
        setupSearchController()
        
        // 3. Load Data
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        loadData()
    }
    
    func loadData() {
        CommunityDataStore.shared.fetchAllUsers { [weak self] users in
            let currentUserID = CommunityDataStore.shared.currentLoggedInUserID
            guard let self = self else { return }
            self.allUsers = users.filter { $0.id != currentUserID }
            self.tableView.reloadData()
        }
    }

    // MARK: - Setup Functions
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // 👇 FIX FOR "EATEN UP" CELLS
        // Since you are using a XIB, sometimes auto-sizing fails.
        // Force a height to ensure they look correct.
        tableView.rowHeight = 80
        
        let nib = UINib(nibName: "PeopleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PeopleTableViewCell")
        
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
    }
    
    func setupSearchController() {
        // This connects the search logic
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search friends..."
        
     
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    // MARK: - Search Logic
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredUsers = allUsers.filter { (user: User) -> Bool in
            return user.name.lowercased().contains(searchText.lowercased()) ||
                   user.username.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredUsers.count : allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // hv to reuse xib here
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        let user = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        cell.nameLabel.text = user.name
        cell.messageLabel.text = "Hey! How are your plants? 🌱"
        cell.timeLabel.text = "9:41 AM"
        let imageName = CommunityDataStore.shared.profileImageString(for: user.id)
        cell.avatarImageView.configureImage(with: imageName)
        cell.avatarImageView.tintColor = .label

        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(
                withIdentifier: "ChatViewController"
            ) as! ChatViewController
        
        chatVC.user = selectedUser
        navigationController?.pushViewController(chatVC, animated: true)
        //print("Selected: \(user.name)")
        
        //performSegue(withIdentifier: "OpenChat", sender: user)
    }
}
