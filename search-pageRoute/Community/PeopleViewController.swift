import UIKit

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!

    private let gradientLayer = CAGradientLayer.backgroundGreen()
    let searchController = UISearchController(searchResultsController: nil)

    var allUsers:      [User] = []
    var filteredUsers: [User] = []

    var isSearchBarEmpty: Bool { searchController.searchBar.text?.isEmpty ?? true }
    var isSearching: Bool { searchController.isActive && !isSearchBarEmpty }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        setupTableView()
        setupSearchController()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        loadData()
    }

    // MARK: - Data
    func loadData() {
        // ✅ fetchAllUsers now lives on NetworkManager, not UserSession
        NetworkManager.shared.fetchAllUsers { [weak self] users in
            guard let self = self else { return }
            let currentId = UserSession.shared.currentLoggedInUserID
            self.allUsers = users.filter { $0.id != currentId }
            self.tableView.reloadData()
        }
    }

    // MARK: - Setup
    func setupTableView() {
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.rowHeight       = 80
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear
        let nib = UINib(nibName: "PeopleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PeopleTableViewCell")
    }

    func setupSearchController() {
        searchController.searchResultsUpdater            = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder           = "Search friends..."
        navigationItem.searchController                  = searchController
        navigationItem.hidesSearchBarWhenScrolling       = false
        definesPresentationContext                        = true
    }

    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text ?? "")
    }

    func filterContentForSearchText(_ text: String) {
        filteredUsers = allUsers.filter {
            $0.name.lowercased().contains(text.lowercased()) ||
            $0.username.lowercased().contains(text.lowercased())
        }
        tableView.reloadData()
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredUsers.count : allUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell",
                                                  for: indexPath) as! PeopleTableViewCell
        let user = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        cell.nameLabel.text    = user.name
        cell.messageLabel.text = "Hey! How are your plants? 🌱"
        cell.timeLabel.text    = "9:41 AM"

        // ✅ profileImageString lives on User directly — no UserSession helper needed
        cell.avatarImageView.configureImage(with: user.profileImageString)
        cell.avatarImageView.tintColor        = .label
        cell.backgroundColor                  = .clear
        cell.contentView.backgroundColor      = .clear

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        let storyboard = UIStoryboard(name: "communityScreens", bundle: nil)
        let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.user = selectedUser
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
