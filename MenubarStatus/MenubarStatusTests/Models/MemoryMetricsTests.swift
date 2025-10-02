//
//  MemoryMetricsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class MemoryMetricsTests: XCTestCase {
    
    func testValidMemoryMetrics() throws {
        // Test valid memory metrics with realistic byte values
        let metrics = MemoryMetrics(
            totalBytes: 17_179_869_184,  // 16 GB
            usedBytes: 8_589_934_592,     // 8 GB
            freeBytes: 7_516_192_768,     // ~7 GB
            cachedBytes: 1_073_741_824    // 1 GB
        )
        
        XCTAssertEqual(metrics.totalBytes, 17_179_869_184)
        XCTAssertEqual(metrics.usedBytes, 8_589_934_592)
        XCTAssertGreaterThan(metrics.totalBytes, 0)
        XCTAssertGreaterThanOrEqual(metrics.freeBytes, 0)
    }
    
    func testUsagePercentageCalculation() throws {
        // Test correct percentage calculation
        let metrics = MemoryMetrics(
            totalBytes: 10_000_000_000,  // 10 GB
            usedBytes: 5_000_000_000,     // 5 GB (50%)
            freeBytes: 5_000_000_000,
            cachedBytes: 0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 50.0, accuracy: 0.1,
                      "Usage percentage should be 50%")
    }
    
    func testGigabytesConversion() throws {
        // Test correct GB conversion
        let metrics = MemoryMetrics(
            totalBytes: 8_589_934_592,    // 8 GB exactly
            usedBytes: 4_294_967_296,     // 4 GB exactly
            freeBytes: 4_294_967_296,
            cachedBytes: 0
        )
        
        XCTAssertEqual(metrics.totalGigabytes, 8.0, accuracy: 0.01,
                      "Total should be 8.0 GB")
        XCTAssertEqual(metrics.usedGigabytes, 4.0, accuracy: 0.01,
                      "Used should be 4.0 GB")
    }
    
    func testComputedProperties() throws {
        // Test all computed properties work correctly
        let metrics = MemoryMetrics(
            totalBytes: 16_000_000_000,
            usedBytes: 8_000_000_000,
            freeBytes: 8_000_000_000,
            cachedBytes: 1_000_000_000
        )
        
        XCTAssertGreaterThan(metrics.totalGigabytes, 0)
        XCTAssertGreaterThan(metrics.usedGigabytes, 0)
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
    }
    
    func testInvalidTotalBytes() throws {
        // Test that totalBytes = 0 is rejected or handled
        let metrics = MemoryMetrics(
            totalBytes: 0,
            usedBytes: 0,
            freeBytes: 0,
            cachedBytes: 0
        )
        
        // Should either throw or set to minimum valid value
        XCTAssertGreaterThan(metrics.totalBytes, 0,
                            "Total bytes must be greater than 0")
    }
    
    func testMemoryInvariants() throws {
        // Test that used <= total
        let metrics = MemoryMetrics(
            totalBytes: 10_000_000_000,
            usedBytes: 6_000_000_000,
            freeBytes: 4_000_000_000,
            cachedBytes: 500_000_000
        )
        
        XCTAssertLessThanOrEqual(metrics.usedBytes, metrics.totalBytes,
                                "Used bytes cannot exceed total bytes")
        XCTAssertLessThanOrEqual(metrics.freeBytes, metrics.totalBytes,
                                "Free bytes cannot exceed total bytes")
    }
    
    func testUsagePercentageRange() throws {
        // Test percentage is always 0-100
        let metrics = MemoryMetrics(
            totalBytes: 8_000_000_000,
            usedBytes: 7_500_000_000,
            freeBytes: 500_000_000,
            cachedBytes: 0
        )
        
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
    }
    
    func testFullMemory() throws {
        // Test 100% memory usage
        let metrics = MemoryMetrics(
            totalBytes: 8_000_000_000,
            usedBytes: 8_000_000_000,
            freeBytes: 0,
            cachedBytes: 0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 100.0, accuracy: 0.1)
    }
}




