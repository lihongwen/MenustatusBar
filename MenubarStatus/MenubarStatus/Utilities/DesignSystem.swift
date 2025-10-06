//
//  DesignSystem.swift
//  MenubarStatus
//
//  Helper methods for applying design system
//

import SwiftUI

/// Design system utilities
struct DesignSystem {
    
    // MARK: - Color Helpers
    
    /// Get status color for a percentage value
    /// - Parameters:
    ///   - percentage: Value percentage (0-100)
    ///   - theme: Color theme to use
    /// - Returns: Status color
    static func statusColor(for percentage: Double, theme: ColorTheme) -> Color {
        return theme.statusColor(for: percentage)
    }
    
    /// Get status gradient for a percentage value
    /// - Parameters:
    ///   - percentage: Value percentage (0-100)
    ///   - theme: Color theme to use
    /// - Returns: Status gradient
    static func statusGradient(for percentage: Double, theme: ColorTheme) -> LinearGradient {
        return theme.gradient(for: percentage)
    }
    
    // MARK: - Spacing Helpers
    
    /// Create vertical spacer with standard spacing
    /// - Parameter size: Spacing size (.s, .m, .l, .xl)
    /// - Returns: Spacer view
    static func vSpace(_ size: SpacingSize = .m) -> some View {
        Spacer()
            .frame(height: size.value)
    }
    
    /// Create horizontal spacer with standard spacing
    /// - Parameter size: Spacing size (.s, .m, .l, .xl)
    /// - Returns: Spacer view
    static func hSpace(_ size: SpacingSize = .m) -> some View {
        Spacer()
            .frame(width: size.value)
    }
    
    // MARK: - Typography Helpers
    
    /// Apply menubar text styling
    /// - Parameter text: Text to style
    /// - Returns: Styled text
    static func menubarText(_ text: String) -> Text {
        Text(text)
            .font(UIStyleConfiguration.menubarFont)
    }
    
    /// Apply body text styling
    /// - Parameter text: Text to style
    /// - Returns: Styled text
    static func bodyText(_ text: String) -> Text {
        Text(text)
            .font(UIStyleConfiguration.bodyFont)
    }
    
    /// Apply heading text styling
    /// - Parameter text: Text to style
    /// - Returns: Styled text
    static func headingText(_ text: String) -> Text {
        Text(text)
            .font(UIStyleConfiguration.headingFont)
    }
    
    // MARK: - Animation Helpers
    
    /// Apply standard UI animation
    /// - Parameter action: Action to animate
    static func withStandardAnimation(_ action: @escaping () -> Void) {
        withAnimation(.standardUI) {
            action()
        }
    }
    
    /// Apply fast UI animation
    /// - Parameter action: Action to animate
    static func withFastAnimation(_ action: @escaping () -> Void) {
        withAnimation(.fastUI) {
            action()
        }
    }
}

// MARK: - Spacing Size

extension DesignSystem {
    /// Standard spacing sizes
    enum SpacingSize {
        case xs, s, m, l, xl
        
        var value: CGFloat {
            switch self {
            case .xs: return UIStyleConfiguration.spacingXS
            case .s: return UIStyleConfiguration.spacingS
            case .m: return UIStyleConfiguration.spacingM
            case .l: return UIStyleConfiguration.spacingL
            case .xl: return UIStyleConfiguration.spacingXL
            }
        }
    }
}

// MARK: - View Modifiers

struct InteractiveCardModifier: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.fastUI, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    /// Apply interactive card behavior (hover scale)
    func interactiveCard() -> some View {
        self.modifier(InteractiveCardModifier())
    }
}

