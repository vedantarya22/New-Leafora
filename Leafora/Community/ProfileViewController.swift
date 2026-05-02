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

    // set from post author/search user; nil means own profile tab
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
        // refresh on every appear (eg after edit profile)
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
            // passed user can be self or other user
            isCurrentUser = UserSession.shared.isCurrentUser(userID: passedUser.id)

            if isCurrentUser {
                // use latest cached self profile
                self.user = UserSession.shared.cachedCurrentUser ?? passedUser
                updateUI()
            } else {
                // show now, then refresh from backend
                updateUI()
                NetworkManager.shared.fetchUser(userId: passedUser.id) { [weak self] fresh in
                    guard let self = self, let fresh = fresh else { return }
                    self.user = fresh
                    self.updateUI()
                }
            }

        } else {
            // no user passed means this is own profile tab
            isCurrentUser = true

            if let cached = UserSession.shared.cachedCurrentUser {
                self.user = cached
                updateUI()
            } else {
                // if cache empty then fetch from backend
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
        
        // keep item sizing manual via sizeForItemAt
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
            // own profile uses local plant count
            let count   = PlantStore.shared.totalPlants
            statsLabel.text = "\(count) \(count == 1 ? "Plant" : "Plants")"

            // hide other-user actions for self
            messageButton.isHidden         = true
            otherUserButtonsStack.isHidden = true

            // ensure saved segment exists on own profile
            if postsSegmentedControl.numberOfSegments < 2 {
                postsSegmentedControl.insertSegment(withTitle: "Saved", at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = true

        } else {
            // other user uses plant count from backend
            let count   = user.plantCount
            statsLabel.text = "\(count) \(count == 1 ? "Plant" : "Plants")"

            // show actions for other user
            messageButton.isHidden         = false
            otherUserButtonsStack.isHidden = false

            // hide saved segment for other users
            if postsSegmentedControl.numberOfSegments > 1 {
                postsSegmentedControl.removeSegment(at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = false
        }

        // cloudinary url or placeholder
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
            // normal posts
            PostRepository.shared.fetchPosts(forUserId: user.id) { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        } else {
            // saved posts (only for own profile)
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
