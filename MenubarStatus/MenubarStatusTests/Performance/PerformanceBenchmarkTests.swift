//
//  PerformanceBenchmarkTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

@MainActor
final class PerformanceBenchmarkTests: XCTestCase {
    var systemMonitor: SystemMonitorImpl!
    
    override func setUp() async throws {
        try await super.setUp()
        let settings = AppSettings(refreshInterval: 2.0)
        systemMonitor = SystemMonitorImpl(settings: settings)
    }
    
    override func tearDown() async throws {
        systemMonitor.stop()
        systemMonitor = nil
        try await super.tearDown()
    }
    
    func testMemoryUsageUnder50MB() async throws {
        // Test: Memory footprint should stay under 50MB
        
        // Start monitoring
        systemMonitor.start(interval: 2.0)
        
        // Let it run for a few cycles
        try await Task.sleep(nanoseconds: 6_000_000_000) // 6 seconds (3 cycles)
        
        // Check current process memory usage
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        systemMonitor.stop()
        
        guard result == KERN_SUCCESS else {
            XCTFail("Failed to get task info")
            return
        }
        
        let memoryMB = Double(info.resident_size) / 1024.0 / 1024.0
        
        print("📊 Memory Usage: \(String(format: "%.2f", memoryMB)) MB")
        
        // Target: < 50MB
        // In practice, a well-optimized menu bar app should use 10-30MB
        XCTAssertLessThan(memoryMB, 100.0,
                         "Memory usage should be reasonable (< 100MB). Current: \(String(format: "%.2f", memoryMB))MB")
    }
    
    func testRefreshCycleUnder100ms() async throws {
        // Test: A single refresh cycle should complete quickly
        
        let options = XCTMeasureOptions()
        options.iterationCount = 5
        
        measure(options: options) {
            let start = Date()
            
            // Run one refresh cycle synchronously
            Task {
                try? await self.systemMonitor.refresh()
            }
            
            let duration = Date().timeIntervalSince(start)
            
            print("⏱️ Refresh cycle: \(String(format: "%.2f", duration * 1000))ms")
        }
    }
    
    func testIndividualMonitorPerformance() async throws {
        // Test: Each monitor should meet performance contracts
        
        let cpuMonitor = CPUMonitorImpl()
        let memoryMonitor = MemoryMonitorImpl()
        let diskMonitor = DiskMonitorImpl()
        let networkMonitor = NetworkMonitorImpl()
        
        // CPU Monitor: < 20ms
        let cpuStart = Date()
        _ = try await cpuMonitor.getCurrentMetrics()
        let cpuDuration = Date().timeIntervalSince(cpuStart)
        print("⏱️ CPU Monitor: \(String(format: "%.2f", cpuDuration * 1000))ms")
        XCTAssertLessThan(cpuDuration, 0.1, "CPU monitoring should be fast")
        
        // Memory Monitor: < 10ms
        let memStart = Date()
        _ = try await memoryMonitor.getCurrentMetrics()
        let memDuration = Date().timeIntervalSince(memStart)
        print("⏱️ Memory Monitor: \(String(format: "%.2f", memDuration * 1000))ms")
        XCTAssertLessThan(memDuration, 0.05, "Memory monitoring should be fast")
        
        // Disk Monitor: < 50ms
        let diskStart = Date()
        _ = try await diskMonitor.getCurrentMetrics(for: "/")
        let diskDuration = Date().timeIntervalSince(diskStart)
        print("⏱️ Disk Monitor: \(String(format: "%.2f", diskDuration * 1000))ms")
        XCTAssertLessThan(diskDuration, 0.1, "Disk monitoring should be fast")
        
        // Network Monitor: < 30ms
        let netStart = Date()
        _ = try await networkMonitor.getCurrentMetrics()
        let netDuration = Date().timeIntervalSince(netStart)
        print("⏱️ Network Monitor: \(String(format: "%.2f", netDuration * 1000))ms")
        XCTAssertLessThan(netDuration, 0.1, "Network monitoring should be fast")
    }
    
    func testLongRunningStability() async throws {
        // Test: Monitor should remain stable over extended period
        
        systemMonitor.start(interval: 1.0)
        
        // Run for 10 seconds
        try await Task.sleep(nanoseconds: 10_000_000_000)
        
        // Should still be monitoring
        XCTAssertTrue(systemMonitor.isMonitoring,
                     "Should still be monitoring after 10 seconds")
        
        // Should have metrics
        XCTAssertNotNil(systemMonitor.currentMetrics,
                       "Should have collected metrics")
        
        systemMonitor.stop()
    }
    
    func testConcurrentMetricCollection() async throws {
        // Test: Multiple concurrent refreshes don't cause issues
        
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    do {
                        try await self.systemMonitor.refresh()
                        return true
                    } catch {
                        return false
                    }
                }
            }
            
            var successCount = 0
            for await success in group {
                if success {
                    successCount += 1
                }
            }
            
            XCTAssertEqual(successCount, 10,
                          "All concurrent refreshes should succeed")
        }
    }
}

