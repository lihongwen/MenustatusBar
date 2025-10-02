//
//  HistoricalDataManagerTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Contract tests for HistoricalDataManaging protocol
final class HistoricalDataManagerTests: XCTestCase {
    
    var sut: HistoricalDataManagerImpl!
    
    override func setUp() {
        super.setUp()
        sut = HistoricalDataManagerImpl()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - recordDataPoint Tests
    
    func testRecordDataPoint_IsThreadSafe() {
        // Given
        let expectation = self.expectation(description: "All threads complete")
        expectation.expectedFulfillmentCount = 10
        
        // When - Record from multiple threads simultaneously
        for i in 0..<10 {
            DispatchQueue.global().async {
                let point = HistoricalDataPoint(
                    timestamp: Date(),
                    metricType: .cpu,
                    value: Double(i * 10)
                )
                self.sut.recordDataPoint(point)
                expectation.fulfill()
            }
        }
        
        // Then - Should not crash
        wait(for: [expectation], timeout: 2.0)
        
        // Verify data was recorded
        let history = sut.getHistory(for: .cpu, duration: 60)
        XCTAssertGreaterThan(history.count, 0, "Should have recorded data points")
    }
    
    func testRecordDataPoint_StoresData() {
        // Given
        let point = HistoricalDataPoint(
            timestamp: Date(),
            metricType: .cpu,
            value: 50.0
        )
        
        // When
        sut.recordDataPoint(point)
        
        // Then
        let history = sut.getHistory(for: .cpu, duration: 60)
        XCTAssertGreaterThan(history.count, 0, "Should have at least one data point")
    }
    
    // MARK: - getHistory Tests
    
    func testGetHistory_ReturnsEmptyForNoData() {
        // When
        let history = sut.getHistory(for: .network, duration: 60)
        
        // Then
        XCTAssertEqual(history.count, 0, "Should return empty array when no data recorded")
    }
    
    func testGetHistory_ReturnsOrderedArray() {
        // Given - Record multiple points
        for i in 0..<5 {
            let point = HistoricalDataPoint(
                timestamp: Date().addingTimeInterval(TimeInterval(i)),
                metricType: .memory,
                value: Double(i * 10)
            )
            sut.recordDataPoint(point)
        }
        
        // Small delay for async recording
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        let history = sut.getHistory(for: .memory, duration: 60)
        
        // Then - Should be ordered from oldest to newest
        XCTAssertGreaterThan(history.count, 0, "Should have recorded points")
        for i in 0..<(history.count - 1) {
            XCTAssertLessThanOrEqual(
                history[i].timestamp,
                history[i + 1].timestamp,
                "History should be ordered from oldest to newest"
            )
        }
    }
    
    func testGetHistory_FiltersByDuration() {
        // Given - Record points at different times
        let now = Date()
        let oldPoint = HistoricalDataPoint(
            timestamp: now.addingTimeInterval(-120), // 2 minutes ago
            metricType: .disk,
            value: 10.0
        )
        let recentPoint = HistoricalDataPoint(
            timestamp: now,
            metricType: .disk,
            value: 50.0
        )
        
        sut.recordDataPoint(oldPoint)
        sut.recordDataPoint(recentPoint)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Request only last 60 seconds
        let history = sut.getHistory(for: .disk, duration: 60)
        
        // Then - Old point should be filtered out
        let hasOldPoint = history.contains { abs($0.timestamp.timeIntervalSince(now.addingTimeInterval(-120))) < 1 }
        XCTAssertFalse(hasOldPoint, "Should filter out points older than duration")
    }
    
    // MARK: - clearHistory Tests
    
    func testClearHistory_RemovesAllData() {
        // Given - Record some data
        for metricType in MetricType.allCases {
            let point = HistoricalDataPoint(
                timestamp: Date(),
                metricType: metricType,
                value: 50.0
            )
            sut.recordDataPoint(point)
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        sut.clearHistory()
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        for metricType in MetricType.allCases {
            let history = sut.getHistory(for: metricType, duration: 60)
            XCTAssertEqual(history.count, 0, "All history should be cleared for \(metricType)")
        }
    }
    
    func testClearHistoryForMetric_OnlyClearsSpecificMetric() {
        // Given - Record data for multiple metrics
        for metricType in MetricType.allCases {
            let point = HistoricalDataPoint(
                timestamp: Date(),
                metricType: metricType,
                value: 50.0
            )
            sut.recordDataPoint(point)
        }
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When - Clear only CPU
        sut.clearHistory(for: .cpu)
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // Then
        let cpuHistory = sut.getHistory(for: .cpu, duration: 60)
        XCTAssertEqual(cpuHistory.count, 0, "CPU history should be cleared")
        
        let memoryHistory = sut.getHistory(for: .memory, duration: 60)
        XCTAssertGreaterThan(memoryHistory.count, 0, "Memory history should still exist")
    }
}

