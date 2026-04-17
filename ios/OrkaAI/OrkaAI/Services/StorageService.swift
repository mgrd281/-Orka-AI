import Foundation

class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - User
    func saveUser(name: String, email: String) {
        defaults.set(name, forKey: "user_name")
        defaults.set(email, forKey: "user_email")
        defaults.set(true, forKey: "is_logged_in")
    }
    
    func getUser() -> (name: String, email: String)? {
        guard defaults.bool(forKey: "is_logged_in"),
              let name = defaults.string(forKey: "user_name"),
              let email = defaults.string(forKey: "user_email") else { return nil }
        return (name, email)
    }
    
    func clearUser() {
        defaults.removeObject(forKey: "user_name")
        defaults.removeObject(forKey: "user_email")
        defaults.set(false, forKey: "is_logged_in")
    }
    
    // MARK: - Conversations
    func saveConversations(_ conversations: [Conversation]) {
        if let data = try? JSONEncoder().encode(conversations) {
            defaults.set(data, forKey: "conversations")
        }
    }
    
    func loadConversations() -> [Conversation] {
        guard let data = defaults.data(forKey: "conversations"),
              let convs = try? JSONDecoder().decode([Conversation].self, from: data) else { return [] }
        return convs
    }
}
