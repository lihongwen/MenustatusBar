//
//  PreciseUpdatesTests.swift
//  MenubarStatusTests
//
//  Test precise real-time updates (Scenario 3)
//  EXPECTED: MAY PASS - tests existing real-time behavior
//

import XCTest
@testable import MenubarStatus

final class PreciseUpdatesTests: XCTestCase {
    
    func testPreciseUpdates_NoRanges() {
        // Test: Values should be exact, not ranges
        let metrics1 = TestHelpers.mockSystemMetrics(cpuUsage: 45.0)
        
        let settings = AppSettings()
        let summary = MenubarSummaryBuilder.build(from: metrics1, settings: settings)
        
        // Verify exact value, not range
        XCTAssertEqual(summary.items[0].primaryText, "45%")
        XCTAssertFalse(summary.items[0].primaryText.contains("-"), "Should not contain range separator")
        
        // Update to different value
        let metrics2 = TestHelpers.mockSystemMetrics(cpuUsage: 47.0)
        
        let summary2 = MenubarSummaryBuilder.build(from: metrics2, settings: settings)
        XCTAssertEqual(summary2.items[0].primaryText, "47%")
    }
    
    func testPercentageStorage_MaintainsPrecision() {
        // Test: item.percentage should store exact value for color calculation
        let metrics = TestHelpers.mockSystemMetrics(cpuUsage: 45.67)
        
        let settings = AppSettings()
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Display should be rounded
        XCTAssertEqual(summary.items[0].primaryText, "46%")
        
        // But internal percentage should be exact
        XCTAssertEqual(summary.items[0].percentage, 45.67, accuracy: 0.01)
    }
}

