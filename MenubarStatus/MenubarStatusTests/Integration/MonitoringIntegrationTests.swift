//
//  MonitoringIntegrationTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

@MainActor
final class MonitoringIntegrationTests: XCTestCase {
    var systemMonitor: SystemMonitorImpl!
    var settings: AppSettings!
    
    override func setUp() async throws {
        try await super.setUp()
        settings = AppSettings()
        systemMonitor = SystemMonitorImpl(settings: settings)
    }
    
    override func tearDown() async throws {
        systemMonitor.stop()
        systemMonitor = nil
        settings = nil
        try await super.tearDown()
    }
    
    func testFullMonitoringCycle() async throws {
        // Test: Start → collect → update → stop
        
        // 1. Start monitoring
        systemMonitor.start(interval: 2.0)
        XCTAssertTrue(systemMonitor.isMonitoring,
                     "Monitor should be running after start()")
        
        // 2. Wait for first collection
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5s
        
        // 3. Verify metrics collected
        XCTAssertNotNil(systemMonitor.currentMetrics,
                       "Should have metrics after interval")
        
        let firstMetrics = systemMonitor.currentMetrics
        XCTAssertNotNil(firstMetrics?.timestamp)
        
        // 4. Wait for second update
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5s
        
        let secondMetrics = systemMonitor.currentMetrics
        XCTAssertNotNil(secondMetrics)
        
        // Timestamps should be different
        if let first = firstMetrics?.timestamp, let second = secondMetrics?.timestamp {
            XCTAssertNotEqual(first, second,
                            "Metrics should update with new timestamp")
        }
        
        // 5. Stop monitoring
        systemMonitor.stop()
        XCTAssertFalse(systemMonitor.isMonitoring,
                      "Monitor should stop after stop()")
    }
    
    func testAllMetricsCollected() async throws {
        // Test: CPU, Memory, Disk, Network all present
        
        try await systemMonitor.refresh()
        
        guard let metrics = systemMonitor.currentMetrics else {
            XCTFail("No metrics collected")
            return
        }
        
        // Verify all metrics present
        XCTAssertNotNil(metrics.cpu,
                       "CPU metrics should be present")
        XCTAssertNotNil(metrics.memory,
                       "Memory metrics should be present")
        XCTAssertNotNil(metrics.disk,
                       "Disk metrics should be present")
        XCTAssertNotNil(metrics.network,
                       "Network metrics should be present")
        
        // Verify CPU values
        XCTAssertGreaterThanOrEqual(metrics.cpu.usagePercentage, 0)
        XCTAssertLessThanOrEqual(metrics.cpu.usagePercentage, 100)
        
        // Verify Memory values
        XCTAssertGreaterThan(metrics.memory.totalBytes, 0)
        XCTAssertGreaterThanOrEqual(metrics.memory.usedBytes, 0)
        
        // Verify Disk values
        XCTAssertGreaterThan(metrics.disk.totalBytes, 0)
        XCTAssertEqual(metrics.disk.volumePath, settings.selectedDiskPath)
        
        // Verify Network values
        XCTAssertGreaterThanOrEqual(metrics.network.uploadBytesPerSecond, 0)
        XCTAssertGreaterThanOrEqual(metrics.network.downloadBytesPerSecond, 0)
    }
    
    func testMetricsWithinReasonableRanges() async throws {
        // Test: Values are reasonable (not NaN, not negative)
        
        try await systemMonitor.refresh()
        
        guard let metrics = systemMonitor.currentMetrics else {
            XCTFail("No metrics collected")
            return
        }
        
        // CPU percentages sum should be ~100%
        let cpuSum = metrics.cpu.usagePercentage + metrics.cpu.idlePercentage
        XCTAssertEqual(cpuSum, 100.0, accuracy: 1.0,
                      "CPU usage + idle should equal 100%")
        
        // Memory: used + free should be <= total (accounting for cached)
        XCTAssertLessThanOrEqual(metrics.memory.usedBytes, metrics.memory.totalBytes,
                                "Used memory should not exceed total")
        
        // Disk: used + free should approximately equal total
        let diskSum = metrics.disk.usedBytes + metrics.disk.freeBytes
        let diskDiff = abs(Int64(diskSum) - Int64(metrics.disk.totalBytes))
        XCTAssertLessThan(diskDiff, 1024 * 1024 * 1024,
                         "Disk used + free should be close to total")
        
        // Network: rates should be reasonable (< 10 GB/s)
        XCTAssertLessThan(metrics.network.downloadBytesPerSecond, 10_000_000_000,
                         "Download rate should be reasonable")
        XCTAssertLessThan(metrics.network.uploadBytesPerSecond, 10_000_000_000,
                         "Upload rate should be reasonable")
    }
    
    func testChangingRefreshInterval() async throws {
        // Test: Changing interval during monitoring
        
        systemMonitor.start(interval: 3.0)
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        
        // Change interval
        var newSettings = settings!
        newSettings.refreshInterval = 1.0
        systemMonitor.settings = newSettings
        
        // Should still be monitoring
        XCTAssertTrue(systemMonitor.isMonitoring,
                     "Should continue monitoring after settings change")
        
        systemMonitor.stop()
    }
    
    func testManualRefreshWhileMonitoring() async throws {
        // Test: Manual refresh while auto-monitoring is active
        
        systemMonitor.start(interval: 5.0)
        
        // Manual refresh should work
        try await systemMonitor.refresh()
        
        XCTAssertNotNil(systemMonitor.currentMetrics,
                       "Manual refresh should work even while monitoring")
        
        systemMonitor.stop()
    }
}

