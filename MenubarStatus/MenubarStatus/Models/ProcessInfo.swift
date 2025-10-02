//
//  ProcessInfo.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import AppKit

// MARK: - ProcessInfo

/// Represents a running system process with resource usage information
struct ProcessInfo: Identifiable {
    // Identity
    let id: Int              // Process ID (PID)
    let name: String         // Process name
    let bundleIdentifier: String?  // App bundle ID (if available)
    
    // Resource Usage
    let cpuUsage: Double     // CPU usage percentage (0-100)
    let memoryUsage: UInt64  // Memory usage in bytes
    
    // UI Properties
    let icon: NSImage?       // App icon (nil if unavailable)
    
    // Computed Properties
    var isTerminable: Bool {
        // System-critical processes cannot be terminated
        // This will be determined by ProcessMonitor.isSystemCritical
        id > 100 // Simple check: PIDs < 100 are typically system processes
    }
    
    var formattedMemory: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
    }
    
    // Validation
    init(id: Int, name: String, bundleIdentifier: String?, cpuUsage: Double, memoryUsage: UInt64, icon: NSImage?) {
        // Ensure valid values
        precondition(id > 0, "Process ID must be positive")
        precondition(!name.isEmpty, "Process name must not be empty")
        precondition(memoryUsage >= 0, "Memory usage must be non-negative")
        
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.cpuUsage = max(0, min(100, cpuUsage)) // Clamp to 0-100
        self.memoryUsage = memoryUsage
        self.icon = icon
    }
}

