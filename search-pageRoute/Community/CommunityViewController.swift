import UIKit

class CommunityViewController: UIViewController, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var postsCollectionView: UICollectionView!

    // MARK: - Data
    private var posts: [Post] = []
    private var expandedPostIds: Set<String> = []
    private var isLoading: Bool = true
    
    private let refreshControl = UIRefreshControl()

    let gradientLayer = CAGradientLayer()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        setupCollectionView()
        loadData()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdate),
                                               name: .didUpdatePosts, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc func handleDataUpdate() { loadData() }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    // MARK: - Setup
    private func setupCollectionView() {
        postsCollectionView.delegate        = self
        postsCollectionView.dataSource      = self
        postsCollectionView.backgroundColor = .clear
        let nib = UINib(nibName: CommunityPostCollectionViewCell.nibName, bundle: nil)
        postsCollectionView.register(nib, forCellWithReuseIdentifier: CommunityPostCollectionViewCell.identifier)
        postsCollectionView.register(ShimmerPostCell.self, forCellWithReuseIdentifier: ShimmerPostCell.identifier)
        postsCollectionView.collectionViewLayout = createLayout()
        postsCollectionView.delaysContentTouches = false
        
        // Setup Pull to Refresh
        refreshControl.tintColor = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        postsCollectionView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        loadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.refreshControl.endRefreshing()
        }
    }

    private func setupBotanicalBackground() {
        let topColor    = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        gradientLayer.colors     = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradientLayer.frame      = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func createLayout() -> UICollectionViewLayout {
        // keep estimated height close to post size for smoother scroll
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(450))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(450))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section   = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets     = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.postsCollectionView.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: - Data Loading
    private func loadData() {
        isLoading = true
        postsCollectionView.reloadData()

        PostRepository.shared.fetchAllPosts { [weak self] fetchedPosts in
            guard let self = self else { return }
            self.posts = fetchedPosts
            self.isLoading = false
            self.postsCollectionView.reloadData()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowComments",
           let commentsVC = segue.destination as? CommentsViewController,
           let post = sender as? Post {
            commentsVC.post = post
        }
        if segue.identifier == "ShowUserProfile",
           let profileVC = segue.destination as? ProfileViewController,
           let user = sender as? User {
            profileVC.user = user
        }
        if let newPostVC = segue.destination as? NewPostViewController {
            newPostVC.onPostSuccess = { [weak self] in self?.loadData() }
        }
    }
}

// MARK: - UICollectionView DataSource
extension CommunityViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 3 : posts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShimmerPostCell.identifier, for: indexPath) as! ShimmerPostCell
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostCollectionViewCell.identifier,
            for: indexPath
        ) as? CommunityPostCollectionViewCell else { return UICollectionViewCell() }

        let post       = posts[indexPath.item]
        let isExpanded = expandedPostIds.contains(post.id)
        cell.configure(with: post, isExpanded: isExpanded)

        cell.onLikeTapped = {
            PostRepository.shared.toggleLike(postId: post.id)
        }


        cell.onCommentTapped = { [weak self] in
            self?.performSegue(withIdentifier: "ShowComments", sender: post)
        }

        cell.onSaveTapped = {
            PostRepository.shared.toggleSave(postId: post.id)
        }

        cell.onProfileTapped = { [weak self] in
            if let author = post.author {
                // make User model from post author for profile screen
                let user = User(id: author.id, name: author.name,
                                username: author.username,
                                profileImageString: author.profileImageString ?? "",
                                plantCount: 0)
                self?.performSegue(withIdentifier: "ShowUserProfile", sender: user)
            }
        }

        cell.onMenuTapped = { [weak self] in
            self?.showPostMenu(for: post)
        }

        // expanded state is local to this screen
        cell.onSeeMoreTapped = { [weak self] in
            guard let self = self else { return }
            if self.expandedPostIds.contains(post.id) {
                self.expandedPostIds.remove(post.id)
            } else {
                self.expandedPostIds.insert(post.id)
            }
            self.postsCollectionView.reloadItems(at: [indexPath])
        }

        return cell
    }
}

// MARK: - Post Menu
extension CommunityViewController {
    func showPostMenu(for post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive) { [weak self] _ in
            let confirm = UIAlertController(title: "Post Reported",
                                            message: "Thank you for reporting. We'll review this post.",
                                            preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirm, animated: true)
        })

        if post.userId == UserSession.shared.currentLoggedInUserID {
            alert.addAction(UIAlertAction(title: "Delete Post", style: .destructive) { _ in
                PostRepository.shared.deletePost(id: post.id)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - Shimmer Cell
class ShimmerPostCell: UICollectionViewCell {
    static let identifier = "ShimmerPostCell"

    private let containerView = UIView()
    private let avatarShimmer = UIView()
    private let nameShimmer = UIView()
    private let dateShimmer = UIView()
    private let imageShimmer = UIView()
    private let textShimmer1 = UIView()
    private let textShimmer2 = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let elements = [avatarShimmer, nameShimmer, dateShimmer, imageShimmer, textShimmer1, textShimmer2]
        elements.forEach {
            $0.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            $0.layer.cornerRadius = 8
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        avatarShimmer.layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            avatarShimmer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarShimmer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarShimmer.widthAnchor.constraint(equalToConstant: 40),
            avatarShimmer.heightAnchor.constraint(equalToConstant: 40),

            nameShimmer.centerYAnchor.constraint(equalTo: avatarShimmer.centerYAnchor, constant: -8),
            nameShimmer.leadingAnchor.constraint(equalTo: avatarShimmer.trailingAnchor, constant: 12),
            nameShimmer.widthAnchor.constraint(equalToConstant: 120),
            nameShimmer.heightAnchor.constraint(equalToConstant: 16),

            dateShimmer.centerYAnchor.constraint(equalTo: avatarShimmer.centerYAnchor, constant: 12),
            dateShimmer.leadingAnchor.constraint(equalTo: avatarShimmer.trailingAnchor, constant: 12),
            dateShimmer.widthAnchor.constraint(equalToConstant: 60),
            dateShimmer.heightAnchor.constraint(equalToConstant: 12),

            imageShimmer.topAnchor.constraint(equalTo: avatarShimmer.bottomAnchor, constant: 16),
            imageShimmer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageShimmer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageShimmer.heightAnchor.constraint(equalToConstant: 300),

            textShimmer1.topAnchor.constraint(equalTo: imageShimmer.bottomAnchor, constant: 16),
            textShimmer1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textShimmer1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            textShimmer1.heightAnchor.constraint(equalToConstant: 16),

            textShimmer2.topAnchor.constraint(equalTo: textShimmer1.bottomAnchor, constant: 8),
            textShimmer2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textShimmer2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -64),
            textShimmer2.heightAnchor.constraint(equalToConstant: 16),
            textShimmer2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }

    private var isShimmeringSetup = false

    override func layoutSubviews() {
        super.layoutSubviews()
        // start shimmer only once
        if !isShimmeringSetup {
            let elements = [avatarShimmer, nameShimmer, dateShimmer, imageShimmer, textShimmer1, textShimmer2]
            elements.forEach { $0.startShimmering() }
            isShimmeringSetup = true
        }
    }
}
