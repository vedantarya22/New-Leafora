import Foundation

// MARK: - Sites
extension NetworkManager {
    
    func fetchSites(completion: @escaping ([MyGardenSite]?) -> Void) {
        guard let url = URL(string: baseURL + "/sites") else { return }
        let request = makeRequest(url: url, method: "GET")
        session.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            let sites = try? JSONDecoder().decode([MyGardenSite].self, from: data)
            DispatchQueue.main.async { completion(sites) }
        }.resume()
    }
    
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
    
    func deleteSite(siteId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL + "/sites/\(siteId)") else { return }
        let request = makeRequest(url: url, method: "DELETE")
        session.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async { completion(error == nil) }
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
}
