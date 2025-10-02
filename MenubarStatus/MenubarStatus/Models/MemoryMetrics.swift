//
//  MemoryMetrics.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Memory usage metrics snapshot
struct MemoryMetrics {
    let totalBytes: UInt64       // Total physical memory
    let usedBytes: UInt64        // Used memory (active + wired)
    let freeBytes: UInt64        // Free memory
    let cachedBytes: UInt64      // Cached/inactive memory
    
    init(totalBytes: UInt64, usedBytes: UInt64, freeBytes: UInt64, cachedBytes: UInt64) {
        // Ensure totalBytes is at least 1 to avoid division by zero
        self.totalBytes = max(1, totalBytes)
        self.usedBytes = usedBytes
        self.freeBytes = freeBytes
        self.cachedBytes = cachedBytes
    }
    
    /// Memory usage as percentage (0.0 - 100.0)
    var usagePercentage: Double {
        Double(usedBytes) / Double(totalBytes) * 100.0
    }
    
    /// Used memory in gigabytes
    var usedGigabytes: Double {
        Double(usedBytes) / 1_073_741_824.0  // 1024^3
    }
    
    /// Total memory in gigabytes
    var totalGigabytes: Double {
        Double(totalBytes) / 1_073_741_824.0
    }
}




