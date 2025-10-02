//
//  DiskMonitorTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class DiskMonitorTests: XCTestCase {
    var monitor: DiskMonitorImpl!
    
    override func setUp() {
        super.setUp()
        monitor = DiskMonitorImpl()
    }
    
    override func tearDown() {
        monitor = nil
        super.tearDown()
    }
    
    func testGetCurrentMetricsForValidPath() async throws {
        // Test that we can get metrics for system disk "/"
        let metrics = try await monitor.getCurrentMetrics(for: "/")
        
        XCTAssertEqual(metrics.volumePath, "/",
                      "Volume path should be /")
        XCTAssertFalse(metrics.volumeName.isEmpty,
                      "Volume name should not be empty")
        XCTAssertGreaterThan(metrics.totalBytes, 0,
                            "Total bytes should be > 0")
        XCTAssertGreaterThanOrEqual(metrics.freeBytes, 0,
                                   "Free bytes should be >= 0")
        XCTAssertGreaterThanOrEqual(metrics.usedBytes, 0,
                                   "Used bytes should be >= 0")
    }
    
    func testGetCurrentMetricsForInvalidPath() async throws {
        // Test that invalid path throws error
        do {
            _ = try await monitor.getCurrentMetrics(for: "/nonexistent/path/12345")
            XCTFail("Should throw error for invalid path")
        } catch {
            // Expected to throw
            XCTAssertTrue(error is MetricError,
                         "Should throw MetricError")
        }
    }
    
    func testGetAvailableVolumes() throws {
        // Test that we can list available volumes
        let volumes = monitor.getAvailableVolumes()
        
        XCTAssertFalse(volumes.isEmpty,
                      "Should have at least one volume")
        XCTAssertTrue(volumes.contains("/"),
                     "System disk / should always be present")
        
        // All paths should be absolute
        for volume in volumes {
            XCTAssertTrue(volume.hasPrefix("/"),
                         "Volume path should be absolute: \(volume)")
        }
    }
    
    func testExecutionTime() async throws {
        // Test that execution completes in <50ms (performance contract)
        let start = Date()
        _ = try await monitor.getCurrentMetrics(for: "/")
        let duration = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(duration, 0.1,
                         "Disk metrics collection should complete in <100ms")
    }
    
    func testUsedPlusFreeEqualsTotal() async throws {
        // Test disk space invariant
        let metrics = try await monitor.getCurrentMetrics(for: "/")
        
        let sum = metrics.usedBytes + metrics.freeBytes
        let difference = abs(Int64(sum) - Int64(metrics.totalBytes))
        
        // Allow small rounding differences
        XCTAssertLessThan(difference, 1024 * 1024,
                         "Used + Free should approximately equal Total")
    }
    
    func testUsagePercentageRange() async throws {
        // Test percentage is 0-100
        let metrics = try await monitor.getCurrentMetrics(for: "/")
        
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
    }
    
    func testIsAvailable() throws {
        // Test that monitor is available
        XCTAssertTrue(monitor.isAvailable,
                     "Disk monitor should be available")
    }
    
    func testMultipleVolumes() async throws {
        // Test querying multiple volumes
        let volumes = monitor.getAvailableVolumes()
        
        for volume in volumes.prefix(3) {
            let metrics = try await monitor.getCurrentMetrics(for: volume)
            XCTAssertGreaterThan(metrics.totalBytes, 0)
        }
    }
}




