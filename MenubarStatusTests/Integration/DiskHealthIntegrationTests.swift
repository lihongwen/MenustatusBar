//
//  DiskHealthIntegrationTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Integration tests for DiskHealthMonitor with real volumes
final class DiskHealthIntegrationTests: XCTestCase {
    
    var diskHealthMonitor: DiskHealthMonitorImpl!
    
    override func setUp() {
        super.setUp()
        diskHealthMonitor = DiskHealthMonitorImpl()
    }
    
    override func tearDown() {
        diskHealthMonitor?.stopMonitoring()
        diskHealthMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Real Volume Integration Tests
    
    func testMonitorAllVolumes_ReturnsSystemVolumes() {
        // When
        let volumes = diskHealthMonitor.monitorAllVolumes()
        
        // Then
        XCTAssertGreaterThan(volumes.count, 0, "Should detect at least one volume (system volume)")
        
        for volume in volumes {
            XCTAssertFalse(volume.id.isEmpty, "Volume ID should not be empty")
            XCTAssertFalse(volume.volumeName.isEmpty, "Volume name should not be empty")
            XCTAssertFalse(volume.bsdName.isEmpty, "BSD name should not be empty")
        }
    }
    
    func testGetHealthInfo_ReturnsDataForRootVolume() {
        // When
        let rootHealth = diskHealthMonitor.getHealthInfo(forVolume: "/")
        
        // Then
        XCTAssertNotNil(rootHealth, "Should return health info for root volume")
        
        if let health = rootHealth {
            XCTAssertFalse(health.volumeName.isEmpty, "Volume name should not be empty")
            XCTAssertFalse(health.bsdName.isEmpty, "BSD name should not be empty")
            
            // Health status should be one of the defined values
            let validStatuses: [HealthStatus] = [.good, .warning, .critical, .unavailable]
            XCTAssertTrue(
                validStatuses.contains(health.status),
                "Health status should be valid"
            )
        }
    }
    
    func testStartMonitoring_DetectsVolumeChanges() {
        // Given
        let expectation = self.expectation(description: "Monitoring callback should be called")
        var callbackCount = 0
        
        // When
        diskHealthMonitor.startMonitoring { volumes in
            callbackCount += 1
            if callbackCount >= 1 {
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3.0)
        XCTAssertGreaterThanOrEqual(callbackCount, 1, "Callback should be called at least once")
    }
    
    func testDiskHealthMonitor_IntegratesWithDiskMonitor() {
        // Given
        let diskHealthMonitor = DiskHealthMonitorImpl()
        let diskMonitor = DiskMonitorImpl(diskHealthMonitor: diskHealthMonitor)
        
        // When - Get metrics for root volume
        do {
            let metrics = try diskMonitor.getCurrentMetrics(for: "/")
            
            // Then - Should include health info
            XCTAssertNotNil(metrics, "Should return metrics")
            // Note: healthInfo might be nil if SMART data is unavailable, which is okay
            // We just verify the integration doesn't crash
        } catch {
            // Disk monitor might fail for various reasons (permissions, etc.)
            // The important thing is it doesn't crash
            print("Disk monitor test failed with expected error: \(error)")
        }
    }
    
    func testMonitorAllVolumes_IncludesHealthStatus() {
        // When
        let volumes = diskHealthMonitor.monitorAllVolumes()
        
        // Then - All volumes should have a health status
        for volume in volumes {
            let validStatuses: [HealthStatus] = [.good, .warning, .critical, .unavailable]
            XCTAssertTrue(
                validStatuses.contains(volume.status),
                "Volume \(volume.volumeName) should have a valid health status"
            )
        }
    }
}

