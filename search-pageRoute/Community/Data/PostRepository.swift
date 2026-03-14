//
//  PostRepository.swift
//  Leafora
//

import Foundation
import UIKit

extension Notification.Name {
    static let didUpdatePosts = Notification.Name("didUpdatePosts")
    static let didUpdatePost  = Notification.Name("didUpdatePost")
}

class PostRepository {
    static let shared = PostRepository()
    private init() {}

    // MARK: - Source of Truth
    private(set) var posts: [Post] = []

    // MARK: - Fetch Feed
    func fetchAllPosts(completion: @escaping ([Post]) -> Void) {
        NetworkManager.shared.fetchFeed(page: 1) { [weak self] response in
            guard let self = self else { return }
            let fetched = response?.posts ?? []
            self.posts = fetched
            self.notifyUpdate()
            completion(fetched)
        }
    }

    // MARK: - Fetch User Posts (for Profile screen)
    func fetchPosts(forUserId userId: String, completion: @escaping ([Post]) -> Void) {
        NetworkManager.shared.fetchUserPosts(userId: userId) { posts in
            completion(posts ?? [])
        }
    }

    // MARK: - Fetch Saved Posts
    func fetchSavedPostsForCurrentUser(completion: @escaping ([Post]) -> Void) {
        NetworkManager.shared.fetchSavedPosts { posts in
            completion(posts ?? [])
        }
    }

    // MARK: - Get Single Post (from in-memory cache)
    func getPost(id: String) -> Post? {
        return posts.first(where: { $0.id == id })
    }

    // MARK: - Toggle Like  (optimistic UI + backend sync)
    func toggleLike(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }

        // 1. Optimistic update
        let wasLiked = posts[index].isLikedByMe
        posts[index].isLikedByMe  = !wasLiked
        posts[index].likesCount   = max(0, posts[index].likesCount + (wasLiked ? -1 : 1))
        notifyPostUpdate(postId: postId)

        // 2. Sync to backend
        NetworkManager.shared.toggleLike(postId: postId) { [weak self] isLiked, likesCount in
            guard let self = self,
                  let idx = self.posts.firstIndex(where: { $0.id == postId }),
                  let isLiked = isLiked,
                  let likesCount = likesCount
            else { return }
            // Reconcile with server truth
            self.posts[idx].isLikedByMe = isLiked
            self.posts[idx].likesCount  = likesCount
            self.notifyPostUpdate(postId: postId)
        }
    }

    // MARK: - Toggle Save  (optimistic UI + backend sync)
    func toggleSave(postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }

        // 1. Optimistic update
        posts[index].isSaved = !posts[index].isSaved
        notifyPostUpdate(postId: postId)

        // 2. Sync to backend
        NetworkManager.shared.toggleSave(postId: postId) { [weak self] isSaved in
            guard let self = self,
                  let idx = self.posts.firstIndex(where: { $0.id == postId }),
                  let isSaved = isSaved
            else { return }
            self.posts[idx].isSaved = isSaved
            self.notifyPostUpdate(postId: postId)
        }
    }

    // MARK: - Delete Post  (local first, then backend)
    func deletePost(id: String) {
        posts.removeAll { $0.id == id }
        notifyUpdate()

        NetworkManager.shared.deletePost(postId: id) { success in
            if !success { print("⚠️ deletePost backend failed for \(id)") }
        }
    }

    // MARK: - Create New Post  (upload image → create post → insert at top)
    func addNewPost(caption: String, image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Could not compress image")
            completion(false)
            return
        }

        // Step 1: Upload image to Cloudinary via backend
        NetworkManager.shared.uploadImageToCloudinary(imageData) { [weak self] imageUrl in
            guard let self = self, let imageUrl = imageUrl else {
                print("❌ Cloudinary upload failed")
                DispatchQueue.main.async { completion(false) }
                return
            }

            // Step 2: Create post on backend
            NetworkManager.shared.createPost(imageUrl: imageUrl, caption: caption) { post in
                guard let post = post else {
                    print("❌ createPost failed")
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                // Step 3: Insert at top of local feed
                self.posts.insert(post, at: 0)
                self.notifyUpdate()
                print("✅ New post created: \(post.id)")
                DispatchQueue.main.async { completion(true) }
            }
        }
    }

    // MARK: - Comments  (delegated directly to NetworkManager)
    func fetchComments(postId: String, completion: @escaping ([Comment]) -> Void) {
        NetworkManager.shared.fetchComments(postId: postId) { response in
            completion(response?.comments ?? [])
        }
    }

    func addComment(postId: String, text: String, completion: @escaping (Comment?) -> Void) {
        NetworkManager.shared.addComment(postId: postId, text: text) { [weak self] comment in
            guard let self = self, let comment = comment else {
                completion(nil)
                return
            }
            // Update local commentsCount
            if let idx = self.posts.firstIndex(where: { $0.id == postId }) {
                self.posts[idx].commentsCount += 1
                self.notifyPostUpdate(postId: postId)
            }
            completion(comment)
        }
    }

    func deleteComment(postId: String, commentId: String, completion: @escaping (Bool) -> Void) {
        NetworkManager.shared.deleteComment(postId: postId, commentId: commentId) { [weak self] success in
            guard let self = self, success else {
                completion(false)
                return
            }
            if let idx = self.posts.firstIndex(where: { $0.id == postId }) {
                self.posts[idx].commentsCount = max(0, self.posts[idx].commentsCount - 1)
                self.notifyPostUpdate(postId: postId)
            }
            completion(true)
        }
    }

    // MARK: - Time Ago Helper  (used by Post.displayTimestamp & Comment.displayTimestamp)
    func timeAgo(from dateString: String) -> String {
        guard !dateString.isEmpty else { return "Just now" }

        let isoFormatter = ISO8601DateFormatter()

        // Try with fractional seconds first (MongoDB default)
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            return format(date: date)
        }

        // Fallback without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return format(date: date)
        }

        return "Just now"
    }

    private func format(date: Date) -> String {
        let s = Int(Date().timeIntervalSince(date))
        let m = 60, h = 3600, d = 86400, w = 604800
        switch s {
        case ..<m:      return "Just now"
        case ..<h:      return "\(s / m)m ago"
        case ..<d:      return "\(s / h)h ago"
        case ..<w:      return "\(s / d)d ago"
        default:        return "\(s / w)w ago"
        }
    }

    // MARK: - Notifications
    private func notifyUpdate() {
        NotificationCenter.default.post(name: .didUpdatePosts, object: nil)
    }

    private func notifyPostUpdate(postId: String) {
        NotificationCenter.default.post(name: .didUpdatePost, object: nil, userInfo: ["postId": postId])
    }
}
