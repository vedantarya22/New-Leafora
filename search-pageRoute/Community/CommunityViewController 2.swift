import UIKit

class CommunityViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    // MARK: - Data
    private var posts: [Post] = []
    
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let gradientLayer = CAGradientLayer()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        setupCollectionView()
        loadData()
        
        // Subscribe to data updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdate), name: .didUpdatePosts, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDataUpdate() {
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
        // 1. Register XIB
        let nib = UINib(nibName: CommunityPostCollectionViewCell.nibName, bundle: nil)
        postsCollectionView.register(nib, forCellWithReuseIdentifier: CommunityPostCollectionViewCell.identifier)
        
        // 2. Set the Compositional Layout (Replaces the old FlowLayout)
        postsCollectionView.collectionViewLayout = createLayout()
        
        postsCollectionView.delaysContentTouches = false
    }
    private func setupBotanicalBackground() {
        // A soft, off-white to very pale sage green
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        // Insert at index 0 so it stays behind the UICollectionView
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Layout Generator
    private func createLayout() -> UICollectionViewLayout {
        // Item — estimated should be below actual content height so the cell grows, never pads
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(350)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(350)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10 // Spacing between posts
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        PostRepository.shared.fetchAllPosts { [weak self] downloadedPosts in
            self?.posts = downloadedPosts
            self?.postsCollectionView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 1. Show Comments
        if segue.identifier == "ShowComments" {
            if let commentsVC = segue.destination as? CommentsViewController,
               let post = sender as? Post {
                commentsVC.post = post
            }
        }
        
        // 2. Show User Profile
        if segue.identifier == "ShowUserProfile" {
            if let profileVC = segue.destination as? ProfileViewController,
               let user = sender as? User {
                profileVC.user = user
            }
        }
        
        // 3. New Post Callback
        if let newPostVC = segue.destination as? NewPostViewController {
            newPostVC.onPostSuccess = { [weak self] in
                self?.loadData()
            }
        }
    }
}

// MARK: - UICollectionView DataSource
extension CommunityViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommunityPostCollectionViewCell.identifier,
            for: indexPath
        ) as? CommunityPostCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let post = posts[indexPath.item]
        cell.configure(with: post)
        
        // Handle like action
        cell.onLikeTapped = { [weak self] isLiked, newCount in
            // Controller acts as delegate to Repository
            PostRepository.shared.updateLikeStatus(
                forPostId: post.id,
                isLiked: isLiked,
                newCount: newCount
            )
            // No need to manually update local 'posts' array or reload row if we trust the Notification trigger
            // But if we want instant optimistic UI, we could.
            // However, the cell callback 'onLikeTapped' often comes from user interaction.
            // The architectural goal says "Controllers should never directly modify Post properties".
            // So we delegate to Repository. The Repository fires notification. We catch notification and reload.
            // This ensures consistency.
        }

        
        // Handle comment action
        cell.onCommentTapped = { [weak self] in
            self?.performSegue(withIdentifier: "ShowComments", sender: post)
        }
        
        // Handle save action
        cell.onSaveTapped = { [weak self] in
            PostRepository.shared.toggleSave(postId: post.id)
            // Local update is handled via notification reload or simply by next fetch
        }
        
        // Handle profile tap
        cell.onProfileTapped = { [weak self] in
            if let author = post.author {
                self?.performSegue(withIdentifier: "ShowUserProfile", sender: author)
            }
        }
        
        // Handle menu tap
        cell.onMenuTapped = { [weak self] in
            self?.showPostMenu(for: post)
        }
        
        return cell
    }
}

// MARK: - Post Menu
extension CommunityViewController {
    func showPostMenu(for post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Report — always visible
        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive) { [weak self] _ in
            let confirm = UIAlertController(title: "Post Reported", message: "Thank you for reporting. We'll review this post.", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirm, animated: true)
        })
        
        // Delete — only for post owner
        let currentUserId = UserSession.shared.currentLoggedInUserID
        if post.userId == currentUserId {
            alert.addAction(UIAlertAction(title: "Delete Post", style: .destructive) { _ in
                PostRepository.shared.deletePost(id: post.id)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
