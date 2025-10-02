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
}

// MARK: - System Default Theme

struct SystemDefaultTheme: ColorTheme {
    let identifier = "system"
    let displayName = "System Default"
    
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
}

// MARK: - Monochrome Theme

struct MonochromeTheme: ColorTheme {
    let identifier = "monochrome"
    let displayName = "Monochrome"
    
    var healthyColor: Color { Color.gray.opacity(0.5) }
    var warningColor: Color { Color.gray.opacity(0.7) }
    var criticalColor: Color { Color.gray }
    
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
}

// MARK: - Traffic Light Theme

struct TrafficLightTheme: ColorTheme {
    let identifier = "traffic"
    let displayName = "Traffic Light"
    
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
}

// MARK: - Cool Theme

struct CoolTheme: ColorTheme {
    let identifier = "cool"
    let displayName = "Cool"
    
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
}

// MARK: - Warm Theme

struct WarmTheme: ColorTheme {
    let identifier = "warm"
    let displayName = "Warm"
    
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

