//
//  SparklinePerformanceTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
import SwiftUI
@testable import MenubarStatus

/// Performance tests for sparkline chart rendering
final class SparklinePerformanceTests: XCTestCase {
    
    // MARK: - Performance Tests
    
    func testSparklineRendering_60Points() {
        // Given - Create 60 data points (1 minute at 1 second intervals)
        let dataPoints = (0..<60).map { i in
            HistoricalDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(-60 + i)),
                metricType: .cpu,
                value: Double.random(in: 0...100)
            )
        }
        
        // Measure rendering performance
        measure(metrics: [XCTClockMetric()]) {
            // When - Create sparkline view
            let sparkline = SparklineChart(
                dataPoints: dataPoints,
                color: .blue
            )
            
            // Force view body evaluation
            _ = sparkline.body
        }
    }
    
    func testSparklineRendering_30Points() {
        // Given - Create 30 data points
        let dataPoints = (0..<30).map { i in
            HistoricalDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(-30 + i)),
                metricType: .memory,
                value: Double.random(in: 0...100)
            )
        }
        
        // Measure rendering performance
        measure(metrics: [XCTClockMetric()]) {
            // When
            let sparkline = SparklineChart(
                dataPoints: dataPoints,
                color: .green
            )
            
            _ = sparkline.body
        }
    }
    
    func testSparklineRendering_EmptyData() {
        // Given
        let emptyData: [HistoricalDataPoint] = []
        
        // Measure rendering performance with empty data
        measure(metrics: [XCTClockMetric()]) {
            // When
            let sparkline = SparklineChart(
                dataPoints: emptyData,
                color: .red
            )
            
            _ = sparkline.body
        }
    }
    
    func testSparklineRendering_WorstCaseData() {
        // Given - Worst case: all different values requiring full range calculation
        let dataPoints = (0..<60).map { i in
            HistoricalDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(-60 + i)),
                metricType: .disk,
                value: Double(i * 1.67) // Values from 0 to ~100
            )
        }
        
        // Measure rendering performance
        measure(metrics: [XCTClockMetric()]) {
            // When
            let sparkline = SparklineChart(
                dataPoints: dataPoints,
                color: .orange
            )
            
            _ = sparkline.body
        }
    }
}

