//
//  CompactFormattingContractTests.swift
//  MenubarStatusTests
//
//  Test contract compliance for CompactFormatting protocol
//  EXPECTED: All tests FAIL (no implementation yet)
//

import XCTest
@testable import MenubarStatus

final class CompactFormattingContractTests: XCTestCase {
    
    // MARK: - formatPercentage Tests
    
    func testFormatPercentage_Standard() {
        // Contract: formatPercentage(45.67) → "46%" (rounds to nearest integer)
        let result = CompactFormatter.formatPercentage(45.67)
        XCTAssertEqual(result, "46%", "Should format to integer percentage with rounding")
    }
    
    func testFormatPercentage_Zero() {
        // Contract: formatPercentage(0.0) → "0%"
        let result = CompactFormatter.formatPercentage(0.0)
        XCTAssertEqual(result, "0%")
    }
    
    func testFormatPercentage_Hundred() {
        // Contract: formatPercentage(100.0) → "100%"
        let result = CompactFormatter.formatPercentage(100.0)
        XCTAssertEqual(result, "100%")
    }
    
    func testFormatPercentage_Rounding() {
        // Contract: Rounds to nearest integer
        XCTAssertEqual(CompactFormatter.formatPercentage(45.4), "45%")
        XCTAssertEqual(CompactFormatter.formatPercentage(45.5), "46%")
        XCTAssertEqual(CompactFormatter.formatPercentage(45.9), "46%")
    }
    
    // MARK: - formatNetworkSpeed Tests
    
    func testFormatNetworkSpeed_Bytes() {
        // Contract: < 1000 B/s → "0.0K"
        let result = CompactFormatter.formatNetworkSpeed(500)
        XCTAssertEqual(result, "0.0K", "Small values should show as 0.0K")
    }
    
    func testFormatNetworkSpeed_Kilobytes() {
        // Contract: 15 KB/s → "15.0K"
        let result = CompactFormatter.formatNetworkSpeed(15_000)
        XCTAssertEqual(result, "15.0K")
    }
    
    func testFormatNetworkSpeed_Megabytes() {
        // Contract: 2.3 MB/s → "2.3M"
        let result = CompactFormatter.formatNetworkSpeed(2_300_000)
        XCTAssertEqual(result, "2.3M")
    }
    
    func testFormatNetworkSpeed_Gigabytes() {
        // Contract: 1.2 GB/s → "1.2G"
        let result = CompactFormatter.formatNetworkSpeed(1_200_000_000)
        XCTAssertEqual(result, "1.2G")
    }
    
    func testFormatNetworkSpeed_EdgeCase_999KB() {
        // Contract: 999 KB/s → "999.0K" (not "1.0M")
        let result = CompactFormatter.formatNetworkSpeed(999_000)
        XCTAssertEqual(result, "999.0K")
    }
    
    func testFormatNetworkSpeed_EdgeCase_1MB() {
        // Contract: 1.0 MB/s → "1.0M"
        let result = CompactFormatter.formatNetworkSpeed(1_000_000)
        XCTAssertEqual(result, "1.0M")
    }
    
    // MARK: - formatForMenubar Tests
    
    func testFormatForMenubar_CPU_WithIcon() {
        // Contract: CPU 45% with icon → (icon: "cpu.fill", text: "45%", color: green)
        let theme = SystemDefaultTheme()
        let result = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 45.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(result.icon, "cpu.fill")
        XCTAssertEqual(result.text, "45%")
        // Green color for 45% (< 60%)
        XCTAssertEqual(result.color, theme.healthyColor)
    }
    
    func testFormatForMenubar_CPU_WithoutIcon() {
        // Contract: showIcon: false → icon should be empty
        let theme = SystemDefaultTheme()
        let result = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 45.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: false
        )
        
        XCTAssertEqual(result.icon, "")
        XCTAssertEqual(result.text, "45%")
    }
    
    func testFormatForMenubar_Memory_YellowThreshold() {
        // Contract: 65% → yellow color
        let theme = SystemDefaultTheme()
        let result = CompactFormatter.formatForMenubar(
            type: .memory,
            percentage: 65.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(result.icon, "memorychip.fill")
        XCTAssertEqual(result.text, "65%")
        XCTAssertEqual(result.color, theme.warningColor)
    }
    
    func testFormatForMenubar_Disk_RedThreshold() {
        // Contract: 85% → red color
        let theme = SystemDefaultTheme()
        let result = CompactFormatter.formatForMenubar(
            type: .disk,
            percentage: 85.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(result.icon, "internaldrive.fill")
        XCTAssertEqual(result.text, "85%")
        XCTAssertEqual(result.color, theme.criticalColor)
    }
    
    func testFormatForMenubar_Network_WithSpeed() {
        // Contract: Network with bytesPerSecond → format speed
        let theme = SystemDefaultTheme()
        let result = CompactFormatter.formatForMenubar(
            type: .network,
            percentage: 30.0,
            bytesPerSecond: 2_300_000, // 2.3 MB/s
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(result.icon, "network")
        XCTAssertEqual(result.text, "↓2.3M")
        XCTAssertEqual(result.color, theme.healthyColor)
    }
    
    func testFormatForMenubar_ColorThresholds() {
        // Contract: Test exact threshold boundaries
        let theme = SystemDefaultTheme()
        
        // 59% → green
        let green = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 59.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: false
        )
        XCTAssertEqual(green.color, theme.healthyColor)
        
        // 60% → yellow
        let yellow = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 60.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: false
        )
        XCTAssertEqual(yellow.color, theme.warningColor)
        
        // 79% → yellow
        let stillYellow = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 79.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: false
        )
        XCTAssertEqual(stillYellow.color, theme.warningColor)
        
        // 80% → red
        let red = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 80.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: false
        )
        XCTAssertEqual(red.color, theme.criticalColor)
    }
    
    // MARK: - Edge Cases
    
    func testFormatPercentage_Negative() {
        // Contract: Negative values → clamp to 0
        let result = CompactFormatter.formatPercentage(-5.0)
        XCTAssertEqual(result, "0%")
    }
    
    func testFormatPercentage_OverHundred() {
        // Contract: Values > 100 → keep actual value
        let result = CompactFormatter.formatPercentage(105.0)
        XCTAssertEqual(result, "105%")
    }
    
    func testFormatNetworkSpeed_Zero() {
        // Contract: 0 B/s → "0.0K"
        let result = CompactFormatter.formatNetworkSpeed(0)
        XCTAssertEqual(result, "0.0K")
    }
}

