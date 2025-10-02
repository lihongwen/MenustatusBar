# Data Model: Mac系统状态监控菜单栏应用

**Feature**: 001-mac-menubar-cpu  
**Date**: 2025-10-02  
**Status**: Design Complete

## Overview
This document defines the data models and their relationships for the macOS menubar system monitor application. All models are designed to be lightweight, immutable where possible, and optimized for frequent updates.

---

## Core Entities

### 1. SystemMetrics
Represents a snapshot of system performance metrics at a specific point in time.

**Purpose**: Encapsulate all monitored system data in a single value type.

**Properties**:
```swift
struct SystemMetrics {
    let timestamp: Date
    let cpu: CPUMetrics
    let memory: MemoryMetrics
    let disk: DiskMetrics
    let network: NetworkMetrics
}
```

**Characteristics**:
- **Immutable**: Value type (struct) for thread safety
- **Timestamp**: Precise measurement time for accurate rate calculations
- **Composite**: Aggregates all metric types in one object

---

### 2. CPUMetrics
CPU usage information.

**Properties**:
```swift
struct CPUMetrics {
    let usagePercentage: Double  // 0.0 - 100.0
    let systemUsage: Double      // System processes (0.0 - 100.0)
    let userUsage: Double        // User processes (0.0 - 100.0)
    let idlePercentage: Double   // Idle time (0.0 - 100.0)
}
```

**Validation Rules**:
- `usagePercentage` = `systemUsage` + `userUsage`
- All values: 0.0 ≤ value ≤ 100.0
- `usagePercentage` + `idlePercentage` ≈ 100.0 (within rounding error)

**Display Format**:
- Primary: `"CPU: XX%"` (rounded to nearest integer)
- Detailed: `"CPU: XX% (User: XX%, System: XX%)"`

---

### 3. MemoryMetrics
Memory usage information.

**Properties**:
```swift
struct MemoryMetrics {
    let totalBytes: UInt64       // Total physical memory
    let usedBytes: UInt64        // Used memory (active + wired)
    let freeBytes: UInt64        // Free memory
    let cachedBytes: UInt64      // Cached/inactive memory
    
    // Computed properties
    var usagePercentage: Double {
        Double(usedBytes) / Double(totalBytes) * 100.0
    }
    
    var usedGigabytes: Double {
        Double(usedBytes) / 1_073_741_824.0  // 1024^3
    }
    
    var totalGigabytes: Double {
        Double(totalBytes) / 1_073_741_824.0
    }
}
```

**Validation Rules**:
- `usedBytes` + `freeBytes` ≤ `totalBytes` (cached may be separate)
- All byte values ≥ 0
- `totalBytes` > 0

**Display Format**:
- Primary: `"Memory: X.X/X.X GB"` (1 decimal place)
- Percentage: `"Memory: XX%"`
- Detailed: `"Used: X.X GB, Free: X.X GB, Cached: X.X GB"`

---

### 4. DiskMetrics
Disk space information for a specific volume.

**Properties**:
```swift
struct DiskMetrics {
    let volumePath: String       // e.g., "/" for system disk
    let volumeName: String       // e.g., "Macintosh HD"
    let totalBytes: UInt64       // Total disk capacity
    let freeBytes: UInt64        // Available space
    let usedBytes: UInt64        // Used space
    
    // Computed properties
    var usagePercentage: Double {
        Double(usedBytes) / Double(totalBytes) * 100.0
    }
    
    var usedGigabytes: Double {
        Double(usedBytes) / 1_073_741_824.0
    }
    
    var totalGigabytes: Double {
        Double(totalBytes) / 1_073_741_824.0
    }
    
    var freeGigabytes: Double {
        Double(freeBytes) / 1_073_741_824.0
    }
}
```

**Validation Rules**:
- `usedBytes` + `freeBytes` = `totalBytes`
- All byte values ≥ 0
- `totalBytes` > 0
- `volumePath` must be a valid absolute path
- `volumeName` must not be empty

**Display Format**:
- Primary: `"Disk: XX%"` or `"Disk: X.X/X.X GB"`
- Detailed: `"[VolumeName]: X.X GB free of X.X GB (XX% used)"`

---

### 5. NetworkMetrics
Network transfer rate information.

**Properties**:
```swift
struct NetworkMetrics {
    let uploadBytesPerSecond: UInt64    // Current upload rate
    let downloadBytesPerSecond: UInt64  // Current download rate
    let totalUploadBytes: UInt64        // Cumulative since app start
    let totalDownloadBytes: UInt64      // Cumulative since app start
    
    // Computed properties
    var uploadFormatted: String {
        formatBytesPerSecond(uploadBytesPerSecond)
    }
    
    var downloadFormatted: String {
        formatBytesPerSecond(downloadBytesPerSecond)
    }
    
    private func formatBytesPerSecond(_ bytes: UInt64) -> String {
        let megabytes = Double(bytes) / 1_048_576.0  // 1024^2
        if megabytes >= 1.0 {
            return String(format: "%.1f MB/s", megabytes)
        } else {
            let kilobytes = Double(bytes) / 1024.0
            return String(format: "%.0f KB/s", kilobytes)
        }
    }
}
```

**Validation Rules**:
- All byte values ≥ 0
- Rate values are instantaneous (per-second)
- Total values accumulate monotonically

**Display Format**:
- Primary: `"↑ XX KB/s ↓ XX KB/s"` or `"↑ X.X MB/s ↓ X.X MB/s"`
- Auto-adapt: Use MB/s when ≥ 1.0 MB/s, otherwise KB/s
- Detailed: Include total transferred

**Special Cases**:
- Network disconnected: Display `"--"` or `"0 KB/s"`

---

## Configuration Entity

### 6. AppSettings
User configuration and preferences.

**Properties**:
```swift
struct AppSettings: Codable {
    // Display preferences
    var showCPU: Bool = true
    var showMemory: Bool = true
    var showDisk: Bool = false
    var showNetwork: Bool = false
    
    // Monitoring configuration
    var refreshInterval: TimeInterval = 2.0  // seconds
    var selectedDiskPath: String = "/"
    
    // Launch configuration
    var launchAtLogin: Bool = false
    
    // Display format preferences
    var useCompactMode: Bool = true
}
```

**Validation Rules**:
- `refreshInterval`: 1.0 ≤ value ≤ 5.0
- `selectedDiskPath`: Must be a valid, mounted volume path
- At least one of `showCPU`, `showMemory`, `showDisk`, `showNetwork` must be true

**Default Values**:
- CPU and Memory shown by default
- 2-second refresh interval
- System disk ("/") selected
- Auto-launch disabled
- Compact mode enabled

**Persistence**:
- Stored in `UserDefaults.standard`
- Key: `"com.menubar.status.settings"`
- Format: JSON encoded via Codable

**State Transitions**:
```
Initial State (First Launch)
  ↓
Load from UserDefaults
  ↓ (if not found)
Apply Default Values
  ↓
User Modifies Settings
  ↓
Validate Settings
  ↓ (if valid)
Save to UserDefaults
  ↓
Apply to Monitoring Service
```

---

## View Models

### 7. MenuBarViewModel
ObservableObject for menubar display state.

**Properties**:
```swift
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var currentMetrics: SystemMetrics?
    @Published var settings: AppSettings
    @Published var isMonitoring: Bool = false
    @Published var errorMessage: String?
    
    // Computed display strings
    var displayText: String {
        // Generate menubar text based on settings and current metrics
    }
    
    var detailsText: String {
        // Generate dropdown details based on current metrics
    }
}
```

**Responsibilities**:
- Aggregate current metrics for display
- Format metrics according to settings
- Manage monitoring state
- Handle errors and display them to user

**Update Pattern**:
- Receives updates from `SystemMonitor` via Combine
- Publishes changes to SwiftUI views
- Updates occur on main thread (@MainActor)

---

### 8. SettingsViewModel
ObservableObject for settings window state.

**Properties**:
```swift
@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var availableDisks: [DiskInfo]
    @Published var isSaving: Bool = false
    @Published var saveError: String?
    
    func saveSettings() async throws
    func resetToDefaults()
    func testMonitoring() async throws
}
```

**Responsibilities**:
- Manage settings form state
- Validate user input
- Save settings to UserDefaults
- Discover available disks
- Apply settings to monitoring service

---

## Relationships

```
SystemMetrics
  ├── CPUMetrics
  ├── MemoryMetrics
  ├── DiskMetrics
  └── NetworkMetrics

AppSettings ←→ MenuBarViewModel
           ←→ SettingsViewModel
           ←→ SystemMonitor

MenuBarViewModel ←── SystemMonitor (publishes SystemMetrics)
```

---

## Data Flow

```
1. User launches app
   ↓
2. AppSettings loaded from UserDefaults (or defaults applied)
   ↓
3. SystemMonitor initialized with AppSettings
   ↓
4. Timer starts (interval from AppSettings.refreshInterval)
   ↓
5. Every interval:
   - CPUMonitor.getCurrentMetrics() → CPUMetrics
   - MemoryMonitor.getCurrentMetrics() → MemoryMetrics
   - DiskMonitor.getCurrentMetrics(path) → DiskMetrics
   - NetworkMonitor.getCurrentMetrics() → NetworkMetrics
   ↓
6. Aggregate into SystemMetrics with timestamp
   ↓
7. Publish to MenuBarViewModel
   ↓
8. MenuBarViewModel formats for display
   ↓
9. SwiftUI view updates menubar

Settings Changes:
   User modifies settings
   ↓
   SettingsViewModel validates
   ↓
   Save to UserDefaults
   ↓
   Notify SystemMonitor
   ↓
   SystemMonitor adjusts (refresh interval, monitored metrics, etc.)
```

---

## Performance Considerations

### Memory Optimization
- **Value types**: All metrics are structs (stack allocation)
- **No retain cycles**: Weak references where needed
- **Minimal caching**: Only cache formatted strings temporarily
- **Target**: <50MB total memory footprint

### CPU Optimization
- **Lazy computation**: Computed properties only when accessed
- **String formatting**: Minimize allocations, reuse formatters
- **Background processing**: Metric collection on background queue
- **Target**: <2% average CPU usage

### Threading Model
- **Metric collection**: Background queue (`.utility` QoS)
- **ViewModel updates**: Main thread (@MainActor)
- **Timer**: Dispatch source timer for precision
- **No locks**: Value types ensure thread safety

---

## Validation Summary

| Entity | Validation Rules |
|--------|-----------------|
| CPUMetrics | Values 0-100%, sum checks |
| MemoryMetrics | Bytes non-negative, used ≤ total |
| DiskMetrics | Bytes non-negative, used + free = total |
| NetworkMetrics | Bytes non-negative, monotonic totals |
| AppSettings | Interval 1-5s, valid disk path, ≥1 metric shown |

---

## Testing Strategy

### Unit Tests
- Validate each struct initializer with edge cases
- Test computed properties (percentages, formatted values)
- Test validation rules (reject invalid data)
- Test Codable conformance (encode/decode AppSettings)

### Integration Tests
- Test complete data flow (monitors → metrics → viewmodel → view)
- Test settings persistence (save → quit → reload)
- Test settings changes (modify → apply → verify effect)

### Performance Tests
- Measure memory footprint of metrics collection
- Benchmark string formatting performance
- Verify <50MB memory, <2% CPU targets

---

**Status**: ✅ Data model design complete and ready for implementation





