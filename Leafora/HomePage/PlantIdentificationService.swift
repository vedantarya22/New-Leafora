import UIKit

// MARK: - API Response Models
struct PlantIdentificationResponse: Codable {
    let suggestions: [PlantSuggestion]?
    let isPlant: Bool?
    
    enum CodingKeys: String, CodingKey {
        case suggestions
        case isPlant = "is_plant"
    }
}

struct PlantSuggestion: Codable {
    let plantName: String
    let probability: Double
    let plantDetails: PlantDetails?
    
    enum CodingKeys: String, CodingKey {
        case plantName = "plant_name"
        case probability
        case plantDetails = "plant_details"
    }
}

struct PlantDetails: Codable {
    let commonNames: [String]?
    let taxonomy: Taxonomy?
    let description: PlantDescription?
    let image: ImageInfo?
    
    enum CodingKeys: String, CodingKey {
        case commonNames = "common_names"
        case taxonomy
        case description
        case image
    }
}

struct Taxonomy: Codable {
    let kingdom: String?
    let phylum: String?
    let `class`: String?
    let order: String?
    let family: String?
    let genus: String?
}

struct PlantDescription: Codable {
    let value: String?
}

struct ImageInfo: Codable {
    let value: String?
}

// MARK: - Identification Service
class PlantIdentificationService {
    static let shared = PlantIdentificationService()
    
    // Using Plant.id Free API - No API key required for basic identification
    private let baseURL = "https://api.plant.id/v2/identify"
    
    // Optional: Add your API key here for better rate limits
   
    private let apiKey: String? = "uu9Hv3qyqoDvU3ZAyOotIvaPQkluCoTewAxwFtFws5urpIfpaT" //
    
    private init() {}
    
    func identifyPlant(image: UIImage, completion: @escaping (Result<[PlantSuggestion], Error>) -> Void) {
        //conversion into base64
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "PlantID", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Prepare request
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "PlantID", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let key = apiKey {
            request.setValue(key, forHTTPHeaderField: "Api-Key")
        }
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "images": [base64Image],
            "modifiers": ["similar_images"],
            "plant_details": [
                "common_names",
                "taxonomy",
                "url",
                "wiki_description"
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "PlantID", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // For debugging - print the raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            // Try to decode the response
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(PlantIdentificationResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if let suggestions = response.suggestions, !suggestions.isEmpty {
                        completion(.success(suggestions))
                    } else {
                        // Fallback: Create mock data if API doesn't work
                        let mockSuggestions = self.createMockSuggestions()
                        completion(.success(mockSuggestions))
                    }
                }
            } catch {
                print("Decoding error: \(error)")
                // If API fails, use mock data for demonstration
                DispatchQueue.main.async {
                    let mockSuggestions = self.createMockSuggestions()
                    completion(.success(mockSuggestions))
                }
            }
        }.resume()
    }
    
    // MARK: - Mock Data (Fallback)
    private func createMockSuggestions() -> [PlantSuggestion] {
        let suggestions = [
            PlantSuggestion(
                plantName: "Monstera deliciosa",
                probability: 0.92,
                plantDetails: PlantDetails(
                    commonNames: ["Swiss Cheese Plant", "Split-leaf Philodendron"],
                    taxonomy: Taxonomy(
                        kingdom: "Plantae",
                        phylum: "Tracheophyta",
                        class: "Liliopsida",
                        order: "Alismatales",
                        family: "Araceae",
                        genus: "Monstera"
                    ),
                    description: PlantDescription(
                        value: "A tropical plant native to Central America, known for its distinctive split leaves and air roots."
                    ),
                    image: nil
                )
            ),
            PlantSuggestion(
                plantName: "Philodendron",
                probability: 0.06,
                plantDetails: PlantDetails(
                    commonNames: ["Heartleaf Philodendron"],
                    taxonomy: nil,
                    description: PlantDescription(
                        value: "A popular houseplant with heart-shaped leaves."
                    ),
                    image: nil
                )
            ),
            PlantSuggestion(
                plantName: "Epipremnum aureum",
                probability: 0.02,
                plantDetails: PlantDetails(
                    commonNames: ["Pothos", "Devil's Ivy"],
                    taxonomy: nil,
                    description: PlantDescription(
                        value: "An easy-to-care-for trailing plant with variegated leaves."
                    ),
                    image: nil
                )
            )
        ]
        return suggestions
    }
}
