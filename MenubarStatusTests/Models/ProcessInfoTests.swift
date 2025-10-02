//
//  ProcessInfoTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

final class ProcessInfoTests: XCTestCase {
    
    // MARK: - Validation Tests
    
    func testInit_ValidatesPID() {
        // Given/When/Then - Valid PID
        XCTAssertNoThrow(
            ProcessInfo(id: 1, name: "test", bundleIdentifier: nil, cpuUsage: 50, memoryUsage: 1000, icon: nil),
            "Should accept positive PID"
        )
    }
    
    func testInit_ClampsC

PUTo0_100() {
        // Given
        let highCPU = ProcessInfo(
            id: 100,
            name: "test",
            bundleIdentifier: nil,
            cpuUsage: 150.0,
            memoryUsage: 1000,
            icon: nil
        )
        
        let lowCPU = ProcessInfo(
            id: 101,
            name: "test",
            bundleIdentifier: nil,
            cpuUsage: -10.0,
            memoryUsage: 1000,
            icon: nil
        )
        
        // Then
        XCTAssertEqual(highCPU.cpuUsage, 100.0, "CPU usage should be clamped to 100")
        XCTAssertEqual(lowCPU.cpuUsage, 0.0, "CPU usage should be clamped to 0")
    }
    
    // MARK: - Computed Properties Tests
    
    func testIsTerminable_ReturnsFalseForSystemProcesses() {
        // Given
        let systemProcess = ProcessInfo(
            id: 1, // Low PID
            name: "kernel_task",
            bundleIdentifier: nil,
            cpuUsage: 10,
            memoryUsage: 1000,
            icon: nil
        )
        
        // Then
        XCTAssertFalse(systemProcess.isTerminable, "System processes should not be terminable")
    }
    
    func testIsTerminable_ReturnsTrueForUserProcesses() {
        // Given
        let userProcess = ProcessInfo(
            id: 1000, // High PID
            name: "Safari",
            bundleIdentifier: "com.apple.Safari",
            cpuUsage: 50,
            memoryUsage: 1000000,
            icon: nil
        )
        
        // Then
        XCTAssertTrue(userProcess.isTerminable, "User processes should be terminable")
    }
    
    func testFormattedMemory_FormatsCorrectly() {
        // Given
        let smallMemory = ProcessInfo(
            id: 100,
            name: "test",
            bundleIdentifier: nil,
            cpuUsage: 10,
            memoryUsage: 1024, // 1 KB
            icon: nil
        )
        
        let largeMemory = ProcessInfo(
            id: 101,
            name: "test",
            bundleIdentifier: nil,
            cpuUsage: 10,
            memoryUsage: 1_073_741_824, // 1 GB
            icon: nil
        )
        
        // Then
        XCTAssertFalse(smallMemory.formattedMemory.isEmpty, "Should format small memory")
        XCTAssertFalse(largeMemory.formattedMemory.isEmpty, "Should format large memory")
        XCTAssertTrue(largeMemory.formattedMemory.contains("GB") || largeMemory.formattedMemory.contains("MB"),
                     "Large memory should be in GB or MB")
    }
}

