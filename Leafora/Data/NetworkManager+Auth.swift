import Foundation

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
                DispatchQueue.main.async { completion(true, nil) }

            } else {
                let message = json["message"] as? String ?? "Signup failed"
                print(" Signup error: \(message)")
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

                KeychainManager.shared.saveUserId(userId)
                DispatchQueue.main.async { completion(true, nil) }

            } else {
                let message = json["message"] as? String ?? "Login failed"
                print(" Login error: \(message)")
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
    }

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
                    print(" Google auth network error: \(error)")
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
                    if let userDict = json["user"] as? [String: Any],
                       let userId   = userDict["_id"] as? String {
                        KeychainManager.shared.saveToken(token)
                        KeychainManager.shared.saveUserId(userId)
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
