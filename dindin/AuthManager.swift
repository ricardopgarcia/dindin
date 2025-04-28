import Foundation

class AuthManager {
    static let shared = AuthManager()
    private let key = "users"

    private var users: [String: String] {
        get {
            UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    func register(email: String, password: String) -> Bool {
        guard users[email] == nil else { return false }
        users[email] = password
        return true
    }

    func login(email: String, password: String) -> Bool {
        return users[email] == password
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}