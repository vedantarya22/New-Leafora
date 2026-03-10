//
//  NetworkManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

class NetworkManager{
    static let shared = NetworkManager()
    let baseURL = "https://plantappbackend-5mdh.onrender.com/api"
    
    var currentUserId : String = "69a574377e957ef7c815b409" // to be set after creating test user
    
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
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                DispatchQueue.main.async { completion(false, "Network error") }
                return
            }

            if let token = json["token"] as? String,
               let user = json["user"] as? [String: Any],
               let userId = user["_id"] as? String {
                KeychainManager.shared.saveToken(token)
                KeychainManager.shared.saveUserId(userId)
                self.currentUserId = userId
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
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else {
                DispatchQueue.main.async { completion(false, "Network error") }
                return
            }

            if let token = json["token"] as? String,
               let user = json["user"] as? [String: Any],
               let userId = user["_id"] as? String {
                KeychainManager.shared.saveToken(token)
                KeychainManager.shared.saveUserId(userId)
                self.currentUserId = userId
                
                
                // ✅ Clear old local data before loading fresh
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
        KeychainManager.shared.clearAll()
        currentUserId = ""
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
        URLSession.shared.dataTask(with: request) { data, _, _ in
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
        URLSession.shared.dataTask(with: url) { data, response, error in

            // ✅ Add these debug prints
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status code: \(httpResponse.statusCode)")
            }
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw response: \(raw)")
            }

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
        URLSession.shared.dataTask(with: url) { data, _, _ in
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
        // ✅ no userId in body — backend gets it from JWT
        let request = makeRequest(url: url, method: "POST", body: [
            "name": name,
            "icon": icon
        ])
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
    
    // ✅ was: baseURL + "/sites/user/" + currentUserId
    func getUserSites(completion: @escaping ([MyGardenSite]?) -> Void) {
        guard let url = URL(string: baseURL + "/sites/user") else { return }
        let request = makeRequest(url: url, method: "GET")  // JWT carries userId
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let sites = try? JSONDecoder().decode([MyGardenSite].self, from: data)
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(sites) }
        }.resume()
    }
    
    func deleteSite(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/sites/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
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
            // ✅ removed userId — JWT provides it
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
        URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    // ✅ was: baseURL + "/userplants/user/" + currentUserId
    func fetchUserPlants(completion: @escaping ([UserPlant]?) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/user") else { return }
        let request = makeRequest(url: url, method: "GET")  // JWT carries userId
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let plants = try? decoder.decode([UserPlant].self, from: data)
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(plants) }
        }.resume()
    }
    
    func markTaskDone(mongoId: String, taskType: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/userplants/\(mongoId)/done/\(taskType)") else { return }
        let request = makeRequest(url: url, method: "PATCH")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    func removePlant(mongoId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/" + mongoId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    func removeAllPlantsOfType(plantId: String, siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/type/" + plantId + "/site/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }
    
    func removeSiteWithPlants(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/userplants/site/" + siteId) else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
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

        URLSession.shared.dataTask(with: request) { data, response, error in
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
