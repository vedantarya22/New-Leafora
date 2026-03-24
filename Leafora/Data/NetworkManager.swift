//
//  NetworkManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

class NetworkManager{
    static let shared = NetworkManager()
    let baseURL = "https://plantappbackend-933m.onrender.com/api"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    private func makeRequest(url: URL,method:String, body: [String:Any]? = nil)-> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = KeychainManager.shared.getToken() {
                   request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
               }
        
        if let body = body{
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }
}


// MARK: - Auth
extension NetworkManager {

    func signup(name: String, username: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: baseURL + "/auth/signup") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "name":     name,
            "username": username,
            "email":    email,
            "password": password
        ])
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                DispatchQueue.main.async { completion(false, "Network error") }
                return
            }

            if let token  = json["token"] as? String,
               let user   = json["user"]  as? [String: Any],
               let userId = user["_id"]   as? String {

                KeychainManager.shared.saveToken(token)
                KeychainManager.shared.saveUserId(userId)
                print("✅ Signup success, userId: \(userId)")
                DispatchQueue.main.async { completion(true, nil) }

            } else {
                let message = json["message"] as? String ?? "Signup failed"
                print("❌ Signup error: \(message)")
                DispatchQueue.main.async { completion(false, message) }
            }
        }.resume()
    }

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: baseURL + "/auth/login") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "email":    email,
            "password": password
        ])
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                DispatchQueue.main.async { completion(false, "Network error") }
                return
            }

            if let token  = json["token"] as? String,
               let user   = json["user"]  as? [String: Any],
               let userId = user["_id"]   as? String {

                KeychainManager.shared.saveToken(token)
                KeychainManager.shared.saveUserId(userId)

                PlantStore.shared.setPlants([])
                SiteStore.shared.setSites([])
                PlantCatalogueCache.shared.invalidate()

                print("✅ Login success, userId: \(userId)")
                DispatchQueue.main.async { completion(true, nil) }

            } else {
                let message = json["message"] as? String ?? "Login failed"
                print("❌ Login error: \(message)")
                DispatchQueue.main.async { completion(false, message) }
            }
        }.resume()
    }

    func logout() {
        ChatSocketManager.shared.disconnect()
        KeychainManager.shared.clearAll()
        UserSession.shared.clearSession()
        PlantStore.shared.setPlants([])
        SiteStore.shared.setSites([])
        PlantCatalogueCache.shared.invalidate()
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        print("✅ Logged out")
    }
}


//MARK:- Create USER
extension NetworkManager {
    
    func createUser(name: String, username: String, email: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "name": name,
            "username": username,
            "email": email,
            "profileImageString": "person.circle.fill"
        ])
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
}

// MARK: - Plants (Catalogue)
extension NetworkManager {
    
    func fetchAllPlants(completion: @escaping ([Plant]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/plants") else { return }
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
            }
            #if DEBUG
            // Verbose logging disabled - can cause performance issues with large payloads
            // if let data = data, let raw = String(data: data, encoding: .utf8) {
            //     print("📦 Raw response: \(raw)")
            // }
            #endif

            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let decoder = JSONDecoder()
            let plants = try? decoder.decode([Plant].self, from: data)
            DispatchQueue.main.async { completion(plants) }
        }.resume()
    }
    
    func fetchPlant(by id: String, completion: @escaping (Plant?) -> Void) {
        guard let url = URL(string: "\(baseURL)/plants/\(id)") else { return }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let plant = try? JSONDecoder().decode(Plant.self, from: data)
            DispatchQueue.main.async { completion(plant) }
        }.resume()
    }
}

// MARK: - Sites
extension NetworkManager {
    
    func addSite(name: String, icon: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: baseURL + "/sites") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "name": name,
            "icon": icon
        ])
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
    
    func getUserSites(completion: @escaping ([MyGardenSite]?) -> Void) {
        guard let url = URL(string: baseURL + "/sites/user") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let sites = try? JSONDecoder().decode([MyGardenSite].self, from: data)
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(sites) }
        }.resume()
    }
    
    func deleteSite(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/sites/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}


// MARK: - UserPlants
extension NetworkManager {
    
    func addUserPlant(
        plantId: String,
        plantName: String,
        siteId: String,
        siteName: String,
        imageData: String?,
        lightRequirement: String?,
        watering: String?,
        repotting: String?,
        quantity: Int,
        lastWatered: Date?,
        lastRepotted: Date?,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: baseURL + "/userplants") else { return }

        var body: [String: Any] = [
            "plantId":         plantId,
            "plantName":       plantName,
            "siteId":          siteId,
            "siteName":        siteName,
            "quantity":        quantity,
            "isAddedToGarden": true
        ]

        if let imageData        = imageData        { body["imageData"]        = imageData }
        if let lightRequirement = lightRequirement { body["lightRequirement"] = lightRequirement }
        if let watering         = watering         { body["watering"]         = watering }
        if let repotting        = repotting        { body["repotting"]        = repotting }
        if let lastWatered      = lastWatered      { body["lastWatered"]      = ISO8601DateFormatter().string(from: lastWatered) }
        if let lastRepotted     = lastRepotted     { body["lastRepotted"]     = ISO8601DateFormatter().string(from: lastRepotted) }

        print("📤 Sending userPlant body: \(body)")

        let request = makeRequest(url: url, method: "POST", body: body)
        session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 userPlant status: \(httpResponse.statusCode)")
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("📦 userPlant response: \(raw)")
            }
            if let error = error {
                print("❌ userPlant network error: \(error.localizedDescription)")
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
    
    func fetchUserPlants(completion: @escaping ([UserPlant]?) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/user") else { return }
        let request = makeRequest(url: url, method: "GET")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let plants = try? decoder.decode([UserPlant].self, from: data)
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(plants) }
        }.resume()
    }
    
    func markTaskDone(mongoId: String, taskType: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/userplants/\(mongoId)/done/\(taskType)") else { return }
        let request = makeRequest(url: url, method: "PATCH")
        session.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    func removePlant(mongoId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/" + mongoId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    func removeAllPlantsOfType(plantId: String, siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/type/" + plantId + "/site/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    func removeSiteWithPlants(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/site/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}

// MARK: - Cloudinary Upload

extension NetworkManager {

    func uploadImageToCloudinary(_ imageData: Data?, completion: @escaping (String?) -> Void) {
        guard let imageData = imageData else {
            completion(nil)
            return
        }

        let urlString = baseURL + "/upload"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid upload URL: \(urlString)")
            completion(nil)
            return
        }

        let base64String = "data:image/jpeg;base64," + imageData.base64EncodedString()

        let request = makeRequest(url: url, method: "POST", body: [
            "image": base64String
        ])

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Upload error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let imageUrl = json["url"] as? String
            else {
                print("❌ Failed to parse upload response")
                DispatchQueue.main.async { completion(nil) }
                return
            }

            print("✅ Image uploaded to Cloudinary: \(imageUrl)")
            DispatchQueue.main.async { completion(imageUrl) }
        }.resume()
    }
}


//MARK: - COMMUNITY

extension NetworkManager {

   // MARK: - Feed
   func fetchFeed(page: Int = 1, completion: @escaping (FeedResponse?) -> Void) {
       guard let url = URL(string: baseURL + "/posts/feed?page=\(page)") else { return }
       let request = makeRequest(url: url, method: "GET")
       session.dataTask(with: request) { data, response, error in
           if let error = error { print("❌ fetchFeed error: \(error.localizedDescription)") }
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
               print("❌ createPost network error: \(error.localizedDescription)")
               DispatchQueue.main.async { completion(nil) }
               return
           }
           if let http = response as? HTTPURLResponse {
               print("📡 createPost status: \(http.statusCode)")
           }
           guard let data = data else {
               print("❌ createPost: no data returned")
               DispatchQueue.main.async { completion(nil) }
               return
           }
           if let raw = String(data: data, encoding: .utf8) {
               print("📦 createPost raw response: \(raw)")
           }
           do {
               let post = try JSONDecoder().decode(Post.self, from: data)
               print("✅ createPost decoded successfully: \(post.id)")
               DispatchQueue.main.async { completion(post) }
           } catch {
               print("❌ createPost decode error: \(error)")
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
           if let error = error { print("❌ toggleLike error: \(error.localizedDescription)") }
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
           if let error = error { print("❌ toggleSave error: \(error.localizedDescription)") }
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
           if let http = response as? HTTPURLResponse { print("📡 addComment status: \(http.statusCode)") }
           guard let data = data else { DispatchQueue.main.async { completion(nil) }; return }
           if let raw = String(data: data, encoding: .utf8) { print("📦 addComment raw: \(raw)") }
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


extension NetworkManager {
 
    func fetchAllUsers(completion: @escaping ([User]) -> Void) {
        guard let url = URL(string: baseURL + "/users") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, response, _ in
            if let http = response as? HTTPURLResponse {
                print("📡 fetchAllUsers status: \(http.statusCode)")
            }
            guard let data = data,
                  let users = try? JSONDecoder().decode([User].self, from: data)
            else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async { completion(users) }
        }.resume()
    }
 
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: baseURL + "/users/\(userId)") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let user = try? JSONDecoder().decode(User.self, from: data)
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(user) }
        }.resume()
    }
}


extension NetworkManager {
 
    func updateUserProfile(userId: String,
                           name: String,
                           username: String,
                           profileImageString: String?,
                           completion: @escaping (Bool) -> Void) {
 
        guard let url = URL(string: baseURL + "/users/\(userId)") else { return }
           print("📡 PATCH URL: \(url)")
           print("📦 body: name=\(name), username=\(username), image=\(profileImageString ?? "nil")")
 
        var body: [String: Any] = [
            "name":     name,
            "username": username
        ]
        if let img = profileImageString {
            body["profileImageString"] = img
        }
 
        let request = makeRequest(url: url, method: "PATCH", body: body)
 
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(" updateUserProfile error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            if let http = response as? HTTPURLResponse {
                print(" updateUserProfile status: \(http.statusCode)")
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print(" updateUserProfile response: \(raw)")
            }
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}

// MARK: - Delete Account
extension NetworkManager {
    
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let userId = KeychainManager.shared.getUserId(),
              let url = URL(string: baseURL + "/users/" + userId)
        else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            if success {
                // Clear all local data
                self.logout()
            }
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}



extension NetworkManager {
 
    // MARK: - Google Auth
    func googleAuth(idToken: String,
                    completion: @escaping (_ success: Bool, _ message: String?) -> Void) {
 
        guard let url = URL(string: "\(baseURL)/auth/google") else {
            completion(false, "Invalid URL")
            return
        }
 
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
        let body = ["idToken": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
 
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Google auth network error: \(error)")
                    completion(false, "Network error")
                    return
                }
 
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                else {
                    completion(false, "Invalid response")
                    return
                }
 
                let httpResponse = response as? HTTPURLResponse
                let statusCode   = httpResponse?.statusCode ?? 0
 
                if statusCode == 200, let token = json["token"] as? String {
                    // Save token + userId to Keychain (same as regular login)
                    if let userDict = json["user"] as? [String: Any],
                       let userId   = userDict["_id"] as? String {
                        KeychainManager.shared.saveToken(token)
                        KeychainManager.shared.saveUserId(userId)
                        print("✅ Google auth success — userId: \(userId)")
                    }
                    completion(true, nil)
                } else {
                    let message = json["message"] as? String ?? "Google auth failed"
                    completion(false, message)
                }
            }
        }.resume()
    }
}
