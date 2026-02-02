//
//  ProfileViewController.swift
//  garden_app
//
//  Created by SDC-USER on 09/12/25.
//
// community profile options
 
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkIsCurrentUser()
        updateUI()
    }
    
    func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func checkIsCurrentUser() {
        //Fetch the "Logged In" user (Shubham/u2)
        if let passedUser = self.user {
            self.isCurrentUser = CommunityDataStore.shared.isCurrentUser(userID: passedUser.id)
        } else {
            
            self.isCurrentUser = true
        }
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        guard let user = user else { return }
        
        if sender.selectedSegmentIndex == 0 {
            // Grid posts
            CommunityDataStore.shared.fetchPosts(forUserId: user.id) { [weak self] posts in
                self?.userPosts = posts
                self?.collectionView.reloadData()
            }
        } else {
            // Saved posts (ONLY current user)
            CommunityDataStore.shared.fetchSavedPostsForCurrentUser { [weak self] posts in
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
        //statsLabel.text = user.searchSubtitle
        let imageName = CommunityDataStore.shared.profileImageString(for: user.id)
        profileImageView.configureImage(with: imageName)
        
        
        navigationItem.rightBarButtonItem = menuButton
        
        //Toggle UI based on Identity
        if isCurrentUser {
            //otherUserButtonsStack.isHidden = true
            //updateCurrentUserStats()
            messageButton.isHidden = true
            //self?.collectionView.reloadData()
            
        } else {
            //otherUserButtonsStack.isHidden = false
            showOtherUserStats()
            if postsSegmentedControl.numberOfSegments > 1 {
                postsSegmentedControl.removeSegment(at: 1, animated: false)
            }

            
        }
        
        //Fetch Posts
        CommunityDataStore.shared.fetchPosts(forUserId: user.id) {
            [weak self] posts in
            self?.userPosts = posts
            self?.collectionView.reloadData()
        }
        
        setupMenu()
    }
    
//    private func updateCurrentUserStats() {
//        let allUserPlants = PlantStore.shared.plants
//        
//        let totalPlants = allUserPlants.reduce(0) { $0 + $1.quantity }
//        
//        if( totalPlants == 1){
//            statsLabel.text = "\(totalPlants) Plant"
//        } else{
//            statsLabel.text = "\(totalPlants) Plants"
//        }
//    }
    private func showOtherUserStats() {
        statsLabel.text = "12 Plants • 3 Sites"
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
            //let editAction = UIAction(title: "Edit Profile", image: UIImage(systemName: "pencil"))*/ //{ [weak self] _ in
            //                self?.openEditProfile()
            //      }
            
            let settingsAction = UIAction(title: "Settings", image: UIImage(systemName: "gearshape")) { _ in
                print("Settings tapped")
            }
            
            let blockAction = UIAction(title: "Block", image: UIImage(systemName: "hand.raised.slash"), attributes: .destructive) { _ in
                print("Block tapped")
            }
            
//            let shareAction = UIAction(title: "Share Profile", image: UIImage(systemName: "square.and.arrow.up")) { _ in
//                print("Share tapped")
//            }
            
            //Choose which menu to show
            var menuItems: [UIAction] = []
            
            if isCurrentUser {
                menuItems = [/*editAction,*/ settingsAction]
            } else {
                menuItems = [blockAction]
            }
            
            let demoMenu = UIMenu(title: isCurrentUser ? "My Options" : "User Options", children: menuItems)
            
            menuButton.menu = demoMenu
        }
        
        func openEditProfile() {
            //open the Edit Screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let editVC = storyboard.instantiateViewController(
                withIdentifier: "EditProfileViewController"
            ) as? EditProfileViewController {
                editVC.user = self.user
                present(editVC, animated: true)
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
            let width = (collectionView.frame.width - 2) / 3
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

