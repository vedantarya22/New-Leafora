import UIKit

class CommunityViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    // MARK: - Data
    private var posts: [Post] = []
    
    let timestamp = ISO8601DateFormatter().string(from: Date())

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
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
    
    // MARK: - Layout Generator
    private func createLayout() -> UICollectionViewLayout {
        // Item
        // We use .estimated(600) to let the XIB calculate its own height
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(450)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        // The group must also be estimated to allow the item to expand
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(600)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0 // Spacing between posts
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        CommunityDataStore.shared.fetchAllPosts { [weak self] downloadedPosts in
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
            guard let self = self else { return }
            guard let index = self.posts.firstIndex(where: { $0.id == post.id }) else { return }

            self.posts[index].isLiked = isLiked
            self.posts[index].likesCount = newCount

            CommunityDataStore.shared.updateLikeStatus(
                forPostId: post.id,
                isLiked: isLiked,
                newCount: newCount
            )
        }

        
        // Handle comment action
        cell.onCommentTapped = { [weak self] in
            self?.performSegue(withIdentifier: "ShowComments", sender: post)
        }
        
        // Handle save action
        cell.onSaveTapped = { [weak self] in
            guard let self = self else { return }
            CommunityDataStore.shared.toggleSave(postId: post.id)
            self.posts[indexPath.item].isSaved.toggle()
        }
        
        // Handle profile tap
        cell.onProfileTapped = { [weak self] in
            if let author = post.author {
                self?.performSegue(withIdentifier: "ShowUserProfile", sender: author)
            }
        }
        
        return cell
    }
}
