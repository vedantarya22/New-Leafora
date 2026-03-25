import Foundation

struct PlantWeatherInfo {
    let temperature: Int
    let condition: String  // e.g., "Clear", "Rain", "Clouds"
    let cityName: String
    
    // This computed property generates the emoji based on the condition string
    var weatherEmoji: String {
        switch condition.lowercased() {
        case let str where str.contains("clear"): return ""
        case let str where str.contains("cloud"): return ""
        case let str where str.contains("rain"), let str where                    str.contains("drizzle"): return ""
        case let str where str.contains("thunder"): return ""
        case let str where str.contains("snow"): return ""
        case let str where str.contains("mist"), let str where str.contains("fog"): return ""
        default: return ""
        }
    }
    
    // SF Symbol for weather icon in UI
    var weatherSFSymbol: String {
        switch condition.lowercased() {
        case let str where str.contains("clear"): return "sun.max.fill"
        case let str where str.contains("cloud"): return "cloud.fill"
        case let str where str.contains("rain"), let str where str.contains("drizzle"): return "cloud.rain.fill"
        case let str where str.contains("thunder"): return "cloud.bolt.fill"
        case let str where str.contains("snow"): return "cloud.snow.fill"
        case let str where str.contains("mist"), let str where str.contains("fog"): return "cloud.fog.fill"
        default: return "cloud.sun.fill"
        }
    }
    
    // This computed property generates the plant-specific advice
    var plantAdvice: String {
        if temperature > 30 {
            return "It's a hot one! Check if your plants need extra water."
        } else if condition.lowercased().contains("rain") {
            return "Free water! You can likely skip watering today."
        } else if temperature < 10 {
            return "A bit chilly. Keep an eye on your tropical plants."
        } else {
            return "Perfect conditions for your balcony garden today."
        }
    }
}
