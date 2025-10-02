//
//  FormatHelpers.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

/// Helper functions for formatting values
enum FormatHelpers {
    
    // MARK: - Bytes Formatting
    
    /// Format bytes to human-readable string
    static func formatBytes(_ bytes: UInt64, style: ByteCountFormatter.CountStyle = .memory) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = style
        formatter.allowedUnits = [.useAll]
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// Format bytes with specific unit
    static func formatBytes(_ bytes: UInt64, unit: String) -> String {
        let value: Double
        switch unit.lowercased() {
        case "gb":
            value = Double(bytes) / 1_073_741_824.0
            return String(format: "%.2f GB", value)
        case "mb":
            value = Double(bytes) / 1_048_576.0
            return String(format: "%.1f MB", value)
        case "kb":
            value = Double(bytes) / 1024.0
            return String(format: "%.0f KB", value)
        default:
            return "\(bytes) B"
        }
    }
    
    // MARK: - Percentage Formatting
    
    /// Format percentage with specified decimal places
    static func formatPercentage(_ value: Double, decimals: Int = 1) -> String {
        let format = "%.\(decimals)f%%"
        return String(format: format, value)
    }
    
    /// Format percentage as compact string (no decimals for whole numbers)
    static func formatPercentageCompact(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f%%", value)
        } else {
            return String(format: "%.1f%%", value)
        }
    }
    
    // MARK: - Duration Formatting
    
    /// Format duration in seconds to human-readable string
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    /// Format uptime in days, hours, minutes
    static func formatUptime(_ seconds: TimeInterval) -> String {
        let days = Int(seconds) / 86400
        let hours = (Int(seconds) % 86400) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - Speed Formatting
    
    /// Format bytes per second to human-readable speed
    static func formatSpeed(_ bytesPerSecond: UInt64) -> String {
        let kb = Double(bytesPerSecond) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        
        if gb >= 1.0 {
            return String(format: "%.2f GB/s", gb)
        } else if mb >= 1.0 {
            return String(format: "%.1f MB/s", mb)
        } else if kb >= 1.0 {
            return String(format: "%.0f KB/s", kb)
        } else {
            return "\(bytesPerSecond) B/s"
        }
    }
    
    // MARK: - Compact Formatting
    
    /// Format value compactly for menubar display
    static func formatCompact(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        } else if value >= 100 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    /// Format bytes compactly for menubar display
    static func formatBytesCompact(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        let mb = Double(bytes) / 1_048_576.0
        
        if gb >= 1 {
            return String(format: "%.1fG", gb)
        } else if mb >= 1 {
            return String(format: "%.0fM", mb)
        } else {
            return String(format: "%.0fK", Double(bytes) / 1024.0)
        }
    }
}

