import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { chatVM.showSettings = false }
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Einstellungen")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(-0.3)
                    
                    Spacer()
                    
                    Button(action: { chatVM.showSettings = false }) {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Account Section
                        settingsSection("Konto") {
                            SettingsRow(icon: "person", title: authVM.userName, subtitle: authVM.userEmail)
                        }
                        
                        // Mode Section
                        settingsSection("Standard-Modus") {
                            ForEach(ChatMode.allCases, id: \.self) { mode in
                                Button(action: { chatVM.currentMode = mode }) {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(chatVM.currentMode == mode ? Color.orkaAccent : Color.orkaBorder)
                                            .frame(width: 8, height: 8)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(mode.label)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.orkaText)
                                            
                                            Text("\(mode.agents.count) Agenten")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orkaText3)
                                        }
                                        
                                        Spacer()
                                        
                                        if chatVM.currentMode == mode {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.orkaAccent)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                            }
                        }
                        
                        // Info Section
                        settingsSection("Info") {
                            SettingsRow(icon: "info.circle", title: "Version", subtitle: "1.0.0")
                            SettingsRow(icon: "globe", title: "API", subtitle: "orka-ai.vercel.app")
                        }
                        
                        // Actions
                        VStack(spacing: 8) {
                            Button(action: { authVM.logout() }) {
                                Text("Abmelden")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orkaRed)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 46)
                                    .background(Color.orkaRed.opacity(0.06))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 40)
                }
            }
            .frame(width: 300)
            .background(Color.orkaBg)
        }
    }
    
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.orkaText3)
                .tracking(0.6)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.orkaSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orkaBorder, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsRow: View {
    var icon: String = ""
    let title: String
    var subtitle: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.orkaText3)
                    .frame(width: 20)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.orkaText)
            
            Spacer()
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.orkaText3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
