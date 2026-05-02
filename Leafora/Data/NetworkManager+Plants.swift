import Foundation

// MARK: - Plants (Catalogue)
extension NetworkManager {
    
    func fetchAllPlants(completion: @escaping ([Plant]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/plants") else { return }
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(" Network error: \(error.localizedDescription)")
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("⚠️ Catalogue fetch status: \(httpResponse.statusCode)")
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
