//
//  TestHelpers.swift
//  MenubarStatusTests
//
//  Test helper functions for creating mock data
//

import Foundation
@testable import MenubarStatus

/// Test helpers for creating mock metrics
struct TestHelpers {
    
    /// Create mock SystemMetrics with custom values
    static func mockSystemMetrics(
        cpuUsage: Double = 45.0,
        memoryUsed: UInt64 = 8_000_000_000,
        memoryTotal: UInt64 = 16_000_000_000,
        diskUsed: UInt64 = 250_000_000_000,
        diskTotal: UInt64 = 1_000_000_000_000,
        downloadRate: UInt64 = 0,
        uploadRate: UInt64 = 0
    ) -> SystemMetrics {
        let cpu = CPUMetrics(
            usagePercentage: cpuUsage,
            systemUsage: cpuUsage * 0.3,
            userUsage: cpuUsage * 0.7,
            idlePercentage: 100.0 - cpuUsage
        )
        
        let memory = MemoryMetrics(
            totalBytes: memoryTotal,
            usedBytes: memoryUsed,
            freeBytes: memoryTotal - memoryUsed,
            cachedBytes: 0
        )
        
        let disk = DiskMetrics(
            volumePath: "/",
            volumeName: "Macintosh HD",
            totalBytes: diskTotal,
            freeBytes: diskTotal - diskUsed,
            usedBytes: diskUsed,
            readBytesPerSecond: 0,
            writeBytesPerSecond: 0
        )
        
        let network = NetworkMetrics(
            uploadBytesPerSecond: uploadRate,
            downloadBytesPerSecond: downloadRate,
            totalUploadBytes: 0,
            totalDownloadBytes: 0
        )
        
        return SystemMetrics(
            timestamp: Date(),
            cpu: cpu,
            memory: memory,
            disk: disk,
            network: network
        )
    }
}

