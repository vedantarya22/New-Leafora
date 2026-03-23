import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "4c250c5b1fc964502cbbc9b6cae203a3"
    
    // 1. Fetch weather using Coordinates (GPS)
    func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (Result<PlantWeatherInfo, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        performRequest(with: urlString, completion: completion)
    }
    
    // 2. Fetch weather using City Name (Fallback)
    func fetchWeather(city: String, completion: @escaping (Result<PlantWeatherInfo, Error>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        performRequest(with: urlString, completion: completion)
    }
    
    // 3. Private helper to handle the network logic
    private func performRequest(with urlString: String, completion: @escaping (Result<PlantWeatherInfo, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Debugging: Print the status code
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 API Response Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401 {
                    print("⚠️ Warning: Your API Key is either invalid or not yet activated by OpenWeatherMap. (Wait 1-2 hours)")
                }
            }

            guard let data = data else { return }
            
            // Debugging: Print the raw JSON to see if it's empty
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Received JSON: \(jsonString)")
            }
            
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                let weatherInfo = PlantWeatherInfo(
                    temperature: Int(decodedData.main.temp),
                    condition: decodedData.weather.first?.main ?? "Clear",
                    cityName: decodedData.name
                )
                completion(.success(weatherInfo))
            } catch {
                print("❌ Decoding Error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - API Response Decoding Models
struct WeatherData: Codable {
    let name: String
    let main: MainData
    let weather: [WeatherDescription]
}

struct MainData: Codable {
    let temp: Double
}

struct WeatherDescription: Codable {
    let main: String
}
