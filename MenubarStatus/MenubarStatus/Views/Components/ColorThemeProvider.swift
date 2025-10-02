//
//  ColorThemeProvider.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

// MARK: - Environment Key

private struct ColorThemeKey: EnvironmentKey {
    static let defaultValue: ColorTheme = SystemDefaultTheme()
}

extension EnvironmentValues {
    var colorTheme: ColorTheme {
        get { self[ColorThemeKey.self] }
        set { self[ColorThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Inject a color theme into the environment
    func colorTheme(_ theme: ColorTheme) -> some View {
        environment(\.colorTheme, theme)
    }
}

// MARK: - Theme Provider View Modifier

struct ThemeProviderModifier: ViewModifier {
    @ObservedObject var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .environment(\.colorTheme, themeManager.currentTheme)
    }
}

extension View {
    /// Apply the global theme manager to this view hierarchy
    func applyThemeManager(_ manager: ThemeManager = .shared) -> some View {
        modifier(ThemeProviderModifier(themeManager: manager))
    }
}

// MARK: - Preview Helper

#if DEBUG
struct ColorThemeProvider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ThemePreviewCard()
                .colorTheme(SystemDefaultTheme())
            
            ThemePreviewCard()
                .colorTheme(MonochromeTheme())
            
            ThemePreviewCard()
                .colorTheme(TrafficLightTheme())
            
            ThemePreviewCard()
                .colorTheme(CoolTheme())
            
            ThemePreviewCard()
                .colorTheme(WarmTheme())
        }
        .padding()
    }
}

private struct ThemePreviewCard: View {
    @Environment(\.colorTheme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(theme.displayName)
                .font(.headline)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(theme.healthyColor)
                    .frame(width: 20, height: 20)
                Text("Healthy")
                    .font(.caption)
                
                Circle()
                    .fill(theme.warningColor)
                    .frame(width: 20, height: 20)
                Text("Warning")
                    .font(.caption)
                
                Circle()
                    .fill(theme.criticalColor)
                    .frame(width: 20, height: 20)
                Text("Critical")
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.cardBackground)
        )
    }
}
#endif

