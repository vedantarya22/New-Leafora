//
//  ProfileViewController.swift
//  garden_app
//
//  Created by SDC-USER on 09/12/25.
//
// community profile options
 
import UIKit

import UIKit

class ProfileViewController: UIViewController, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Always refresh user data to ensure we show the latest (e.g. if edited in another tab)
        refreshUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ✅ App theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        setupUI()
        checkIsCurrentUser()
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataUpdate), name: .didUpdatePosts, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDataUpdate() {
        refreshData()
    }
    
    func refreshUser() {
        if let currentUserId = user?.id {
             // Re-fetch object from session "source of truth"
            if let freshUser = UserSession.shared.user(withId: currentUserId) {
                self.user = freshUser
                updateUI()
            }
        }
    }
    
    func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        gradientLayer.frame = view.bounds
    }
    
    func checkIsCurrentUser() {
        //Fetch the "Logged In" user
        if let passedUser = self.user {
            self.isCurrentUser = UserSession.shared.isCurrentUser(userID: passedUser.id)
        } else {
            self.isCurrentUser = true
            // If no user passed, assume current user and fetch details
            UserSession.shared.fetchCurrentUser { [weak self] user in
                self?.user = user
                self?.updateUI()
            }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        refreshData()
    }
    
    func refreshData() {
        guard let user = user else { return }
        
        if postsSegmentedControl.selectedSegmentIndex == 0 {
            // Grid posts
            PostRepository.shared.fetchPosts(forUserId: user.id) { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        } else {
            // Saved posts (ONLY current user)
            // Ideally non-current users shouldn't see this segment or it should be hidden
            // Logic below assumes if we are here we want saved posts
            PostRepository.shared.fetchSavedPostsForCurrentUser { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        }
    }
    
    
    func updateUI() {
        guard let user = user else { return }
        
        print(isCurrentUser, "Current USER")
        
        //Fill Text
        nameLabel.text = user.name
        handleLabel.text = "@\(user.username)"
        // Calculate plant count for current user from local garden data
        let plantCount = isCurrentUser ? PlantStore.shared.totalPlants : 0
        statsLabel.text = "\(plantCount) \(plantCount == 1 ? "Plant" : "Plants") in Garden"
        let imageName = UserSession.shared.profileImageString(for: user.id)
        profileImageView.configureImage(with: imageName)
        
        
        navigationItem.rightBarButtonItem = menuButton
        
        //Toggle UI based on Identity
        if isCurrentUser {
            //otherUserButtonsStack.isHidden = true
            messageButton.isHidden = true
            //self?.collectionView.reloadData()
            
        } else {
            //otherUserButtonsStack.isHidden = false
            showOtherUserStats()
            if postsSegmentedControl.numberOfSegments > 1 {
                postsSegmentedControl.removeSegment(at: 1, animated: false)
            }
            postsSegmentedControl.isUserInteractionEnabled = false
            
        }
        
        refreshData()
        
        setupMenu()
    }
    
    private func showOtherUserStats() {
        // For other users, show 0 for now until a backend route is added
        statsLabel.text = "0 Plants in Garden"
    }
    
    
    
    
    
    // Actions Performed
    
    @IBAction func messageTapped(_ sender: UIButton) {
        print("Opening Chat with \(user?.name ?? "User")...")
        performSegue(withIdentifier: "OpenChat", sender: self.user)
    }
    
    // This is the bridge that passes data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenChat" {
            if let chatVC = segue.destination as? ChatViewController {
                if let userToPass = sender as? User {
                    chatVC.user = userToPass
                }
            }
        } else if segue.identifier == "ShowPostFromProfile" {
            if let destinationVC = segue.destination as? profilePostsViewerController,
               let postToSend = sender as? Post {
                destinationVC.post = postToSend
            }
        }
    }
        
        
        func setupMenu() {
            //Define Actions for "My Profile"
            let editAction = UIAction(title: "Edit Profile", image: UIImage(systemName: "pencil")) { [weak self] _ in
                            self?.openPersonalInfoSettings()
                  }
            
//            let settingsAction = UIAction(title: "Settings", image: UIImage(systemName: "gearshape")) { _ in
//                print("Settings tapped")
//            }
            
            let blockAction = UIAction(title: "Block", image: UIImage(systemName: "hand.raised.slash"), attributes: .destructive) { _ in
                print("Block tapped")
            }
            
//            let shareAction = UIAction(title: "Share Profile", image: UIImage(systemName: "square.and.arrow.up")) { _ in
//                print("Share tapped")
//            }
            
            //Choose which menu to show
            var menuItems: [UIAction] = []
            
            if isCurrentUser {
                menuItems = [editAction, /*settingsAction*/]
            } else {
                menuItems = [blockAction]
            }
            
            let demoMenu = UIMenu(title: isCurrentUser ? "My Options" : "User Options", children: menuItems)
            
            menuButton.menu = demoMenu
        }
        
//        func openEditProfile() {
//            //open the Edit Screen
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let editVC = storyboard.instantiateViewController(
//                withIdentifier: "EditProfileViewController"
//            ) as? EditProfileViewController {
//                editVC.user = self.user
//                present(editVC, animated: true)
//            }
//        }
    
    @objc func openPersonalInfoSettings() {
        // 1. Get the Profile storyboard
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        
        // 2. Instantiate the Personal Info VC using its ID
        if let personalInfoVC = storyboard.instantiateViewController(withIdentifier: "Personal_InfoViewController") as? Personal_InfoViewController {
            
            // 3. Push it onto the navigation stack
            // (Make sure your Community VC is inside a Navigation Controller)
            navigationController?.pushViewController(personalInfoVC, animated: true)
            
            // OR present it modally if you prefer:
            // present(personalInfoVC, animated: true)
        }
    }
        
        
        
        // CollectionView
        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {
            return userPosts.count
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "ProfileGridCell",
                for: indexPath
            ) as! ProfileGridCell
            let post = userPosts[indexPath.row]
            cell.imageView.configureImage(with: post.postImageString)
            return cell
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
            // 3 columns, 1px gap between each = 2 gaps total
            let spacing: CGFloat = 1
            let totalSpacing = spacing * 2
            let width = (collectionView.frame.width - totalSpacing) / 3
            return CGSize(width: width, height: width)
        }
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
            return 1
        }
        
        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumLineSpacingForSectionAt section: Int
        ) -> CGFloat {
            return 1
        }
        
        // Detect the tap
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // find oout which post was tapped and return that post in the array
            let selectedPost = userPosts[indexPath.item]
            performSegue(withIdentifier: "ShowPostFromProfile", sender: selectedPost)
        }
        
        
    }

