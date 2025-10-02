# Service Contracts: Monitoring Protocols

**Feature**: 002-ui-menubar-ui  
**Date**: 2025-10-02  
**Status**: Complete

## Overview

This document defines protocol contracts for all monitoring services. These protocols serve as interfaces that:
1. Decouple implementation from usage (enables testing via mocks)
2. Define clear API boundaries between services and ViewModels
3. Document expected behavior and error conditions

---

## 1. ProcessMonitoring Protocol

### Purpose
Monitor running system processes and their resource usage.

### Protocol Definition

```swift
import Foundation

protocol ProcessMonitoring: AnyObject {
    /// Get the top N processes sorted by specified criteria
    /// - Parameters:
    ///   - sortBy: CPU or Memory usage
    ///   - limit: Maximum number of processes to return
    /// - Returns: Array of ProcessInfo, sorted by criteria (highest first)
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo]
    
    /// Attempt to terminate a process by PID
    /// - Parameter pid: Process ID to terminate
    /// - Throws: ProcessTerminationError if termination fails
    func terminateProcess(pid: Int) throws
    
    /// Check if a process is system-critical and should not be terminated
    /// - Parameter pid: Process ID to check
    /// - Returns: True if process is protected, false if safe to terminate
    func isSystemCritical(pid: Int) -> Bool
    
    /// Get detailed information about a specific process
    /// - Parameter pid: Process ID
    /// - Returns: ProcessInfo if found, nil otherwise
    func getProcessInfo(pid: Int) -> ProcessInfo?
}
```

### Error Types

```swift
enum ProcessTerminationError: Error, LocalizedError {
    case processNotFound
    case insufficientPermissions
    case systemCriticalProcess
    case terminationFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .processNotFound:
            return "Process not found"
        case .insufficientPermissions:
            return "Insufficient permissions to terminate process"
        case .systemCriticalProcess:
            return "Cannot terminate system-critical process"
        case .terminationFailed(let reason):
            return "Failed to terminate process: \(reason)"
        }
    }
}
```

### Behavior Specifications

**getTopProcesses**:
- Returns empty array if no processes found (never returns nil)
- Always returns at most `limit` processes
- Sorting is stable (same CPU/memory usage maintains order)
- Updates reflect current state (no caching)
- Execution time: <50ms for top 5 processes

**terminateProcess**:
- Throws `systemCriticalProcess` if `isSystemCritical(pid)` returns true
- Throws `processNotFound` if PID doesn't exist
- Throws `insufficientPermissions` if lacking privilege (rare)
- Returns normally if termination signal sent successfully
- Does NOT wait for process to actually exit (asynchronous)

**isSystemCritical**:
- Returns true for PIDs < 100 (system range)
- Returns true for hardcoded protected process names
- Returns true if unable to determine (safe default)
- Never throws errors

### Usage Example

```swift
class ProcessListViewModel: ObservableObject {
    private let processMonitor: ProcessMonitoring
    @Published var topProcesses: [ProcessInfo] = []
    
    func refreshProcesses() {
        topProcesses = processMonitor.getTopProcesses(
            sortBy: .cpu,
            limit: 5
        )
    }
    
    func terminateProcess(_ process: ProcessInfo) {
        guard !processMonitor.isSystemCritical(pid: process.id) else {
            showError("Cannot terminate system process")
            return
        }
        
        do {
            try processMonitor.terminateProcess(pid: process.id)
            showSuccess("Process terminated")
        } catch {
            showError(error.localizedDescription)
        }
    }
}
```

---

## 2. DiskHealthMonitoring Protocol

### Purpose
Monitor disk health using S.M.A.R.T. data.

### Protocol Definition

```swift
import Foundation

protocol DiskHealthMonitoring: AnyObject {
    /// Get health information for a specific volume
    /// - Parameter path: Volume mount path (e.g., "/", "/Volumes/External")
    /// - Returns: DiskHealthInfo if available, nil if volume not found or SMART unavailable
    func getHealthInfo(forVolume path: String) -> DiskHealthInfo?
    
    /// Get health information for all mounted volumes
    /// - Returns: Array of DiskHealthInfo for all volumes with available SMART data
    func monitorAllVolumes() -> [DiskHealthInfo]
    
    /// Start monitoring for disk mount/unmount events
    /// - Parameter callback: Called when volumes change
    func startMonitoring(onChange: @escaping ([DiskHealthInfo]) -> Void)
    
    /// Stop monitoring disk events
    func stopMonitoring()
}
```

### Behavior Specifications

**getHealthInfo**:
- Returns nil if volume path doesn't exist
- Returns nil if S.M.A.R.T. data unavailable (e.g., network volumes)
- Returns `DiskHealthInfo` with `.unavailable` status if can't read SMART
- Never throws errors (returns nil on failure)
- Execution time: <100ms per volume

**monitorAllVolumes**:
- Returns array of all volumes with SMART data
- Excludes volumes without SMART support (doesn't include nil entries)
- Order: Internal drives first, then external, then other
- Execution time: <200ms for typical system (2-3 volumes)

**startMonitoring**:
- Callback fired immediately with current state
- Callback fired on mount/unmount events
- Callback always called on main thread (safe for UI updates)
- Can be called multiple times (replaces previous callback)

**stopMonitoring**:
- Safe to call even if not monitoring
- Cleans up DiskArbitration session
- Callbacks no longer fired after this call

### Usage Example

```swift
class DiskHealthViewModel: ObservableObject {
    private let diskHealthMonitor: DiskHealthMonitoring
    @Published var diskHealths: [DiskHealthInfo] = []
    
    func startMonitoring() {
        diskHealthMonitor.startMonitoring { [weak self] healthInfos in
            self?.diskHealths = healthInfos
        }
    }
    
    func stopMonitoring() {
        diskHealthMonitor.stopMonitoring()
    }
}
```

---

## 3. HistoricalDataManaging Protocol

### Purpose
Manage time-series data for sparkline charts.

### Protocol Definition

```swift
import Foundation

protocol HistoricalDataManaging: AnyObject {
    /// Record a new data point
    /// - Parameter point: Data point to record
    /// - Note: Automatically removes points older than retention period
    func recordDataPoint(_ point: HistoricalDataPoint)
    
    /// Get historical data for a metric
    /// - Parameters:
    ///   - metric: Which metric to retrieve
    ///   - duration: How far back to retrieve (default: 60 seconds)
    /// - Returns: Array of data points within duration, ordered oldest to newest
    func getHistory(for metric: MetricType, duration: TimeInterval) -> [HistoricalDataPoint]
    
    /// Clear all historical data
    func clearHistory()
    
    /// Clear history for a specific metric
    /// - Parameter metric: Which metric to clear
    func clearHistory(for metric: MetricType)
}
```

### Behavior Specifications

**recordDataPoint**:
- Thread-safe (can be called from any thread)
- Automatically drops oldest point when buffer full (60 points)
- O(1) operation (constant time)
- No return value, never throws

**getHistory**:
- Returns empty array if no data for metric
- Filters to points within `duration` from now
- Always returns ordered array (oldest first)
- Execution time: O(n) where n = number of points (max 60)

**clearHistory**:
- Thread-safe operations
- Safe to call multiple times
- Immediate effect (no async cleanup)

### Usage Example

```swift
class MetricViewModel: ObservableObject {
    private let dataManager: HistoricalDataManaging
    @Published var sparklineData: [HistoricalDataPoint] = []
    
    func recordMetric(value: Double, type: MetricType) {
        let point = HistoricalDataPoint(
            timestamp: Date(),
            metricType: type,
            value: value
        )
        dataManager.recordDataPoint(point)
        updateSparkline(for: type)
    }
    
    func updateSparkline(for metric: MetricType) {
        sparklineData = dataManager.getHistory(for: metric, duration: 60)
    }
}
```

---

## 4. MemoryPurging Protocol

### Purpose
Free inactive system memory on demand.

### Protocol Definition

```swift
import Foundation

protocol MemoryPurging: AnyObject {
    /// Purge inactive memory
    /// - Returns: Result containing before/after memory stats and amount freed
    /// - Throws: MemoryPurgeError if operation fails
    func purgeInactiveMemory() async throws -> MemoryPurgeResult
    
    /// Check if memory purge is currently available
    /// - Returns: True if purge can be performed, false if already in progress
    func canPurge() -> Bool
}
```

### Error Types

```swift
enum MemoryPurgeError: Error, LocalizedError {
    case operationInProgress
    case systemCommandFailed
    case insufficientPermissions
    
    var errorDescription: String? {
        switch self {
        case .operationInProgress:
            return "Memory purge already in progress"
        case .systemCommandFailed:
            return "Failed to execute purge command"
        case .insufficientPermissions:
            return "Insufficient permissions to purge memory"
        }
    }
}
```

### Behavior Specifications

**purgeInactiveMemory**:
- Async operation (takes 1-3 seconds typically)
- Throws if another purge already in progress
- Returns result even if no memory freed (freedBytes may be 0)
- Automatically updates `canPurge()` state during operation
- Safe to call from any context (handles threading internally)

**canPurge**:
- Returns false while purge operation in progress
- Returns true immediately after purge completes
- Thread-safe
- Never throws

### Usage Example

```swift
class MemoryViewModel: ObservableObject {
    private let memoryMonitor: MemoryPurging
    @Published var isPurging = false
    
    func purgeMemory() async {
        guard memoryMonitor.canPurge() else {
            showError("Purge already in progress")
            return
        }
        
        isPurging = true
        defer { isPurging = false }
        
        do {
            let result = try await memoryMonitor.purgeInactiveMemory()
            showSuccess("Freed \(result.formattedFreed)")
        } catch {
            showError(error.localizedDescription)
        }
    }
}
```

---

## 5. Enhanced SystemMonitor Protocol

### Purpose
Coordinate all monitoring services and provide unified metrics.

### Protocol Definition

```swift
import Foundation
import Combine

protocol SystemMonitor: AnyObject {
    /// Current system metrics (CPU, memory, disk, network)
    var currentMetrics: SystemMetrics? { get }
    
    /// Whether monitoring is active
    var isMonitoring: Bool { get }
    
    /// Publisher for metric updates
    var metricsPublisher: AnyPublisher<SystemMetrics, Never> { get }
    
    /// Start monitoring with specified interval
    /// - Parameter interval: Seconds between updates (1.0-5.0)
    func start(interval: TimeInterval)
    
    /// Stop monitoring
    func stop()
    
    /// Force immediate refresh of all metrics
    func refresh()
    
    /// Access to specialized monitors (NEW)
    var processMonitor: ProcessMonitoring { get }
    var diskHealthMonitor: DiskHealthMonitoring { get }
    var historicalDataManager: HistoricalDataManaging { get }
    var memoryPurger: MemoryPurging { get }
}
```

### Behavior Specifications

**start**:
- Begins periodic metric collection
- First update delivered immediately
- Interval clamped to 1.0-5.0 seconds
- Safe to call multiple times (restarts with new interval)

**stop**:
- Stops periodic updates
- Retains last `currentMetrics` value
- Safe to call when not monitoring

**refresh**:
- Triggers immediate metric collection
- Updates `currentMetrics` and fires publisher
- Can be called whether monitoring or not
- Execution time: <100ms

**Specialized monitors**:
- Always available (even when not monitoring)
- Independent lifecycle from SystemMonitor
- Can be used directly by ViewModels

---

## 6. Contract Testing Strategy

Each protocol must have corresponding contract tests:

### Test Structure

```swift
class ProcessMonitoringContractTests: XCTestCase {
    var sut: ProcessMonitoring!
    
    func testGetTopProcesses_returnsAtMostLimit() {
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 5)
        XCTAssertLessThanOrEqual(processes.count, 5)
    }
    
    func testGetTopProcesses_sortsByCPU() {
        let processes = sut.getTopProcesses(sortBy: .cpu, limit: 10)
        for i in 0..<(processes.count - 1) {
            XCTAssertGreaterThanOrEqual(
                processes[i].cpuUsage,
                processes[i + 1].cpuUsage
            )
        }
    }
    
    func testTerminateProcess_throwsForSystemCritical() {
        XCTAssertThrowsError(try sut.terminateProcess(pid: 1)) { error in
            XCTAssertEqual(error as? ProcessTerminationError, .systemCriticalProcess)
        }
    }
    
    func testIsSystemCritical_returnsTrueForLowPIDs() {
        XCTAssertTrue(sut.isSystemCritical(pid: 1))
        XCTAssertTrue(sut.isSystemCritical(pid: 50))
    }
}
```

### Mock Implementations

```swift
class MockProcessMonitor: ProcessMonitoring {
    var mockProcesses: [ProcessInfo] = []
    var shouldThrowOnTerminate = false
    
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo] {
        let sorted = mockProcesses.sorted {
            sortBy == .cpu ? $0.cpuUsage > $1.cpuUsage : $0.memoryUsage > $1.memoryUsage
        }
        return Array(sorted.prefix(limit))
    }
    
    func terminateProcess(pid: Int) throws {
        if shouldThrowOnTerminate {
            throw ProcessTerminationError.systemCriticalProcess
        }
    }
    
    func isSystemCritical(pid: Int) -> Bool {
        return pid < 100
    }
    
    func getProcessInfo(pid: Int) -> ProcessInfo? {
        return mockProcesses.first { $0.id == pid }
    }
}
```

---

## 7. Protocol Relationships

```
SystemMonitor (coordinator)
├── CPUMonitoring (existing)
├── MemoryMonitoring (existing, enhanced)
├── DiskMonitoring (existing, enhanced)
├── NetworkMonitoring (existing)
├── ProcessMonitoring (NEW)
├── DiskHealthMonitoring (NEW)
├── HistoricalDataManaging (NEW)
└── MemoryPurging (NEW)

ViewModels depend only on protocols, not concrete implementations
Tests use mock implementations of protocols
Dependency injection enables swapping implementations
```

---

## 8. Implementation Checklist

For each protocol:
- [ ] Define protocol with clear doc comments
- [ ] Create error types if needed
- [ ] Implement concrete class conforming to protocol
- [ ] Create mock implementation for testing
- [ ] Write contract tests validating behavior
- [ ] Write unit tests for concrete implementation
- [ ] Document usage examples

---

**Status**: ✅ All protocol contracts defined  
**Next**: Create quickstart.md with integration test scenarios


