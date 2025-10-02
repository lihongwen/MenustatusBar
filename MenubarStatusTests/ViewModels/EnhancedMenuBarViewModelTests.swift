//
//  EnhancedMenuBarViewModelTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Tests for enhanced MenuBarViewModel features
@MainActor
final class EnhancedMenuBarViewModelTests: XCTestCase {
    
    var sut: MenuBarViewModel!
    var settings: AppSettings!
    
    override func setUp() async throws {
        try await super.setUp()
        settings = AppSettings()
        sut = MenuBarViewModel(settings: settings)
    }
    
    override func tearDown() async throws {
        await sut.stopMonitoring()
        sut = nil
        settings = nil
        try await super.tearDown()
    }
    
    // MARK: - Process List Integration Tests
    
    func testStartProcessListMonitoring_CreatesViewModel() async {
        // When
        sut.startProcessListMonitoring()
        
        // Then
        XCTAssertNotNil(sut.processListViewModel, "Should create process list view model")
    }
    
    func testStopProcessListMonitoring_RemovesViewModel() async {
        // Given
        sut.startProcessListMonitoring()
        XCTAssertNotNil(sut.processListViewModel, "Should have process list view model")
        
        // When
        sut.stopProcessListMonitoring()
        
        // Then
        XCTAssertNil(sut.processListViewModel, "Should remove process list view model")
    }
    
    func testShowProcessList_TogglesCorrectly() {
        // Given
        XCTAssertFalse(sut.showProcessList, "Should start hidden")
        
        // When
        sut.showProcessList = true
        
        // Then
        XCTAssertTrue(sut.showProcessList, "Should be shown")
    }
    
    // MARK: - Memory Purge Tests
    
    func testPurgeMemory_ExecutesSuccessfully() async {
        // Given
        XCTAssertFalse(sut.isPurgingMemory, "Should not be purging initially")
        XCTAssertNil(sut.lastPurgeResult, "Should not have purge result initially")
        
        // When
        await sut.purgeMemory()
        
        // Then
        XCTAssertFalse(sut.isPurgingMemory, "Should not be purging after completion")
        XCTAssertNotNil(sut.lastPurgeResult, "Should have purge result")
        
        if let result = sut.lastPurgeResult {
            XCTAssertGreaterThanOrEqual(result.beforeUsage, 0, "Before usage should be valid")
            XCTAssertGreaterThanOrEqual(result.afterUsage, 0, "After usage should be valid")
            XCTAssertGreaterThanOrEqual(result.freedBytes, 0, "Freed bytes should be valid")
        }
    }
    
    func testPurgeMemory_BlocksConcurrentCalls() async {
        // Given - Start first purge
        let firstPurgeTask = Task {
            await sut.purgeMemory()
        }
        
        // Small delay to ensure first purge has started
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Try second purge
        await sut.purgeMemory()
        
        // Then - Should handle gracefully (no crash)
        await firstPurgeTask.value
        
        XCTAssertFalse(sut.isPurgingMemory, "Should not be purging after both complete")
    }
    
    // MARK: - Historical Data Tests
    
    func testGetHistoricalData_ReturnsData() async throws {
        // Given - Start monitoring to collect data
        await sut.startMonitoring()
        try await Task.sleep(nanoseconds: 3_000_000_000) // Wait for data collection
        
        // When
        let cpuHistory = sut.getHistoricalData(for: .cpu)
        let memoryHistory = sut.getHistoricalData(for: .memory)
        
        // Then
        XCTAssertGreaterThan(cpuHistory.count, 0, "Should have CPU historical data")
        XCTAssertGreaterThan(memoryHistory.count, 0, "Should have memory historical data")
    }
    
    func testGetHistoricalData_ReturnsEmptyWhenNoData() {
        // When - No monitoring started
        let history = sut.getHistoricalData(for: .network)
        
        // Then
        XCTAssertEqual(history.count, 0, "Should return empty array when no data")
    }
    
    // MARK: - Disk Health Tests
    
    func testGetAllDiskHealth_ReturnsVolumes() {
        // When
        let diskHealth = sut.getAllDiskHealth()
        
        // Then
        XCTAssertGreaterThan(diskHealth.count, 0, "Should return at least one volume")
        
        for health in diskHealth {
            XCTAssertFalse(health.volumeName.isEmpty, "Volume name should not be empty")
            XCTAssertFalse(health.bsdName.isEmpty, "BSD name should not be empty")
        }
    }
    
    // MARK: - Monitoring Integration Tests
    
    func testStartMonitoring_RecordsHistoricalData() async throws {
        // When
        await sut.startMonitoring()
        
        // Wait for multiple refresh cycles
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Then - Should have recorded historical data
        let cpuHistory = sut.getHistoricalData(for: .cpu)
        let memoryHistory = sut.getHistoricalData(for: .memory)
        let diskHistory = sut.getHistoricalData(for: .disk)
        let networkHistory = sut.getHistoricalData(for: .network)
        
        XCTAssertGreaterThan(cpuHistory.count, 0, "Should record CPU history")
        XCTAssertGreaterThan(memoryHistory.count, 0, "Should record memory history")
        XCTAssertGreaterThan(diskHistory.count, 0, "Should record disk history")
        XCTAssertGreaterThan(networkHistory.count, 0, "Should record network history")
    }
}

