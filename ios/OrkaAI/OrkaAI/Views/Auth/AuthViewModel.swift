import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var errorMessage = ""
    @Published var showRegister = false
    
    init() {
        if let user = StorageService.shared.getUser() {
            userName = user.name
            userEmail = user.email
            isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte alle Felder ausfüllen."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Passwort mindestens 6 Zeichen."
            return
        }
        
        // Check stored users
        let users = UserDefaults.standard.dictionary(forKey: "orka_users") as? [String: [String: String]] ?? [:]
        guard let user = users[email] else {
            errorMessage = "Konto nicht gefunden. Bitte registrieren."
            return
        }
        guard user["password"] == password else {
            errorMessage = "Falsches Passwort."
            return
        }
        
        userName = user["name"] ?? ""
        userEmail = email
        StorageService.shared.saveUser(name: userName, email: email)
        errorMessage = ""
        withAnimation(.spring(response: 0.4)) { isAuthenticated = true }
    }
    
    func register(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Bitte alle Felder ausfüllen."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Passwort mindestens 6 Zeichen."
            return
        }
        guard email.contains("@") else {
            errorMessage = "Ungültige E-Mail-Adresse."
            return
        }
        
        var users = UserDefaults.standard.dictionary(forKey: "orka_users") as? [String: [String: String]] ?? [:]
        guard users[email] == nil else {
            errorMessage = "E-Mail bereits registriert."
            return
        }
        
        users[email] = ["name": name, "password": password]
        UserDefaults.standard.set(users, forKey: "orka_users")
        
        userName = name
        userEmail = email
        StorageService.shared.saveUser(name: name, email: email)
        errorMessage = ""
        withAnimation(.spring(response: 0.4)) { isAuthenticated = true }
    }
    
    func logout() {
        StorageService.shared.clearUser()
        withAnimation(.spring(response: 0.4)) {
            isAuthenticated = false
            userName = ""
            userEmail = ""
        }
    }
}
