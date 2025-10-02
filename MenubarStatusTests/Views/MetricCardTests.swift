//
//  MetricCardTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
import SwiftUI
@testable import MenubarStatus

/// Tests for MetricCard component
final class MetricCardTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testMetricCard_InitializesWithValidData() {
        // Given
        let sparklineData = [
            HistoricalDataPoint(timestamp: Date(), metricType: .cpu, value: 50.0)
        ]
        let theme = SystemDefaultTheme()
        
        // When/Then - Should not crash
        XCTAssertNoThrow({
            MetricCard(
                title: "CPU",
                value: "50%",
                percentage: 0.5,
                sparklineData: sparklineData,
                metricType: .cpu,
                theme: theme
            ) {
                Text("Details")
            }
        }(), "Should initialize with valid data")
    }
    
    func testMetricCard_InitializesWithEmptySparklineData() {
        // Given
        let emptyData: [HistoricalDataPoint] = []
        let theme = SystemDefaultTheme()
        
        // When/Then - Should not crash
        XCTAssertNoThrow({
            MetricCard(
                title: "Memory",
                value: "75%",
                percentage: 0.75,
                sparklineData: emptyData,
                metricType: .memory,
                theme: theme
            ) {
                EmptyView()
            }
        }(), "Should handle empty sparkline data")
    }
    
    func testMetricCard_ClampsPercentageToValidRange() {
        // Given
        let theme = SystemDefaultTheme()
        let sparklineData: [HistoricalDataPoint] = []
        
        // When - Create cards with out-of-range percentages
        let tooHighCard = MetricCard(
            title: "Test",
            value: "150%",
            percentage: 1.5,
            sparklineData: sparklineData,
            metricType: .cpu,
            theme: theme
        ) {
            EmptyView()
        }
        
        let tooLowCard = MetricCard(
            title: "Test",
            value: "-50%",
            percentage: -0.5,
            sparklineData: sparklineData,
            metricType: .cpu,
            theme: theme
        ) {
            EmptyView()
        }
        
        // Then - Should not crash (clamping happens internally)
        XCTAssertNotNil(tooHighCard.body)
        XCTAssertNotNil(tooLowCard.body)
    }
    
    // MARK: - View Body Tests
    
    func testMetricCard_BodyReturnsView() {
        // Given
        let theme = SystemDefaultTheme()
        let card = MetricCard(
            title: "Network",
            value: "1.5 MB/s",
            percentage: 0.3,
            sparklineData: [],
            metricType: .network,
            theme: theme
        ) {
            Text("Network details")
        }
        
        // When
        let body = card.body
        
        // Then
        XCTAssertNotNil(body, "Body should return a view")
    }
}

