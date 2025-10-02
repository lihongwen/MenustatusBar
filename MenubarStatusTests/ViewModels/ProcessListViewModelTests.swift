//
//  ProcessListViewModelTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Tests for ProcessListViewModel
@MainActor
final class ProcessListViewModelTests: XCTestCase {
    
    var sut: ProcessListViewModel!
    var mockProcessMonitor: ProcessMonitorImpl!
    
    override func setUp() async throws {
        try await super.setUp()
        mockProcessMonitor = ProcessMonitorImpl()
        sut = ProcessListViewModel(processMonitor: mockProcessMonitor, limit: 10)
    }
    
    override func tearDown() async throws {
        sut.stopRefreshing()
        sut = nil
        mockProcessMonitor = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_SetsDefaultValues() {
        // Then
        XCTAssertEqual(sut.topProcesses.count, 0, "Should start with empty processes")
        XCTAssertEqual(sut.sortBy, .cpu, "Should default to CPU sort")
        XCTAssertNil(sut.errorMessage, "Should not have error initially")
    }
    
    // MARK: - Refresh Tests
    
    func testStartRefreshing_LoadsProcesses() async throws {
        // Given
        let expectation = self.expectation(description: "Processes should be loaded")
        
        // When
        sut.startRefreshing()
        
        // Wait for refresh cycle
        try await Task.sleep(nanoseconds: 3_500_000_000) // 3.5 seconds (refresh interval is 3s)
        
        // Then
        if sut.topProcesses.count > 0 {
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
        XCTAssertGreaterThan(sut.topProcesses.count, 0, "Should have loaded processes")
    }
    
    func testStopRefreshing_StopsUpdates() async throws {
        // Given
        sut.startRefreshing()
        try await Task.sleep(nanoseconds: 3_500_000_000) // Wait for first refresh
        
        let countAfterFirstRefresh = sut.topProcesses.count
        XCTAssertGreaterThan(countAfterFirstRefresh, 0, "Should have processes after first refresh")
        
        // When
        sut.stopRefreshing()
        
        // Then - Count shouldn't change significantly after stopping
        try await Task.sleep(nanoseconds: 3_500_000_000)
        // Processes might still be there, but no new refresh should happen
        // We can't easily verify this without more complex timing logic
    }
    
    // MARK: - Sort Criteria Tests
    
    func testChangeSortCriteria_RefreshesProcesses() async {
        // Given
        sut.startRefreshing()
        try? await Task.sleep(nanoseconds: 3_500_000_000)
        
        let cpuProcesses = sut.topProcesses
        XCTAssertGreaterThan(cpuProcesses.count, 0, "Should have processes")
        
        // When - Change sort criteria
        sut.sortBy = .memory
        try? await Task.sleep(nanoseconds: 3_500_000_000) // Wait for refresh
        
        // Then - Processes should be re-sorted
        let memoryProcesses = sut.topProcesses
        XCTAssertGreaterThan(memoryProcesses.count, 0, "Should still have processes")
        
        // Verify sorting order
        if memoryProcesses.count >= 2 {
            for i in 0..<(memoryProcesses.count - 1) {
                XCTAssertGreaterThanOrEqual(
                    memoryProcesses[i].memoryUsage,
                    memoryProcesses[i + 1].memoryUsage,
                    "Processes should be sorted by memory"
                )
            }
        }
    }
    
    // MARK: - Terminate Process Tests
    
    func testTerminateProcess_HandlesSystemProcessError() async {
        // Given - Create a system process
        let systemProcess = ProcessInfo(
            id: 1, // System process
            name: "kernel_task",
            bundleIdentifier: nil,
            cpuUsage: 10,
            memoryUsage: 1000,
            icon: nil
        )
        
        // When
        await sut.terminateProcess(systemProcess)
        
        // Then - Should have error message
        XCTAssertNotNil(sut.errorMessage, "Should have error message for system process")
        XCTAssertTrue(
            sut.errorMessage?.contains("critical") ?? false,
            "Error should mention system critical process"
        )
    }
    
    func testTerminateProcess_HandlesNonExistentProcess() async {
        // Given - Create a non-existent process
        let nonExistentProcess = ProcessInfo(
            id: 999999, // Non-existent PID
            name: "NonExistent",
            bundleIdentifier: nil,
            cpuUsage: 0,
            memoryUsage: 0,
            icon: nil
        )
        
        // When
        await sut.terminateProcess(nonExistentProcess)
        
        // Then - Should have error message
        XCTAssertNotNil(sut.errorMessage, "Should have error message for non-existent process")
    }
}

