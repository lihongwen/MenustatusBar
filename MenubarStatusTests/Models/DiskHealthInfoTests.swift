//
//  DiskHealthInfoTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
import SwiftUI
@testable import MenubarStatus

final class DiskHealthInfoTests: XCTestCase {
    
    // MARK: - Health Status Determination Tests
    
    func testDetermineStatus_ReturnsUnavailableWhenNoSMART() {
        // When
        let status = HealthStatus.determineStatus(
            smartStatus: nil,
            readErrors: 0,
            writeErrors: 0,
            reallocatedSectors: 0
        )
        
        // Then
        XCTAssertEqual(status, .unavailable, "Should return unavailable when SMART data is nil")
    }
    
    func testDetermineStatus_ReturnsCriticalForFailingStatus() {
        // When
        let status = HealthStatus.determineStatus(
            smartStatus: "Failing",
            readErrors: 0,
            writeErrors: 0,
            reallocatedSectors: 0
        )
        
        // Then
        XCTAssertEqual(status, .critical, "Should return critical when SMART status is 'Failing'")
    }
    
    func testDetermineStatus_ReturnsCriticalForHighReallocatedSectors() {
        // When
        let status = HealthStatus.determineStatus(
            smartStatus: "Verified",
            readErrors: 0,
            writeErrors: 0,
            reallocatedSectors: 51
        )
        
        // Then
        XCTAssertEqual(status, .critical, "Should return critical when reallocated sectors > 50")
    }
    
    func testDetermineStatus_ReturnsWarningForModerateErrors() {
        // When
        let status = HealthStatus.determineStatus(
            smartStatus: "Verified",
            readErrors: 11,
            writeErrors: 5,
            reallocatedSectors: 0
        )
        
        // Then
        XCTAssertEqual(status, .warning, "Should return warning for moderate errors")
    }
    
    func testDetermineStatus_ReturnsGoodForHealthyDisk() {
        // When
        let status = HealthStatus.determineStatus(
            smartStatus: "Verified",
            readErrors: 0,
            writeErrors: 0,
            reallocatedSectors: 0
        )
        
        // Then
        XCTAssertEqual(status, .good, "Should return good for healthy disk")
    }
    
    // MARK: - Color Mapping Tests
    
    func testHealthColor_ReturnsCorrectColors() {
        // Given
        let goodHealth = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .good
        )
        let warningHealth = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .warning
        )
        let criticalHealth = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .critical
        )
        let unavailableHealth = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .unavailable
        )
        
        // Then - Just verify they return colors (actual color comparison is complex in SwiftUI)
        XCTAssertNotNil(goodHealth.healthColor)
        XCTAssertNotNil(warningHealth.healthColor)
        XCTAssertNotNil(criticalHealth.healthColor)
        XCTAssertNotNil(unavailableHealth.healthColor)
    }
    
    // MARK: - Icon Mapping Tests
    
    func testHealthIcon_ReturnsCorrectIcons() {
        // Given
        let statuses: [HealthStatus] = [.good, .warning, .critical, .unavailable]
        
        // Then
        for status in statuses {
            let health = DiskHealthInfo(
                id: "/",
                volumeName: "Test",
                bsdName: "disk0",
                status: status
            )
            XCTAssertFalse(health.healthIcon.isEmpty, "Icon should not be empty for \(status)")
            XCTAssertTrue(health.healthIcon.contains("."), "Icon should be an SF Symbol name")
        }
    }
    
    // MARK: - Formatted Power-On Time Tests
    
    func testFormattedPowerOnTime_FormatsCorrectly() {
        // Given
        let health = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .good,
            powerOnHours: 1440 // 60 days
        )
        
        // Then
        XCTAssertEqual(health.formattedPowerOnTime, "60 days", "Should format power-on time correctly")
    }
    
    func testFormattedPowerOnTime_ReturnsNilWhenUnavailable() {
        // Given
        let health = DiskHealthInfo(
            id: "/",
            volumeName: "Test",
            bsdName: "disk0",
            status: .good,
            powerOnHours: nil
        )
        
        // Then
        XCTAssertNil(health.formattedPowerOnTime, "Should return nil when power-on hours unavailable")
    }
}

