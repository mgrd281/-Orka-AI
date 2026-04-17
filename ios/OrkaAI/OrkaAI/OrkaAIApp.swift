import SwiftUI

@main
struct OrkaAIApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var chatVM = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    ChatView()
                        .environmentObject(authVM)
                        .environmentObject(chatVM)
                } else {
                    AuthView()
                        .environmentObject(authVM)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
