//
//  UIStyleConfiguration.swift
//  MenubarStatus
//
//  Design system constants for consistent UI styling
//  Following macOS Big Sur+ design language
//

import SwiftUI

/// Design system configuration
struct UIStyleConfiguration {
    
    // MARK: - Spacing Scale (8pt grid)
    
    /// Extra small spacing: 4pt
    static let spacingXS: CGFloat = 4
    
    /// Small spacing: 8pt
    static let spacingS: CGFloat = 8
    
    /// Medium spacing: 16pt
    static let spacingM: CGFloat = 16
    
    /// Large spacing: 24pt
    static let spacingL: CGFloat = 24
    
    /// Extra large spacing: 32pt
    static let spacingXL: CGFloat = 32
    
    // MARK: - Typography
    
    /// Menubar icon size: 11pt
    static let menubarIconSize: CGFloat = 11
    
    /// Menubar text size: 11pt
    static let menubarTextSize: CGFloat = 11
    
    /// Small text: 10pt
    static let textSizeSmall: CGFloat = 10
    
    /// Body text: 13pt
    static let textSizeBody: CGFloat = 13
    
    /// Heading text: 17pt
    static let textSizeHeading: CGFloat = 17
    
    /// Large heading: 22pt
    static let textSizeLargeHeading: CGFloat = 22
    
    /// Menubar font: SF Pro Rounded, Bold
    static let menubarFont = Font.system(size: menubarTextSize, weight: .bold, design: .rounded)
    
    /// Body font: SF Pro
    static let bodyFont = Font.system(size: textSizeBody)
    
    /// Heading font: SF Pro, Semibold
    static let headingFont = Font.system(size: textSizeHeading, weight: .semibold)
    
    // MARK: - Corner Radius
    
    /// Small corner radius: 6pt
    static let cornerRadiusS: CGFloat = 6
    
    /// Medium corner radius: 8pt
    static let cornerRadiusM: CGFloat = 8
    
    /// Large corner radius: 12pt
    static let cornerRadiusL: CGFloat = 12
    
    /// Extra large corner radius: 16pt
    static let cornerRadiusXL: CGFloat = 16
    
    // MARK: - Shadows
    
    /// Card shadow
    static let cardShadow = Color.black.opacity(0.1)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 2
    
    /// Dropdown shadow
    static let dropdownShadow = Color.black.opacity(0.15)
    static let dropdownShadowRadius: CGFloat = 12
    static let dropdownShadowY: CGFloat = 4
    
    // MARK: - Animation Durations
    
    /// Fast animation: 150ms
    static let animationFast: Double = 0.15
    
    /// Standard animation: 300ms
    static let animationStandard: Double = 0.3
    
    /// Slow animation: 500ms
    static let animationSlow: Double = 0.5
    
    // MARK: - Menubar Specific
    
    /// Icon-value spacing in menubar: 2px
    static let menubarIconTextSpacing: CGFloat = 2
    
    /// Spacing between metrics in menubar: 6px
    static let menubarMetricSpacing: CGFloat = 6
    
    /// Horizontal padding in menubar: 6px
    static let menubarHorizontalPadding: CGFloat = 6
    
    /// Vertical padding in menubar: 2px
    static let menubarVerticalPadding: CGFloat = 2
    
    // MARK: - Color Thresholds
    
    /// Healthy threshold: < 60%
    static let healthyThreshold: Double = 60.0
    
    /// Warning threshold: 60-80%
    static let warningThreshold: Double = 80.0
    
    /// Critical threshold: ≥ 80%
    // (anything >= warningThreshold is critical)
    
    // MARK: - Size Constraints
    
    /// Target menubar width for 4 metrics: ≤150pt
    static let targetMenubarWidth: CGFloat = 150
    
    /// Estimated width per metric: ~37pt
    static let estimatedMetricWidth: CGFloat = 37
    
    /// Card minimum width
    static let cardMinWidth: CGFloat = 200
    
    /// Card height
    static let cardHeight: CGFloat = 80
    
    // MARK: - Opacity Values
    
    /// Disabled opacity
    static let opacityDisabled: Double = 0.5
    
    /// Secondary element opacity
    static let opacitySecondary: Double = 0.7
    
    /// Hover overlay opacity
    static let opacityHover: Double = 0.05
    
    /// Active overlay opacity
    static let opacityActive: Double = 0.1
}

// MARK: - Animation Extensions

extension Animation {
    /// Standard UI animation (300ms)
    static var standardUI: Animation {
        .easeInOut(duration: UIStyleConfiguration.animationStandard)
    }
    
    /// Fast UI animation (150ms)
    static var fastUI: Animation {
        .easeInOut(duration: UIStyleConfiguration.animationFast)
    }
    
    /// Slow UI animation (500ms)
    static var slowUI: Animation {
        .easeInOut(duration: UIStyleConfiguration.animationSlow)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply standard card styling
    func cardStyle() -> some View {
        self
            .padding(UIStyleConfiguration.spacingM)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(UIStyleConfiguration.cornerRadiusL)
            .shadow(
                color: UIStyleConfiguration.cardShadow,
                radius: UIStyleConfiguration.cardShadowRadius,
                y: UIStyleConfiguration.cardShadowY
            )
    }
    
    /// Apply dropdown styling
    func dropdownStyle() -> some View {
        self
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(UIStyleConfiguration.cornerRadiusM)
            .shadow(
                color: UIStyleConfiguration.dropdownShadow,
                radius: UIStyleConfiguration.dropdownShadowRadius,
                y: UIStyleConfiguration.dropdownShadowY
            )
    }
}

