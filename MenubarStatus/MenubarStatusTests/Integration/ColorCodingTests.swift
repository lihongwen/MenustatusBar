//
//  ColorCodingTests.swift
//  MenubarStatusTests
//
//  Test color coding precision (Scenario 4)
//  EXPECTED: MAY PASS - tests existing color behavior
//

import XCTest
import SwiftUI
@testable import MenubarStatus

final class ColorCodingTests: XCTestCase {
    
    func testColorCoding_ExactThresholds() {
        let theme = SystemDefaultTheme()
        let settings = AppSettings()
        
        // Test 30% → Green
        let green = TestHelpers.mockSystemMetrics(cpuUsage: 30.0)
        let greenSummary = MenubarSummaryBuilder.build(from: green, settings: settings)
        XCTAssertEqual(greenSummary.items[0].theme.statusColor(for: 30.0), theme.healthyColor)
        
        // Test 65% → Yellow
        let yellow = TestHelpers.mockSystemMetrics(cpuUsage: 65.0)
        let yellowSummary = MenubarSummaryBuilder.build(from: yellow, settings: settings)
        XCTAssertEqual(yellowSummary.items[0].theme.statusColor(for: 65.0), theme.warningColor)
        
        // Test 85% → Red
        let red = TestHelpers.mockSystemMetrics(cpuUsage: 85.0)
        let redSummary = MenubarSummaryBuilder.build(from: red, settings: settings)
        XCTAssertEqual(redSummary.items[0].theme.statusColor(for: 85.0), theme.criticalColor)
    }
}

