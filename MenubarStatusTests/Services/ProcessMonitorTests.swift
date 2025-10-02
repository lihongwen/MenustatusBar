//
//  ProcessMonitorTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Contract tests for ProcessMonitoring protocol
final class ProcessMonitorTests: XCTestCase {
    
    var sut: ProcessMonitorImpl!
    
    override func setUp() {
        super.setUp()
        sut = ProcessMonitorImpl()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - getTopProcesses Tests
    
    func testGetTopProcesses_ReturnsAtMostLimit() {
        // When
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 5)
        
        // Then
        XCTAssertLessThanOrEqual(processes.count, 5, "Should return at most the specified limit")
    }
    
    func testGetTopProcesses_SortsByCPU() {
        // When
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 10)
        
        // Then - Verify sorting order (descending)
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(
                processes[i].cpuUsage,
                processes[i + 1].cpuUsage,
                "Processes should be sorted by CPU usage in descending order"
            )
        }
    }
    
    func testGetTopProcesses_SortsByMemory() {
        // When
        let processes = sut.getTopProcesses(sortBy: .memory, limit: 10)
        
        // Then - Verify sorting order (descending)
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(
                processes[i].memoryUsage,
                processes[i + 1].memoryUsage,
                "Processes should be sorted by memory usage in descending order"
            )
        }
    }
    
    func testGetTopProcesses_ReturnsEmptyArrayForZeroLimit() {
        // When
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 0)
        
        // Then
        XCTAssertEqual(processes.count, 0, "Should return empty array when limit is 0")
    }
    
    // MARK: - isSystemCritical Tests
    
    func testIsSystemCritical_ReturnsTrueForLowPIDs() {
        // When/Then
        XCTAssertTrue(sut.isSystemCritical(pid: 1), "PID 1 (launchd) should be system critical")
        XCTAssertTrue(sut.isSystemCritical(pid: 50), "PIDs below 100 should be system critical")
        XCTAssertTrue(sut.isSystemCritical(pid: 99), "PID 99 should be system critical")
    }
    
    func testIsSystemCritical_ReturnsFalseForHighPIDs() {
        // When/Then
        XCTAssertFalse(sut.isSystemCritical(pid: 10000), "High PID processes should not be automatically critical")
    }
    
    // MARK: - terminateProcess Tests
    
    func testTerminateProcess_ThrowsForSystemCritical() {
        // Given - PID 1 is always system critical (launchd)
        let systemPID = 1
        
        // When/Then
        XCTAssertThrowsError(try sut.terminateProcess(pid: systemPID)) { error in
            XCTAssertTrue(
                error is ProcessTerminationError,
                "Should throw ProcessTerminationError"
            )
            if let terminationError = error as? ProcessTerminationError {
                if case .systemCriticalProcess = terminationError {
                    // Expected error
                } else {
                    XCTFail("Should throw systemCriticalProcess error")
                }
            }
        }
    }
    
    func testTerminateProcess_ThrowsForNonExistentProcess() {
        // Given - Use an extremely high PID that shouldn't exist
        let nonExistentPID = 999999
        
        // When/Then
        XCTAssertThrowsError(try sut.terminateProcess(pid: nonExistentPID)) { error in
            XCTAssertTrue(
                error is ProcessTerminationError,
                "Should throw ProcessTerminationError for non-existent process"
            )
        }
    }
    
    // MARK: - getProcessInfo Tests
    
    func testGetProcessInfo_ReturnsNilForInvalidPID() {
        // Given
        let invalidPID = 999999
        
        // When
        let processInfo = sut.getProcessInfo(pid: invalidPID)
        
        // Then
        XCTAssertNil(processInfo, "Should return nil for invalid PID")
    }
    
    func testGetProcessInfo_ReturnsValidInfoForExistingProcess() {
        // Given - Get a valid process from the top processes list
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 1)
        guard let firstProcess = processes.first else {
            XCTFail("Should have at least one running process")
            return
        }
        
        // When
        let processInfo = sut.getProcessInfo(pid: firstProcess.id)
        
        // Then
        XCTAssertNotNil(processInfo, "Should return process info for existing process")
        XCTAssertEqual(processInfo?.id, firstProcess.id, "PID should match")
        XCTAssertFalse(processInfo?.name.isEmpty ?? true, "Process name should not be empty")
    }
}

