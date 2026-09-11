//  PeopleViewController.swift

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
    private var emptyStateView: UIView!

    var isSearchBarEmpty: Bool { searchController.searchBar.text?.isEmpty ?? true }
    var isSearching: Bool { searchController.isActive && !isSearchBarEmpty }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        setupTableView()
        setupSearchController()
        setupEmptyStateView()
        loadData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPreviews),
            name: .didSendMessage,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        sortUsersByLatestMessage()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.searchController.searchBar.searchTextField.backgroundColor = .white
        }
    }

    // MARK: - Refresh Inbox Ordering
    @objc private func refreshPreviews() {
        sortUsersByLatestMessage()
        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - Sorting
    private func sortUsersByLatestMessage() {

        allUsers.sort { a, b in
            let previewA = ChatManager.shared.lastPreview(with: a.id)
            let previewB = ChatManager.shared.lastPreview(with: b.id)

            let timeA = previewA?.timestamp ?? .distantPast
            let timeB = previewB?.timestamp ?? .distantPast

            // Latest message first
            if timeA != timeB {
                return timeA > timeB
            }

            // Fallback alphabetical sort
            return a.name.lowercased() < b.name.lowercased()
        }

        filteredUsers.sort { a, b in
            let previewA = ChatManager.shared.lastPreview(with: a.id)
            let previewB = ChatManager.shared.lastPreview(with: b.id)

            let timeA = previewA?.timestamp ?? .distantPast
            let timeB = previewB?.timestamp ?? .distantPast

            if timeA != timeB {
                return timeA > timeB
            }

            return a.name.lowercased() < b.name.lowercased()
        }
    }

    // MARK: - Data
    func loadData() {

        // Load users and rooms in parallel
        let group = DispatchGroup()

        group.enter()
        NetworkManager.shared.fetchAllUsers { [weak self] users in
            guard let self = self else {
                group.leave()
                return
            }

            let currentId = UserSession.shared.currentLoggedInUserID

            self.allUsers = users.filter {
                $0.id != currentId
            }

            group.leave()
        }

        group.enter()

        // Loads decrypted previews into ChatManager cache
        ChatManager.shared.loadRooms {
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            self.allUsers = self.allUsers.filter {
                ChatManager.shared.lastPreview(with: $0.id) != nil
            }

            self.sortUsersByLatestMessage()
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }

    // MARK: - Setup
    func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .clear

        let nib = UINib(
            nibName: "PeopleTableViewCell",
            bundle: nil
        )

        tableView.register(
            nib,
            forCellReuseIdentifier: "PeopleTableViewCell"
        )
    }

    func setupSearchController() {

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search friends..."

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        searchController.searchBar.searchTextField.backgroundColor = .white
    }

    // MARK: - Search
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(
            searchController.searchBar.text ?? ""
        )
    }

    func filterContentForSearchText(_ text: String) {

        filteredUsers = allUsers.filter {
            $0.name.lowercased().contains(text.lowercased()) ||
            $0.username.lowercased().contains(text.lowercased())
        }

        // Keep filtered results sorted too
        sortUsersByLatestMessage()

        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return isSearching
            ? filteredUsers.count
            : allUsers.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PeopleTableViewCell",
            for: indexPath
        ) as! PeopleTableViewCell

        let user = isSearching
            ? filteredUsers[indexPath.row]
            : allUsers[indexPath.row]

        cell.nameLabel.text = user.name

        // Decrypted preview from ChatManager cache
        if let preview = ChatManager.shared.lastPreview(with: user.id) {

            let myId = UserSession.shared.currentLoggedInUserID

            let prefix = preview.senderId == myId
                ? "You: "
                : ""

            cell.messageLabel.text = "\(prefix)\(preview.text)"

            cell.timeLabel.text = ChatManager.shared.formattedTime(
                for: preview.timestamp
            )

            cell.timeLabel.isHidden = false

        } else {

            cell.messageLabel.text = user.searchSubtitle
            cell.timeLabel.isHidden = true
        }

        cell.avatarImageView.configureImage(
            with: user.profileImageString ?? "person.circle.fill"
        )

        cell.avatarImageView.tintColor = .label

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let selectedUser = isSearching
            ? filteredUsers[indexPath.row]
            : allUsers[indexPath.row]

        let storyboard = UIStoryboard(
            name: "communityScreens",
            bundle: nil
        )

        let chatVC = storyboard.instantiateViewController(
            withIdentifier: "ChatViewController"
        ) as! ChatViewController

        chatVC.user = selectedUser

        navigationController?.pushViewController(
            chatVC,
            animated: true
        )
    }

    // MARK: - Swipe Actions
    // Cosmetic only — does not delete MongoDB messages
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let user = isSearching
            ? filteredUsers[indexPath.row]
            : allUsers[indexPath.row]

        let clear = UIContextualAction(
            style: .destructive,
            title: "Clear Chat"
        ) { [weak self] _, _, done in

            ChatManager.shared.clearPreview(for: user.id)

            self?.allUsers.removeAll { $0.id == user.id }
            self?.filteredUsers.removeAll { $0.id == user.id }

            self?.sortUsersByLatestMessage()
            self?.tableView.reloadData()
            self?.updateEmptyState()

            done(true)
        }

        clear.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(
            actions: [clear]
        )
    }

    // MARK: - Empty State
    func setupEmptyStateView() {
        emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)

        let label = UILabel()
        label.text = "Connect with plant owners!"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("Find People", for: .normal)
        button.backgroundColor = .brandGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFindPeople), for: .touchUpInside)

        emptyStateView.addSubview(label)
        emptyStateView.addSubview(button)

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),

            label.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            label.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),

            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 140),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }

    func updateEmptyState() {
        let isEmpty = isSearching ? filteredUsers.isEmpty : allUsers.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    @objc private func didTapFindPeople() {
        let storyboard = UIStoryboard(name: "communityScreens", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchPeopleViewController") as! SearchPeopleViewController
        navigationController?.pushViewController(searchVC, animated: true)
    }
}
