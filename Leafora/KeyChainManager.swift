//  KeychainManager.swift
//  Leafora

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    private let tokenKey  = "plantapp_jwt_token"
    private let userIdKey = "plantapp_user_id"
    
    // MARK: - Auth Token & UserId
    func saveToken(_ token: String)   { saveString(key: tokenKey,  value: token) }
    func saveUserId(_ userId: String) { saveString(key: userIdKey, value: userId) }
    func getToken()  -> String? { getString(key: tokenKey) }
    func getUserId() -> String? { getString(key: userIdKey) }
    func clearAll() {
        delete(key: tokenKey)
        delete(key: userIdKey)
    }
    
    // MARK: - E2EE Private Key
    // Raw Curve25519 private key bytes — never leaves the device.
    // Stored as Data (not String) so no base64 roundtrip needed.
    func savePrivateKey(_ keyData: Data, for userId: String) {
        saveData(key: privateKeyKeychainKey(for: userId), data: keyData)
    }
    
    func getPrivateKey(for userId: String) -> Data? {
        getData(key: privateKeyKeychainKey(for: userId))
    }
    
    func deletePrivateKey(for userId: String) {
        delete(key: privateKeyKeychainKey(for: userId))
    }
    
    private func privateKeyKeychainKey(for userId: String) -> String {
        "e2ee_private_key_\(userId)"
    }
    
    // MARK: - Private: String helpers
    private func saveString(key: String, value: String) {
        saveData(key: key, data: Data(value.utf8))
    }
    
    private func getString(key: String) -> String? {
        guard let data = getData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Private: Data helpers
    private func saveData(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func getData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return result as? Data
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
