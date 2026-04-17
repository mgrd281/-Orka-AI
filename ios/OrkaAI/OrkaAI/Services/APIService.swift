import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "https://orka-ai.vercel.app"
    
    private init() {}
    
    func sendMessage(content: String, mode: ChatMode, history: [Message]) async throws -> ChatResponse {
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            throw APIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120
        
        let historyPayload = history.suffix(10).map { msg in
            ["role": msg.role.rawValue, "content": msg.content]
        }
        
        let body: [String: Any] = [
            "message": content,
            "mode": mode.rawValue,
            "history": historyPayload
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw APIServiceError.serverError(apiError.error)
            }
            throw APIServiceError.serverError("Fehler \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(ChatResponse.self, from: data)
    }
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Ungültige URL"
        case .invalidResponse: return "Ungültige Antwort"
        case .serverError(let msg): return msg
        }
    }
}
