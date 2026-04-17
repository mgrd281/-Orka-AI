import Foundation

enum ChatMode: String, CaseIterable, Codable {
    case fast, smart, deep
    
    var label: String {
        switch self {
        case .fast: return "Schnell"
        case .smart: return "Smart"
        case .deep: return "Tief"
        }
    }
    
    var agentCount: String {
        switch self {
        case .fast: return "2 Agenten"
        case .smart: return "5 Agenten"
        case .deep: return "6+ Agenten"
        }
    }
    
    var agents: [Agent] {
        switch self {
        case .fast:
            return [
                Agent(id: "analyst", name: "Analyst", color: "4318FF"),
                Agent(id: "synthesizer", name: "Synthesizer", color: "22C55E")
            ]
        case .smart:
            return [
                Agent(id: "analyst", name: "Analyst", color: "4318FF"),
                Agent(id: "researcher", name: "Researcher", color: "0EA5E9"),
                Agent(id: "creative", name: "Creative", color: "8B5CF6"),
                Agent(id: "critic", name: "Critic", color: "EF4444"),
                Agent(id: "synthesizer", name: "Synthesizer", color: "22C55E")
            ]
        case .deep:
            return [
                Agent(id: "analyst", name: "Analyst", color: "4318FF"),
                Agent(id: "researcher", name: "Researcher", color: "0EA5E9"),
                Agent(id: "creative", name: "Creative", color: "8B5CF6"),
                Agent(id: "critic", name: "Critic", color: "EF4444"),
                Agent(id: "synthesizer", name: "Synthesizer", color: "22C55E"),
                Agent(id: "judge", name: "Quality Judge", color: "F59E0B")
            ]
        }
    }
}

struct Agent: Identifiable, Codable {
    let id: String
    let name: String
    let color: String
}

struct Message: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    var reasoning: [ReasoningStep]
    let timestamp: Date
    
    init(role: MessageRole, content: String, reasoning: [ReasoningStep] = []) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.reasoning = reasoning
        self.timestamp = Date()
    }
}

enum MessageRole: String, Codable {
    case user, assistant
}

struct ReasoningStep: Identifiable, Codable {
    let id: UUID
    let agent: String
    let name: String
    let summary: String
    let color: String
    
    init(agent: String, name: String, summary: String, color: String = "4318FF") {
        self.id = UUID()
        self.agent = agent
        self.name = name
        self.summary = summary
        self.color = color
    }
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [Message]
    var mode: ChatMode
    let createdAt: Date
    var updatedAt: Date
    
    init(title: String, mode: ChatMode) {
        self.id = UUID()
        self.title = title
        self.messages = []
        self.mode = mode
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct ChatResponse: Codable {
    let response: String
    let reasoning: [APIReasoningStep]?
}

struct APIReasoningStep: Codable {
    let agent: String
    let name: String
    let summary: String
}

struct APIError: Codable {
    let error: String
}
