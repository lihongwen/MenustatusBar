//
//  HistoricalDataIntegrationTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Integration tests for HistoricalDataManager with SystemMonitor
final class HistoricalDataIntegrationTests: XCTestCase {
    
    var systemMonitor: SystemMonitorImpl!
    var historicalDataManager: HistoricalDataManaging!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let settings = AppSettings()
        systemMonitor = await SystemMonitorImpl(settings: settings)
        historicalDataManager = await systemMonitor.historicalDataManager
    }
    
    override func tearDown() async throws {
        await systemMonitor.stopMonitoring()
        systemMonitor = nil
        historicalDataManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Integration Tests
    
    func testSystemMonitor_RecordsHistoricalData() async throws {
        // Given
        let expectation = self.expectation(description: "Metrics should be collected")
        
        // When - Start monitoring
        await systemMonitor.startMonitoring()
        
        // Wait for at least one refresh cycle (2 seconds + buffer)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        
        // Then - Historical data should be recorded
        let cpuHistory = historicalDataManager.getHistory(for: .cpu, duration: 60)
        let memoryHistory = historicalDataManager.getHistory(for: .memory, duration: 60)
        let diskHistory = historicalDataManager.getHistory(for: .disk, duration: 60)
        let networkHistory = historicalDataManager.getHistory(for: .network, duration: 60)
        
        XCTAssertGreaterThan(cpuHistory.count, 0, "Should have recorded CPU data")
        XCTAssertGreaterThan(memoryHistory.count, 0, "Should have recorded memory data")
        XCTAssertGreaterThan(diskHistory.count, 0, "Should have recorded disk data")
        XCTAssertGreaterThan(networkHistory.count, 0, "Should have recorded network data")
        
        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testHistoricalData_AccumulatesOverTime() async throws {
        // Given
        await systemMonitor.startMonitoring()
        
        // Wait for first data point
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
        
        let firstCount = historicalDataManager.getHistory(for: .cpu, duration: 60).count
        
        // When - Wait for more refresh cycles
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 more seconds
        
        // Then - Should have more data points
        let secondCount = historicalDataManager.getHistory(for: .cpu, duration: 60).count
        XCTAssertGreaterThan(secondCount, firstCount, "Historical data should accumulate over time")
    }
    
    func testHistoricalData_MaintainsBufferLimit() async throws {
        // Given - Record many data points rapidly
        for i in 0..<100 {
            let point = HistoricalDataPoint(
                timestamp: Date(),
                metricType: .cpu,
                value: Double(i)
            )
            historicalDataManager.recordDataPoint(point)
        }
        
        // Small delay for async processing
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // When
        let history = historicalDataManager.getHistory(for: .cpu, duration: 60)
        
        // Then - Should respect buffer limit (60 points max)
        XCTAssertLessThanOrEqual(
            history.count,
            60,
            "Historical data should not exceed buffer capacity"
        )
    }
    
    func testClearHistory_RemovesAllRecordedData() async throws {
        // Given - Start monitoring to accumulate data
        await systemMonitor.startMonitoring()
        try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
        
        // Verify data exists
        let beforeClear = historicalDataManager.getHistory(for: .cpu, duration: 60).count
        XCTAssertGreaterThan(beforeClear, 0, "Should have recorded data before clearing")
        
        // When
        historicalDataManager.clearHistory()
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds for async processing
        
        // Then
        for metricType in MetricType.allCases {
            let history = historicalDataManager.getHistory(for: metricType, duration: 60)
            XCTAssertEqual(
                history.count,
                0,
                "All historical data should be cleared for \(metricType)"
            )
        }
    }
}

