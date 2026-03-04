//
//  NetworkManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

class NetworkManager{
    static let shared = NetworkManager()
    let baseURL = "https://plantappbackend-5mdh.onrender.com"
    
    var currentUserId : String = "" // to be set after creating test user
    
    private init() {}
    
    private func makeRequest(url: URL,method:String, body: [String:Any]? = nil)-> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body{
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
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
        URLSession.shared.dataTask(with: url) { data, _, error in
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
        guard let url = URL(string: "\(baseURL)/sites") else { return }
        let request = makeRequest(url: url, method: "POST", body: [
            "name": name,
            "icon": icon,
            "userId": currentUserId
        ])
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
    
    func getUserSites(completion: @escaping ([MyGardenSite]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/sites/user/\(currentUserId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let sites = try? JSONDecoder().decode([MyGardenSite].self, from: data)
            DispatchQueue.main.async { completion(sites) }
        }.resume()
    }
    
    func deleteSite(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/sites/\(siteId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
}


// MARK: - UserPlants
extension NetworkManager {
    
    func addUserPlant(
        plantId: String,
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
        guard let url = URL(string: "\(baseURL)/userplants") else { return }
        
        var body: [String: Any] = [
            "plantId":   plantId,
            "siteId":    siteId,
            "siteName":  siteName,
            "userId":    currentUserId,
            "quantity":  quantity,
            "isAddedToGarden": true
        ]
        
        if let imageData      = imageData      { body["imageData"]        = imageData }
        if let lightRequirement = lightRequirement { body["lightRequirement"] = lightRequirement }
        if let watering       = watering       { body["watering"]         = watering }
        if let repotting      = repotting      { body["repotting"]        = repotting }
        if let lastWatered    = lastWatered    { body["lastWatered"]      = ISO8601DateFormatter().string(from: lastWatered) }
        if let lastRepotted   = lastRepotted   { body["lastRepotted"]     = ISO8601DateFormatter().string(from: lastRepotted) }
        
        let request = makeRequest(url: url, method: "POST", body: body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let mongoId = json["_id"] as? String
            else { DispatchQueue.main.async { completion(nil) }; return }
            DispatchQueue.main.async { completion(mongoId) }
        }.resume()
    }
    
    func fetchUserPlants(completion: @escaping ([UserPlant]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/userplants/user/\(currentUserId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let plants = try? decoder.decode([UserPlant].self, from: data)
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
        guard let url = URL(string: "\(baseURL)/userplants/\(mongoId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    func removeAllPlantsOfType(plantId: String, siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/userplants/type/\(plantId)/site/\(siteId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
    
    func removeSiteWithPlants(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/userplants/site/\(siteId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                completion((response as? HTTPURLResponse)?.statusCode == 200)
            }
        }.resume()
    }
}
