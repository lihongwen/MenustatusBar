//
//  CompactDisplayTests.swift
//  MenubarStatusTests
//
//  Integration test for compact display format (Scenario 1)
//  EXPECTED: FAIL - Compact format not implemented yet
//

import XCTest
import SwiftUI
@testable import MenubarStatus

final class CompactDisplayTests: XCTestCase {
    
    var settings: AppSettings!
    
    override func setUp() {
        super.setUp()
        settings = AppSettings()
        settings.displayConfiguration.showMenubarIcons = true
    }
    
    // MARK: - Scenario 1: Compact Format Display
    
    func testCompactFormat_DisplaysCorrectPattern() {
        // Given: System metrics
        let metrics = TestHelpers.mockSystemMetrics(
            cpuUsage: 45.0,
            memoryUsed: 8_000_000_000,
            memoryTotal: 16_000_000_000,
            diskUsed: 250_000_000_000,
            diskTotal: 1_000_000_000_000,
            downloadRate: 2_300_000
        )
        
        // When: Build menubar summary
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Then: Should match compact format
        XCTAssertEqual(summary.items.count, 4, "Should show 4 metrics")
        
        // CPU: ⚡45%
        let cpuItem = summary.items[0]
        XCTAssertEqual(cpuItem.icon, "cpu.fill")
        XCTAssertEqual(cpuItem.primaryText, "45%")
        
        // Memory: 💾50% (8GB/16GB = 50%)
        let memItem = summary.items[1]
        XCTAssertEqual(memItem.icon, "memorychip.fill")
        XCTAssertEqual(memItem.primaryText, "50%")
        
        // Disk: 💿25% (250GB/1TB = 25%)
        let diskItem = summary.items[2]
        XCTAssertEqual(diskItem.icon, "internaldrive.fill")
        XCTAssertEqual(diskItem.primaryText, "25%")
        
        // Network: 🌐↓2.3M
        let netItem = summary.items[3]
        XCTAssertEqual(netItem.icon, "network")
        XCTAssertEqual(netItem.primaryText, "↓2.3M")
    }
    
    func testCompactFormat_IntegerPercentages() {
        // Given: Metrics with decimal values
        let metrics = TestHelpers.mockSystemMetrics(
            cpuUsage: 45.67,
            memoryUsed: 8_500_000_000,
            memoryTotal: 16_000_000_000
        )
        
        // When: Build summary
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Then: Should display integers
        XCTAssertEqual(summary.items[0].primaryText, "46%", "CPU 45.67 → rounds to 46%")
        XCTAssertEqual(summary.items[1].primaryText, "53%", "Memory 53.125% → rounds to 53%")
    }
    
    func testCompactFormat_ColorCoding() {
        // Test: Icons colored based on exact percentages
        let theme = SystemDefaultTheme()
        
        // Green: < 60%
        let greenMetrics = TestHelpers.mockSystemMetrics(cpuUsage: 30.0)
        
        let greenSummary = MenubarSummaryBuilder.build(from: greenMetrics, settings: settings)
        XCTAssertEqual(greenSummary.items[0].theme.statusColor(for: 30.0), theme.healthyColor)
        
        // Yellow: 60-80%
        let yellowMetrics = TestHelpers.mockSystemMetrics(cpuUsage: 65.0)
        
        let yellowSummary = MenubarSummaryBuilder.build(from: yellowMetrics, settings: settings)
        XCTAssertEqual(yellowSummary.items[0].theme.statusColor(for: 65.0), theme.warningColor)
        
        // Red: >= 80%
        let redMetrics = TestHelpers.mockSystemMetrics(cpuUsage: 85.0)
        
        let redSummary = MenubarSummaryBuilder.build(from: redMetrics, settings: settings)
        XCTAssertEqual(redSummary.items[0].theme.statusColor(for: 85.0), theme.criticalColor)
    }
    
    func testCompactFormat_SmartNetworkUnits() {
        // Test: Network speeds use K/M/G units
        
        // 15 KB/s
        let kbMetrics = TestHelpers.mockSystemMetrics(downloadRate: 15_000)
        
        let kbSummary = MenubarSummaryBuilder.build(from: kbMetrics, settings: settings)
        XCTAssertEqual(kbSummary.items[3].primaryText, "↓15.0K")
        
        // 2.3 MB/s
        let mbMetrics = TestHelpers.mockSystemMetrics(downloadRate: 2_300_000)
        
        let mbSummary = MenubarSummaryBuilder.build(from: mbMetrics, settings: settings)
        XCTAssertEqual(mbSummary.items[3].primaryText, "↓2.3M")
        
        // 1.2 GB/s
        let gbMetrics = TestHelpers.mockSystemMetrics(downloadRate: 1_200_000_000)
        
        let gbSummary = MenubarSummaryBuilder.build(from: gbMetrics, settings: settings)
        XCTAssertEqual(gbSummary.items[3].primaryText, "↓1.2G")
    }
    
    func testCompactFormat_WithIconsDisabled() {
        // Given: Icons disabled
        settings.displayConfiguration.showMenubarIcons = false
        
        let metrics = TestHelpers.mockSystemMetrics(
            cpuUsage: 45.0,
            downloadRate: 2_300_000
        )
        
        // When: Build summary
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Then: Icons should be empty
        for item in summary.items {
            XCTAssertEqual(item.icon, "", "Icons should be empty when disabled")
        }
    }
    
    func testCompactFormat_WidthEstimate() {
        // Test: Verify compact format saves space
        // Expected: ~150pt for 4 metrics (vs ~240pt old format)
        
        // Note: Actual width measurement would require UI testing
        // This test verifies the format compactness
        
        let metrics = TestHelpers.mockSystemMetrics(
            cpuUsage: 100.0,
            memoryUsed: 16_000_000_000,
            memoryTotal: 16_000_000_000,
            diskUsed: 1_000_000_000_000,
            diskTotal: 1_000_000_000_000,
            downloadRate: 999_000_000
        )
        
        let summary = MenubarSummaryBuilder.build(from: metrics, settings: settings)
        
        // Verify all metrics present
        XCTAssertEqual(summary.items.count, 4)
        
        // Verify compact text
        XCTAssertTrue(summary.items[0].primaryText.count <= 4, "CPU text should be ≤4 chars")
        XCTAssertTrue(summary.items[1].primaryText.count <= 4, "Memory text should be ≤4 chars")
        XCTAssertTrue(summary.items[2].primaryText.count <= 4, "Disk text should be ≤4 chars")
        XCTAssertTrue(summary.items[3].primaryText.count <= 7, "Network text should be ≤7 chars")
    }
}

