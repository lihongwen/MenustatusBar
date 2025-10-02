# Research: Modern UI & Menubar Enhancement

**Feature**: 002-ui-menubar-ui  
**Date**: 2025-10-02  
**Status**: Complete

## Overview

This document captures technical research and decisions for implementing a modern, compact menubar monitoring application with process management, memory purging, multi-disk monitoring, and health status features.

---

## 1. Sparkline Chart Implementation

### Decision
Use **SwiftUI Charts framework** (macOS 13.0+) for sparkline visualization

### Rationale
- Native Apple framework with optimized performance
- Built-in accessibility support (VoiceOver compatibility)
- Seamless SwiftUI integration with declarative syntax
- Automatic light/dark mode adaptation
- GPU-accelerated rendering

### Implementation Approach
```swift
import Charts

struct SparklineChart: View {
    let dataPoints: [HistoricalDataPoint]
    let color: Color
    
    var body: some View {
        Chart(dataPoints) { point in
            LineMark(
                x: .value("Time", point.timestamp),
                y: .value("Value", point.value)
            )
            .foregroundStyle(color.gradient)
            .lineStyle(StrokeStyle(lineWidth: 1.5))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 30)
    }
}
```

### Alternatives Considered
- **Custom Core Graphics**: More control but requires manual accessibility, harder to maintain
- **Third-party libraries (SwiftUICharts)**: Additional dependency, not as optimized as native framework
- **ASCII art sparklines**: Not visually appealing enough for modern UI requirements

### Performance Considerations
- Limit data points to 60 (1 per second for 60 seconds)
- Use `@State` with debounced updates to avoid excessive redraws
- Chart framework handles GPU acceleration automatically
- Expected render time: <5ms for 60 points

---

## 2. Process Monitoring & Management

### Decision
Use **Foundation Process APIs** with `task_info()` system calls

### Rationale
- Native macOS API, no third-party dependencies
- Access to real-time CPU and memory usage per process
- Can retrieve process name, PID, and application bundle identifier
- Supports filtering and sorting

### Implementation Approach
```swift
import Foundation

class ProcessMonitor: ProcessMonitoring {
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo] {
        let processes = runningProcesses()
        let sorted = processes.sorted { 
            sortBy == .cpu ? $0.cpuUsage > $1.cpuUsage : $0.memoryUsage > $1.memoryUsage 
        }
        return Array(sorted.prefix(limit))
    }
    
    private func runningProcesses() -> [ProcessInfo] {
        // Use sysctl with KERN_PROC_ALL to get process list
        // Parse task_info for each PID to get CPU/memory stats
    }
}
```

### Safety Mechanisms
**System-Critical Process Protection**:
```swift
private let protectedProcesses: Set<String> = [
    "kernel_task", "launchd", "WindowServer", "loginwindow",
    "SystemUIServer", "Dock", "Finder", "coreaudiod"
]

func isSystemCritical(pid: Int) -> Bool {
    guard let name = processName(for: pid) else { return true }
    return protectedProcesses.contains(name) || pid < 100
}
```

### Alternatives Considered
- **ActivityMonitor framework**: Not publicly available
- **Shell execution of `ps`/`top`**: Slower, harder to parse, less reliable
- **Third-party process monitoring libraries**: Overkill for our needs

### Performance Considerations
- Query process list only on refresh interval (1-5 seconds)
- Cache process names and icons to avoid repeated lookups
- Run enumeration on background thread, update UI on main thread
- Expected overhead: <10ms per refresh for top 5 processes

---

## 3. S.M.A.R.T. Disk Health Monitoring

### Decision
Use **IOKit framework** to access S.M.A.R.T. attributes

### Rationale
- Standard macOS framework for hardware interaction
- Direct access to disk S.M.A.R.T. data without external tools
- Can retrieve power-on hours, error counts, health status
- Works with both internal and external drives (when supported)

### Implementation Approach
```swift
import IOKit
import IOKit.storage

class DiskHealthMonitor: DiskHealthMonitoring {
    func getHealthInfo(forVolume path: String) -> DiskHealthInfo? {
        guard let bsdName = getBSDName(forPath: path) else { return nil }
        
        let matchingDict = IOServiceMatching("IOBlockStorageDevice")
        var iterator: io_iterator_t = 0
        
        IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator)
        
        // Iterate devices, find matching BSD name
        // Read SMART attributes from device properties
        // Parse health status, power-on hours, error counts
    }
}
```

### Health Status Determination
- **Good**: No errors, temperature normal, smart status "Verified"
- **Warning**: Minor errors (<10), smart status ok but approaching limits
- **Critical**: High error count (>10), failing SMART status, imminent failure predicted
- **Unavailable**: SMART not supported (e.g., some external drives, network volumes)

### Alternatives Considered
- **smartctl command-line tool**: Requires external dependency, slower to execute
- **diskutil command**: Limited SMART data, requires parsing shell output
- **Third-party frameworks**: Not needed for our use case

### Graceful Degradation
- Return `.unavailable` status when SMART data cannot be read
- Don't crash or show errors for volumes without SMART support
- Hide health indicator if all disks return unavailable

---

## 4. Memory Purge Functionality

### Decision
Use **system `purge` command** via Process API

### Rationale
- Apple-provided system command specifically for freeing inactive memory
- Requires no special entitlements (user-level operation)
- Safe operation that won't harm system stability
- Provides immediate memory reclamation

### Implementation Approach
```swift
class MemoryMonitor {
    func purgeInactiveMemory() async throws -> MemoryPurgeResult {
        let beforeMemory = getCurrentMemoryUsage()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/purge")
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw MemoryPurgeError.purgeFailed
        }
        
        // Wait brief moment for system to update stats
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let afterMemory = getCurrentMemoryUsage()
        let freed = beforeMemory - afterMemory
        
        return MemoryPurgeResult(
            freedBytes: freed,
            beforeUsage: beforeMemory,
            afterUsage: afterMemory
        )
    }
}
```

### User Experience Considerations
- Show loading indicator during purge operation (typically 1-3 seconds)
- Display before/after memory stats to confirm effectiveness
- Handle case where no memory was freed (already optimal)
- Provide error message if purge fails (rare, but possible)

### Alternatives Considered
- **Direct memory pressure API**: More complex, requires entitlements
- **Custom memory management**: Not safe, could destabilize system
- **No purge feature**: User requested this specifically

---

## 5. Multi-Disk Monitoring

### Decision
Use **FileManager + DiskArbitration framework** for dynamic volume tracking

### Rationale
- FileManager provides list of all mounted volumes
- DiskArbitration framework notifies of mount/unmount events
- Can monitor internal drives, external drives, network volumes
- Automatic UI updates when disks change

### Implementation Approach
```swift
import DiskArbitration
import Foundation

class DiskMonitor {
    private var diskArbitrationSession: DASession?
    
    func startMonitoring() {
        diskArbitrationSession = DASessionCreate(kCFAllocatorDefault)
        DASessionSetDispatchQueue(diskArbitrationSession, DispatchQueue.main)
        
        DARegisterDiskAppearedCallback(diskArbitrationSession, nil, diskAppeared, nil)
        DARegisterDiskDisappearedCallback(diskArbitrationSession, nil, diskDisappeared, nil)
    }
    
    func getAllMountedVolumes() -> [DiskInfo] {
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey
        ]
        
        let volumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        )
        
        return volumes?.compactMap { url in
            // Extract disk information from URL resource values
        } ?? []
    }
}
```

### UI Update Strategy
- Maintain `@Published var disks: [DiskInfo]` in ViewModel
- SwiftUI automatically updates UI when array changes
- Animate card appearance/disappearance with `.transition()` modifiers
- Sort disks by: Internal first, then external, then network

### Alternatives Considered
- **Poll FileManager periodically**: Inefficient, misses real-time changes
- **Only monitor one disk**: User specifically requested multi-disk support

---

## 6. Color Theme System

### Decision
Use **SwiftUI Environment + PreferenceKey** pattern

### Rationale
- Native SwiftUI pattern for app-wide theming
- Allows easy theme switching without view reconstruction
- Supports dynamic color adaptation for light/dark mode
- Minimal performance overhead

### Implementation Approach
```swift
protocol ColorTheme {
    var healthyColor: Color { get }
    var warningColor: Color { get }
    var criticalColor: Color { get }
    var backgroundColor: Color { get }
    var accentColor: Color { get }
}

struct SystemDefaultTheme: ColorTheme {
    var healthyColor: Color { .green }
    var warningColor: Color { .yellow }
    var criticalColor: Color { .red }
    var backgroundColor: Color { Color(NSColor.windowBackgroundColor) }
    var accentColor: Color { .accentColor }
}

// Inject via environment
.environmentObject(ThemeManager.shared)
```

### Theme Definitions
1. **System Default**: Uses macOS accent color and system colors
2. **Monochrome**: Grayscale only (white/gray/black)
3. **Traffic Light**: Red/yellow/green (high contrast)
4. **Cool**: Blue/cyan gradients
5. **Warm**: Orange/red gradients

### Alternatives Considered
- **Hardcoded colors**: Not flexible, requires code changes for new themes
- **CSS-like styling**: Not native to SwiftUI, adds complexity

---

## 7. Animation & Performance

### Decision
Use **native SwiftUI animations** with consistent timing

### Rationale
- GPU-accelerated, no custom animation engine needed
- Consistent with macOS system animations
- Simple to implement and maintain
- Supports accessibility (reduced motion)

### Standard Animation Set
```swift
extension Animation {
    static let standardSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let quickFade = Animation.easeInOut(duration: 0.2)
    static let smoothTransition = Animation.easeInOut(duration: 0.3)
}
```

### Performance Optimization Strategies
1. **Debounced Updates**: Update UI maximum once per refresh interval
2. **Lazy Views**: Use `LazyVStack` for process lists
3. **Conditional Rendering**: Only render visible cards
4. **Background Processing**: All system calls on background threads
5. **Memory Management**: Limit historical data to 60 points per metric

### Performance Targets (from spec)
- Frame time: <16ms (60fps)
- Memory footprint: <50MB
- CPU usage at idle: <5%
- Sparkline render time: <5ms

---

## 8. Data Retention Strategy

### Decision
Use **in-memory circular buffer** for 60-second historical data

### Rationale
- No disk I/O overhead
- Automatic memory management (fixed size)
- Fast access for sparkline rendering
- Data doesn't persist across app restarts (privacy)

### Implementation Approach
```swift
class HistoricalDataManager {
    private var dataBuffers: [MetricType: CircularBuffer<HistoricalDataPoint>] = [:]
    
    init() {
        MetricType.allCases.forEach { metric in
            dataBuffers[metric] = CircularBuffer(capacity: 60)
        }
    }
    
    func recordDataPoint(_ point: HistoricalDataPoint) {
        dataBuffers[point.metricType]?.append(point)
    }
    
    func getHistory(for metric: MetricType) -> [HistoricalDataPoint] {
        return dataBuffers[metric]?.asArray() ?? []
    }
}

struct CircularBuffer<T> {
    private var buffer: [T]
    private var head = 0
    private let capacity: Int
    
    // Append replaces oldest when full
}
```

### Memory Footprint
- 60 points × 5 metrics × ~32 bytes per point = ~9.6 KB
- Negligible impact on overall memory budget

### Alternatives Considered
- **Persistent storage (Core Data)**: Overkill, adds complexity, privacy concerns
- **Unlimited history**: Memory leak risk, not required by spec
- **File-based storage**: I/O overhead, slower access

---

## 9. Settings Persistence

### Decision
Continue using **UserDefaults** with enhanced AppSettings model

### Rationale
- Already in use by existing app
- Perfect for user preferences
- Automatic iCloud sync (if enabled by user)
- Simple to use, no additional dependencies

### Enhanced AppSettings Properties
```swift
struct AppSettings: Codable {
    // Existing properties
    var showCPU: Bool
    var showMemory: Bool
    var showDisk: Bool
    var showNetwork: Bool
    var refreshInterval: TimeInterval
    
    // New properties
    var displayMode: DisplayMode
    var colorTheme: String // Theme identifier
    var metricOrder: [String] // Serialized MetricType array
    var showTopProcesses: Bool
    var processSortCriteria: String
    var autoHideThreshold: Double
}
```

---

## 10. Error Handling Strategy

### Decision
Use **Swift Result type** and graceful degradation

### Principles
1. **Never crash**: All errors handled gracefully
2. **User-friendly messages**: No technical jargon in UI
3. **Automatic recovery**: Retry failed operations
4. **Logging**: Console logs for debugging (not user-visible)

### Error Categories
- **Recoverable**: Show toast/alert, retry automatically
- **Non-critical**: Hide feature, log error, continue
- **Critical**: Show alert, offer settings/quit options

### Examples
```swift
// Non-critical: SMART data unavailable
if let health = diskHealthMonitor.getHealthInfo(forVolume: path) {
    // Show health status
} else {
    // Just don't show health indicator, show "N/A"
}

// Recoverable: Memory purge failed
do {
    let result = try await memoryMonitor.purgeInactiveMemory()
    showSuccess(result)
} catch {
    showAlert("Unable to free memory. Please try again.")
}

// Critical: System monitoring completely failed
guard let metrics = systemMonitor.currentMetrics else {
    showAlert("System monitoring failed. Please restart the app.")
    return
}
```

---

## Summary of Key Decisions

| Area | Technology | Rationale |
|------|------------|-----------|
| Sparklines | SwiftUI Charts | Native, optimized, accessible |
| Process Monitoring | Foundation Process APIs | Native, real-time, no dependencies |
| Disk Health | IOKit | Direct SMART access, reliable |
| Memory Purge | system `purge` command | Safe, simple, effective |
| Multi-Disk | FileManager + DiskArbitration | Dynamic updates, comprehensive |
| Theming | Environment + PreferenceKey | Native SwiftUI pattern |
| Animation | Native SwiftUI | GPU-accelerated, consistent |
| Data Storage | In-memory circular buffer | Fast, privacy-friendly |
| Settings | UserDefaults | Already in use, simple |
| Error Handling | Result type + graceful degradation | User-friendly, robust |

---

## Implementation Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| SMART data unavailable | Medium | Graceful fallback, show "N/A" |
| Process termination fails | Low | Confirmation dialogs, error messages |
| Memory purge has no effect | Low | Show actual freed amount (could be 0) |
| Sparkline performance issues | Medium | Limit to 60 points, debounced updates |
| Multi-disk UI overflow | Low | ScrollView, collapse cards |
| Theme switching bugs | Low | Comprehensive testing, use Environment |

---

## References

- [Apple SwiftUI Charts Documentation](https://developer.apple.com/documentation/charts)
- [IOKit Framework Reference](https://developer.apple.com/documentation/iokit)
- [DiskArbitration Framework](https://developer.apple.com/documentation/diskarbitration)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SwiftUI Animation Best Practices](https://developer.apple.com/documentation/swiftui/animation)

---

**Status**: ✅ All technical decisions documented  
**Next Phase**: Phase 1 - Design & Contracts


