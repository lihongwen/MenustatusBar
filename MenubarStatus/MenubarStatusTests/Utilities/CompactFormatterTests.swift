//
//  CompactFormatterTests.swift
//  MenubarStatusTests
//
//  Comprehensive edge case tests for CompactFormatter
//

import XCTest
@testable import MenubarStatus

final class CompactFormatterTests: XCTestCase {
    
    // MARK: - Percentage Formatting Tests
    
    func testFormatPercentage_Zero() {
        XCTAssertEqual(CompactFormatter.formatPercentage(0.0), "0%")
    }
    
    func testFormatPercentage_SmallValue() {
        XCTAssertEqual(CompactFormatter.formatPercentage(0.3), "0%")
        XCTAssertEqual(CompactFormatter.formatPercentage(0.4), "0%")
    }
    
    func testFormatPercentage_RoundsDown() {
        XCTAssertEqual(CompactFormatter.formatPercentage(45.2), "45%")
        XCTAssertEqual(CompactFormatter.formatPercentage(45.4), "45%")
    }
    
    func testFormatPercentage_RoundsUp() {
        XCTAssertEqual(CompactFormatter.formatPercentage(45.5), "46%")
        XCTAssertEqual(CompactFormatter.formatPercentage(45.7), "46%")
        XCTAssertEqual(CompactFormatter.formatPercentage(45.9), "46%")
    }
    
    func testFormatPercentage_Exactly50() {
        XCTAssertEqual(CompactFormatter.formatPercentage(50.0), "50%")
    }
    
    func testFormatPercentage_NearHundred() {
        XCTAssertEqual(CompactFormatter.formatPercentage(99.4), "99%")
        XCTAssertEqual(CompactFormatter.formatPercentage(99.5), "100%")
        XCTAssertEqual(CompactFormatter.formatPercentage(99.9), "100%")
    }
    
    func testFormatPercentage_ExactlyHundred() {
        XCTAssertEqual(CompactFormatter.formatPercentage(100.0), "100%")
    }
    
    func testFormatPercentage_OverHundred() {
        // Edge case: system might report >100% in some scenarios
        XCTAssertEqual(CompactFormatter.formatPercentage(101.5), "102%")
        XCTAssertEqual(CompactFormatter.formatPercentage(150.0), "150%")
    }
    
    func testFormatPercentage_Negative() {
        // Edge case: should handle negative values gracefully
        XCTAssertEqual(CompactFormatter.formatPercentage(-1.0), "-1%")
        XCTAssertEqual(CompactFormatter.formatPercentage(-0.3), "0%")
    }
    
    // MARK: - Network Speed Formatting Tests
    
    func testFormatNetworkSpeed_Zero() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(0), "0K")
    }
    
    func testFormatNetworkSpeed_LessThan1KB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(100), "0K")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(512), "0K")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1023), "0K")
    }
    
    func testFormatNetworkSpeed_ExactlyOneKB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1024), "1.0K")
    }
    
    func testFormatNetworkSpeed_KBRange() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(15_360), "15.0K")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(102_400), "100.0K")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(512_000), "500.0K")
    }
    
    func testFormatNetworkSpeed_AlmostMB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_048_575), "1024.0K")
    }
    
    func testFormatNetworkSpeed_ExactlyOneMB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_048_576), "1.0M")
    }
    
    func testFormatNetworkSpeed_MBRange() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(2_457_600), "2.3M")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(10_485_760), "10.0M")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(104_857_600), "100.0M")
    }
    
    func testFormatNetworkSpeed_AlmostGB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_073_741_823), "1024.0M")
    }
    
    func testFormatNetworkSpeed_ExactlyOneGB() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_073_741_824), "1.0G")
    }
    
    func testFormatNetworkSpeed_GBRange() {
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_288_490_189), "1.2G")
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(10_737_418_240), "10.0G")
    }
    
    func testFormatNetworkSpeed_VeryLarge() {
        // Edge case: extremely high network speeds
        XCTAssertEqual(CompactFormatter.formatNetworkSpeed(10_737_418_240_000), "10000.0G")
    }
    
    func testFormatNetworkSpeed_MaxUInt64() {
        // Edge case: maximum UInt64 value
        let maxValue = UInt64.max
        let result = CompactFormatter.formatNetworkSpeed(maxValue)
        // Should not crash and should produce some output
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.hasSuffix("G"))
    }
    
    // MARK: - Format for Menubar Tests
    
    func testFormatForMenubar_CPUWithIcon() {
        let theme = SystemDefaultTheme()
        let (text, color) = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 45.23,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "cpu.fill 45%")
        // Color should be healthy (green) for 45%
        XCTAssertEqual(color, theme.healthyColor)
    }
    
    func testFormatForMenubar_CPUWithoutIcon() {
        let theme = SystemDefaultTheme()
        let (text, _) = CompactFormatter.formatForMenubar(
            type: .cpu,
            percentage: 45.23,
            theme: theme,
            showIcon: false
        )
        
        XCTAssertEqual(text, "45%")
    }
    
    func testFormatForMenubar_MemoryWarningRange() {
        let theme = SystemDefaultTheme()
        let (text, color) = CompactFormatter.formatForMenubar(
            type: .memory,
            percentage: 72.5,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "memorychip.fill 73%")
        // Color should be warning (yellow/orange) for 72.5%
        XCTAssertEqual(color, theme.warningColor)
    }
    
    func testFormatForMenubar_DiskCriticalRange() {
        let theme = SystemDefaultTheme()
        let (text, color) = CompactFormatter.formatForMenubar(
            type: .disk,
            percentage: 85.0,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "internaldrive.fill 85%")
        // Color should be critical (red) for 85%
        XCTAssertEqual(color, theme.criticalColor)
    }
    
    func testFormatForMenubar_NetworkWithSpeed() {
        let theme = SystemDefaultTheme()
        let (text, _) = CompactFormatter.formatForMenubar(
            type: .network,
            percentage: 30.0,
            bytesPerSecond: 2_457_600,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "network ↓2.3M")
    }
    
    func testFormatForMenubar_NetworkWithoutSpeed() {
        let theme = SystemDefaultTheme()
        let (text, _) = CompactFormatter.formatForMenubar(
            type: .network,
            percentage: 30.0,
            bytesPerSecond: nil,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "network 0K")
    }
    
    func testFormatForMenubar_NetworkZeroSpeed() {
        let theme = SystemDefaultTheme()
        let (text, _) = CompactFormatter.formatForMenubar(
            type: .network,
            percentage: 0.0,
            bytesPerSecond: 0,
            theme: theme,
            showIcon: true
        )
        
        XCTAssertEqual(text, "network 0K")
    }
    
    // MARK: - Format for Dropdown Tests
    
    func testFormatForDropdown_TwoDecimalPlaces() {
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .cpu, percentage: 45.23), "45.23%")
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .memory, percentage: 72.84), "72.84%")
    }
    
    func testFormatForDropdown_RoundsToTwoDecimals() {
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .cpu, percentage: 45.236), "45.24%")
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .cpu, percentage: 45.234), "45.23%")
    }
    
    func testFormatForDropdown_WholeNumbers() {
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .cpu, percentage: 50.0), "50.00%")
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .memory, percentage: 100.0), "100.00%")
    }
    
    func testFormatForDropdown_Zero() {
        XCTAssertEqual(CompactFormatter.formatForDropdown(type: .disk, percentage: 0.0), "0.00%")
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_FormatPercentage() {
        measure {
            for i in 0..<10_000 {
                _ = CompactFormatter.formatPercentage(Double(i % 100))
            }
        }
    }
    
    func testPerformance_FormatNetworkSpeed() {
        measure {
            for i in 0..<10_000 {
                _ = CompactFormatter.formatNetworkSpeed(UInt64(i * 1024))
            }
        }
    }
    
    func testPerformance_FormatForMenubar() {
        let theme = SystemDefaultTheme()
        measure {
            for i in 0..<1_000 {
                _ = CompactFormatter.formatForMenubar(
                    type: .cpu,
                    percentage: Double(i % 100),
                    theme: theme,
                    showIcon: true
                )
            }
        }
    }
    
    // MARK: - Consistency Tests
    
    func testConsistency_Formatting() {
        // Same input should always produce same output
        let value = 45.67
        let result1 = CompactFormatter.formatPercentage(value)
        let result2 = CompactFormatter.formatPercentage(value)
        XCTAssertEqual(result1, result2)
    }
    
    func testConsistency_NetworkFormatting() {
        // Same input should always produce same output
        let bytes: UInt64 = 2_457_600
        let result1 = CompactFormatter.formatNetworkSpeed(bytes)
        let result2 = CompactFormatter.formatNetworkSpeed(bytes)
        XCTAssertEqual(result1, result2)
    }
}

