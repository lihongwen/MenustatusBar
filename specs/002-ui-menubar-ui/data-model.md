# Data Model: Modern UI & Menubar Enhancement

**Feature**: 002-ui-menubar-ui  
**Date**: 2025-10-02  
**Status**: Complete

## Overview

This document defines all data models, enums, and data structures needed for the modern UI enhancement feature. Models follow Swift naming conventions and support Codable for persistence where applicable.

---

## 1. Process Monitoring Models

### ProcessInfo

Represents a running system process with resource usage information.

```swift
struct ProcessInfo: Identifiable {
    // Identity
    let id: Int              // Process ID (PID)
    let name: String         // Process name
    let bundleIdentifier: String?  // App bundle ID (if available)
    
    // Resource Usage
    let cpuUsage: Double     // CPU usage percentage (0-100)
    let memoryUsage: UInt64  // Memory usage in bytes
    
    // UI Properties
    let icon: NSImage?       // App icon (nil if unavailable)
    
    // Computed Properties
    var isTerminable: Bool {
        // System-critical processes cannot be terminated
        ProcessMonitor.isSystemCritical(pid: id) == false
    }
    
    var formattedMemory: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
    }
}
```

**Relationships**:
- Referenced by `ProcessListViewModel`
- Created by `ProcessMonitor` service
- Displayed in `ProcessRowView`

**Validation Rules**:
- `id` must be > 0
- `cpuUsage` must be 0-100 (clamped)
- `name` must not be empty
- `memoryUsage` must be >= 0

---

### ProcessSortCriteria

Enum defining how to sort process lists.

```swift
enum ProcessSortCriteria: String, Codable, CaseIterable {
    case cpu = "cpu"
    case memory = "memory"
    
    var displayName: String {
        switch self {
        case .cpu: return "CPU Usage"
        case .memory: return "Memory Usage"
        }
    }
}
```

**Usage**: User preference stored in `AppSettings`

---

## 2. Disk Health Models

### DiskHealthInfo

Represents S.M.A.R.T. health information for a disk volume.

```swift
struct DiskHealthInfo: Identifiable {
    // Identity
    let id: String           // Volume path (e.g., "/", "/Volumes/External")
    let volumeName: String   // User-friendly name
    let bsdName: String      // BSD device name (e.g., "disk0s1")
    
    // Health Status
    let status: HealthStatus
    
    // S.M.A.R.T. Attributes (optional - may be unavailable)
    let powerOnHours: Int?
    let temperature: Int?        // Celsius
    let readErrorCount: Int?
    let writeErrorCount: Int?
    let reallocatedSectorCount: Int?
    
    // Computed Properties
    var healthColor: Color {
        switch status {
        case .good: return .green
        case .warning: return .yellow
        case .critical: return .red
        case .unavailable: return .gray
        }
    }
    
    var healthIcon: String {
        switch status {
        case .good: return "checkmark.shield.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.shield.fill"
        case .unavailable: return "questionmark.circle.fill"
        }
    }
    
    var formattedPowerOnTime: String? {
        guard let hours = powerOnHours else { return nil }
        let days = hours / 24
        return "\(days) days"
    }
}
```

**Relationships**:
- One per mounted volume
- Created by `DiskHealthMonitor` service
- Displayed in `MetricCard` for each disk

**Validation Rules**:
- `id` must be valid file system path
- `volumeName` must not be empty
- Numeric values must be >= 0 when present

---

### HealthStatus

Enum representing overall disk health condition.

```swift
enum HealthStatus: String, Codable {
    case good        // No issues detected
    case warning     // Minor issues, monitor closely
    case critical    // Failure imminent, back up immediately
    case unavailable // S.M.A.R.T. data not accessible
    
    var displayName: String {
        switch self {
        case .good: return "Good"
        case .warning: return "Warning"
        case .critical: return "Critical"
        case .unavailable: return "N/A"
        }
    }
    
    var description: String {
        switch self {
        case .good:
            return "Disk is healthy"
        case .warning:
            return "Minor issues detected"
        case .critical:
            return "Backup your data immediately"
        case .unavailable:
            return "Health data unavailable"
        }
    }
}
```

**Determination Logic**:
```swift
static func determineStatus(
    smartStatus: String?,
    readErrors: Int,
    writeErrors: Int,
    reallocatedSectors: Int
) -> HealthStatus {
    guard smartStatus != nil else { return .unavailable }
    
    if smartStatus == "Failing" || reallocatedSectors > 50 {
        return .critical
    } else if readErrors > 10 || writeErrors > 10 || reallocatedSectors > 10 {
        return .warning
    } else {
        return .good
    }
}
```

---

## 3. Historical Data Models

### HistoricalDataPoint

Represents a single data point in time-series history for sparkline charts.

```swift
struct HistoricalDataPoint: Identifiable {
    let id: UUID = UUID()
    let timestamp: Date
    let metricType: MetricType
    let value: Double
    
    // Computed for Chart framework
    var timeOffset: TimeInterval {
        timestamp.timeIntervalSinceNow
    }
}
```

**Relationships**:
- Stored in `HistoricalDataManager` circular buffers
- Consumed by `SparklineChart` views
- One buffer per `MetricType`

**Retention Policy**:
- Maximum 60 points per metric type
- Points older than 60 seconds automatically dropped
- Cleared on app restart (no persistence)

**Validation Rules**:
- `value` must be >= 0
- `timestamp` must not be in the future

---

### MetricType

Enum identifying different system metrics that can have historical data.

```swift
enum MetricType: String, Codable, CaseIterable {
    case cpu = "cpu"
    case memory = "memory"
    case disk = "disk"
    case network = "network"
    
    var displayName: String {
        switch self {
        case .cpu: return "CPU"
        case .memory: return "Memory"
        case .disk: return "Disk"
        case .network: return "Network"
        }
    }
    
    var icon: String {
        switch self {
        case .cpu: return "cpu.fill"
        case .memory: return "memorychip.fill"
        case .disk: return "internaldrive.fill"
        case .network: return "network"
        }
    }
}
```

---

## 4. Display Configuration Models

### DisplayConfiguration

User preferences for how metrics are displayed in the menubar.

```swift
struct DisplayConfiguration: Codable {
    // Display Mode
    var displayMode: DisplayMode
    
    // Ordering (array of metric identifiers)
    var metricOrder: [String]  // Serialized MetricType.rawValue
    
    // Auto-hide Settings
    var autoHideEnabled: Bool
    var autoHideThreshold: Double  // 0.0-1.0 (e.g., 0.5 = 50%)
    
    // Color Theme
    var colorThemeIdentifier: String
    
    // Process Display
    var showTopProcesses: Bool
    var processSortCriteria: ProcessSortCriteria
    
    // Validation
    init(
        displayMode: DisplayMode = .iconAndValue,
        metricOrder: [String] = MetricType.allCases.map { $0.rawValue },
        autoHideEnabled: Bool = false,
        autoHideThreshold: Double = 0.5,
        colorThemeIdentifier: String = "system",
        showTopProcesses: Bool = false,
        processSortCriteria: ProcessSortCriteria = .cpu
    ) {
        self.displayMode = displayMode
        self.metricOrder = metricOrder
        self.autoHideEnabled = autoHideEnabled
        self.autoHideThreshold = max(0.0, min(1.0, autoHideThreshold))
        self.colorThemeIdentifier = colorThemeIdentifier
        self.showTopProcesses = showTopProcesses
        self.processSortCriteria = processSortCriteria
    }
    
    // Computed
    var orderedMetrics: [MetricType] {
        metricOrder.compactMap { MetricType(rawValue: $0) }
    }
}
```

**Storage**: Embedded in `AppSettings`, persisted via UserDefaults

**Validation Rules**:
- `autoHideThreshold` clamped to 0.0-1.0
- `metricOrder` must contain valid MetricType values
- `colorThemeIdentifier` must reference registered theme

---

### DisplayMode

Enum defining how metrics appear in the menubar.

```swift
enum DisplayMode: String, Codable, CaseIterable {
    case iconAndValue = "iconAndValue"  // Icon + numeric value
    case compactText = "compactText"    // Abbreviated text
    case graphMode = "graphMode"        // Tiny sparkline
    case iconsOnly = "iconsOnly"        // Just colored icons
    
    var displayName: String {
        switch self {
        case .iconAndValue: return "Icon + Value"
        case .compactText: return "Compact Text"
        case .graphMode: return "Graph Mode"
        case .iconsOnly: return "Icons Only"
        }
    }
    
    var description: String {
        switch self {
        case .iconAndValue:
            return "Show SF Symbol icon followed by percentage"
        case .compactText:
            return "Show abbreviated text (e.g., 'CPU 45%')"
        case .graphMode:
            return "Show tiny inline sparkline chart"
        case .iconsOnly:
            return "Show only colored icons (hover for details)"
        }
    }
    
    var estimatedWidth: CGFloat {
        switch self {
        case .iconAndValue: return 60
        case .compactText: return 70
        case .graphMode: return 40
        case .iconsOnly: return 20
        }
    }
}
```

---

## 5. Memory Management Models

### MemoryPurgeResult

Result of a memory purge operation.

```swift
struct MemoryPurgeResult {
    let timestamp: Date
    let beforeUsage: UInt64   // Bytes used before purge
    let afterUsage: UInt64    // Bytes used after purge
    let freedBytes: UInt64    // Amount freed
    
    // Computed
    var formattedFreed: String {
        ByteCountFormatter.string(fromByteCount: Int64(freedBytes), countStyle: .memory)
    }
    
    var percentageFreed: Double {
        guard beforeUsage > 0 else { return 0 }
        return Double(freedBytes) / Double(beforeUsage) * 100
    }
    
    var wasSuccessful: Bool {
        freedBytes > 0
    }
}
```

**Usage**: Returned by `MemoryMonitor.purgeInactiveMemory()`, displayed in success alert

---

## 6. Color Theme Models

### ColorTheme Protocol

Defines interface for color themes.

```swift
protocol ColorTheme {
    var identifier: String { get }
    var displayName: String { get }
    
    // Metric Status Colors
    var healthyColor: Color { get }
    var warningColor: Color { get }
    var criticalColor: Color { get }
    
    // UI Colors
    var backgroundColor: Color { get }
    var cardBackground: Color { get }
    var accentColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    // Gradient Support
    func gradient(for percentage: Double) -> LinearGradient
}
```

**Implementations**:

```swift
struct SystemDefaultTheme: ColorTheme {
    let identifier = "system"
    let displayName = "System Default"
    
    var healthyColor: Color { .green }
    var warningColor: Color { .yellow }
    var criticalColor: Color { .red }
    var accentColor: Color { .accentColor }
    // ... etc
}

struct MonochromeTheme: ColorTheme {
    let identifier = "monochrome"
    let displayName = "Monochrome"
    
    var healthyColor: Color { Color.gray.opacity(0.5) }
    var warningColor: Color { Color.gray.opacity(0.7) }
    var criticalColor: Color { Color.gray }
    // ... etc
}

struct TrafficLightTheme: ColorTheme {
    let identifier = "traffic"
    let displayName = "Traffic Light"
    
    var healthyColor: Color { Color(red: 0, green: 0.8, blue: 0) }
    var warningColor: Color { Color(red: 1, green: 0.8, blue: 0) }
    var criticalColor: Color { Color(red: 1, green: 0, blue: 0) }
    // ... etc
}

// Similar for CoolTheme, WarmTheme
```

---

## 7. Enhanced Existing Models

### AppSettings (Enhanced)

Extend existing `AppSettings` with new properties:

```swift
struct AppSettings: Codable {
    // EXISTING PROPERTIES (keep as-is)
    private var _showCPU: Bool
    private var _showMemory: Bool
    private var _showDisk: Bool
    private var _showNetwork: Bool
    private var _refreshInterval: TimeInterval
    private var _selectedDiskPath: String
    var diskDisplayMode: DiskDisplayMode
    var launchAtLogin: Bool
    var useCompactMode: Bool
    
    // NEW PROPERTIES
    var displayConfiguration: DisplayConfiguration
    
    // Computed accessors (existing)
    var showCPU: Bool { get set }
    var showMemory: Bool { get set }
    var showDisk: Bool { get set }
    var showNetwork: Bool { get set }
    var refreshInterval: TimeInterval { get set }
    var selectedDiskPath: String { get set }
    
    // NEW: Default initializer includes new fields
    init(/* ... existing params ...*/, displayConfiguration: DisplayConfiguration = DisplayConfiguration()) {
        // ... existing initialization ...
        self.displayConfiguration = displayConfiguration
    }
}
```

---

### DiskMetrics (Enhanced)

Extend existing `DiskMetrics` with health information:

```swift
struct DiskMetrics {
    // EXISTING PROPERTIES
    let volumePath: String
    let volumeName: String
    let totalBytes: UInt64
    let usedBytes: UInt64
    let freeBytes: UInt64
    let readBytesPerSecond: UInt64
    let writeBytesPerSecond: UInt64
    
    // NEW PROPERTIES
    let healthInfo: DiskHealthInfo?  // Optional - may be unavailable
    
    // Computed properties (existing)
    var usagePercentage: Double { /* ... */ }
    var readSpeedFormatted: String { /* ... */ }
    var writeSpeedFormatted: String { /* ... */ }
}
```

---

## 8. UI State Models

### CardExpansionState

Tracks which metric cards are expanded in the dropdown.

```swift
class CardExpansionState: ObservableObject {
    @Published var expandedCards: Set<MetricType> = []
    
    func toggle(_ metric: MetricType) {
        if expandedCards.contains(metric) {
            expandedCards.remove(metric)
        } else {
            expandedCards.insert(metric)
        }
    }
    
    func isExpanded(_ metric: MetricType) -> Bool {
        expandedCards.contains(metric)
    }
}
```

**Usage**: Shared state in `MenuBarView` for expandable cards

---

## 9. Data Relationships Diagram

```
AppSettings
├── displayConfiguration: DisplayConfiguration
│   ├── displayMode: DisplayMode
│   ├── metricOrder: [MetricType]
│   ├── colorThemeIdentifier: String → ColorTheme
│   └── processSortCriteria: ProcessSortCriteria
│
└── (existing properties...)

SystemMetrics
├── cpu: CPUMetrics
├── memory: MemoryMetrics
├── disk: DiskMetrics
│   └── healthInfo?: DiskHealthInfo
│       └── status: HealthStatus
├── network: NetworkMetrics
└── timestamp: Date

HistoricalDataManager
├── [MetricType.cpu]: CircularBuffer<HistoricalDataPoint>
├── [MetricType.memory]: CircularBuffer<HistoricalDataPoint>
├── [MetricType.disk]: CircularBuffer<HistoricalDataPoint>
└── [MetricType.network]: CircularBuffer<HistoricalDataPoint>

ProcessMonitor
└── topProcesses: [ProcessInfo]
    ├── id (PID)
    ├── cpuUsage
    └── memoryUsage
```

---

## 10. State Transitions

### DiskHealthInfo State Machine

```
[Initial] → Unavailable  (if SMART not supported)
[Initial] → Good         (if SMART ok, no errors)

Good → Warning           (if errors increase 0→10)
Warning → Good           (if errors decrease or reset)
Warning → Critical       (if errors > 50 or SMART failing)
Critical → Warning       (rare - if errors decrease)

Any → Unavailable        (if disk unmounted or SMART access fails)
```

### CardExpansionState Transitions

```
Collapsed → Expanded     (user clicks card)
Expanded → Collapsed     (user clicks card again)
Expanded → Collapsed     (user clicks different card, if single-expansion mode)
```

---

## 11. Validation Summary

| Model | Key Validations |
|-------|----------------|
| ProcessInfo | PID > 0, CPU 0-100, memory >= 0 |
| DiskHealthInfo | Valid path, name not empty |
| HistoricalDataPoint | Value >= 0, timestamp not future |
| DisplayConfiguration | Threshold 0-1, valid metric order |
| MemoryPurgeResult | beforeUsage >= afterUsage |
| AppSettings | At least one metric enabled |

---

## 12. Persistence Strategy

| Model | Persistence Method | Lifetime |
|-------|--------------------|----------|
| AppSettings | UserDefaults (JSON) | Permanent |
| DisplayConfiguration | Embedded in AppSettings | Permanent |
| ProcessInfo | None (ephemeral) | Refresh cycle |
| DiskHealthInfo | None (ephemeral) | Refresh cycle |
| HistoricalDataPoint | In-memory buffer | 60 seconds |
| MemoryPurgeResult | None (ephemeral) | Operation only |
| CardExpansionState | None (session only) | App lifetime |

---

**Status**: ✅ All data models defined  
**Next**: Generate service protocol contracts


