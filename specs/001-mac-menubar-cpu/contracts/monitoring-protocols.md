# Monitoring Service Contracts

**Feature**: 001-mac-menubar-cpu  
**Date**: 2025-10-02  
**Status**: Design Complete

## Overview
This document defines the protocol contracts for all monitoring services. These protocols ensure testability, modularity, and consistent behavior across all metric collectors.

---

## 1. MetricProvider Protocol

Base protocol for all metric providers.

```swift
/// Protocol for providing system metrics
protocol MetricProvider {
    /// The type of metrics this provider produces
    associatedtype Metrics
    
    /// Asynchronously retrieves current metrics
    /// - Throws: MetricError if collection fails
    /// - Returns: Current metrics snapshot
    func getCurrentMetrics() async throws -> Metrics
    
    /// Indicates if the provider is currently available
    var isAvailable: Bool { get }
}
```

**Contract Rules**:
- `getCurrentMetrics()` must complete within 100ms under normal conditions
- Must throw `MetricError` (not generic Error) for specific error handling
- `isAvailable` should be fast to compute (<1ms)
- Thread-safe: Can be called from any thread
- Must not block the calling thread

**Error Handling**:
```swift
enum MetricError: Error, LocalizedError {
    case permissionDenied
    case systemAPIUnavailable
    case timeout
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied to access system metrics"
        case .systemAPIUnavailable:
            return "System monitoring API is unavailable"
        case .timeout:
            return "Metric collection timed out"
        case .invalidData:
            return "Received invalid metric data from system"
        }
    }
}
```

---

## 2. CPUMonitor Protocol

```swift
/// Protocol for CPU metrics monitoring
protocol CPUMonitor: MetricProvider where Metrics == CPUMetrics {
    /// Retrieves current CPU usage metrics
    /// - Throws: MetricError if CPU data cannot be collected
    /// - Returns: Current CPU metrics including user, system, and idle percentages
    func getCurrentMetrics() async throws -> CPUMetrics
}
```

**Implementation Requirements**:
- Use `host_processor_info()` from mach kernel
- Calculate delta from previous call for accurate percentages
- Store previous tick values internally
- Return values in range 0.0-100.0

**Expected Behavior**:
```swift
// First call - may return 0 or estimate
let metrics1 = try await monitor.getCurrentMetrics()

// Subsequent calls - accurate delta calculation
try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
let metrics2 = try await monitor.getCurrentMetrics()

// metrics2 reflects actual CPU usage during the interval
assert(metrics2.usagePercentage >= 0.0 && metrics2.usagePercentage <= 100.0)
assert(metrics2.userUsage + metrics2.systemUsage ≈ metrics2.usagePercentage)
```

**Performance Contract**:
- Execution time: <20ms
- Memory allocation: <1KB per call
- Thread-safe concurrent calls

---

## 3. MemoryMonitor Protocol

```swift
/// Protocol for memory metrics monitoring
protocol MemoryMonitor: MetricProvider where Metrics == MemoryMetrics {
    /// Retrieves current memory usage metrics
    /// - Throws: MetricError if memory data cannot be collected
    /// - Returns: Current memory metrics including used, free, and cached
    func getCurrentMetrics() async throws -> MemoryMetrics
}
```

**Implementation Requirements**:
- Use `host_statistics64()` with `HOST_VM_INFO64`
- Return physical memory statistics (not virtual)
- All byte values must be ≥ 0
- `usedBytes` + `freeBytes` ≤ `totalBytes`

**Expected Behavior**:
```swift
let metrics = try await monitor.getCurrentMetrics()

// Invariants
assert(metrics.totalBytes > 0)
assert(metrics.usedBytes <= metrics.totalBytes)
assert(metrics.freeBytes <= metrics.totalBytes)
assert(metrics.usedBytes >= 0 && metrics.freeBytes >= 0)

// Computed properties
assert(metrics.usagePercentage >= 0.0 && metrics.usagePercentage <= 100.0)
assert(metrics.totalGigabytes > 0)
```

**Performance Contract**:
- Execution time: <10ms
- Memory allocation: <500 bytes per call
- No caching (always fresh data)

---

## 4. DiskMonitor Protocol

```swift
/// Protocol for disk metrics monitoring
protocol DiskMonitor: MetricProvider where Metrics == DiskMetrics {
    /// Retrieves disk usage metrics for a specific volume
    /// - Parameter volumePath: Absolute path to volume (e.g., "/")
    /// - Throws: MetricError if disk data cannot be collected
    /// - Returns: Current disk metrics for the specified volume
    func getCurrentMetrics(for volumePath: String) async throws -> DiskMetrics
    
    /// Lists all available mounted volumes
    /// - Returns: Array of volume paths
    func getAvailableVolumes() -> [String]
}
```

**Implementation Requirements**:
- Use `FileManager.attributesOfFileSystem(forPath:)`
- Validate `volumePath` is mounted before querying
- Return accurate byte counts
- Include volume name from mount point

**Expected Behavior**:
```swift
let volumes = monitor.getAvailableVolumes()
assert(volumes.contains("/")) // System disk always present

let metrics = try await monitor.getCurrentMetrics(for: "/")

// Invariants
assert(metrics.volumePath == "/")
assert(!metrics.volumeName.isEmpty)
assert(metrics.totalBytes > 0)
assert(metrics.usedBytes + metrics.freeBytes == metrics.totalBytes)
assert(metrics.usagePercentage >= 0.0 && metrics.usagePercentage <= 100.0)
```

**Error Cases**:
```swift
// Invalid path
XCTAssertThrowsError(try await monitor.getCurrentMetrics(for: "/nonexistent")) { error in
    XCTAssertEqual(error as? MetricError, .invalidData)
}

// Unmounted volume
XCTAssertThrowsError(try await monitor.getCurrentMetrics(for: "/Volumes/Unmounted"))
```

**Performance Contract**:
- Execution time: <50ms (filesystem I/O)
- Can cache results for up to 1 second
- `getAvailableVolumes()`: <10ms

---

## 5. NetworkMonitor Protocol

```swift
/// Protocol for network metrics monitoring
protocol NetworkMonitor: MetricProvider where Metrics == NetworkMetrics {
    /// Retrieves current network transfer rate
    /// - Throws: MetricError if network data cannot be collected
    /// - Returns: Current network metrics with upload/download rates
    func getCurrentMetrics() async throws -> NetworkMetrics
    
    /// Resets cumulative counters (total upload/download)
    func resetCounters()
}
```

**Implementation Requirements**:
- Use `getifaddrs()` or Network framework for interface stats
- Calculate rate from delta between calls
- Track cumulative totals since app start
- Aggregate all network interfaces (WiFi + Ethernet)

**Expected Behavior**:
```swift
let metrics1 = try await monitor.getCurrentMetrics()

// Wait for network activity
try await Task.sleep(nanoseconds: 1_000_000_000)

let metrics2 = try await monitor.getCurrentMetrics()

// Rates reflect current transfer speed
assert(metrics2.uploadBytesPerSecond >= 0)
assert(metrics2.downloadBytesPerSecond >= 0)

// Totals are monotonic increasing
assert(metrics2.totalUploadBytes >= metrics1.totalUploadBytes)
assert(metrics2.totalDownloadBytes >= metrics1.totalDownloadBytes)
```

**Reset Behavior**:
```swift
monitor.resetCounters()
let metrics = try await monitor.getCurrentMetrics()

// Totals reset to 0 or current delta
assert(metrics.totalUploadBytes == 0)
assert(metrics.totalDownloadBytes == 0)
```

**Performance Contract**:
- Execution time: <30ms
- Must cache previous interface stats for delta calculation
- Thread-safe for concurrent rate calculations

---

## 6. SystemMonitor Protocol

Coordinator protocol that orchestrates all metric providers.

```swift
/// Protocol for coordinating system monitoring
protocol SystemMonitor: ObservableObject {
    /// Current system metrics snapshot
    var currentMetrics: SystemMetrics? { get }
    
    /// Whether monitoring is currently active
    var isMonitoring: Bool { get }
    
    /// Application settings
    var settings: AppSettings { get set }
    
    /// Starts monitoring with configured interval
    /// - Parameter interval: Refresh interval in seconds (1.0-5.0)
    func start(interval: TimeInterval)
    
    /// Stops monitoring and releases resources
    func stop()
    
    /// Manually triggers a metrics update
    /// - Throws: MetricError if any metric collection fails
    func refresh() async throws
}
```

**Implementation Requirements**:
- Coordinate all metric providers (CPU, Memory, Disk, Network)
- Use `DispatchSourceTimer` for precise intervals
- Collect metrics on background queue (`.utility` QoS)
- Publish updates on main thread
- Only collect enabled metrics (per `settings`)

**Expected Behavior**:
```swift
let monitor = SystemMonitorImpl(settings: settings)

// Start monitoring
monitor.start(interval: 2.0)
assert(monitor.isMonitoring == true)

// Wait for first update
try await Task.sleep(nanoseconds: 2_100_000_000) // 2.1s
assert(monitor.currentMetrics != nil)

// Verify refresh interval
let timestamp1 = monitor.currentMetrics!.timestamp
try await Task.sleep(nanoseconds: 2_000_000_000) // 2s
let timestamp2 = monitor.currentMetrics!.timestamp
let actualInterval = timestamp2.timeIntervalSince(timestamp1)
assert(abs(actualInterval - 2.0) < 0.1) // Within 100ms tolerance

// Stop monitoring
monitor.stop()
assert(monitor.isMonitoring == false)
```

**Settings Change Behavior**:
```swift
// Change refresh interval while running
monitor.settings.refreshInterval = 5.0
// Monitor should automatically adjust timer

// Disable a metric
monitor.settings.showDisk = false
// Monitor should stop collecting disk metrics
```

**Error Handling**:
- Individual metric failures should not stop entire monitoring
- Log errors but continue with available metrics
- Expose error state through published property

**Performance Contract**:
- CPU usage: <2% average with default 2s interval
- Memory usage: <50MB total
- Timer precision: ±50ms
- Metric collection: Complete within interval/2

---

## 7. Testing Contracts

### Mock Implementations

```swift
/// Mock CPU monitor for testing
class MockCPUMonitor: CPUMonitor {
    var mockMetrics: CPUMetrics
    var shouldThrow: Error?
    var callCount: Int = 0
    
    func getCurrentMetrics() async throws -> CPUMetrics {
        callCount += 1
        if let error = shouldThrow {
            throw error
        }
        return mockMetrics
    }
    
    var isAvailable: Bool { shouldThrow == nil }
}
```

**Testing Requirements**:
- Provide mock implementations for all protocols
- Enable controllable behavior (success, failure, specific values)
- Track call counts for verification
- Support async testing with XCTest

### Contract Tests

Each protocol implementation must have contract tests:

```swift
class CPUMonitorContractTests: XCTestCase {
    var monitor: CPUMonitor!
    
    func testGetCurrentMetricsReturnsValidRange() async throws {
        let metrics = try await monitor.getCurrentMetrics()
        
        XCTAssertGreaterThanOrEqual(metrics.usagePercentage, 0.0)
        XCTAssertLessThanOrEqual(metrics.usagePercentage, 100.0)
        XCTAssertGreaterThanOrEqual(metrics.userUsage, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.systemUsage, 0.0)
        XCTAssertGreaterThanOrEqual(metrics.idlePercentage, 0.0)
    }
    
    func testGetCurrentMetricsCompletesQuickly() async throws {
        let start = Date()
        _ = try await monitor.getCurrentMetrics()
        let duration = Date().timeIntervalSince(start)
        
        XCTAssertLessThan(duration, 0.1) // <100ms
    }
    
    func testConcurrentCallsAreThreadSafe() async throws {
        await withTaskGroup(of: CPUMetrics?.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try? await self.monitor.getCurrentMetrics()
                }
            }
        }
        // Should not crash or corrupt state
    }
}
```

---

## Protocol Dependency Graph

```
MetricProvider (base)
  ├── CPUMonitor
  ├── MemoryMonitor
  ├── DiskMonitor
  └── NetworkMonitor

SystemMonitor (coordinator)
  ├── depends on: CPUMonitor
  ├── depends on: MemoryMonitor
  ├── depends on: DiskMonitor
  ├── depends on: NetworkMonitor
  └── publishes: SystemMetrics
```

---

## Performance Summary

| Protocol | Max Execution Time | Memory Per Call | Thread Safety |
|----------|-------------------|-----------------|---------------|
| CPUMonitor | 20ms | <1KB | Yes |
| MemoryMonitor | 10ms | <500B | Yes |
| DiskMonitor | 50ms | <2KB | Yes |
| NetworkMonitor | 30ms | <1KB | Yes |
| SystemMonitor | 100ms | <5KB | Yes (publishes on main) |

---

## Compliance Checklist

For each implementation, verify:

- [ ] Conforms to protocol signature exactly
- [ ] Throws only `MetricError` (not generic errors)
- [ ] Completes within performance contract timeframe
- [ ] Returns valid data within specified ranges
- [ ] Thread-safe for concurrent access
- [ ] Includes comprehensive unit tests
- [ ] Includes contract compliance tests
- [ ] Properly handles error cases
- [ ] Documented with code comments

---

**Status**: ✅ Protocol contracts defined and ready for test-first implementation





