import Foundation

/// Centralized Manager for secure API keys and app secrets.
/// Secrets are loaded at runtime from `Secrets.plist` (which is gitignored).
enum Secrets {
    private static var secretsDict: [String: Any]? = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ [Secrets] Secrets.plist not found in Bundle. Make sure Secrets.plist exists and is included in the build target.")
            return nil
        }
        return dict
    }()
    
    /// Weather API Key (OpenWeatherMap)
    static var weatherAPIKey: String {
        guard let key = secretsDict?["WEATHER_API_KEY"] as? String,
              !key.isEmpty,
              key != "YOUR_OPENWEATHERMAP_API_KEY_HERE" else {
            return ""
        }
        return key
    }
    
    /// Plant Identification API Key (Plant.id)
    static var plantIDAPIKey: String {
        guard let key = secretsDict?["PLANT_ID_API_KEY"] as? String,
              !key.isEmpty,
              key != "YOUR_PLANT_ID_API_KEY_HERE" else {
            return ""
        }
        return key
    }
}
