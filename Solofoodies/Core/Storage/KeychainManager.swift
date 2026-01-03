//
//  KeychainManager.swift
//  Solofoodies
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.solofoodies.app"
    private let tokenKey = "jwt_token"

    private init() {}

    // MARK: - Token Management

    func saveToken(_ token: String) {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing token first
        SecItemDelete(query as CFDictionary)

        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("KeychainManager: Error saving token - \(status)")
        }
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("KeychainManager: Error clearing token - \(status)")
        }
    }

    var isAuthenticated: Bool {
        getToken() != nil
    }
}
