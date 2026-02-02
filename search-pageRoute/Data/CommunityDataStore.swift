//import Foundation
//import UIKit
//
//class CommunityDataStore {
//    
//    static let shared = CommunityDataStore()
//    
//    private var users: [User] = []
//    private var posts: [Post] = []
//    private var savedPostsByUser: [String: Set<String>] = [:]
//
//    
//    var currentLoggedInUserID: String = "u2"
//    
//    private init() {
//        seedDummyData()
//    }
//    
//    func fetchAllPosts(completion: @escaping ([Post]) -> Void) {
//        let userId = currentLoggedInUserID
//        let savedIDs = savedPostsByUser[userId] ?? []
//
//        let updatedPosts = posts.map { post in
//            var post = post
//            post.isSaved = savedIDs.contains(post.id)
//            return post
//        }
//
//        completion(updatedPosts)
//    }
//    
//    func fetchSavedPostsForCurrentUser(completion: @escaping ([Post]) -> Void) {
//        let userId = currentLoggedInUserID
//        let savedIDs = savedPostsByUser[userId] ?? []
//
//        let savedPosts = posts
//            .filter { savedIDs.contains($0.id) }
//            .map { post in
//                var post = post
//                post.isSaved = true
//                return post
//            }
//
//        completion(savedPosts)
//    }
//
//
//
//    func toggleSave(postId: String) {
//        let userId = currentLoggedInUserID
//
//        if savedPostsByUser[userId] == nil {
//            savedPostsByUser[userId] = []
//        }
//
//        if savedPostsByUser[userId]!.contains(postId) {
//            savedPostsByUser[userId]!.remove(postId)
//        } else {
//            savedPostsByUser[userId]!.insert(postId)
//        }
//    }
//
//    func fetchPosts(forUserId userId: String, completion: @escaping ([Post]) -> Void) {
//        let savedIDs = savedPostsByUser[currentLoggedInUserID] ?? []
//
//        let userPosts = posts
//            .filter { $0.userId == userId }
//            .map { post in
//                var post = post
//                post.isSaved = savedIDs.contains(post.id)
//                return post
//            }
//
//        completion(userPosts)
//    }
//
//    
//    func fetchAllUsers(completion: @escaping ([User]) -> Void) {
//        completion(self.users)
//    }
//    
//    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
//        let foundUser = self.users.first(where: { $0.id == self.currentLoggedInUserID })
//        completion(foundUser)
//    }
//    
//    func isCurrentUser(userID: String) -> Bool {
//        return currentLoggedInUserID == userID
//    }
//    
//    // MARK: - Seed Data
//    private func seedDummyData() {
//        let vedant = User(
//            id: "u1",
//            name: "Vedant Arya",
//            username: "vedantarya.22",
//            profileImageString: "person.circle",
//            plantCount: 12
//        )
//        
//        let shubham = User(
//            id: "u2",
//            name: "Shubham",
//            username: "shubham_r24",
//            profileImageString: "person.circle.fill",
//            plantCount: 32
//        )
//        
//        let arya = User(
//            id: "u3",
//            name: "Arya Kulkarni",
//            username: "arya.grows",
//            profileImageString: "leaf.circle",
//            plantCount: 7
//        )
//        
//        let rohan = User(
//            id: "u4",
//            name: "Rohan Mehta",
//            username: "rohan.plants",
//            profileImageString: "tree.circle",
//            plantCount: 18
//        )
//        
//        let neha = User(
//            id: "u5",
//            name: "Neha Sharma",
//            username: "neha.greens",
//            profileImageString: "sun.max.circle",
//            plantCount: 25
//        )
//        
//        let kabir = User(
//            id: "u6",
//            name: "Kabir Verma",
//            username: "kabir.gardens",
//            profileImageString: "drop.circle",
//            plantCount: 9
//        )
//        
//        
//        self.users = [
//            vedant,
//            shubham,
//            arya,
//            rohan,
//            neha,
//            kabir
//        ]
//        
//        let p1 = Post(
//            id: "p1",
//            userId: "u1",
//            postImageString: "plant_vedant",
//            likesCount: 5,
//            caption: "New leaf alert! 🌿",
//            timestamp: Date(),
//            author: vedant
//        )
//        
//        let p2 = Post(
//            id: "p2",
//            userId: "u2",
//            postImageString: "plant_shubham",
//            likesCount: 3,
//            caption: "Watering day 💧",
//            timestamp: Date(),
//            author: shubham
//        )
//        
//        let p3 = Post(
//            id: "p3",
//            userId: "u3",
//            postImageString: "plant_arya",
//            likesCount: 12,
//            caption: "My balcony jungle is thriving 🌱",
//            timestamp: Date(),
//            author: arya
//        )
//        
//        let p4 = Post(
//            id: "p4",
//            userId: "u4",
//            postImageString: "plant_rohan",
//            likesCount: 8,
//            caption: "Repotted my monstera today 🪴",
//            timestamp: Date(),
//            author: rohan
//        )
//        
//        let p5 = Post(
//            id: "p5",
//            userId: "u5",
//            postImageString: "plant_neha",
//            likesCount: 21,
//            caption: "Sunlight + patience = happy plants ☀️",
//            timestamp: Date(),
//            author: neha
//        )
//        
//        let p6 = Post(
//            id: "p6",
//            userId: "u6",
//            postImageString: "plant_kabir",
//            likesCount: 2,
//            caption: "Still learning, but loving it 🌿",
//            timestamp: Date(),
//            author: kabir
//        )
//        self.users = [vedant, shubham]
//        
//        self.posts = [p1, p2, p3, p4, p5, p6]
//    }
//    
//    func updateLikeStatus(forPostId postId: String, isLiked: Bool, newCount: Int) {
//        if let index = posts.firstIndex(where: { $0.id == postId }) {
//            posts[index].isLiked = isLiked
//            posts[index].likesCount = newCount
//        }
//    }
//    
//    func profileImageString(for userID: String) -> String {
//        if let user = users.first(where: { $0.id == userID }) {
//            return user.profileImageString
//        }
//        
//        // Fallback (safety)
//        return "person.circle"
//    }
//    //         Helper to find where to save images on the phone
//    private func getDocumentsDirectory() -> URL {
//        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//    
//    
//    func addNewPost(caption: String, image: UIImage, currentUser: User, completion: @escaping (Bool) -> Void) {
//        
//        //Save Image to Disk
//        let imageID = UUID().uuidString // Generate unique name
//        if let data = image.jpegData(compressionQuality: 0.8) {
//            let filename = getDocumentsDirectory().appendingPathComponent(imageID)
//            try? data.write(to: filename)
//        }
//        
//        //Create the Post Object
//        let newPost = Post(
//            id: UUID().uuidString,
//            userId: currentUser.id,
//            postImageString: imageID,
//            likesCount: 0,
//            caption: caption,
//            timestamp: Date(),
//            author: currentUser
//        )
//        
//        //Add to the top of the list
//        self.posts.insert(newPost, at: 0)
//        
//        // show success
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            completion(true)
//        }
//    }
//}
