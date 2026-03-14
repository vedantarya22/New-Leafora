import UIKit

class SearchPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                                   UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    var allUsers:      [User] = []
    var filteredUsers: [User] = []

    let searchController      = UISearchController(searchResultsController: nil)
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    var isSearchBarEmpty: Bool { searchController.searchBar.text?.isEmpty ?? true }
    var isSearching: Bool { searchController.isActive && !isSearchBarEmpty }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        self.extendedLayoutIncludesOpaqueBars = true
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
        navigationItem.hidesSearchBarWhenScrolling       = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
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
    func setupSearchController() {
        searchController.searchResultsUpdater                 = self
        searchController.delegate                             = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder                = "Search people..."
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
        definesPresentationContext                            = true
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        UIView.animate(withDuration: 0.1) {
            self.navigationController?.view.setNeedsLayout()
            self.navigationController?.view.layoutIfNeeded()
        }
    }

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
        cell.messageLabel.text = user.searchSubtitle

        // ✅ profileImageString lives on User directly
        cell.avatarImageView.configureImage(with: user.profileImageString)
        cell.avatarImageView.tintColor   = .label
        cell.backgroundColor             = .clear
        cell.contentView.backgroundColor = .clear
        cell.timeLabel.isHidden          = true
        cell.accessoryType               = .disclosureIndicator

        return cell
    }

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
