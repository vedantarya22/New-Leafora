import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var otherUserButtonsStack: UIStackView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var postsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    var user: User?
    var isCurrentUser: Bool = false
    private var userPosts: [Post] = []
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        setupUI()
        checkIsCurrentUser()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdate),
                                               name: .didUpdatePosts, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        gradientLayer.frame = view.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc func handleDataUpdate() { refreshData() }

    // MARK: - Determine Current User
    func checkIsCurrentUser() {
        if let passedUser = self.user {
            // A user was passed in (e.g. from tapping someone's profile)
            self.isCurrentUser = UserSession.shared.isCurrentUser(userID: passedUser.id)
            updateUI()
        } else {
            // No user passed — this is the logged-in user's own profile tab
            self.isCurrentUser = true
            if let cached = UserSession.shared.cachedCurrentUser {
                self.user = cached
                updateUI()
            } else {
                // Cache is cold — fetch from backend
                UserSession.shared.fetchCurrentUser { [weak self] user in
                    guard let self = self, let user = user else { return }
                    self.user = user
                    self.updateUI()
                }
            }
        }
    }

    // MARK: - Refresh User Data
    func refreshUser() {
        guard let userId = user?.id else { return }

        if UserSession.shared.isCurrentUser(userID: userId) {
            // Always use the latest cached profile for current user
            if let fresh = UserSession.shared.cachedCurrentUser {
                self.user = fresh
                updateUI()
            }
        } else {
            // Re-fetch other user's profile from backend
            NetworkManager.shared.fetchUser(userId: userId) { [weak self] freshUser in
                guard let self = self, let freshUser = freshUser else { return }
                self.user = freshUser
                self.updateUI()
            }
        }
    }

    // MARK: - Setup CollectionView
    func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode   = .scaleAspectFill
        collectionView.delegate        = self
        collectionView.dataSource      = self
        collectionView.backgroundColor = .clear
    }

    // MARK: - Update UI with User Data
    func updateUI() {
        guard let user = user else { return }

        // ✅ Name and handle
        nameLabel.text   = user.name
        handleLabel.text = "@\(user.username)"

        // ✅ Plants only — no friends
        let plantCount = isCurrentUser ? PlantStore.shared.totalPlants : 0
        statsLabel.text = "\(plantCount) \(plantCount == 1 ? "Plant" : "Plants")"

        // ✅ Profile image — handles Cloudinary URL, local asset, or SF symbol
        profileImageView.configureImage(with: user.profileImageString ?? "person.circle.fill")

        // ✅ Hide message button for current user, show for others
        messageButton.isHidden = isCurrentUser

        // ✅ Remove "Saved" segment for other users — they can't see your saved posts
        if !isCurrentUser {
            if postsSegmentedControl.numberOfSegments > 1 {
                postsSegmentedControl.removeSegment(at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = false
        }

        navigationItem.rightBarButtonItem = menuButton
        setupMenu()
        refreshData()
    }

    // MARK: - Load Posts
    @IBAction func segmentChanged(_ sender: UISegmentedControl) { refreshData() }

    func refreshData() {
        guard let user = user else { return }

        if postsSegmentedControl.selectedSegmentIndex == 0 {
            // My posts / their posts
            PostRepository.shared.fetchPosts(forUserId: user.id) { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        } else {
            // Saved posts — current user only
            PostRepository.shared.fetchSavedPostsForCurrentUser { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        }
    }

    // MARK: - Actions
    @IBAction func messageTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "OpenChat", sender: self.user)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenChat",
           let chatVC = segue.destination as? ChatViewController,
           let user = sender as? User {
            chatVC.user = user
        } else if segue.identifier == "ShowPostFromProfile",
                  let destVC = segue.destination as? profilePostsViewerController,
                  let post = sender as? Post {
            destVC.post = post
        }
    }

    // MARK: - Menu
    func setupMenu() {
        let editAction = UIAction(title: "Edit Profile",
                                  image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.openPersonalInfoSettings()
        }
        let blockAction = UIAction(title: "Block",
                                   image: UIImage(systemName: "hand.raised.slash"),
                                   attributes: .destructive) { _ in
            print("Block tapped")
        }
        menuButton.menu = UIMenu(
            title: isCurrentUser ? "My Options" : "User Options",
            children: isCurrentUser ? [editAction] : [blockAction]
        )
    }

    @objc func openPersonalInfoSettings() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "Personal_InfoViewController") as? Personal_InfoViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        userPosts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ProfileGridCell",
            for: indexPath) as! ProfileGridCell
        cell.imageView.configureImage(with: userPosts[indexPath.row].postImageString)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 1 }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPostFromProfile", sender: userPosts[indexPath.item])
    }
}
