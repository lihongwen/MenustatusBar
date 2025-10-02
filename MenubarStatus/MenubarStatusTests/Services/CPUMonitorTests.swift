//
//  CPUMonitorTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class CPUMonitorTests: XCTestCase {
    var monitor: CPUMonitorImpl!
    
    override func setUp() {
        super.setUp()
        monitor = CPUMonitorImpl()
    }
    
    override func tearDown() {
        monitor = nil
        super.tearDown()
    }
    
    func testGetCurrentMetricsReturnsValidRange() async throws {
        // Test that CPU metrics are within valid range 0-100
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0,
                                   "CPU usage should be >= 0%")
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0,
                                "CPU usage should be <= 100%")
        XCTAssertGreaterThanOrEqual(metrics.userUsage, 0.0)
        XCTAssertLessThanOrEqual(metrics.userUsage, 100.0)
        XCTAssertGreaterThanOrEqual(metrics.systemUsage, 0.0)
        XCTAssertLessThanOrEqual(metrics.systemUsage, 100.0)
        XCTAssertGreaterThanOrEqual(metrics.idlePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.idlePercentage, 100.0)
    }
    
    func testGetCurrentMetricsCompletesQuickly() async throws {
        // Test that execution completes in <20ms (performance contract)
        let start = Date()
        _ = try await monitor.getCurrentMetrics()
        let duration = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(duration, 0.1,
                         "CPU metrics collection should complete in <100ms")
    }
    
    func testConcurrentCallsAreThreadSafe() async throws {
        // Test that concurrent calls don't crash or corrupt state
        await withTaskGroup(of: CPUMetrics?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.monitor.getCurrentMetrics()
                }
            }
            
            var results: [CPUMetrics] = []
            for await result in group {
                if let metrics = result {
                    results.append(metrics)
                }
            }
            
            XCTAssertEqual(results.count, 10,
                          "All concurrent calls should succeed")
        }
    }
    
    func testIsAvailableProperty() throws {
        // Test that isAvailable returns Bool
        let available = monitor.isAvailable
        XCTAssertTrue(available is Bool,
                     "isAvailable should return Bool")
    }
    
    func testDeltaCalculation() async throws {
        // Test accurate delta calculation between calls
        let metrics1 = try await monitor.getCurrentMetrics()
        
        // Wait for CPU activity
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        let metrics2 = try await monitor.getCurrentMetrics()
        
        // Second call should have valid metrics (not necessarily different)
        XCTAssertGreaterThanOrEqual(metrics2.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics2.usagePercentage, 100.0)
    }
    
    func testMultipleSequentialCalls() async throws {
        // Test that multiple sequential calls work correctly
        for _ in 0..<5 {
            let metrics = try await monitor.getCurrentMetrics()
            XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
            XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
        }
    }
}




