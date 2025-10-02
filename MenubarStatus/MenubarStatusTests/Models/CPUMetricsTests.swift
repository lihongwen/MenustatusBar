//
//  CPUMetricsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class CPUMetricsTests: XCTestCase {
    
    func testValidCPUMetrics() throws {
        // Test valid CPU metrics within 0-100 range
        let metrics = CPUMetrics(
            usagePercentage: 45.0,
            systemUsage: 20.0,
            userUsage: 25.0,
            idlePercentage: 55.0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 45.0, accuracy: 0.01)
        XCTAssertEqual(metrics.systemUsage, 20.0, accuracy: 0.01)
        XCTAssertEqual(metrics.userUsage, 25.0, accuracy: 0.01)
        XCTAssertEqual(metrics.idlePercentage, 55.0, accuracy: 0.01)
    }
    
    func testCPUUsageSum() throws {
        // Test that usagePercentage equals systemUsage + userUsage
        let metrics = CPUMetrics(
            usagePercentage: 60.0,
            systemUsage: 35.0,
            userUsage: 25.0,
            idlePercentage: 40.0
        )
        
        let calculatedUsage = metrics.systemUsage + metrics.userUsage
        XCTAssertEqual(metrics.usagePercentage, calculatedUsage, accuracy: 0.01,
                      "Usage percentage should equal sum of system and user usage")
    }
    
    func testCPUIdleCalculation() throws {
        // Test that usagePercentage + idlePercentage ≈ 100
        let metrics = CPUMetrics(
            usagePercentage: 35.0,
            systemUsage: 15.0,
            userUsage: 20.0,
            idlePercentage: 65.0
        )
        
        let total = metrics.usagePercentage + metrics.idlePercentage
        XCTAssertEqual(total, 100.0, accuracy: 0.1,
                      "Usage + idle should approximately equal 100%")
    }
    
    func testInvalidNegativeValues() throws {
        // Test that negative values are rejected or clamped
        // This should either throw an error or clamp to 0
        let metrics = CPUMetrics(
            usagePercentage: -10.0,
            systemUsage: -5.0,
            userUsage: -5.0,
            idlePercentage: 110.0
        )
        
        // Expect validation to prevent negative values
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.systemUsage, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.userUsage, 0.0)
    }
    
    func testInvalidExcessiveValues() throws {
        // Test that values > 100 are rejected or clamped
        let metrics = CPUMetrics(
            usagePercentage: 150.0,
            systemUsage: 80.0,
            userUsage: 70.0,
            idlePercentage: -50.0
        )
        
        // Expect validation to prevent values > 100
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
        XCTAssertLessThanOrEqual(metrics.systemUsage, 100.0)
        XCTAssertLessThanOrEqual(metrics.userUsage, 100.0)
    }
    
    func testZeroValues() throws {
        // Test edge case with all zeros
        let metrics = CPUMetrics(
            usagePercentage: 0.0,
            systemUsage: 0.0,
            userUsage: 0.0,
            idlePercentage: 100.0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 0.0)
        XCTAssertEqual(metrics.idlePercentage, 100.0)
    }
    
    func testMaxValues() throws {
        // Test edge case with maximum values
        let metrics = CPUMetrics(
            usagePercentage: 100.0,
            systemUsage: 60.0,
            userUsage: 40.0,
            idlePercentage: 0.0
        )
        
        XCTAssertEqual(metrics.usagePercentage, 100.0)
        XCTAssertEqual(metrics.idlePercentage, 0.0)
    }
}




