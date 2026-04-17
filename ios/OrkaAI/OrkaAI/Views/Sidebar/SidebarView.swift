import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { chatVM.showSidebar = false }
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Gespräche")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(-0.3)
                    
                    Spacer()
                    
                    Button(action: { chatVM.showSidebar = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.orkaText3)
                            .frame(width: 32, height: 32)
                            .background(Color.orkaSurface)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Conversations List
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(chatVM.conversations.reversed()) { conv in
                            Button(action: { chatVM.openConversation(conv) }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: conv.mode.agents.first?.color ?? "4318FF"))
                                        .frame(width: 8, height: 8)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(conv.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.orkaText)
                                            .lineLimit(1)
                                        
                                        Text(conv.mode.label + " · " + formatDate(conv.updatedAt))
                                            .font(.system(size: 11))
                                            .foregroundColor(.orkaText3)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    chatVM.activeConversation?.id == conv.id ? Color.orkaAccentSoft : Color.clear
                                )
                            }
                        }
                    }
                }
                
                Spacer()
                
                // User Info
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.orkaAccentSoft)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Text(String(authVM.userName.prefix(1)).uppercased())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orkaAccent)
                        )
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(authVM.userName)
                            .font(.system(size: 13, weight: .semibold))
                        Text(authVM.userEmail)
                            .font(.system(size: 11))
                            .foregroundColor(.orkaText3)
                    }
                    
                    Spacer()
                    
                    Button(action: { authVM.logout() }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 13))
                            .foregroundColor(.orkaText3)
                    }
                }
                .padding(20)
                .background(Color.orkaSurface)
            }
            .frame(width: 300)
            .background(Color.orkaBg)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
