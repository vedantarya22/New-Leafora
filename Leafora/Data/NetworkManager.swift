//
//  NetworkManager.swift
//  Leafora
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://plantappbackend-933m.onrender.com/api"
    
    internal let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 120
        return URLSession(configuration: config)
    }()
    
    private init() {}
    
    internal func makeRequest(url: URL, method: String, body: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }
}

// MARK: - Optimization Note
// Feature-specific network methods have been moved to extensions:
// - NetworkManager+Auth.swift
// - NetworkManager+Plants.swift
// - NetworkManager+Sites.swift
// - NetworkManager+User.swift
// - NetworkManager+UserPlants.swift
// - NetworkManager+Community.swift
// - NetworkManager+Upload.swift
