import Foundation

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

        let request = makeRequest(url: url, method: "POST", body: body)
        session.dataTask(with: request) { data, _, _ in
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
