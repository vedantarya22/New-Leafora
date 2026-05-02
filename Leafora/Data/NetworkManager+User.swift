import Foundation

// MARK: - User Profile & Search
extension NetworkManager {
    
    func fetchUserProfile(userId: String, completion: @escaping (User?) -> Void) {
        guard let url = URL(string: baseURL + "/users/\(userId)") else { return }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let user = try? JSONDecoder().decode(User.self, from: data)
            DispatchQueue.main.async { completion(user) }
        }.resume()
    }
    
    func updateUserProfile(userId: String, name: String, username: String, profileImageString: String?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/users/\(userId)") else { return }
        
        var body: [String: Any] = [
            "name": name,
            "username": username
        ]
        if let img = profileImageString {
            body["profileImageString"] = img
        }
        
        let request = makeRequest(url: url, method: "PATCH", body: body)
        session.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    func searchUsers(query: String, completion: @escaping ([User]?) -> Void) {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: baseURL + "/users/search?q=\(encoded)") else { return }
        session.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let users = try? JSONDecoder().decode([User].self, from: data)
            DispatchQueue.main.async { completion(users) }
        }.resume()
    }

    func fetchAllUsers(completion: @escaping ([User]) -> Void) {
        guard let url = URL(string: baseURL + "/users") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, response, _ in
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
                self.logout()
            }
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
}
