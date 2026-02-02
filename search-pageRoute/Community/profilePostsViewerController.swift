import UIKit

class profilePostsViewerController: UIViewController, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    // The single post passed from the Profile Screen
    var post: Post?
    
    // Internal array for the CollectionView DataSource
    private var posts: [Post] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSinglePostUpdate(_:)), name: .didUpdatePost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostsUpdate), name: .didUpdatePosts, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleSinglePostUpdate(_ notification: Notification) {
        if let updatedPostId = notification.userInfo?["postId"] as? String,
           updatedPostId == post?.id {
            refreshPost()
        }
    }
    
    @objc func handlePostsUpdate() {
        refreshPost()
    }
    
    private func refreshPost() {
        guard let currentId = post?.id else { return }
        if let freshPost = PostRepository.shared.getPost(id: currentId) {
            self.post = freshPost
            self.posts = [freshPost]
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Setup
    private func setupData() {
        // Wrap the single post into the array
        if let post = post {
            self.posts = [post]
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 1. Register XIB
        let nib = UINib(nibName: "CommunityPostCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CommunityPostCollectionViewCell")
        
        // 2. Set the Compositional Layout (Dynamic Height)
        collectionView.collectionViewLayout = createLayout()
        
        collectionView.delaysContentTouches = false
    }
    
    // MARK: - Layout Generator
    private func createLayout() -> UICollectionViewLayout {
        // Item
        // .estimated(600) allows the XIB to determine its own height based on content
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(600)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowComments" {
            if let commentsVC = segue.destination as? CommentsViewController,
               let post = sender as? Post {
                commentsVC.post = post
            }
        }
    }
}

// MARK: - UICollectionView DataSource
extension profilePostsViewerController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CommunityPostCollectionViewCell",
            for: indexPath
        ) as? CommunityPostCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let currentPost = posts[indexPath.item]
        cell.configure(with: currentPost)
        
        // MARK: - Handle Actions
        
        // 1. Like Action
        cell.onLikeTapped = { (isLiked, newCount) in
            // Update Database
            PostRepository.shared.updateLikeStatus(
                forPostId: currentPost.id,
                isLiked: isLiked,
                newCount: newCount
            )
        }
        
        // 2. Save Action
        cell.onSaveTapped = {
            PostRepository.shared.toggleSave(postId: currentPost.id)
        }
        
        // 3. Comment Action
        cell.onCommentTapped = { [weak self] in
            // Trigger the segue to comments
            self?.performSegue(withIdentifier: "ShowComments", sender: currentPost)
        }
        
        return cell
    }
}
