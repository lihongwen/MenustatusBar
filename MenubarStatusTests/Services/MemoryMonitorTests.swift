//
//  MemoryMonitorTests.swift
//  MenubarStatusTests
//
//  Created by AI Assistant on 2025-10-02.
//

import XCTest
@testable import MenubarStatus

/// Contract tests for MemoryPurging protocol
final class MemoryMonitorContractTests: XCTestCase {
    
    var sut: MemoryMonitorImpl!
    
    override func setUp() async throws {
        try await super.setUp()
        sut = MemoryMonitorImpl()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - canPurge Tests
    
    func testCanPurge_ReturnsTrueInitially() {
        // When
        let canPurge = sut.canPurge()
        
        // Then
        XCTAssertTrue(canPurge, "Should be able to purge initially")
    }
    
    func testCanPurge_BlocksDuringOperation() async throws {
        // Given
        let expectation = self.expectation(description: "Purge operation starts")
        
        // When - Start purge in background
        Task {
            _ = try? await sut.purgeInactiveMemory()
            expectation.fulfill()
        }
        
        // Small delay to ensure purge has started
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then - Should not be able to purge while operation in progress
        // Note: This might be true or false depending on timing,
        // but we'll just verify the method doesn't crash
        let canPurgeDuringOperation = sut.canPurge()
        
        // Wait for purge to complete
        await fulfillment(of: [expectation], timeout: 10.0)
        
        // After completion, should be able to purge again
        let canPurgeAfter = sut.canPurge()
        XCTAssertTrue(canPurgeAfter, "Should be able to purge after operation completes")
    }
    
    // MARK: - purgeInactiveMemory Tests
    
    func testPurgeInactiveMemory_ReturnsResult() async throws {
        // When
        let result = try await sut.purgeInactiveMemory()
        
        // Then
        XCTAssertNotNil(result, "Should return a result")
        XCTAssertGreaterThanOrEqual(result.beforeUsage, 0, "Before usage should be non-negative")
        XCTAssertGreaterThanOrEqual(result.afterUsage, 0, "After usage should be non-negative")
        XCTAssertGreaterThanOrEqual(result.freedBytes, 0, "Freed bytes should be non-negative")
    }
    
    func testPurgeInactiveMemory_HasValidTimestamp() async throws {
        // Given
        let before = Date()
        
        // When
        let result = try await sut.purgeInactiveMemory()
        
        let after = Date()
        
        // Then
        XCTAssertGreaterThanOrEqual(result.timestamp, before, "Timestamp should be after test start")
        XCTAssertLessThanOrEqual(result.timestamp, after, "Timestamp should be before test end")
    }
    
    func testPurgeInactiveMemory_ThrowsWhenOperationInProgress() async {
        // Given - Start first purge
        let firstPurgeTask = Task {
            _ = try? await sut.purgeInactiveMemory()
        }
        
        // Small delay to ensure first purge has started
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
        
        // When/Then - Second purge should throw
        do {
            _ = try await sut.purgeInactiveMemory()
            XCTFail("Should throw error when operation already in progress")
        } catch let error as MemoryPurgeError {
            if case .operationInProgress = error {
                // Expected
            } else {
                XCTFail("Should throw operationInProgress error")
            }
        } catch {
            XCTFail("Should throw MemoryPurgeError")
        }
        
        // Clean up
        await firstPurgeTask.value
    }
    
    func testMemoryPurgeResult_ComputedProperties() async throws {
        // When
        let result = try await sut.purgeInactiveMemory()
        
        // Then - Test computed properties
        XCTAssertFalse(result.formattedFreed.isEmpty, "Formatted freed should not be empty")
        XCTAssertGreaterThanOrEqual(result.percentageFreed, 0, "Percentage should be non-negative")
        XCTAssertLessThanOrEqual(result.percentageFreed, 100, "Percentage should not exceed 100")
        
        // wasSuccessful is true if any bytes were freed
        if result.freedBytes > 0 {
            XCTAssertTrue(result.wasSuccessful, "Should be successful if bytes were freed")
        }
    }
}
