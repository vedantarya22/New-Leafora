import UIKit

class profilePostsViewerController: UIViewController, UICollectionViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    var post: Post?
    private var posts: [Post] = []
    private var expandedPostIds: Set<String> = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupCollectionView()

        NotificationCenter.default.addObserver(self, selector: #selector(handleSinglePostUpdate(_:)),
                                               name: .didUpdatePost, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostsUpdate),
                                               name: .didUpdatePosts, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification Handlers
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
            self.post  = freshPost
            self.posts = [freshPost]
            self.collectionView.reloadData()
        }
    }

    // MARK: - Setup
    private func setupData() {
        if let post = post {
            self.posts = [post]
        }
    }

    private func setupCollectionView() {
        collectionView.delegate   = self
        collectionView.dataSource = self

        let nib = UINib(nibName: "CommunityPostCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CommunityPostCollectionViewCell")
        collectionView.collectionViewLayout = createLayout()
        collectionView.delaysContentTouches = false
    }

    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(350))
        let item      = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(350))
        let group     = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section   = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Rotation
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowComments",
           let commentsVC = segue.destination as? CommentsViewController,
           let post = sender as? Post {
            commentsVC.post = post
        }
    }
}

// MARK: - UICollectionView DataSource
extension profilePostsViewerController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        posts.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CommunityPostCollectionViewCell",
            for: indexPath
        ) as? CommunityPostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let currentPost = posts[indexPath.item]
        let isExpanded  = expandedPostIds.contains(currentPost.id)
        cell.configure(with: currentPost, isExpanded: isExpanded)

        // ✅ Capture postId as String before closures to avoid SwiftUI .id() ambiguity
        let postId = currentPost.id

        // 1. Like
        cell.onLikeTapped = {
            PostRepository.shared.toggleLike(postId: postId)
        }

        // 2. Save
        cell.onSaveTapped = {
            PostRepository.shared.toggleSave(postId: postId)
        }

        // 3. Comments
        cell.onCommentTapped = { [weak self] in
            self?.performSegue(withIdentifier: "ShowComments", sender: currentPost)
        }

        // 4. Menu
        cell.onMenuTapped = { [weak self] in
            self?.showPostMenu(for: currentPost)
        }

        // 5. Expand caption
        cell.onSeeMoreTapped = { [weak self] in
            guard let self = self else { return }
            if self.expandedPostIds.contains(postId) {
                self.expandedPostIds.remove(postId)
            } else {
                self.expandedPostIds.insert(postId)
            }
            self.collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }
}

// MARK: - Post Menu
extension profilePostsViewerController {

    func showPostMenu(for post: Post) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Report Post", style: .destructive) { [weak self] _ in
            let confirm = UIAlertController(
                title: "Post Reported",
                message: "Thank you for reporting. We'll review this post.",
                preferredStyle: .alert
            )
            confirm.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(confirm, animated: true)
        })

        if post.userId == UserSession.shared.currentLoggedInUserID {
            alert.addAction(UIAlertAction(title: "Delete Post", style: .destructive) { [weak self] _ in
                PostRepository.shared.deletePost(id: post.id)
                self?.navigationController?.popViewController(animated: true)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
