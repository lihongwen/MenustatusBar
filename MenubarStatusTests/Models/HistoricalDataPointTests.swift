//
//  HistoricalDataPointTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

final class HistoricalDataPointTests: XCTestCase {
    
    // MARK: - Validation Tests
    
    func testInit_AcceptsValidValues() {
        // When/Then
        XCTAssertNoThrow(
            HistoricalDataPoint(
                timestamp: Date(),
                metricType: .cpu,
                value: 50.0
            ),
            "Should accept valid values"
        )
    }
    
    // MARK: - TimeOffset Calculation Tests
    
    func testTimeOffset_CalculatesCorrectly() {
        // Given
        let now = Date()
        let pastDate = now.addingTimeInterval(-30) // 30 seconds ago
        
        let dataPoint = HistoricalDataPoint(
            timestamp: pastDate,
            metricType: .cpu,
            value: 50.0
        )
        
        // When
        let timeOffset = dataPoint.timeOffset
        
        // Then
        XCTAssertLessThan(timeOffset, 0, "Time offset should be negative for past dates")
        XCTAssertGreaterThan(timeOffset, -31, "Time offset should be approximately -30 seconds")
        XCTAssertLessThan(timeOffset, -29, "Time offset should be approximately -30 seconds")
    }
    
    func testTimeOffset_IsNegativeForPastTimestamps() {
        // Given
        let pastDate = Date().addingTimeInterval(-100)
        let dataPoint = HistoricalDataPoint(
            timestamp: pastDate,
            metricType: .memory,
            value: 75.0
        )
        
        // Then
        XCTAssertLessThan(dataPoint.timeOffset, 0, "Time offset should be negative for past timestamps")
    }
    
    // MARK: - MetricType Tests
    
    func testMetricType_HasDisplayNames() {
        // Given
        let types = MetricType.allCases
        
        // Then
        for type in types {
            XCTAssertFalse(type.displayName.isEmpty, "Display name should not be empty for \(type)")
        }
    }
    
    func testMetricType_HasIcons() {
        // Given
        let types = MetricType.allCases
        
        // Then
        for type in types {
            XCTAssertFalse(type.icon.isEmpty, "Icon should not be empty for \(type)")
        }
    }
    
    // MARK: - Identifiable Tests
    
    func testDataPoint_HasUniqueIDs() {
        // Given
        let point1 = HistoricalDataPoint(
            timestamp: Date(),
            metricType: .cpu,
            value: 50.0
        )
        let point2 = HistoricalDataPoint(
            timestamp: Date(),
            metricType: .cpu,
            value: 50.0
        )
        
        // Then
        XCTAssertNotEqual(point1.id, point2.id, "Each data point should have a unique ID")
    }
}

