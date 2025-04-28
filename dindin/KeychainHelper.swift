import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    private let keyTag = "com.dindin.realm.encryptionKey"

    func getOrCreateKey() -> Data {
        if let existingKey = loadKey() {
            return existingKey
        }

        var keyData = Data(count: 64)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 64, $0.baseAddress!)
        }

        guard result == errSecSuccess else {
            fatalError("Não foi possível gerar chave aleatória.")
        }

        saveKey(keyData)
        return keyData
    }

    private func saveKey(_ data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadKey() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else { return nil }
        return dataTypeRef as? Data
    }
}