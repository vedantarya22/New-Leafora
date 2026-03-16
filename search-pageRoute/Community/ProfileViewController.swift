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

    // Set from outside when tapping a post author or search result.
    // Leave nil when this VC is used as the current user's profile tab.
    var user: User?
    private var isCurrentUser: Bool = false
    private var userPosts: [Post] = []
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        setupCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdate),
                                               name: .didUpdatePosts, object: nil)
        loadUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh every time screen appears (e.g. returning from Edit Profile)
        loadUser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        gradientLayer.frame = view.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc func handleDataUpdate() { refreshData() }

    // MARK: - Load User
    private func loadUser() {
        if let passedUser = user {
            // A user was passed in — could be self or someone else
            isCurrentUser = UserSession.shared.isCurrentUser(userID: passedUser.id)

            if isCurrentUser {
                // Use latest cached profile for own data
                self.user = UserSession.shared.cachedCurrentUser ?? passedUser
                updateUI()
            } else {
                // Show what we have immediately, then refresh from backend
                updateUI()
                NetworkManager.shared.fetchUser(userId: passedUser.id) { [weak self] fresh in
                    guard let self = self, let fresh = fresh else { return }
                    self.user = fresh
                    self.updateUI()
                }
            }

        } else {
            // No user passed — this is the current user's own profile tab
            isCurrentUser = true

            if let cached = UserSession.shared.cachedCurrentUser {
                self.user = cached
                updateUI()
            } else {
                // Cache cold — fetch from backend
                UserSession.shared.fetchCurrentUser { [weak self] fetchedUser in
                    guard let self = self, let fetchedUser = fetchedUser else { return }
                    self.user = fetchedUser
                    self.updateUI()
                }
            }
        }
    }

    // MARK: - Setup
    private func setupCollectionView() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode   = .scaleAspectFill
        collectionView.delegate        = self
        collectionView.dataSource      = self
        collectionView.backgroundColor = .clear
        
        // Disable automatic cell sizing so sizeForItemAt is respected
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
    }

    // MARK: - Update UI
    private func updateUI() {
        guard let user = user else { return }

        nameLabel.text   = user.name
        handleLabel.text = "@\(user.username)"

        if isCurrentUser {
            // ── Own profile ──────────────────────────────────────────────
            // Plant count from local PlantStore (already synced from backend)
            let count   = PlantStore.shared.totalPlants
            statsLabel.text = "\(count) \(count == 1 ? "Plant" : "Plants")"

            // ✅ No message button for own profile
            messageButton.isHidden         = true
            otherUserButtonsStack.isHidden = true

            // ✅ Restore "Saved" segment if it was removed in a previous load
            if postsSegmentedControl.numberOfSegments < 2 {
                postsSegmentedControl.insertSegment(withTitle: "Saved", at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = true

        } else {
            // ── Other user's profile ─────────────────────────────────────
            // plantCount comes from the backend via fetchUser (Option B above)
            // User model needs a plantCount field populated by the backend.
            let count   = user.plantCount
            statsLabel.text = "\(count) \(count == 1 ? "Plant" : "Plants")"

            // ✅ Show message button for other users
            messageButton.isHidden         = false
            otherUserButtonsStack.isHidden = false

            // ✅ Hide "Saved" segment — other users can't see your saved posts
            if postsSegmentedControl.numberOfSegments > 1 {
                postsSegmentedControl.removeSegment(at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = false
        }

        // Profile image — handles Cloudinary URL or falls back to placeholder
        profileImageView.configureImage(with: user.profileImageString ?? "person.circle.fill")

        navigationItem.rightBarButtonItem = menuButton
        setupMenu()
        refreshData()
    }

    // MARK: - Posts
    @IBAction func segmentChanged(_ sender: UISegmentedControl) { refreshData() }

    private func refreshData() {
        guard let user = user else { return }

        if postsSegmentedControl.selectedSegmentIndex == 0 {
            // ✅ Posts — works for both own profile and other users
            PostRepository.shared.fetchPosts(forUserId: user.id) { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        } else {
            // ✅ Saved — only reachable on own profile (segment hidden for others)
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
    private func setupMenu() {
        let editAction = UIAction(
            title: "Edit Profile",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.openPersonalInfoSettings()
        }

        let blockAction = UIAction(
            title: "Block",
            image: UIImage(systemName: "hand.raised.slash"),
            attributes: .destructive
        ) { _ in
            print("Block tapped")
        }

        menuButton.menu = UIMenu(
            title: isCurrentUser ? "My Options" : "User Options",
            children: isCurrentUser ? [editAction] : [blockAction]
        )
    }

    @objc private func openPersonalInfoSettings() {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(
            withIdentifier: "Personal_InfoViewController"
        ) as? Personal_InfoViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { userPosts.count }

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
