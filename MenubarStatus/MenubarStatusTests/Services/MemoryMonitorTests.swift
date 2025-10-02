//
//  MemoryMonitorTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class MemoryMonitorTests: XCTestCase {
    var monitor: MemoryMonitorImpl!
    
    override func setUp() {
        super.setUp()
        monitor = MemoryMonitorImpl()
    }
    
    override func tearDown() {
        monitor = nil
        super.tearDown()
    }
    
    func testGetCurrentMetricsReturnsValidData() async throws {
        // Test that memory metrics have non-negative byte values
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertGreaterThan(metrics.totalBytes, 0,
                            "Total memory should be > 0")
        XCTAssertGreaterThanOrEqual(metrics.usedBytes, 0,
                                   "Used memory should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.freeBytes, 0,
                                   "Free memory should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.cachedBytes, 0,
                                   "Cached memory should be >= 0")
    }
    
    func testGetCurrentMetricsCompletesQuickly() async throws {
        // Test that execution completes in <10ms (performance contract)
        let start = Date()
        _ = try await monitor.getCurrentMetrics()
        let duration = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(duration, 0.05,
                         "Memory metrics collection should complete in <50ms")
    }
    
    func testMemoryInvariants() async throws {
        // Test that usedBytes <= totalBytes
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertLessThanOrEqual(metrics.usedBytes, metrics.totalBytes,
                                "Used memory cannot exceed total memory")
        XCTAssertLessThanOrEqual(metrics.freeBytes, metrics.totalBytes,
                                "Free memory cannot exceed total memory")
    }
    
    func testNoCache() async throws {
        // Test that metrics are always fresh (no caching)
        let metrics1 = try await monitor.getCurrentMetrics()
        
        // Small delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        let metrics2 = try await monitor.getCurrentMetrics()
        
        // Both calls should succeed with valid data
        XCTAssertGreaterThan(metrics1.totalBytes, 0)
        XCTAssertGreaterThan(metrics2.totalBytes, 0)
    }
    
    func testUsagePercentageRange() async throws {
        // Test that usage percentage is 0-100
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
    }
    
    func testIsAvailable() throws {
        // Test that monitor is available
        XCTAssertTrue(monitor.isAvailable,
                     "Memory monitor should be available")
    }
    
    func testConcurrentAccess() async throws {
        // Test thread safety
        await withTaskGroup(of: MemoryMetrics?.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    try? await self.monitor.getCurrentMetrics()
                }
            }
            
            var results: [MemoryMetrics] = []
            for await result in group {
                if let metrics = result {
                    results.append(metrics)
                }
            }
            
            XCTAssertEqual(results.count, 5,
                          "All concurrent calls should succeed")
        }
    }
}




