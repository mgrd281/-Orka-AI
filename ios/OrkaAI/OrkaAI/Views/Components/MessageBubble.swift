import SwiftUI

struct MessageBubble: View {
    let message: Message
    @State private var showReasoning = false
    
    var body: some View {
        if message.role == .user {
            userBubble
        } else {
            assistantBubble
        }
    }
    
    private var userBubble: some View {
        HStack {
            Spacer(minLength: 60)
            Text(message.content)
                .font(.system(size: 14))
                .lineSpacing(4)
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(Color.orkaText)
                .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                .cornerRadius(4, corners: [.bottomRight])
        }
    }
    
    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(LocalizedStringKey(message.content))
                    .font(.system(size: 14))
                    .lineSpacing(5)
                    .foregroundColor(.orkaText)
                    .textSelection(.enabled)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orkaSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orkaBorder, lineWidth: 1)
            )
            .cornerRadius(16)
            
            // Actions
            HStack(spacing: 6) {
                CopyButton(text: message.content)
                
                if !message.reasoning.isEmpty {
                    Button(action: { withAnimation(.spring(response: 0.3)) { showReasoning.toggle() } }) {
                        Text("Denkprozess anzeigen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orkaAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.orkaAccentSoft)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Reasoning Panel
            if showReasoning {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(message.reasoning) { step in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(Color(hex: step.color))
                                .frame(width: 8, height: 8)
                                .padding(.top, 5)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: step.color))
                                
                                Text(step.summary)
                                    .font(.system(size: 13))
                                    .foregroundColor(.orkaText2)
                                    .lineSpacing(3)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.orkaAccentSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orkaAccent.opacity(0.08), lineWidth: 1)
                )
                .cornerRadius(12)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

struct CopyButton: View {
    let text: String
    @State private var copied = false
    
    var body: some View {
        Button(action: {
            UIPasteboard.general.string = text
            copied = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
        }) {
            Text(copied ? "✓ Kopiert" : "Kopieren")
                .font(.system(size: 12))
                .foregroundColor(.orkaText3)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .cornerRadius(8)
        }
    }
}

// Corner radius extension for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
