//
//  ProcessMonitorIntegrationTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Integration tests for ProcessMonitor with system processes
final class ProcessMonitorIntegrationTests: XCTestCase {
    
    var processMonitor: ProcessMonitorImpl!
    
    override func setUp() {
        super.setUp()
        processMonitor = ProcessMonitorImpl()
    }
    
    override func tearDown() {
        processMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Real System Integration Tests
    
    func testGetTopProcesses_ReturnsRealProcesses() {
        // When
        let processes = processMonitor.getTopProcesses(sortBy: .cpu, limit: 10)
        
        // Then
        XCTAssertGreaterThan(processes.count, 0, "Should return at least some running processes")
        
        for process in processes {
            XCTAssertGreaterThan(process.id, 0, "Process ID should be positive")
            XCTAssertFalse(process.name.isEmpty, "Process name should not be empty")
            XCTAssertGreaterThanOrEqual(process.cpuUsage, 0, "CPU usage should be non-negative")
            XCTAssertGreaterThan(process.memoryUsage, 0, "Memory usage should be positive")
        }
    }
    
    func testGetTopProcesses_IncludesSystemProcesses() {
        // When
        let processes = processMonitor.getTopProcesses(sortBy: .cpu, limit: 50)
        
        // Then - Should include some well-known system processes
        let processNames = Set(processes.map { $0.name.lowercased() })
        
        // At least one of these common processes should be running
        let commonProcesses = ["kernel_task", "launchd", "windowserver", "finder", "systemuiserver"]
        let hasCommonProcess = commonProcesses.contains(where: { processNames.contains($0) })
        
        XCTAssertTrue(hasCommonProcess, "Should include common system processes")
    }
    
    func testSortByCPU_OrdersCorrectly() {
        // When
        let processes = processMonitor.getTopProcesses(sortBy: .cpu, limit: 20)
        
        // Then - Should be ordered by CPU descending
        if processes.count >= 2 {
            for i in 0..<(processes.count - 1) {
                XCTAssertGreaterThanOrEqual(
                    processes[i].cpuUsage,
                    processes[i + 1].cpuUsage,
                    "Processes should be ordered by CPU usage (descending)"
                )
            }
        }
    }
    
    func testSortByMemory_OrdersCorrectly() {
        // When
        let processes = processMonitor.getTopProcesses(sortBy: .memory, limit: 20)
        
        // Then - Should be ordered by memory descending
        if processes.count >= 2 {
            for i in 0..<(processes.count - 1) {
                XCTAssertGreaterThanOrEqual(
                    processes[i].memoryUsage,
                    processes[i + 1].memoryUsage,
                    "Processes should be ordered by memory usage (descending)"
                )
            }
        }
    }
    
    func testGetProcessInfo_ReturnsDataForExistingProcess() {
        // Given - Get a known process
        let topProcesses = processMonitor.getTopProcesses(sortBy: .cpu, limit: 1)
        guard let firstProcess = topProcesses.first else {
            XCTFail("Should have at least one process")
            return
        }
        
        // When
        let processInfo = processMonitor.getProcessInfo(pid: firstProcess.id)
        
        // Then
        XCTAssertNotNil(processInfo, "Should return info for existing process")
        XCTAssertEqual(processInfo?.id, firstProcess.id, "PID should match")
        XCTAssertFalse(processInfo?.name.isEmpty ?? true, "Name should not be empty")
    }
    
    func testIsSystemCritical_ProtectsSystemProcesses() {
        // When - Get some low-PID processes
        let allProcesses = processMonitor.getTopProcesses(sortBy: .cpu, limit: 100)
        let lowPIDProcesses = allProcesses.filter { $0.id < 100 }
        
        // Then - Low PID processes should be marked as critical
        for process in lowPIDProcesses {
            XCTAssertTrue(
                processMonitor.isSystemCritical(pid: process.id),
                "Process with PID \(process.id) (\(process.name)) should be system critical"
            )
        }
    }
}

