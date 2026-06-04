//
//  NetworkManager.swift
//  Leafora
//
//  Created by SDC-USER on 04/03/26.
//

import Foundation

// MARK: - NetworkManager
// NOTE: NSObject + URLSessionDelegate are required to handle server trust
// challenges explicitly. The iOS Simulator has a known TLS 1.3 handshake
// bug (-9816 errSSLHandshakeFailure) with Cloudflare-fronted servers.
// Forcing TLS 1.2 and providing a delegate that manually evaluates server
// trust is the reliable workaround.
class NetworkManager: NSObject {
    static let shared = NetworkManager()
    let baseURL = "https://plantappbackend-933m.onrender.com/api"

    internal lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90
        config.timeoutIntervalForResource = 120

        // Force TLS 1.2 — works around iOS Simulator errSSLHandshakeFailure (-9816)
        // with Cloudflare + TLS 1.3 + HTTP/2 (h2 ALPN). Cloudflare supports both
        // 1.2 and 1.3; 1.2 is stable on all iOS runtimes including Simulator.
        if #available(iOS 13.0, *) {
            config.tlsMinimumSupportedProtocolVersion = .TLSv12
            config.tlsMaximumSupportedProtocolVersion = .TLSv12
        }

        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private override init() {}

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

// MARK: - URLSessionDelegate (explicit server trust evaluation)
extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Evaluate the server's certificate chain using the system trust store.
        // This replaces the implicit evaluation that the iOS Simulator sometimes
        // drops, causing the -9816 handshake failure.
        var cfError: CFError?
        let trusted = SecTrustEvaluateWithError(serverTrust, &cfError)
        if trusted {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print(" Server trust evaluation failed: \(cfError?.localizedDescription ?? "unknown")")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
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
