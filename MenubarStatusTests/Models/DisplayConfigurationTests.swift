//
//  DisplayConfigurationTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

final class DisplayConfigurationTests: XCTestCase {
    
    // MARK: - Threshold Clamping Tests
    
    func testInit_ClampsThresholdToValidRange() {
        // Given/When
        let tooLow = DisplayConfiguration(autoHideThreshold: -0.5)
        let tooHigh = DisplayConfiguration(autoHideThreshold: 1.5)
        let valid = DisplayConfiguration(autoHideThreshold: 0.5)
        
        // Then
        XCTAssertEqual(tooLow.autoHideThreshold, 0.0, "Should clamp negative threshold to 0.0")
        XCTAssertEqual(tooHigh.autoHideThreshold, 1.0, "Should clamp threshold above 1.0 to 1.0")
        XCTAssertEqual(valid.autoHideThreshold, 0.5, "Should accept valid threshold")
    }
    
    // MARK: - Metric Order Validation Tests
    
    func testOrderedMetrics_ReturnsValidMetricTypes() {
        // Given
        let config = DisplayConfiguration(
            metricOrder: ["cpu", "memory", "disk", "network"]
        )
        
        // When
        let orderedMetrics = config.orderedMetrics
        
        // Then
        XCTAssertEqual(orderedMetrics.count, 4, "Should have 4 valid metrics")
        XCTAssertTrue(orderedMetrics.contains(.cpu), "Should contain CPU metric")
        XCTAssertTrue(orderedMetrics.contains(.memory), "Should contain Memory metric")
        XCTAssertTrue(orderedMetrics.contains(.disk), "Should contain Disk metric")
        XCTAssertTrue(orderedMetrics.contains(.network), "Should contain Network metric")
    }
    
    func testOrderedMetrics_FiltersInvalidValues() {
        // Given
        let config = DisplayConfiguration(
            metricOrder: ["cpu", "invalid", "memory", "unknown"]
        )
        
        // When
        let orderedMetrics = config.orderedMetrics
        
        // Then
        XCTAssertEqual(orderedMetrics.count, 2, "Should filter out invalid metric types")
        XCTAssertTrue(orderedMetrics.contains(.cpu), "Should contain CPU metric")
        XCTAssertTrue(orderedMetrics.contains(.memory), "Should contain Memory metric")
    }
    
    func testOrderedMetrics_PreservesOrder() {
        // Given
        let config = DisplayConfiguration(
            metricOrder: ["network", "cpu", "disk", "memory"]
        )
        
        // When
        let orderedMetrics = config.orderedMetrics
        
        // Then
        XCTAssertEqual(orderedMetrics[0], .network, "Should preserve metric order")
        XCTAssertEqual(orderedMetrics[1], .cpu, "Should preserve metric order")
        XCTAssertEqual(orderedMetrics[2], .disk, "Should preserve metric order")
        XCTAssertEqual(orderedMetrics[3], .memory, "Should preserve metric order")
    }
    
    // MARK: - Codable Compliance Tests
    
    func testCodable_EncodesAndDecodes() throws {
        // Given
        let original = DisplayConfiguration(
            displayMode: .compactText,
            metricOrder: ["cpu", "memory"],
            autoHideEnabled: true,
            autoHideThreshold: 0.75,
            colorThemeIdentifier: "cool",
            showTopProcesses: true,
            processSortCriteria: "memory"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DisplayConfiguration.self, from: data)
        
        // Then
        XCTAssertEqual(decoded.displayMode, original.displayMode)
        XCTAssertEqual(decoded.metricOrder, original.metricOrder)
        XCTAssertEqual(decoded.autoHideEnabled, original.autoHideEnabled)
        XCTAssertEqual(decoded.autoHideThreshold, original.autoHideThreshold)
        XCTAssertEqual(decoded.colorThemeIdentifier, original.colorThemeIdentifier)
        XCTAssertEqual(decoded.showTopProcesses, original.showTopProcesses)
        XCTAssertEqual(decoded.processSortCriteria, original.processSortCriteria)
    }
    
    // MARK: - Display Mode Tests
    
    func testDisplayMode_HasEstimatedWidths() {
        // Given
        let modes = DisplayMode.allCases
        
        // Then
        for mode in modes {
            XCTAssertGreaterThan(mode.estimatedWidth, 0, "Estimated width should be positive for \(mode)")
        }
    }
    
    func testDisplayMode_IconsOnlyIsNarrowest() {
        // Given
        let iconsOnly = DisplayMode.iconsOnly
        let others = DisplayMode.allCases.filter { $0 != .iconsOnly }
        
        // Then
        for mode in others {
            XCTAssertLessThan(
                iconsOnly.estimatedWidth,
                mode.estimatedWidth,
                "Icons only should be narrower than \(mode)"
            )
        }
    }
}

