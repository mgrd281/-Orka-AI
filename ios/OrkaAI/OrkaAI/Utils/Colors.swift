import SwiftUI

extension Color {
    static let orkaBg = Color(hex: "FAF9F7")
    static let orkaBgAlt = Color(hex: "F3F2EE")
    static let orkaSurface = Color.white
    static let orkaText = Color(hex: "0A0A0A")
    static let orkaText2 = Color(hex: "6B6B6B")
    static let orkaText3 = Color(hex: "9CA3AF")
    static let orkaAccent = Color(hex: "4318FF")
    static let orkaAccentSoft = Color(hex: "4318FF").opacity(0.06)
    static let orkaBorder = Color(hex: "E6E6E3")
    static let orkaGreen = Color(hex: "22C55E")
    static let orkaRed = Color(hex: "EF4444")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
