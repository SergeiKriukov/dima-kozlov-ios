import SwiftUI

struct AppTheme {
    // Цветовая палитра в стиле Хармса - минималистичные, слегка депрессивные тона
    static let background = Color(hex: "#F8F8F6") // Кремовый
    static let secondaryBackground = Color(hex: "#E8E8E3") // Светло-серый кремовый
    static let accent = Color(hex: "#8B7355") // Темно-коричневый
    static let textPrimary = Color(hex: "#2C2C2C") // Темно-серый
    static let textSecondary = Color(hex: "#666666") // Средне-серый
    static let textOnAccent = Color.white
    static let shadow = Color.black.opacity(0.1)

    // Темная тема
    static let darkBackground = Color(hex: "#1A1A1A") // Темно-серый
    static let darkSecondaryBackground = Color(hex: "#2D2D2D") // Средне-серый
    static let darkAccent = Color(hex: "#A0886B") // Светло-коричневый
    static let darkTextPrimary = Color(hex: "#F5F5F5") // Светло-серый
    static let darkTextSecondary = Color(hex: "#CCCCCC") // Средне-светло-серый

    // Адаптивные цвета
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    static var currentBackground: Color {
        adaptiveColor(light: background, dark: darkBackground)
    }

    static var currentSecondaryBackground: Color {
        adaptiveColor(light: secondaryBackground, dark: darkSecondaryBackground)
    }

    static var currentAccent: Color {
        adaptiveColor(light: accent, dark: darkAccent)
    }

    static var currentTextPrimary: Color {
        adaptiveColor(light: textPrimary, dark: darkTextPrimary)
    }

    static var currentTextSecondary: Color {
        adaptiveColor(light: textSecondary, dark: darkTextSecondary)
    }
}

// Расширение для создания цветов из hex
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
            (a, r, g, b) = (1, 1, 1, 0)
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

// Стили для текста
struct AppTypography {
    static let titleFont = Font.custom("Georgia", size: 28).weight(.medium)
    static let bodyFont = Font.custom("Georgia", size: 18)
    static let captionFont = Font.custom("Georgia", size: 14)
    static let largeTitleFont = Font.custom("Georgia", size: 34).weight(.bold)
}

// Модификаторы для стилизации
extension View {
    func storyCardStyle() -> some View {
        self
            .background(AppTheme.currentBackground)
            .cornerRadius(16)
            .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 4)
            .padding(.horizontal)
    }

    func readingTextStyle() -> some View {
        self
            .font(AppTypography.bodyFont)
            .foregroundColor(AppTheme.currentTextPrimary)
            .lineSpacing(6)
            .multilineTextAlignment(.leading)
    }

    func storyTitleStyle() -> some View {
        self
            .font(AppTypography.titleFont)
            .foregroundColor(AppTheme.currentAccent)
            .multilineTextAlignment(.center)
    }
}
