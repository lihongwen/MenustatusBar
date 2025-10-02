//
//  MemoryPurgeIntegrationTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Integration tests for memory purge functionality
final class MemoryPurgeIntegrationTests: XCTestCase {
    
    var memoryMonitor: MemoryMonitorImpl!
    
    override func setUp() async throws {
        try await super.setUp()
        memoryMonitor = MemoryMonitorImpl()
    }
    
    override func tearDown() async throws {
        memoryMonitor = nil
        try await super.tearDown()
    }
    
    // MARK: - Real Memory Purge Integration Tests
    
    func testPurgeInactiveMemory_ExecutesSuccessfully() async throws {
        // Given
        let canPurgeBefore = memoryMonitor.canPurge()
        XCTAssertTrue(canPurgeBefore, "Should be able to purge before operation")
        
        // When
        let result = try await memoryMonitor.purgeInactiveMemory()
        
        // Then
        XCTAssertNotNil(result, "Should return a result")
        XCTAssertGreaterThanOrEqual(result.beforeUsage, 0, "Before usage should be non-negative")
        XCTAssertGreaterThanOrEqual(result.afterUsage, 0, "After usage should be non-negative")
        XCTAssertGreaterThanOrEqual(result.freedBytes, 0, "Freed bytes should be non-negative")
        
        // Verify result properties
        XCTAssertFalse(result.formattedFreed.isEmpty, "Formatted freed should not be empty")
        XCTAssertGreaterThanOrEqual(result.percentageFreed, 0, "Percentage should be non-negative")
        XCTAssertLessThanOrEqual(result.percentageFreed, 100, "Percentage should not exceed 100")
    }
    
    func testPurgeInactiveMemory_BlocksConcurrentCalls() async {
        // Given - Start first purge
        let firstPurgeTask = Task {
            return try? await memoryMonitor.purgeInactiveMemory()
        }
        
        // Small delay to ensure first purge has started
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // When - Try concurrent purge
        do {
            _ = try await memoryMonitor.purgeInactiveMemory()
            XCTFail("Should throw error when purge already in progress")
        } catch let error as MemoryPurgeError {
            // Then - Should throw operationInProgress error
            if case .operationInProgress = error {
                // Expected behavior
            } else {
                XCTFail("Should throw operationInProgress error, got: \(error)")
            }
        } catch {
            XCTFail("Should throw MemoryPurgeError, got: \(error)")
        }
        
        // Wait for first purge to complete
        _ = await firstPurgeTask.value
        
        // After completion, should be able to purge again
        let canPurgeAfter = memoryMonitor.canPurge()
        XCTAssertTrue(canPurgeAfter, "Should be able to purge after first operation completes")
    }
    
    func testCanPurge_ReflectsOperationState() async throws {
        // Given
        XCTAssertTrue(memoryMonitor.canPurge(), "Should be able to purge initially")
        
        // When - Start purge operation
        let purgeTask = Task {
            return try? await memoryMonitor.purgeInactiveMemory()
        }
        
        // Small delay for operation to start
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // Then - During operation, canPurge might be false (timing dependent)
        // After operation, should be true again
        _ = await purgeTask.value
        
        XCTAssertTrue(memoryMonitor.canPurge(), "Should be able to purge after operation completes")
    }
    
    func testMemoryPurgeResult_HasRealisticValues() async throws {
        // When
        let result = try await memoryMonitor.purgeInactiveMemory()
        
        // Then - Verify values are realistic
        XCTAssertGreaterThan(result.beforeUsage, 0, "Before usage should be positive (system is using memory)")
        XCTAssertGreaterThan(result.afterUsage, 0, "After usage should be positive (system still using memory)")
        
        // After usage should be less than or equal to before usage
        XCTAssertLessThanOrEqual(
            result.afterUsage,
            result.beforeUsage,
            "After usage should not exceed before usage"
        )
        
        // Freed bytes should match the difference
        let expectedFreed = result.beforeUsage - result.afterUsage
        XCTAssertEqual(
            result.freedBytes,
            expectedFreed,
            "Freed bytes should equal the difference"
        )
    }
    
    func testPurgeInactiveMemory_VerifyTimestamp() async throws {
        // Given
        let before = Date()
        
        // When
        let result = try await memoryMonitor.purgeInactiveMemory()
        
        let after = Date()
        
        // Then
        XCTAssertGreaterThanOrEqual(
            result.timestamp,
            before,
            "Result timestamp should be after test start"
        )
        XCTAssertLessThanOrEqual(
            result.timestamp,
            after,
            "Result timestamp should be before test end"
        )
    }
}

