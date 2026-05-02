import Foundation
import UIKit

// MARK: - Community (Feed, Posts, Comments)
extension NetworkManager {
    
    // MARK: - Feed
    func fetchFeed(page: Int = 1, completion: @escaping (FeedResponse?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/feed?page=\(page)") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, response, error in
            if let error = error { print(" fetchFeed error: \(error.localizedDescription)") }
            guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
            let feed = try? JSONDecoder().decode(FeedResponse.self, from: data)
            DispatchQueue.main.async { completion(feed) }
        }.resume()
    }
    
    // MARK: - Create Post
    func createPost(imageUrl: String, caption: String, completion: @escaping (Post?) -> Void) {
        guard let url = URL(string: baseURL + "/posts") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "postImageString": imageUrl,
            "caption":         caption
        ])
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(" createPost network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let post = try JSONDecoder().decode(Post.self, from: data)
                DispatchQueue.main.async { completion(post) }
            } catch {
                print(" createPost decode error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
    
    // MARK: - Delete Post
    func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    // MARK: - Toggle Like
    func toggleLike(postId: String, completion: @escaping (Bool?, Int?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)/like") else { return }
        let request = makeRequest(url: url, method: "POST")
        session.dataTask(with: request) { data, _, error in
            if let error = error { print(" toggleLike error: \(error.localizedDescription)") }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { DispatchQueue.main.async { completion(nil, nil) }; return }
            DispatchQueue.main.async {
                completion(json["isLiked"] as? Bool, json["likesCount"] as? Int)
            }
        }.resume()
    }
    
    // MARK: - Toggle Save
    func toggleSave(postId: String, completion: @escaping (Bool?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)/save") else { return }
        let request = makeRequest(url: url, method: "POST")
        session.dataTask(with: request) { data, _, error in
            if let error = error { print(" toggleSave error: \(error.localizedDescription)") }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(json["isSaved"] as? Bool) }
        }.resume()
    }
    
    // MARK: - Fetch Comments
    func fetchComments(postId: String, page: Int = 1, completion: @escaping (CommentsResponse?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)/comments?page=\(page)") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
            let response = try? JSONDecoder().decode(CommentsResponse.self, from: data)
            DispatchQueue.main.async { completion(response) }
        }.resume()
    }
    
    // MARK: - Add Comment
    func addComment(postId: String, text: String, completion: @escaping (Comment?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)/comments") else { return }
        let request = makeRequest(url: url, method: "POST", body: ["text": text])
        session.dataTask(with: request) { data, response, _ in
            guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
            let comment = try? JSONDecoder().decode(Comment.self, from: data)
            DispatchQueue.main.async { completion(comment) }
        }.resume()
    }
    
    // MARK: - Delete Comment
    func deleteComment(postId: String, commentId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/posts/\(postId)/comments/\(commentId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    // MARK: - Saved Posts
    func fetchSavedPosts(completion: @escaping ([Post]?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/saved") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
            let posts = try? JSONDecoder().decode([Post].self, from: data)
            DispatchQueue.main.async { completion(posts) }
        }.resume()
    }
    
    // MARK: - User Posts
    func fetchUserPosts(userId: String, completion: @escaping ([Post]?) -> Void) {
        guard let url = URL(string: baseURL + "/posts/user/\(userId)") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
            let posts = try? JSONDecoder().decode([Post].self, from: data)
            DispatchQueue.main.async { completion(posts) }
        }.resume()
    }
}
