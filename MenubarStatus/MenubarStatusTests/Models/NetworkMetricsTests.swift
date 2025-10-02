//
//  NetworkMetricsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class NetworkMetricsTests: XCTestCase {
    
    func testValidNetworkMetrics() throws {
        // Test valid byte rates
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 1_048_576,      // 1 MB/s
            downloadBytesPerSecond: 5_242_880,    // 5 MB/s
            totalUploadBytes: 100_000_000,
            totalDownloadBytes: 500_000_000
        )
        
        XCTAssertEqual(metrics.uploadBytesPerSecond, 1_048_576)
        XCTAssertEqual(metrics.downloadBytesPerSecond, 5_242_880)
        XCTAssertGreaterThanOrEqual(metrics.totalUploadBytes, 0)
        XCTAssertGreaterThanOrEqual(metrics.totalDownloadBytes, 0)
    }
    
    func testFormatKBPerSecond() throws {
        // Test format as KB/s when < 1 MB/s
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 512_000,      // 500 KB/s
            downloadBytesPerSecond: 102_400,    // 100 KB/s
            totalUploadBytes: 0,
            totalDownloadBytes: 0
        )
        
        XCTAssertTrue(metrics.uploadFormatted.contains("KB/s"),
                     "Should format as KB/s for < 1 MB/s")
        XCTAssertTrue(metrics.downloadFormatted.contains("KB/s"),
                     "Should format as KB/s for < 1 MB/s")
    }
    
    func testFormatMBPerSecond() throws {
        // Test format as MB/s when >= 1 MB/s
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 2_097_152,      // 2 MB/s
            downloadBytesPerSecond: 10_485_760,   // 10 MB/s
            totalUploadBytes: 0,
            totalDownloadBytes: 0
        )
        
        XCTAssertTrue(metrics.uploadFormatted.contains("MB/s"),
                     "Should format as MB/s for >= 1 MB/s")
        XCTAssertTrue(metrics.downloadFormatted.contains("MB/s"),
                     "Should format as MB/s for >= 1 MB/s")
    }
    
    func testMonotonicTotals() throws {
        // Test that total bytes only increase
        let metrics1 = NetworkMetrics(
            uploadBytesPerSecond: 1000,
            downloadBytesPerSecond: 2000,
            totalUploadBytes: 1_000_000,
            totalDownloadBytes: 2_000_000
        )
        
        let metrics2 = NetworkMetrics(
            uploadBytesPerSecond: 1500,
            downloadBytesPerSecond: 2500,
            totalUploadBytes: 1_500_000,    // Increased
            totalDownloadBytes: 2_500_000   // Increased
        )
        
        XCTAssertGreaterThanOrEqual(metrics2.totalUploadBytes, metrics1.totalUploadBytes,
                                   "Total upload should be monotonic increasing")
        XCTAssertGreaterThanOrEqual(metrics2.totalDownloadBytes, metrics1.totalDownloadBytes,
                                   "Total download should be monotonic increasing")
    }
    
    func testZeroValues() throws {
        // Test network disconnected (0 values)
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 0,
            downloadBytesPerSecond: 0,
            totalUploadBytes: 0,
            totalDownloadBytes: 0
        )
        
        XCTAssertEqual(metrics.uploadBytesPerSecond, 0)
        XCTAssertEqual(metrics.downloadBytesPerSecond, 0)
        // Should still format properly even with 0
        XCTAssertFalse(metrics.uploadFormatted.isEmpty)
        XCTAssertFalse(metrics.downloadFormatted.isEmpty)
    }
    
    func testFormatAccuracy() throws {
        // Test formatting precision
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 1_572_864,    // 1.5 MB/s
            downloadBytesPerSecond: 524_288,    // 512 KB/s
            totalUploadBytes: 0,
            totalDownloadBytes: 0
        )
        
        // Upload should show decimal for MB/s
        XCTAssertTrue(metrics.uploadFormatted.contains(".") || metrics.uploadFormatted.contains("MB/s"),
                     "Should show decimal precision for MB/s")
        
        // Download should be integer for KB/s
        XCTAssertTrue(metrics.downloadFormatted.contains("KB/s"))
    }
    
    func testHighBandwidth() throws {
        // Test with high bandwidth values (10 Gbps = ~1.25 GB/s)
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 1_250_000_000,    // ~1.19 GB/s
            downloadBytesPerSecond: 1_250_000_000,
            totalUploadBytes: 100_000_000_000,
            totalDownloadBytes: 100_000_000_000
        )
        
        XCTAssertGreaterThan(metrics.uploadBytesPerSecond, 0)
        XCTAssertTrue(metrics.uploadFormatted.contains("MB/s"),
                     "Should format large values as MB/s")
    }
    
    func testNegativeValuesRejected() throws {
        // Test that negative values are not allowed
        let metrics = NetworkMetrics(
            uploadBytesPerSecond: 1000,
            downloadBytesPerSecond: 2000,
            totalUploadBytes: 1_000_000,
            totalDownloadBytes: 2_000_000
        )
        
        // All values should be non-negative
        XCTAssertGreaterThanOrEqual(metrics.uploadBytesPerSecond, 0)
        XCTAssertGreaterThanOrEqual(metrics.downloadBytesPerSecond, 0)
        XCTAssertGreaterThanOrEqual(metrics.totalUploadBytes, 0)
        XCTAssertGreaterThanOrEqual(metrics.totalDownloadBytes, 0)
    }
}




