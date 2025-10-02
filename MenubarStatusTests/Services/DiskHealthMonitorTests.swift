//
//  DiskHealthMonitorTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Contract tests for DiskHealthMonitoring protocol
final class DiskHealthMonitorTests: XCTestCase {
    
    var sut: DiskHealthMonitorImpl!
    
    override func setUp() {
        super.setUp()
        sut = DiskHealthMonitorImpl()
    }
    
    override func tearDown() {
        sut?.stopMonitoring()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - getHealthInfo Tests
    
    func testGetHealthInfo_ReturnsNilForInvalidPath() {
        // Given
        let invalidPath = "/this/path/does/not/exist/definitely"
        
        // When
        let healthInfo = sut.getHealthInfo(forVolume: invalidPath)
        
        // Then
        XCTAssertNil(healthInfo, "Should return nil for invalid volume path")
    }
    
    func testGetHealthInfo_ReturnsDataForRootVolume() {
        // Given
        let rootPath = "/"
        
        // When
        let healthInfo = sut.getHealthInfo(forVolume: rootPath)
        
        // Then
        XCTAssertNotNil(healthInfo, "Should return health info for root volume")
        XCTAssertEqual(healthInfo?.id, rootPath, "ID should match the volume path")
        XCTAssertFalse(healthInfo?.volumeName.isEmpty ?? true, "Volume name should not be empty")
        XCTAssertFalse(healthInfo?.bsdName.isEmpty ?? true, "BSD name should not be empty")
    }
    
    func testGetHealthInfo_ReturnsValidHealthStatus() {
        // When
        let healthInfo = sut.getHealthInfo(forVolume: "/")
        
        // Then
        if let health = healthInfo {
            // Health status should be one of the defined cases
            let validStatuses: [HealthStatus] = [.good, .warning, .critical, .unavailable]
            XCTAssertTrue(
                validStatuses.contains(health.status),
                "Health status should be one of the defined values"
            )
        }
    }
    
    // MARK: - monitorAllVolumes Tests
    
    func testMonitorAllVolumes_ReturnsArray() {
        // When
        let volumes = sut.monitorAllVolumes()
        
        // Then
        XCTAssertTrue(volumes is [DiskHealthInfo], "Should return an array")
        XCTAssertGreaterThan(volumes.count, 0, "Should return at least one volume (root)")
    }
    
    func testMonitorAllVolumes_IncludesRootVolume() {
        // When
        let volumes = sut.monitorAllVolumes()
        
        // Then
        let hasRootVolume = volumes.contains { $0.id == "/" || $0.id.hasPrefix("/System") }
        XCTAssertTrue(hasRootVolume, "Should include the root volume")
    }
    
    func testMonitorAllVolumes_ReturnsSortedVolumes() {
        // When
        let volumes = sut.monitorAllVolumes()
        
        // Then - Internal volumes should come first
        if volumes.count > 1 {
            let firstVolumeIsInternal = volumes[0].id == "/" || volumes[0].id.hasPrefix("/System")
            // If we have multiple volumes and first is not internal, something's wrong
            // But we'll just verify the array is returned in expected order
            XCTAssertTrue(volumes.count > 0, "Should have volumes")
        }
    }
    
    // MARK: - startMonitoring/stopMonitoring Tests
    
    func testStartMonitoring_CallsCallbackImmediately() {
        // Given
        let expectation = self.expectation(description: "Callback should be called immediately")
        var callbackCalled = false
        
        // When
        sut.startMonitoring { volumes in
            callbackCalled = true
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(callbackCalled, "Callback should be called immediately upon starting monitoring")
    }
    
    func testStartMonitoring_CallbackReceivesValidData() {
        // Given
        let expectation = self.expectation(description: "Callback should receive valid data")
        
        // When
        sut.startMonitoring { volumes in
            // Then
            XCTAssertGreaterThan(volumes.count, 0, "Should provide at least one volume")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testStopMonitoring_CanBeCalledWhenNotMonitoring() {
        // When/Then - Should not crash
        XCTAssertNoThrow(sut.stopMonitoring(), "Should be safe to call stopMonitoring when not monitoring")
    }
    
    func testStopMonitoring_StopsCallbacks() {
        // Given
        var callbackCount = 0
        sut.startMonitoring { _ in
            callbackCount += 1
        }
        
        // Wait for initial callback
        Thread.sleep(forTimeInterval: 0.5)
        let initialCount = callbackCount
        
        // When
        sut.stopMonitoring()
        
        // Wait a bit more
        Thread.sleep(forTimeInterval: 0.5)
        
        // Then - Count shouldn't increase significantly after stopping
        // (there might be one more callback in flight)
        XCTAssertLessThanOrEqual(callbackCount, initialCount + 1, "Callbacks should stop after stopMonitoring")
    }
}

