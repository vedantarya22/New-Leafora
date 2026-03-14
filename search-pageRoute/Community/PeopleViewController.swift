import UIKit

extension Notification.Name {
    static let didSendMessage = Notification.Name("didSendMessage")
}

class PeopleViewController: UIViewController, UITableViewDelegate,
                             UITableViewDataSource, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!

    private let gradientLayer = CAGradientLayer.backgroundGreen()
    let searchController = UISearchController(searchResultsController: nil)

    private var allUsers:      [User] = []
    private var filteredUsers: [User] = []

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

        // Refresh preview when a message is sent inside ChatViewController
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshPreviews),
            name: .didSendMessage, object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        // Always refresh previews when coming back from a chat
        tableView.reloadData()
        loadData()
    }

    @objc private func refreshPreviews() {
        tableView.reloadData()
    }

    // MARK: - Data
    func loadData() {
        NetworkManager.shared.fetchAllUsers { [weak self] users in
            guard let self = self else { return }
            let currentId = UserSession.shared.currentLoggedInUserID
            // Sort: users with recent messages first, then alphabetical
            self.allUsers = users
                .filter { $0.id != currentId }
                .sorted { a, b in
                    let lastA = ChatManager.shared.lastMessage(with: a.id)?.timestamp ?? .distantPast
                    let lastB = ChatManager.shared.lastMessage(with: b.id)?.timestamp ?? .distantPast
                    return lastA > lastB
                }
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
        searchController.searchResultsUpdater                 = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder                = "Search friends..."
        navigationItem.searchController                       = searchController
        navigationItem.hidesSearchBarWhenScrolling            = false
        definesPresentationContext                            = true
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
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredUsers.count : allUsers.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PeopleTableViewCell",
            for: indexPath) as! PeopleTableViewCell

        let user = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        // Name
        cell.nameLabel.text = user.name

        // Last message preview or fallback to plant count
        if let last = ChatManager.shared.lastMessage(with: user.id) {
            let myId   = UserSession.shared.currentLoggedInUserID
            let prefix = last.senderId == myId ? "You: " : ""
            cell.messageLabel.text  = "\(prefix)\(last.text ?? "")"
            cell.timeLabel.text     = ChatManager.shared.formattedTime(for: last.timestamp)
            cell.timeLabel.isHidden = false
        } else {
            cell.messageLabel.text  = user.searchSubtitle
            cell.timeLabel.isHidden = true
        }

        // Avatar
        cell.avatarImageView.configureImage(with: user.profileImageString ?? "person.circle.fill")
        cell.avatarImageView.tintColor   = .label
        cell.backgroundColor             = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]

        let storyboard = UIStoryboard(name: "communityScreens", bundle: nil)
        let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.user = selectedUser
        navigationController?.pushViewController(chatVC, animated: true)
    }

    // Swipe to delete conversation
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let user = isSearching ? filteredUsers[indexPath.row] : allUsers[indexPath.row]
        let delete = UIContextualAction(style: .destructive,
                                        title: "Delete Chat") { [weak self] _, _, done in
            ChatManager.shared.deleteConversation(with: user.id)
            self?.tableView.reloadData()
            done(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
