//
//  Colors.swift
//  Solofoodies
//

import SwiftUI

extension Color {
    // Brand colors
    static let sfPrimary = Color("Primary")
    static let sfLowblack = Color("Lowblack")
    static let sfDgray = Color("Dgray")
    static let sfLgray = Color("Lgray")
}

// Fallback colors if Asset Catalog colors are not set
extension Color {
    static let sfPrimaryFallback = Color(hex: "E53935")
    static let sfLowblackFallback = Color(hex: "333333")
    static let sfDgrayFallback = Color(hex: "666666")
    static let sfLgrayFallback = Color(hex: "F5F5F5")
}

// Hex initializer for Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
