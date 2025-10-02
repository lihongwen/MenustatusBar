//
//  DiskMetrics.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Disk space metrics for a specific volume
struct DiskMetrics {
    let volumePath: String       // Absolute path (e.g., "/" or "/Volumes/External")
    let volumeName: String       // Volume name (e.g., "Macintosh HD")
    let totalBytes: UInt64       // Total disk capacity
    let freeBytes: UInt64        // Available space
    let usedBytes: UInt64        // Used space
    let readBytesPerSecond: UInt64   // Read speed in bytes/sec
    let writeBytesPerSecond: UInt64  // Write speed in bytes/sec
    
    init(
        volumePath: String,
        volumeName: String,
        totalBytes: UInt64,
        freeBytes: UInt64,
        usedBytes: UInt64,
        readBytesPerSecond: UInt64 = 0,
        writeBytesPerSecond: UInt64 = 0
    ) {
        // Ensure volumePath is absolute
        self.volumePath = volumePath.hasPrefix("/") ? volumePath : "/" + volumePath
        
        // Ensure volumeName is not empty
        self.volumeName = volumeName.isEmpty ? "Untitled" : volumeName
        
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
        self.readBytesPerSecond = readBytesPerSecond
        self.writeBytesPerSecond = writeBytesPerSecond
    }
    
    /// Disk usage as percentage (0.0 - 100.0)
    var usagePercentage: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(usedBytes) / Double(totalBytes) * 100.0
    }
    
    /// Used space in gigabytes
    var usedGigabytes: Double {
        Double(usedBytes) / 1_073_741_824.0
    }
    
    /// Total capacity in gigabytes
    var totalGigabytes: Double {
        Double(totalBytes) / 1_073_741_824.0
    }
    
    /// Free space in gigabytes
    var freeGigabytes: Double {
        Double(freeBytes) / 1_073_741_824.0
    }
    
    /// Read speed formatted
    var readSpeedFormatted: String {
        formatBytesPerSecond(readBytesPerSecond)
    }
    
    /// Write speed formatted
    var writeSpeedFormatted: String {
        formatBytesPerSecond(writeBytesPerSecond)
    }
    
    /// Total I/O speed (read + write)
    var totalIOBytesPerSecond: UInt64 {
        readBytesPerSecond + writeBytesPerSecond
    }
    
    /// Total I/O speed formatted
    var totalIOSpeedFormatted: String {
        formatBytesPerSecond(totalIOBytesPerSecond)
    }
    
    private func formatBytesPerSecond(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        let gb = mb / 1024.0
        
        if gb >= 1.0 {
            return String(format: "%.2f GB/s", gb)
        } else if mb >= 1.0 {
            return String(format: "%.1f MB/s", mb)
        } else if kb >= 1.0 {
            return String(format: "%.0f KB/s", kb)
        } else {
            return "\(bytes) B/s"
        }
    }
}




