//
//  UserSession.swift
//  Leafora
//

import Foundation

class UserSession {
    static let shared = UserSession()
    
    private let userCacheKey = "cached_current_user"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: userCacheKey),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            self.cachedCurrentUser = decoded
        }
    }

    // MARK: - Identity
    var token:   String? { KeychainManager.shared.getToken() }
    var mongoId: String? { KeychainManager.shared.getUserId() }

    // MongoDB _id of logged-in user; empty when logged out
    var currentLoggedInUserID: String { mongoId ?? "" }

    var isLoggedIn: Bool { token != nil && mongoId != nil }

    func isCurrentUser(userID: String) -> Bool { mongoId == userID }

    // MARK: - Cached Profile
    // set by fetchCurrentUser()
    var cachedCurrentUser: User?

    // may be nil until fetchCurrentUser completes
    var currentUser: User? { cachedCurrentUser }

    // MARK: - Fetch Current User Profile
    // GET /users/:id then cache the result
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let userId = mongoId,
              let url = URL(string: NetworkManager.shared.baseURL + "/users/\(userId)")
        else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            if let http = response as? HTTPURLResponse {
                print("fetchCurrentUser status: \(http.statusCode)")
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("fetchCurrentUser raw: \(raw)")
            }
            guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self?.cachedCurrentUser = user
            self?.saveUserToCache(user)
            DispatchQueue.main.async { completion(user) }
        }.resume()
    }

    private func saveUserToCache(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userCacheKey)
        }
    }

    // MARK: - Clear on Logout
    func clearSession() {
        cachedCurrentUser = nil
        UserDefaults.standard.removeObject(forKey: userCacheKey)
    }
}
