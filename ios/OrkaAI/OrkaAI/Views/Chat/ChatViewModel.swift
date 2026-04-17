import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var activeConversation: Conversation?
    @Published var isGenerating = false
    @Published var currentMode: ChatMode = .smart
    @Published var thinkingAgentIndex = 0
    @Published var showSidebar = false
    @Published var showSettings = false
    
    init() {
        conversations = StorageService.shared.loadConversations()
    }
    
    var currentAgents: [Agent] { currentMode.agents }
    
    func newConversation() {
        activeConversation = nil
        showSidebar = false
    }
    
    func openConversation(_ conv: Conversation) {
        activeConversation = conv
        showSidebar = false
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isGenerating else { return }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create or get conversation
        if activeConversation == nil {
            let title = String(trimmed.prefix(50)) + (trimmed.count > 50 ? "…" : "")
            activeConversation = Conversation(title: title, mode: currentMode)
        }
        
        // Add user message
        let userMsg = Message(role: .user, content: trimmed)
        activeConversation?.messages.append(userMsg)
        saveCurrentConversation()
        
        isGenerating = true
        thinkingAgentIndex = 0
        
        // Start thinking animation
        startThinkingAnimation()
        
        // Call API
        let history = activeConversation?.messages ?? []
        let mode = currentMode
        
        Task {
            do {
                let response = try await APIService.shared.sendMessage(
                    content: trimmed,
                    mode: mode,
                    history: history
                )
                
                let reasoning = (response.reasoning ?? []).enumerated().map { (i, r) in
                    let agents = mode.agents
                    let color = i < agents.count ? agents[i].color : "4318FF"
                    return ReasoningStep(agent: r.agent, name: r.name, summary: r.summary, color: color)
                }
                
                let assistantMsg = Message(role: .assistant, content: response.response, reasoning: reasoning)
                
                await MainActor.run {
                    activeConversation?.messages.append(assistantMsg)
                    saveCurrentConversation()
                    isGenerating = false
                }
            } catch {
                let errMsg = Message(role: .assistant, content: "**Fehler:** \(error.localizedDescription)")
                await MainActor.run {
                    activeConversation?.messages.append(errMsg)
                    saveCurrentConversation()
                    isGenerating = false
                }
            }
        }
    }
    
    private func startThinkingAnimation() {
        let agents = currentMode.agents
        let interval: TimeInterval = currentMode == .fast ? 1.0 : currentMode == .deep ? 2.5 : 1.5
        
        func animateNext(_ index: Int) {
            guard isGenerating, index < agents.count else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
                guard let self, self.isGenerating else { return }
                withAnimation(.spring(response: 0.3)) {
                    self.thinkingAgentIndex = index + 1
                }
                animateNext(index + 1)
            }
        }
        animateNext(0)
    }
    
    private func saveCurrentConversation() {
        guard var conv = activeConversation else { return }
        conv.updatedAt = Date()
        activeConversation = conv
        
        if let idx = conversations.firstIndex(where: { $0.id == conv.id }) {
            conversations[idx] = conv
        } else {
            conversations.append(conv)
        }
        
        StorageService.shared.saveConversations(conversations)
        objectWillChange.send()
    }
}
