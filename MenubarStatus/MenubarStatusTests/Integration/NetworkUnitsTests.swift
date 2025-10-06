//
//  NetworkUnitsTests.swift
//  MenubarStatusTests
//
//  Test network smart units (Scenario 5)
//  EXPECTED: FAIL - CompactFormatter not implemented
//

import XCTest
@testable import MenubarStatus

final class NetworkUnitsTests: XCTestCase {
    
    func testNetworkUnits_SmartFormatting() {
        let settings = AppSettings()
        
        // 15 KB/s
        let kb = TestHelpers.mockSystemMetrics(downloadRate: 15_000)
        let kbSummary = MenubarSummaryBuilder.build(from: kb, settings: settings)
        XCTAssertEqual(kbSummary.items[3].primaryText, "↓15.0K")
        
        // 2.3 MB/s
        let mb = TestHelpers.mockSystemMetrics(downloadRate: 2_300_000)
        let mbSummary = MenubarSummaryBuilder.build(from: mb, settings: settings)
        XCTAssertEqual(mbSummary.items[3].primaryText, "↓2.3M")
        
        // 1.2 GB/s
        let gb = TestHelpers.mockSystemMetrics(downloadRate: 1_200_000_000)
        let gbSummary = MenubarSummaryBuilder.build(from: gb, settings: settings)
        XCTAssertEqual(gbSummary.items[3].primaryText, "↓1.2G")
    }
}

