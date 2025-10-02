//
//  MenuBarViewModelTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
import Combine
@testable import MenubarStatus

@MainActor
final class MenuBarViewModelTests: XCTestCase {
    var viewModel: MenuBarViewModel!
    var mockMonitor: MockSystemMonitor!
    var settings: AppSettings!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        try await super.setUp()
        settings = AppSettings()
        mockMonitor = MockSystemMonitor(settings: settings)
        viewModel = MenuBarViewModel(monitor: mockMonitor)
        cancellables = []
    }
    
    override func tearDown() async throws {
        cancellables = nil
        viewModel = nil
        mockMonitor = nil
        settings = nil
        try await super.tearDown()
    }
    
    func testInitialState() throws {
        // Test that ViewModel starts with nil metrics
        XCTAssertNil(viewModel.currentMetrics,
                    "Current metrics should be nil initially")
        XCTAssertFalse(viewModel.isMonitoring,
                      "Should not be monitoring initially")
        XCTAssertNil(viewModel.errorMessage,
                    "Error message should be nil initially")
    }
    
    func testReceivingMetrics() async throws {
        // Test that ViewModel updates when monitor publishes metrics
        let expectation = expectation(description: "Metrics received")
        
        viewModel.$currentMetrics
            .dropFirst()
            .sink { metrics in
                if metrics != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Simulate monitor publishing metrics
        let testMetrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 50, systemUsage: 20, userUsage: 30, idlePercentage: 50),
            memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 8_000_000_000, freeBytes: 8_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 250_000_000_000, usedBytes: 250_000_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 1024, downloadBytesPerSecond: 2048, totalUploadBytes: 10240, totalDownloadBytes: 20480)
        )
        mockMonitor.publishMetrics(testMetrics)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(viewModel.currentMetrics,
                       "Current metrics should be updated")
        XCTAssertEqual(viewModel.currentMetrics?.cpu.usagePercentage, 50)
    }
    
    func testDisplayTextFormatting() throws {
        // Test that displayText formats based on settings
        let testMetrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 45.5, systemUsage: 15.5, userUsage: 30.0, idlePercentage: 54.5),
            memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 8_000_000_000, freeBytes: 8_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 250_000_000_000, usedBytes: 250_000_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 1024, downloadBytesPerSecond: 2048, totalUploadBytes: 10240, totalDownloadBytes: 20480)
        )
        viewModel.currentMetrics = testMetrics
        
        // With CPU and Memory enabled (default)
        var newSettings = settings!
        newSettings.showCPU = true
        newSettings.showMemory = true
        newSettings.showDisk = false
        newSettings.showNetwork = false
        viewModel.settings = newSettings
        
        let displayText = viewModel.displayText
        XCTAssertFalse(displayText.isEmpty,
                      "Display text should not be empty")
        XCTAssertNotEqual(displayText, "---",
                         "Display text should show data when metrics available")
    }
    
    func testDetailsTextFormatting() throws {
        // Test that detailsText includes all metrics
        let testMetrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 60, systemUsage: 25, userUsage: 35, idlePercentage: 40),
            memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 10_000_000_000, freeBytes: 6_000_000_000, cachedBytes: 0),
            disk: DiskMetrics(volumePath: "/", volumeName: "System", totalBytes: 500_000_000_000, freeBytes: 200_000_000_000, usedBytes: 300_000_000_000),
            network: NetworkMetrics(uploadBytesPerSecond: 5120, downloadBytesPerSecond: 10240, totalUploadBytes: 51200, totalDownloadBytes: 102400)
        )
        viewModel.currentMetrics = testMetrics
        
        let detailsText = viewModel.detailsText
        
        XCTAssertFalse(detailsText.isEmpty,
                      "Details text should not be empty")
        XCTAssertNotEqual(detailsText, "No data available",
                         "Details text should show data when metrics available")
    }
    
    func testErrorHandling() async throws {
        // Test that ViewModel can handle errors gracefully
        // Note: Error handling is passive - we don't actively propagate errors to ViewModel
        // Instead, metrics simply won't update if collection fails
        
        // Initially no metrics
        XCTAssertNil(viewModel.currentMetrics)
        
        // Simulate error (metrics remain nil)
        mockMonitor.simulateError(MetricError.systemAPIUnavailable)
        
        // displayText should show fallback
        XCTAssertEqual(viewModel.displayText, "---",
                      "Display text should show fallback when no metrics")
    }
    
    func testSettingsChangePropagation() throws {
        // Test that changing settings updates the ViewModel
        var newSettings = settings!
        newSettings.refreshInterval = 5.0
        newSettings.showCPU = true
        newSettings.showMemory = false
        
        viewModel.settings = newSettings
        
        XCTAssertEqual(viewModel.settings.refreshInterval, 5.0,
                      "Settings should be updated")
        XCTAssertTrue(viewModel.settings.showCPU)
        XCTAssertFalse(viewModel.settings.showMemory)
    }
    
    func testStartMonitoring() async throws {
        // Test that start() triggers monitoring
        viewModel.startMonitoring()
        
        XCTAssertTrue(viewModel.isMonitoring,
                     "Should be monitoring after start")
        XCTAssertTrue(mockMonitor.isMonitoring,
                     "Mock monitor should be started")
    }
    
    func testStopMonitoring() async throws {
        // Test that stop() halts monitoring
        viewModel.startMonitoring()
        XCTAssertTrue(viewModel.isMonitoring)
        
        viewModel.stopMonitoring()
        
        XCTAssertFalse(viewModel.isMonitoring,
                      "Should not be monitoring after stop")
        XCTAssertFalse(mockMonitor.isMonitoring,
                      "Mock monitor should be stopped")
    }
}

// MARK: - Mock System Monitor

@MainActor
class MockSystemMonitor: SystemMonitorImpl {
    private var errorToSimulate: Error?
    
    override init(settings: AppSettings) {
        super.init(settings: settings)
    }
    
    func publishMetrics(_ metrics: SystemMetrics) {
        self.currentMetrics = metrics
    }
    
    func simulateError(_ error: Error) {
        self.errorToSimulate = error
        // In real implementation, this would trigger error handling
    }
}

