//
//  SparklineChartTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
import SwiftUI
@testable import MenubarStatus

/// Tests for SparklineChart component
final class SparklineChartTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testSparklineChart_InitializesWithValidData() {
        // Given
        let dataPoints = [
            HistoricalDataPoint(timestamp: Date(), metricType: .cpu, value: 50.0),
            HistoricalDataPoint(timestamp: Date(), metricType: .cpu, value: 75.0)
        ]
        
        // When/Then - Should not crash
        XCTAssertNoThrow(
            SparklineChart(dataPoints: dataPoints, color: .blue),
            "Should initialize with valid data"
        )
    }
    
    func testSparklineChart_InitializesWithEmptyData() {
        // Given
        let emptyData: [HistoricalDataPoint] = []
        
        // When/Then - Should not crash
        XCTAssertNoThrow(
            SparklineChart(dataPoints: emptyData, color: .red),
            "Should handle empty data gracefully"
        )
    }
    
    func testSparklineChart_HandlesLargeDataset() {
        // Given - 60 data points
        let dataPoints = (0..<60).map { i in
            HistoricalDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(-60 + i)),
                metricType: .cpu,
                value: Double.random(in: 0...100)
            )
        }
        
        // When/Then - Should not crash
        XCTAssertNoThrow(
            SparklineChart(dataPoints: dataPoints, color: .green),
            "Should handle 60 data points"
        )
    }
    
    // MARK: - View Body Tests
    
    func testSparklineChart_BodyReturnsView() {
        // Given
        let dataPoints = [
            HistoricalDataPoint(timestamp: Date(), metricType: .memory, value: 50.0)
        ]
        let sparkline = SparklineChart(dataPoints: dataPoints, color: .blue)
        
        // When
        let body = sparkline.body
        
        // Then - Body should be a valid view
        XCTAssertNotNil(body, "Body should return a view")
    }
}

