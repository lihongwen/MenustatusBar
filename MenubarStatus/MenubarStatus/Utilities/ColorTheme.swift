//
//  ColorTheme.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI
import Combine

// MARK: - ColorTheme Protocol

/// Defines interface for color themes
protocol ColorTheme {
    var identifier: String { get }
    var displayName: String { get }
    
    // Metric Status Colors
    var healthyColor: Color { get }
    var warningColor: Color { get }
    var criticalColor: Color { get }
    
    // UI Colors
    var backgroundColor: Color { get }
    var cardBackground: Color { get }
    var accentColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    // Gradient Support
    func gradient(for percentage: Double) -> LinearGradient
    
    // Status Color
    func statusColor(for percentage: Double) -> Color
}

// MARK: - System Default Theme

struct SystemDefaultTheme: ColorTheme {
    let identifier = "system"
    var displayName: String {
        LocalizedStrings.language == .chinese ? "系统默认" : "System Default"
    }
    
    var healthyColor: Color { .green }
    var warningColor: Color { .yellow }
    var criticalColor: Color { .red }
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackground: Color { Color(NSColor.controlBackgroundColor) }
    var accentColor: Color { .accentColor }
    var textPrimary: Color { Color(NSColor.labelColor) }
    var textSecondary: Color { Color(NSColor.secondaryLabelColor) }
    
    func gradient(for percentage: Double) -> LinearGradient {
        let color: Color
        if percentage < 60 {
            color = healthyColor
        } else if percentage < 80 {
            color = warningColor
        } else {
            color = criticalColor
        }
        
        return LinearGradient(
            colors: [color.opacity(0.6), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 {
            return healthyColor
        } else if percentage < 80 {
            return warningColor
        } else {
            return criticalColor
        }
    }
}

// MARK: - Monochrome Theme

struct MonochromeTheme: ColorTheme {
    let identifier = "monochrome"
    var displayName: String {
        LocalizedStrings.language == .chinese ? "单色" : "Monochrome"
    }
    
    // 🔧 FIX: 使用更明显的灰色系，不用半透明
    var healthyColor: Color { Color(red: 0.7, green: 0.7, blue: 0.7) } // 浅灰 - 良好
    var warningColor: Color { Color(red: 0.5, green: 0.5, blue: 0.5) } // 中灰 - 警告
    var criticalColor: Color { Color(red: 0.2, green: 0.2, blue: 0.2) } // 深灰 - 危险
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackground: Color { Color(NSColor.controlBackgroundColor) }
    var accentColor: Color { Color.gray }
    var textPrimary: Color { Color(NSColor.labelColor) }
    var textSecondary: Color { Color(NSColor.secondaryLabelColor) }
    
    func gradient(for percentage: Double) -> LinearGradient {
        let opacity = 0.5 + (percentage / 200) // 0.5 to 1.0
        return LinearGradient(
            colors: [Color.gray.opacity(opacity * 0.6), Color.gray.opacity(opacity)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 {
            return healthyColor
        } else if percentage < 80 {
            return warningColor
        } else {
            return criticalColor
        }
    }
}

// MARK: - Traffic Light Theme

struct TrafficLightTheme: ColorTheme {
    let identifier = "traffic"
    var displayName: String {
        LocalizedStrings.language == .chinese ? "交通灯" : "Traffic Light"
    }
    
    var healthyColor: Color { Color(red: 0, green: 0.8, blue: 0) }
    var warningColor: Color { Color(red: 1, green: 0.8, blue: 0) }
    var criticalColor: Color { Color(red: 1, green: 0, blue: 0) }
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackground: Color { Color(NSColor.controlBackgroundColor) }
    var accentColor: Color { Color(red: 0, green: 0.8, blue: 0) }
    var textPrimary: Color { Color(NSColor.labelColor) }
    var textSecondary: Color { Color(NSColor.secondaryLabelColor) }
    
    func gradient(for percentage: Double) -> LinearGradient {
        let color: Color
        if percentage < 60 {
            color = healthyColor
        } else if percentage < 80 {
            color = warningColor
        } else {
            color = criticalColor
        }
        
        return LinearGradient(
            colors: [color.opacity(0.6), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 {
            return healthyColor
        } else if percentage < 80 {
            return warningColor
        } else {
            return criticalColor
        }
    }
}

// MARK: - Cool Theme

struct CoolTheme: ColorTheme {
    let identifier = "cool"
    var displayName: String {
        LocalizedStrings.language == .chinese ? "冷色调" : "Cool"
    }
    
    var healthyColor: Color { Color(red: 0, green: 0.7, blue: 0.9) }
    var warningColor: Color { Color(red: 0.4, green: 0.6, blue: 0.9) }
    var criticalColor: Color { Color(red: 0.6, green: 0.4, blue: 0.9) }
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackground: Color { Color(NSColor.controlBackgroundColor) }
    var accentColor: Color { Color(red: 0, green: 0.7, blue: 0.9) }
    var textPrimary: Color { Color(NSColor.labelColor) }
    var textSecondary: Color { Color(NSColor.secondaryLabelColor) }
    
    func gradient(for percentage: Double) -> LinearGradient {
        let color: Color
        if percentage < 60 {
            color = healthyColor
        } else if percentage < 80 {
            color = warningColor
        } else {
            color = criticalColor
        }
        
        return LinearGradient(
            colors: [color.opacity(0.6), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 {
            return healthyColor
        } else if percentage < 80 {
            return warningColor
        } else {
            return criticalColor
        }
    }
}

// MARK: - Warm Theme

struct WarmTheme: ColorTheme {
    let identifier = "warm"
    var displayName: String {
        LocalizedStrings.language == .chinese ? "暖色调" : "Warm"
    }
    
    var healthyColor: Color { Color(red: 1, green: 0.7, blue: 0.2) }
    var warningColor: Color { Color(red: 1, green: 0.5, blue: 0.2) }
    var criticalColor: Color { Color(red: 1, green: 0.2, blue: 0.2) }
    
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var cardBackground: Color { Color(NSColor.controlBackgroundColor) }
    var accentColor: Color { Color(red: 1, green: 0.6, blue: 0.2) }
    var textPrimary: Color { Color(NSColor.labelColor) }
    var textSecondary: Color { Color(NSColor.secondaryLabelColor) }
    
    func gradient(for percentage: Double) -> LinearGradient {
        let color: Color
        if percentage < 60 {
            color = healthyColor
        } else if percentage < 80 {
            color = warningColor
        } else {
            color = criticalColor
        }
        
        return LinearGradient(
            colors: [color.opacity(0.6), color],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 {
            return healthyColor
        } else if percentage < 80 {
            return warningColor
        } else {
            return criticalColor
        }
    }
}

// MARK: - Theme Manager

/// Manages available themes and current theme selection
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ColorTheme
    
    private let themes: [ColorTheme] = [
        SystemDefaultTheme(),
        MonochromeTheme(),
        TrafficLightTheme(),
        CoolTheme(),
        WarmTheme()
    ]
    
    private init() {
        // Load from settings or use default
        self.currentTheme = SystemDefaultTheme()
    }
    
    var availableThemes: [ColorTheme] {
        return themes
    }
    
    func selectTheme(identifier: String) {
        if let theme = themes.first(where: { $0.identifier == identifier }) {
            currentTheme = theme
        }
    }
    
    func getTheme(identifier: String) -> ColorTheme? {
        return themes.first(where: { $0.identifier == identifier })
    }
}

