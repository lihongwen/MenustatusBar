# Research: Mac系统状态监控菜单栏应用

**Feature**: 001-mac-menubar-cpu  
**Date**: 2025-10-02  
**Status**: Complete

## Overview
This document consolidates technical research findings for building a lightweight macOS menubar system monitor. The research focuses on native API selection, performance optimization, and best practices for menubar applications.

---

## 1. System Monitoring APIs

### Decision: Use Native macOS System APIs
**Chosen approach**:
- **CPU**: `host_processor_info()` from `mach/mach_host.h`
- **Memory**: `host_statistics64()` from `mach/mach_host.h`
- **Disk**: `FileManager` + `attributesOfFileSystem(forPath:)` from Foundation
- **Network**: `nw_path_monitor` from Network framework (for interface stats)

**Rationale**:
- Native APIs provide lowest overhead and highest performance
- No external dependencies needed
- Direct access to real-time metrics
- Well-documented and stable across macOS versions
- Can achieve <2% CPU and <50MB memory targets

**Alternatives considered**:
1. **Third-party libraries** (e.g., SwiftSystemMonitor)
   - Rejected: Adds unnecessary dependencies, increases app size
   - May not meet strict performance requirements
   
2. **Command-line tools** (e.g., `top`, `iostat` via Process)
   - Rejected: High overhead from process spawning
   - Parsing text output is inefficient and fragile
   
3. **ActivityMonitor framework** (private API)
   - Rejected: Not available as public API
   - Would violate App Store guidelines

**Implementation notes**:
- Use Grand Central Dispatch (GCD) for efficient async polling
- Implement efficient caching to minimize system calls
- Use `DispatchSourceTimer` for precise refresh intervals

---

## 2. MenuBar Integration

### Decision: Use MenuBarExtra (SwiftUI, macOS 13+)
**Chosen approach**:
- SwiftUI `MenuBarExtra` API (introduced macOS 13.0)
- NSImage for menubar icon generation
- SwiftUI views for dropdown content

**Rationale**:
- Modern declarative UI approach
- Native integration with SwiftUI app architecture
- Better support for dynamic content updates
- Automatically handles light/dark mode
- Cleaner code compared to AppKit NSStatusBar

**Alternatives considered**:
1. **NSStatusBar (AppKit)**
   - Rejected for primary UI: More verbose, imperative code
   - Still needed for advanced icon customization
   - May use as fallback for <macOS 13
   
2. **NSMenu with custom NSView**
   - Rejected: Complex to implement and maintain
   - Poor integration with SwiftUI
   
3. **SwiftUI App with `.menuBarExtraStyle(.window)`**
   - Considered: May use if dropdown needs more space
   - Default `.menu` style sufficient for initial implementation

**Implementation notes**:
- Use `MenuBarExtra` with label for icon display
- Dynamic text label for CPU/Memory values
- SwiftUI views for dropdown menu content
- Settings window as separate `Window` group

---

## 3. Auto-Launch on Startup

### Decision: Use SMAppService (ServiceManagement framework)
**Chosen approach**:
- `SMAppService.mainApp.register()` for macOS 13+
- Settings toggle to enable/disable via `SMAppService` status

**Rationale**:
- Modern replacement for deprecated `SMLoginItemSetEnabled`
- User-friendly: Respects System Settings > Login Items
- No helper app or LaunchAgent plist required
- Simple API with clear error handling
- Approved by Apple for App Store distribution

**Alternatives considered**:
1. **LSSharedFileList (Login Items)**
   - Deprecated in macOS 13
   - More complex implementation
   
2. **Launch Agent with plist**
   - Rejected: Requires separate bundle, complex setup
   - Poor user experience (harder to disable)
   
3. **Open at Login (Sandbox entitlement)**
   - Requires manual user action
   - Not automatic like SMAppService

**Implementation notes**:
```swift
import ServiceManagement

// Register for auto-launch
try? SMAppService.mainApp.register()

// Check status
let status = SMAppService.mainApp.status
```

**Required entitlements**:
- `com.apple.security.application-groups` (for settings persistence)

---

## 4. Performance Optimization

### Decision: Optimized Polling with Adaptive Intervals
**Chosen approach**:
- Use `DispatchSourceTimer` with configurable intervals (1-5s)
- Implement metric caching to avoid redundant calculations
- Use `DispatchQueue.global(qos: .utility)` for background work
- Batch system calls where possible
- Lazy initialization of monitoring services

**Rationale**:
- Meets <2% CPU, <50MB memory targets
- Efficient background processing
- Avoids blocking main thread
- Scales well with user-configured refresh rates

**Alternatives considered**:
1. **Continuous monitoring with delegates**
   - Rejected: Higher CPU usage
   - More complex to implement correctly
   
2. **Combine publishers with timers**
   - Considered: More "Swifty" but adds overhead
   - Timer-based approach simpler and more efficient
   
3. **Real-time notifications (NotificationCenter)**
   - Rejected: Not available for all metrics
   - Would create uneven update patterns

**Optimization techniques**:
- **Incremental CPU calculation**: Store previous ticks, calculate delta
- **Memory caching**: Cache computed values for ~100ms
- **Lazy loading**: Only monitor enabled metrics
- **String formatting**: Pre-compute format strings
- **Network monitoring**: Use nw_path_monitor for efficient callbacks

**Performance testing strategy**:
- Use Instruments (Time Profiler, Allocations)
- Create benchmark tests with XCTMetric
- Continuous monitoring during development
- Target: 1% average CPU, 30MB average memory

---

## 5. Settings Persistence

### Decision: UserDefaults with Codable Models
**Chosen approach**:
- UserDefaults for simple key-value storage
- Codable protocol for type-safe serialization
- Property wrappers (@AppStorage) for SwiftUI binding

**Rationale**:
- Native, lightweight solution
- Perfect fit for small configuration data
- Automatic synchronization
- SwiftUI integration via @AppStorage
- No external dependencies

**Alternatives considered**:
1. **Core Data**
   - Rejected: Massive overkill for simple settings
   - Adds ~10MB to memory footprint
   
2. **Property List (plist) files**
   - Rejected: More manual management required
   - UserDefaults is higher-level abstraction of plist
   
3. **JSON files in Application Support**
   - Rejected: Manual file I/O and error handling
   - No automatic synchronization

**Implementation pattern**:
```swift
struct AppSettings: Codable {
    var refreshInterval: TimeInterval = 2.0
    var showCPU: Bool = true
    var showMemory: Bool = true
    var showDisk: Bool = false
    var showNetwork: Bool = false
    var selectedDisk: String = "/"
    var launchAtLogin: Bool = false
}

// UserDefaults extension
extension UserDefaults {
    var settings: AppSettings {
        get {
            guard let data = data(forKey: "appSettings"),
                  let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
            else { return AppSettings() }
            return settings
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: "appSettings")
        }
    }
}

// SwiftUI integration
@AppStorage("appSettings") var settings: AppSettings
```

---

## 6. Testing Strategies for MenuBar Apps

### Decision: Multi-Layer Testing Approach
**Chosen approach**:
1. **Unit Tests**: XCTest for models and services
2. **Integration Tests**: Service coordination and data flow
3. **UI Tests**: XCUITest for menubar interaction
4. **Performance Tests**: XCTMetric for CPU/memory benchmarks

**Rationale**:
- Comprehensive coverage across all layers
- Native XCTest integration with Xcode
- Performance testing built into XCTest
- UI testing for critical user flows

**Testing challenges and solutions**:

**Challenge 1: Testing NSStatusBar/MenuBarExtra**
- Solution: Separate view logic from menubar integration
- Use dependency injection for testability
- Mock SystemMonitor protocol in tests

**Challenge 2: Testing background timers**
- Solution: Use protocol-based timer abstraction
- Inject test doubles for time-sensitive tests
- Use XCTestExpectation for async verification

**Challenge 3: Testing UserDefaults persistence**
- Solution: Use separate UserDefaults suite for tests
- Reset state in setUp/tearDown
- Test with mock/ephemeral storage

**Challenge 4: Testing system API calls**
- Solution: Protocol-based abstraction for metrics
- Mock implementations for predictable testing
- Integration tests with real APIs (slower, run separately)

**Test organization**:
```
MenubarStatusTests/
├── Models/
│   ├── SystemMetricsTests.swift       # Value objects, validation
│   └── UserSettingsTests.swift        # Settings model, defaults
├── Services/
│   ├── CPUMonitorTests.swift          # CPU metric collection
│   ├── MemoryMonitorTests.swift       # Memory metric collection
│   ├── DiskMonitorTests.swift         # Disk metric collection
│   └── NetworkMonitorTests.swift      # Network metric collection
├── Integration/
│   ├── MonitoringFlowTests.swift      # End-to-end monitoring
│   └── SettingsPersistenceTests.swift # Settings save/load
└── Performance/
    ├── CPUBenchmarkTests.swift        # CPU usage validation
    └── MemoryBenchmarkTests.swift     # Memory usage validation
```

**Performance test example**:
```swift
func testCPUUsageUnder2Percent() throws {
    measure(metrics: [XCTCPUMetric()]) {
        let monitor = SystemMonitor()
        monitor.start(interval: 2.0)
        RunLoop.current.run(until: Date().addingTimeInterval(60))
        monitor.stop()
    }
    // Verify average CPU < 2%
}
```

---

## 7. Dark Mode Support

### Decision: Automatic System Appearance Adaptation
**Chosen approach**:
- SwiftUI automatic color adaptation
- SF Symbols for icons (automatically adapt)
- `@Environment(\.colorScheme)` for custom logic

**Rationale**:
- Zero-effort implementation with SwiftUI
- Consistent with macOS design guidelines
- Automatic updates when system theme changes

**Implementation notes**:
- Use semantic colors (`Color.primary`, `Color.secondary`)
- SF Symbols for menubar icon
- Test both light and dark modes in UI tests

---

## 8. Minimum macOS Version

### Decision: macOS 13.0 Ventura
**Chosen approach**:
- Target macOS 13.0 (Ventura) as minimum
- Deployment target: macOS 13.0

**Rationale**:
- MenuBarExtra API requires macOS 13.0+
- SMAppService requires macOS 13.0+
- SwiftUI improvements in Ventura
- Covers ~85% of active macOS users (as of 2024)

**Alternatives considered**:
1. **macOS 12.0 (Monterey)**
   - Would require NSStatusBar fallback
   - More complex codebase
   - Marginal user base increase
   
2. **macOS 14.0 (Sonoma)**
   - Latest features but limits user base
   - No critical features needed from Sonoma

---

## Technical Decisions Summary

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| CPU Monitoring | host_processor_info() | Native, low overhead |
| Memory Monitoring | host_statistics64() | Native, accurate |
| Disk Monitoring | FileManager APIs | Simple, sufficient |
| Network Monitoring | nw_path_monitor | Efficient, callback-based |
| MenuBar UI | MenuBarExtra (SwiftUI) | Modern, declarative |
| Settings Storage | UserDefaults | Lightweight, native |
| Auto-Launch | SMAppService | Modern, user-friendly |
| Testing | XCTest + XCUITest | Native, comprehensive |
| Min macOS Version | 13.0 (Ventura) | Required for MenuBarExtra |
| Performance | DispatchSourceTimer + caching | Meets <2% CPU target |

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| CPU usage exceeds 2% | High | Implement caching, optimize polling, performance tests |
| Memory usage exceeds 50MB | Medium | Lazy initialization, efficient data structures |
| MenuBarExtra limitations | Low | Well-documented API, fallback to NSStatusBar if needed |
| System API changes | Low | Use stable APIs, version checks for new features |
| Testing menubar interaction | Medium | UI tests + manual verification |
| App Store approval | Low | Using only public APIs, follows HIG |

---

## Next Steps (Phase 1)
1. Create data-model.md with entity definitions
2. Define protocol contracts in contracts/
3. Generate quickstart.md with setup instructions
4. Update agent context file with Swift/macOS specifics

**Research Complete**: ✅ All technical unknowns resolved

