//
//  KeyChainManager.swift
//  search-pageRoute
//
//  Created by SDC-USER on 07/03/26.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    private let tokenKey = "plantapp_jwt_token"
    private let userIdKey = "plantapp_user_id"

    // MARK: - Save
    func saveToken(_ token: String) {
        save(key: tokenKey, value: token)
    }

    func saveUserId(_ userId: String) {
        save(key: userIdKey, value: userId)
    }

    // MARK: - Get
    func getToken() -> String? {
        return get(key: tokenKey)
    }

    func getUserId() -> String? {
        return get(key: userIdKey)
    }

    // MARK: - Delete
    func clearAll() {
        delete(key: tokenKey)
        delete(key: userIdKey)
    }

    // MARK: - Private Helpers
    private func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
