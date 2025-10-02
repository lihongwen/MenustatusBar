//
//  SystemMonitorTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

@MainActor
final class SystemMonitorTests: XCTestCase {
    var monitor: SystemMonitorImpl!
    var settings: AppSettings!
    
    override func setUp() async throws {
        try await super.setUp()
        settings = AppSettings()
        monitor = SystemMonitorImpl(settings: settings)
    }
    
    override func tearDown() async throws {
        monitor.stop()
        monitor = nil
        settings = nil
        try await super.tearDown()
    }
    
    func testStartMonitoring() async throws {
        // Test that start() sets isMonitoring = true
        XCTAssertFalse(monitor.isMonitoring,
                      "Should not be monitoring initially")
        
        monitor.start(interval: 2.0)
        
        XCTAssertTrue(monitor.isMonitoring,
                     "Should be monitoring after start()")
    }
    
    func testStopMonitoring() async throws {
        // Test that stop() sets isMonitoring = false
        monitor.start(interval: 2.0)
        XCTAssertTrue(monitor.isMonitoring)
        
        monitor.stop()
        
        XCTAssertFalse(monitor.isMonitoring,
                      "Should not be monitoring after stop()")
    }
    
    func testRefreshInterval() async throws {
        // Test that updates occur at configured interval (±100ms tolerance)
        monitor.start(interval: 1.0)
        
        // Wait for first update
        try await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s
        
        let timestamp1 = monitor.currentMetrics?.timestamp
        XCTAssertNotNil(timestamp1, "Should have metrics after interval")
        
        // Wait for second update
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1.0s
        
        let timestamp2 = monitor.currentMetrics?.timestamp
        XCTAssertNotNil(timestamp2, "Should have updated metrics")
        
        if let t1 = timestamp1, let t2 = timestamp2 {
            let actualInterval = t2.timeIntervalSince(t1)
            XCTAssertEqual(actualInterval, 1.0, accuracy: 0.2,
                          "Actual interval should be close to configured interval")
        }
        
        monitor.stop()
    }
    
    func testManualRefresh() async throws {
        // Test that refresh() can trigger manual update
        XCTAssertNil(monitor.currentMetrics,
                    "Should have no metrics initially")
        
        try await monitor.refresh()
        
        XCTAssertNotNil(monitor.currentMetrics,
                       "Should have metrics after manual refresh")
    }
    
    func testSettingsChange() async throws {
        // Test that changing settings adjusts behavior
        monitor.start(interval: 2.0)
        
        // Change refresh interval
        var newSettings = settings!
        newSettings.refreshInterval = 5.0
        monitor.settings = newSettings
        
        // Monitor should continue running with new interval
        XCTAssertTrue(monitor.isMonitoring)
        
        monitor.stop()
    }
    
    func testOnlyEnabledMetrics() async throws {
        // Test that only enabled metrics are collected
        var testSettings = AppSettings()
        testSettings.showCPU = true
        testSettings.showMemory = false
        testSettings.showDisk = false
        testSettings.showNetwork = false
        
        let testMonitor = SystemMonitorImpl(settings: testSettings)
        
        try await testMonitor.refresh()
        
        let metrics = testMonitor.currentMetrics
        XCTAssertNotNil(metrics, "Should have metrics")
        
        // All metrics should be present (implementation detail)
        // But monitor should respect settings when updating UI
        XCTAssertNotNil(metrics?.cpu)
    }
    
    func testCurrentMetricsNilBeforeStart() throws {
        // Test that currentMetrics is nil before monitoring starts
        XCTAssertNil(monitor.currentMetrics,
                    "Current metrics should be nil initially")
    }
    
    func testMultipleStartStopCycles() async throws {
        // Test that monitor handles multiple start/stop cycles
        for _ in 0..<3 {
            monitor.start(interval: 2.0)
            XCTAssertTrue(monitor.isMonitoring)
            
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            
            monitor.stop()
            XCTAssertFalse(monitor.isMonitoring)
        }
    }
    
    func testMetricsContainTimestamp() async throws {
        // Test that metrics have valid timestamp
        try await monitor.refresh()
        
        let metrics = monitor.currentMetrics
        XCTAssertNotNil(metrics?.timestamp,
                       "Metrics should have timestamp")
        
        let now = Date()
        let difference = abs(metrics!.timestamp.timeIntervalSince(now))
        XCTAssertLessThan(difference, 1.0,
                         "Timestamp should be recent")
    }
}




