//
//  UserSession.swift
//  Leafora
//

import Foundation

class UserSession {
    static let shared = UserSession()
    private init() {}

    // MARK: - Identity  (live from Keychain — always in sync with login/logout)
    var token:   String? { KeychainManager.shared.getToken() }
    var mongoId: String? { KeychainManager.shared.getUserId() }

    /// MongoDB _id of the logged-in user. Empty string if not logged in.
    var currentLoggedInUserID: String { mongoId ?? "" }

    var isLoggedIn: Bool { token != nil && mongoId != nil }

    func isCurrentUser(userID: String) -> Bool { mongoId == userID }

    // MARK: - Cached Profile
    // Populated by fetchCurrentUser() — call once after login / app launch.
    var cachedCurrentUser: User?

    /// Synchronous convenience accessor — may be nil until fetchCurrentUser completes.
    var currentUser: User? { cachedCurrentUser }

    // MARK: - Fetch Current User Profile from Backend
    /// Hits GET /api/users/:id, decodes into User, caches result.
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
                print("📡 fetchCurrentUser status: \(http.statusCode)")
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 fetchCurrentUser raw: \(raw)")
            }
            guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self?.cachedCurrentUser = user
            DispatchQueue.main.async { completion(user) }
        }.resume()
    }

    // MARK: - Clear on Logout
    func clearSession() {
        cachedCurrentUser = nil
    }
}
