//
//  DiskMetricsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class DiskMetricsTests: XCTestCase {
    
    func testValidDiskMetrics() throws {
        // Test valid disk data
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "Macintosh HD",
            totalBytes: 500_000_000_000,  // 500 GB
            freeBytes: 200_000_000_000,    // 200 GB
            usedBytes: 300_000_000_000     // 300 GB
        )
        
        XCTAssertEqual(metrics.volumePath, "/")
        XCTAssertEqual(metrics.volumeName, "Macintosh HD")
        XCTAssertEqual(metrics.totalBytes, 500_000_000_000)
        XCTAssertEqual(metrics.freeBytes, 200_000_000_000)
        XCTAssertEqual(metrics.usedBytes, 300_000_000_000)
    }
    
    func testUsedPlusFreeEqualsTotal() throws {
        // Test that usedBytes + freeBytes = totalBytes
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "System",
            totalBytes: 1_000_000_000_000,
            freeBytes: 400_000_000_000,
            usedBytes: 600_000_000_000
        )
        
        let sum = metrics.usedBytes + metrics.freeBytes
        XCTAssertEqual(sum, metrics.totalBytes,
                      "Used + Free should equal Total")
    }
    
    func testUsagePercentageCalculation() throws {
        // Test correct percentage calculation
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "Main",
            totalBytes: 1_000_000_000_000,  // 1 TB
            freeBytes: 250_000_000_000,      // 250 GB (25% free)
            usedBytes: 750_000_000_000       // 750 GB (75% used)
        )
        
        XCTAssertEqual(metrics.usagePercentage, 75.0, accuracy: 0.1,
                      "Usage should be 75%")
    }
    
    func testVolumePathValidation() throws {
        // Test valid absolute path
        let metrics = DiskMetrics(
            volumePath: "/Volumes/External",
            volumeName: "External Drive",
            totalBytes: 2_000_000_000_000,
            freeBytes: 1_000_000_000_000,
            usedBytes: 1_000_000_000_000
        )
        
        XCTAssertTrue(metrics.volumePath.hasPrefix("/"),
                     "Volume path should be absolute")
        XCTAssertFalse(metrics.volumePath.isEmpty,
                      "Volume path should not be empty")
    }
    
    func testEmptyVolumeNameRejected() throws {
        // Test that volume name cannot be empty
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "",
            totalBytes: 500_000_000_000,
            freeBytes: 200_000_000_000,
            usedBytes: 300_000_000_000
        )
        
        XCTAssertFalse(metrics.volumeName.isEmpty,
                      "Volume name should not be empty")
    }
    
    func testGigabytesConversion() throws {
        // Test GB conversion for all properties
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "Test",
            totalBytes: 1_073_741_824_000,  // ~1000 GB
            freeBytes: 536_870_912_000,      // ~500 GB
            usedBytes: 536_870_912_000       // ~500 GB
        )
        
        XCTAssertEqual(metrics.totalGigabytes, 1000.0, accuracy: 1.0)
        XCTAssertEqual(metrics.freeGigabytes, 500.0, accuracy: 1.0)
        XCTAssertEqual(metrics.usedGigabytes, 500.0, accuracy: 1.0)
    }
    
    func testFullDisk() throws {
        // Test 100% disk usage
        let metrics = DiskMetrics(
            volumePath: "/",
            volumeName: "Full Disk",
            totalBytes: 500_000_000_000,
            freeBytes: 0,
            usedBytes: 500_000_000_000
        )
        
        XCTAssertEqual(metrics.usagePercentage, 100.0, accuracy: 0.1)
        XCTAssertEqual(metrics.freeBytes, 0)
    }
    
    func testEmptyDisk() throws {
        // Test 0% disk usage (brand new disk)
        let metrics = DiskMetrics(
            volumePath: "/Volumes/New",
            volumeName: "Empty Disk",
            totalBytes: 1_000_000_000_000,
            freeBytes: 1_000_000_000_000,
            usedBytes: 0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 0.0, accuracy: 0.1)
        XCTAssertEqual(metrics.usedBytes, 0)
    }
}




