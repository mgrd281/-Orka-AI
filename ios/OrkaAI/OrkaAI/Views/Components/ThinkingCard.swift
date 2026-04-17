import SwiftUI

struct ThinkingCard: View {
    let agents: [Agent]
    let currentIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.orkaAccent)
                    .frame(width: 8, height: 8)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 1.5).repeatForever(), value: pulseScale)
                    .onAppear { pulseScale = 1.2 }
                
                Text("Agenten arbeiten …")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.orkaAccent)
            }
            
            // Agent Steps
            ForEach(Array(agents.enumerated()), id: \.element.id) { index, agent in
                HStack(spacing: 10) {
                    Circle()
                        .fill(stepColor(for: index))
                        .frame(width: 6, height: 6)
                    
                    Text(agent.name + (index < currentIndex ? " ✓" : ""))
                        .font(.system(size: 13))
                        .foregroundColor(stepTextColor(for: index))
                    
                    if index == currentIndex {
                        ThinkingDots()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.orkaSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orkaBorder, lineWidth: 1)
        )
        .cornerRadius(16)
    }
    
    @State private var pulseScale: CGFloat = 0.8
    
    private func stepColor(for index: Int) -> Color {
        if index < currentIndex { return .orkaGreen }
        if index == currentIndex { return Color(hex: agents[index].color) }
        return .orkaBorder
    }
    
    private func stepTextColor(for index: Int) -> Color {
        if index < currentIndex { return .orkaText3 }
        if index == currentIndex { return .orkaText2 }
        return .orkaText3
    }
}

struct ThinkingDots: View {
    @State private var phase = 0
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.orkaText3)
                    .frame(width: 4, height: 4)
                    .opacity(phase == i ? 1 : 0.2)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
