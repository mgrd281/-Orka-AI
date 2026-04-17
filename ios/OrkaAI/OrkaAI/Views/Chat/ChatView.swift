import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool
    
    var body: some View {
        ZStack {
            Color.orkaBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                topBar
                
                // Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        if chatVM.activeConversation == nil || chatVM.activeConversation?.messages.isEmpty == true {
                            emptyState
                        } else {
                            messagesView
                        }
                        
                        if chatVM.isGenerating {
                            ThinkingCard(agents: chatVM.currentAgents, currentIndex: chatVM.thinkingAgentIndex)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 8)
                                .id("thinking")
                        }
                        
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .onChange(of: chatVM.activeConversation?.messages.count) { _ in
                        withAnimation { proxy.scrollTo("bottom") }
                    }
                    .onChange(of: chatVM.isGenerating) { _ in
                        withAnimation { proxy.scrollTo("bottom") }
                    }
                }
                
                // Mode Selector
                modeSelector
                
                // Input Bar
                inputBar
            }
            
            // Sidebar Overlay
            if chatVM.showSidebar {
                SidebarView()
                    .environmentObject(authVM)
                    .environmentObject(chatVM)
                    .transition(.move(edge: .leading))
            }
            
            // Settings Overlay
            if chatVM.showSettings {
                SettingsView()
                    .environmentObject(authVM)
                    .environmentObject(chatVM)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(response: 0.35), value: chatVM.showSidebar)
        .animation(.spring(response: 0.35), value: chatVM.showSettings)
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: { chatVM.showSidebar = true }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 17))
                    .foregroundColor(.orkaText3)
                    .frame(width: 36, height: 36)
            }
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orkaText)
                .frame(width: 28, height: 28)
                .overlay(
                    Text("O").font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                )
            
            Text("Orka")
                .font(.system(size: 15, weight: .bold))
                .tracking(-0.2)
            
            Spacer()
            
            Button(action: { chatVM.newConversation() }) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15))
                    .foregroundColor(.orkaText3)
                    .frame(width: 36, height: 36)
            }
            
            Button(action: { chatVM.showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 15))
                    .foregroundColor(.orkaText3)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
        .background(Color.orkaBg.opacity(0.9))
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 80)
            
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.orkaAccentSoft)
                .frame(width: 48, height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orkaAccent)
                        .frame(width: 10, height: 10)
                )
                .padding(.bottom, 24)
            
            Text("Wie kann ich helfen?")
                .font(.system(size: 22, weight: .heavy))
                .tracking(-0.6)
            
            Text("Sechs KI-Agenten arbeiten zusammen\nfür Antworten auf einem neuen Level.")
                .font(.system(size: 14))
                .foregroundColor(.orkaText2)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.bottom, 36)
            
            VStack(spacing: 8) {
                SuggestionRow(text: "Schreibe einen überzeugenden LinkedIn-Post über KI im Alltag") { sendSuggestion($0) }
                SuggestionRow(text: "Analysiere Vor- und Nachteile von Remote-Arbeit für Startups") { sendSuggestion($0) }
                SuggestionRow(text: "Erkläre Quantencomputing einfach und verständlich") { sendSuggestion($0) }
                SuggestionRow(text: "Erstelle einen Businessplan für eine nachhaltige App-Idee") { sendSuggestion($0) }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Messages
    private var messagesView: some View {
        LazyVStack(spacing: 16) {
            ForEach(chatVM.activeConversation?.messages ?? []) { message in
                MessageBubble(message: message)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Mode Selector
    private var modeSelector: some View {
        HStack(spacing: 6) {
            ForEach(ChatMode.allCases, id: \.self) { mode in
                Button(action: { withAnimation(.spring(response: 0.25)) { chatVM.currentMode = mode } }) {
                    Text(mode.label)
                        .font(.system(size: 13, weight: chatVM.currentMode == mode ? .semibold : .medium))
                        .foregroundColor(chatVM.currentMode == mode ? .orkaAccent : .orkaText3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            chatVM.currentMode == mode ? Color.orkaAccentSoft : Color.clear
                        )
                        .overlay(
                            Capsule()
                                .stroke(chatVM.currentMode == mode ? Color.orkaAccent.opacity(0.2) : Color.orkaBorder, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            HStack(alignment: .bottom) {
                TextField("Nachricht eingeben …", text: $inputText, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .focused($inputFocused)
            }
            .background(Color.orkaSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(inputFocused ? Color.orkaAccent.opacity(0.3) : Color.orkaBorder, lineWidth: 1)
            )
            .cornerRadius(14)
            
            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .frame(width: 46, height: 46)
                    .background(chatVM.isGenerating ? Color.orkaText.opacity(0.3) : Color.orkaText)
                    .cornerRadius(14)
            }
            .disabled(chatVM.isGenerating)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Actions
    private func send() {
        let text = inputText
        inputText = ""
        chatVM.sendMessage(text)
    }
    
    private func sendSuggestion(_ text: String) {
        chatVM.sendMessage(text)
    }
}

struct SuggestionRow: View {
    let text: String
    let action: (String) -> Void
    
    var body: some View {
        Button(action: { action(text) }) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orkaAccent)
                    .frame(width: 6, height: 6)
                
                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(.orkaText2)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.orkaText3)
            }
            .padding(15)
            .background(Color.orkaSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.orkaBorder, lineWidth: 1)
            )
            .cornerRadius(14)
        }
    }
}
