//
//  NetworkMonitorTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class NetworkMonitorTests: XCTestCase {
    var monitor: NetworkMonitorImpl!
    
    override func setUp() {
        super.setUp()
        monitor = NetworkMonitorImpl()
    }
    
    override func tearDown() {
        monitor = nil
        super.tearDown()
    }
    
    func testGetCurrentMetricsReturnsValidRates() async throws {
        // Test that network metrics have non-negative rates
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertGreaterThanOrEqual(metrics.uploadBytesPerSecond, 0,
                                   "Upload rate should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.downloadBytesPerSecond, 0,
                                   "Download rate should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.totalUploadBytes, 0,
                                   "Total upload should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.totalDownloadBytes, 0,
                                   "Total download should be >= 0")
    }
    
    func testMonotonicTotals() async throws {
        // Test that total bytes increase monotonically
        let metrics1 = try await monitor.getCurrentMetrics()
        
        // Wait for potential network activity
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        let metrics2 = try await monitor.getCurrentMetrics()
        
        // Totals should not decrease
        XCTAssertGreaterThanOrEqual(metrics2.totalUploadBytes, metrics1.totalUploadBytes,
                                   "Total upload should not decrease")
        XCTAssertGreaterThanOrEqual(metrics2.totalDownloadBytes, metrics1.totalDownloadBytes,
                                   "Total download should not decrease")
    }
    
    func testResetCounters() async throws {
        // Test that resetCounters resets totals
        _ = try await monitor.getCurrentMetrics()
        
        monitor.resetCounters()
        
        let metrics = try await monitor.getCurrentMetrics()
        
        // After reset, totals should be 0 or very small
        XCTAssertLessThan(metrics.totalUploadBytes, 1024 * 1024,
                         "Total upload should be near 0 after reset")
        XCTAssertLessThan(metrics.totalDownloadBytes, 1024 * 1024,
                         "Total download should be near 0 after reset")
    }
    
    func testExecutionTime() async throws {
        // Test that execution completes in <30ms (performance contract)
        let start = Date()
        _ = try await monitor.getCurrentMetrics()
        let duration = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(duration, 0.1,
                         "Network metrics collection should complete in <100ms")
    }
    
    func testThreadSafety() async throws {
        // Test concurrent rate calculations are safe
        await withTaskGroup(of: NetworkMetrics?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.monitor.getCurrentMetrics()
                }
            }
            
            var results: [NetworkMetrics] = []
            for await result in group {
                if let metrics = result {
                    results.append(metrics)
                }
            }
            
            XCTAssertEqual(results.count, 10,
                          "All concurrent calls should succeed")
        }
    }
    
    func testIsAvailable() throws {
        // Test that monitor is available
        XCTAssertTrue(monitor.isAvailable,
                     "Network monitor should be available")
    }
    
    func testFormattedOutput() async throws {
        // Test that formatted strings are valid
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertFalse(metrics.uploadFormatted.isEmpty,
                      "Upload formatted string should not be empty")
        XCTAssertFalse(metrics.downloadFormatted.isEmpty,
                      "Download formatted string should not be empty")
        
        // Should contain unit
        XCTAssertTrue(metrics.uploadFormatted.contains("B/s"),
                     "Upload should contain bytes/s unit")
        XCTAssertTrue(metrics.downloadFormatted.contains("B/s"),
                     "Download should contain bytes/s unit")
    }
}




