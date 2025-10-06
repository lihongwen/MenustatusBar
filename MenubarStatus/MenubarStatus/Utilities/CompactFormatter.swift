//
//  CompactFormatter.swift
//  MenubarStatus
//
//  Utility for compact value formatting with smart units
//  Implements CompactFormatting contract
//

import SwiftUI

/// Compact formatter for menubar display
struct CompactFormatter {
    
    // MARK: - Percentage Formatting
    
    /// Format percentage as integer for menubar
    /// - Parameter percentage: 0.0-100.0 (or any Double)
    /// - Returns: Compact string like "45%"
    static func formatPercentage(_ percentage: Double) -> String {
        // Clamp negative values to 0
        let clamped = max(0.0, percentage)
        
        // Round to nearest integer
        let rounded = Int(round(clamped))
        
        return "\(rounded)%"
    }
    
    // MARK: - Network Speed Formatting
    
    /// Format network speed with smart units (K/M/G)
    /// - Parameter bytesPerSecond: Raw bytes per second
    /// - Returns: Compact string like "2.3M", "15.0K", "1.2G"
    static func formatNetworkSpeed(_ bytesPerSecond: UInt64) -> String {
        let bytes = Double(bytesPerSecond)
        
        // Thresholds (using 1000 for network speeds, not 1024)
        let kb = 1000.0
        let mb = kb * 1000.0
        let gb = mb * 1000.0
        
        if bytes >= gb {
            // Gigabytes: ≥1GB → "X.XG"
            let value = bytes / gb
            return String(format: "%.1fG", value)
        } else if bytes >= mb {
            // Megabytes: 1MB-999MB → "X.XM"
            let value = bytes / mb
            return String(format: "%.1fM", value)
        } else if bytes >= kb {
            // Kilobytes: 1KB-999KB → "X.XK"
            let value = bytes / kb
            return String(format: "%.1fK", value)
        } else {
            // <1KB → "0.0K"
            return "0.0K"
        }
    }
    
    // MARK: - Menubar Formatting
    
    /// Result type for menubar formatting
    struct MenubarFormat {
        let icon: String
        let text: String
        let color: Color
    }
    
    /// Format metric for menubar display
    /// - Parameters:
    ///   - type: Metric type
    ///   - percentage: Exact percentage (stored for color calculation)
    ///   - bytesPerSecond: Optional network speed
    ///   - theme: Color theme for status colors
    ///   - showIcon: Include SF Symbols icon
    /// - Returns: Formatted icon, text, and color
    static func formatForMenubar(
        type: MetricType,
        percentage: Double,
        bytesPerSecond: UInt64?,
        theme: ColorTheme,
        showIcon: Bool
    ) -> MenubarFormat {
        
        // Get icon (empty if disabled)
        let icon = showIcon ? iconName(for: type) : ""
        
        // Format text based on metric type
        let text: String
        if type == .network, let speed = bytesPerSecond {
            // Network: show speed with arrow
            text = "↓\(formatNetworkSpeed(speed))"
        } else {
            // Other metrics: show percentage
            text = formatPercentage(percentage)
        }
        
        // Determine color based on percentage
        let color = theme.statusColor(for: percentage)
        
        return MenubarFormat(icon: icon, text: text, color: color)
    }
    
    // MARK: - Icon Mapping
    
    /// Get SF Symbols icon name for metric type
    /// - Parameter type: Metric type
    /// - Returns: SF Symbols name
    static func iconName(for type: MetricType) -> String {
        switch type {
        case .cpu:
            return "cpu.fill"
        case .memory:
            return "memorychip.fill"
        case .disk:
            return "internaldrive.fill"
        case .network:
            return "network"
        }
    }
}

// MARK: - MetricType Extension

extension MetricType {
    /// Get SF Symbols icon name
    var iconName: String {
        CompactFormatter.iconName(for: self)
    }
}

