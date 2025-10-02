//
//  CPUMetrics.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// CPU usage metrics snapshot
struct CPUMetrics {
    let usagePercentage: Double  // Total CPU usage (0.0 - 100.0)
    let systemUsage: Double      // System processes usage (0.0 - 100.0)
    let userUsage: Double        // User processes usage (0.0 - 100.0)
    let idlePercentage: Double   // Idle time (0.0 - 100.0)
    
    init(usagePercentage: Double, systemUsage: Double, userUsage: Double, idlePercentage: Double) {
        // Clamp all values to valid range [0.0, 100.0]
        self.usagePercentage = max(0.0, min(100.0, usagePercentage))
        self.systemUsage = max(0.0, min(100.0, systemUsage))
        self.userUsage = max(0.0, min(100.0, userUsage))
        self.idlePercentage = max(0.0, min(100.0, idlePercentage))
    }
}




