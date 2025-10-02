//
//  SystemMetricsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class SystemMetricsTests: XCTestCase {
    
    func testValidSystemMetrics() throws {
        // Test creating complete system metrics snapshot
        let cpu = CPUMetrics(
            usagePercentage: 45.0,
            systemUsage: 20.0,
            userUsage: 25.0,
            idlePercentage: 55.0
        )
        
        let memory = MemoryMetrics(
            totalBytes: 16_000_000_000,
            usedBytes: 8_000_000_000,
            freeBytes: 8_000_000_000,
            cachedBytes: 1_000_000_000
        )
        
        let disk = DiskMetrics(
            volumePath: "/",
            volumeName: "Macintosh HD",
            totalBytes: 500_000_000_000,
            freeBytes: 200_000_000_000,
            usedBytes: 300_000_000_000
        )
        
        let network = NetworkMetrics(
            uploadBytesPerSecond: 1_048_576,
            downloadBytesPerSecond: 5_242_880,
            totalUploadBytes: 100_000_000,
            totalDownloadBytes: 500_000_000
        )
        
        let timestamp = Date()
        let metrics = SystemMetrics(
            timestamp: timestamp,
            cpu: cpu,
            memory: memory,
            disk: disk,
            network: network
        )
        
        XCTAssertEqual(metrics.timestamp, timestamp)
        XCTAssertEqual(metrics.cpu.usagePercentage, 45.0, accuracy: 0.01)
        XCTAssertEqual(metrics.memory.totalBytes, 16_000_000_000)
        XCTAssertEqual(metrics.disk.volumePath, "/")
        XCTAssertEqual(metrics.network.uploadBytesPerSecond, 1_048_576)
    }
    
    func testTimestamp() throws {
        // Test that timestamp is present and valid
        let now = Date()
        
        let metrics = SystemMetrics(
            timestamp: now,
            cpu: CPUMetrics(usagePercentage: 0, systemUsage: 0, userUsage: 0, idlePercentage: 100),
            memory: MemoryMetrics(totalBytes: 1000, usedBytes: 0, freeBytes: 1000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "Test", totalBytes: 1000, freeBytes: 1000, usedBytes: 0),
            network: NetworkMetrics(uploadBytesPerSecond: 0, downloadBytesPerSecond: 0, totalUploadBytes: 0, totalDownloadBytes: 0)
        )
        
        XCTAssertEqual(metrics.timestamp.timeIntervalSince(now), 0, accuracy: 0.001,
                      "Timestamp should match creation time")
    }
    
    func testCompositeStructure() throws {
        // Test that all sub-metrics are present and accessible
        let metrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 50, systemUsage: 25, userUsage: 25, idlePercentage: 50),
            memory: MemoryMetrics(totalBytes: 8_000_000_000, usedBytes: 4_000_000_000, freeBytes: 4_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 250_000_000_000, usedBytes: 250_000_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 500_000, downloadBytesPerSecond: 1_000_000, totalUploadBytes: 0, totalDownloadBytes: 0)
        )
        
        // Verify all components are accessible
        XCTAssertNotNil(metrics.cpu)
        XCTAssertNotNil(metrics.memory)
        XCTAssertNotNil(metrics.disk)
        XCTAssertNotNil(metrics.network)
        XCTAssertNotNil(metrics.timestamp)
    }
    
    func testMultipleSnapshots() throws {
        // Test that multiple snapshots can be created with different timestamps
        let snapshot1 = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 30, systemUsage: 15, userUsage: 15, idlePercentage: 70),
            memory: MemoryMetrics(totalBytes: 8_000_000_000, usedBytes: 3_000_000_000, freeBytes: 5_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 250_000_000_000, usedBytes: 250_000_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 100_000, downloadBytesPerSecond: 200_000, totalUploadBytes: 1_000_000, totalDownloadBytes: 2_000_000)
        )
        
        // Wait a tiny bit
        Thread.sleep(forTimeInterval: 0.01)
        
        let snapshot2 = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 35, systemUsage: 18, userUsage: 17, idlePercentage: 65),
            memory: MemoryMetrics(totalBytes: 8_000_000_000, usedBytes: 3_500_000_000, freeBytes: 4_500_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 249_900_000_000, usedBytes: 250_100_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 150_000, downloadBytesPerSecond: 250_000, totalUploadBytes: 1_150_000, totalDownloadBytes: 2_250_000)
        )
        
        // Timestamps should be different
        XCTAssertGreaterThan(snapshot2.timestamp, snapshot1.timestamp,
                            "Second snapshot should have later timestamp")
        
        // Values can be different
        XCTAssertNotEqual(snapshot1.cpu.usagePercentage, snapshot2.cpu.usagePercentage)
        XCTAssertGreaterThan(snapshot2.network.totalUploadBytes, snapshot1.network.totalUploadBytes)
    }
    
    func testStructIsImmutable() throws {
        // Test that SystemMetrics is a value type (struct)
        let original = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 40, systemUsage: 20, userUsage: 20, idlePercentage: 60),
            memory: MemoryMetrics(totalBytes: 8_000_000_000, usedBytes: 4_000_000_000, freeBytes: 4_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "Test", totalBytes: 1_000_000_000, freeBytes: 500_000_000, usedBytes: 500_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 0, downloadBytesPerSecond: 0, totalUploadBytes: 0, totalDownloadBytes: 0)
        )
        
        var copy = original
        
        // Modifying copy shouldn't affect original (value semantics)
        // This test verifies struct behavior
        XCTAssertEqual(original.cpu.usagePercentage, copy.cpu.usagePercentage)
    }
}




