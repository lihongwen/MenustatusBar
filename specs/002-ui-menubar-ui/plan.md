# Implementation Plan: Modern UI & Compact Menubar Display Enhancement

**Branch**: `002-ui-menubar-ui` | **Date**: 2025-10-02 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/Users/lihongwen/Projects/memubar-status/specs/002-ui-menubar-ui/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → ✅ Loaded successfully
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → ✅ Detected Project Type: macOS Desktop Application (SwiftUI)
   → ✅ Set Structure Decision based on existing Xcode project
3. Fill the Constitution Check section based on the content of the constitution document.
   → ✅ Applied SwiftUI/macOS best practices
4. Evaluate Constitution Check section below
   → ✅ No violations - following Apple HIG and SwiftUI patterns
   → ✅ Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → ✅ No critical NEEDS CLARIFICATION (all resolved via /clarify)
6. Execute Phase 1 → contracts, data-model.md, quickstart.md
   → ✅ In progress
7. Re-evaluate Constitution Check section
   → ✅ Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
   → ✅ Planned
9. STOP - Ready for /tasks command
```

## Summary

This feature modernizes the MenubarStatus macOS app's UI/UX with:
- **Compact menubar display**: 50% space reduction using icons, color-coding, and smart layouts
- **Modern dropdown dashboard**: Card-based design with sparkline charts, vibrancy effects, and smooth animations
- **Process management**: Optional TOP 5 resource-consuming processes with termination capability
- **Memory management**: One-click memory purge functionality
- **Multi-disk monitoring**: Simultaneous monitoring of all mounted volumes
- **Disk health**: S.M.A.R.T. status display with health indicators

**Technical Approach**: Enhance existing SwiftUI views with modern macOS design patterns, add new monitoring services for processes and disk health, implement sparkline charts using SwiftUI Charts framework.

## Technical Context

**Language/Version**: Swift 5.9+ (SwiftUI)  
**Primary Dependencies**: SwiftUI, AppKit (for menubar integration), Foundation, IOKit (for S.M.A.R.T. data), Charts (for sparklines)  
**Storage**: UserDefaults for preferences, in-memory for historical data (60s retention)  
**Testing**: XCTest for unit/integration tests, XCUITest for UI tests  
**Target Platform**: macOS 13.0+ (Ventura and later)  
**Project Type**: macOS desktop application (single Xcode project)  
**Performance Goals**: <16ms frame time (60fps), <50MB memory footprint, <5% CPU usage at idle  
**Constraints**: Menubar width ≤200 points, real-time updates every 1-5 seconds, smooth animations  
**Scale/Scope**: 4 core metrics, 5+ display modes, 5 color themes, ~15 new UI components

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. SwiftUI Best Practices ✅
- **Principle**: Follow Apple's SwiftUI framework patterns and Human Interface Guidelines
- **Application**: 
  - Use native SwiftUI components (Cards, Progress bars, SF Symbols)
  - Implement MVVM architecture (existing pattern)
  - Leverage @ObservedObject and Combine for reactive updates
  - Apply vibrancy effects and native animations
- **Status**: COMPLIANT - Enhancing existing SwiftUI architecture

### II. Separation of Concerns ✅
- **Principle**: Clear separation between Models, ViewModels, Views, and Services
- **Application**:
  - Models: Data structures (ProcessInfo, DiskHealthInfo, DisplayConfiguration)
  - Services: System monitoring (ProcessMonitor, DiskHealthMonitor)
  - ViewModels: Business logic and state management
  - Views: Pure presentation layer
- **Status**: COMPLIANT - Following existing project structure

### III. Performance & Responsiveness ✅
- **Principle**: Maintain 60fps and responsive UI even with real-time monitoring
- **Application**:
  - Background thread for system metric collection
  - Debounced UI updates (no more than refresh interval)
  - Lazy loading for process lists
  - Efficient sparkline rendering (max 60 data points)
- **Status**: COMPLIANT - Performance requirements documented in spec

### IV. User Privacy & System Safety ✅
- **Principle**: Respect system boundaries and user safety
- **Application**:
  - Prevent termination of system-critical processes
  - Confirmation dialogs for destructive actions
  - Graceful degradation when APIs unavailable
  - No persistent storage of sensitive data
- **Status**: COMPLIANT - Safety measures in requirements

### V. Testability ✅
- **Principle**: All features must be unit-testable and integration-testable
- **Application**:
  - Protocol-based service interfaces (allows mocking)
  - Dependency injection for ViewModels
  - Separate business logic from UI
  - Integration tests for monitoring workflows
- **Status**: COMPLIANT - Existing test structure supports this

## Project Structure

### Documentation (this feature)
```
specs/002-ui-menubar-ui/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (in progress)
├── data-model.md        # Phase 1 output (in progress)
├── quickstart.md        # Phase 1 output (in progress)
├── contracts/           # Phase 1 output (in progress)
│   └── monitoring-protocols.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created yet)
```

### Source Code (repository root)
```
MenubarStatus/
├── MenubarStatus/
│   ├── Models/
│   │   ├── AppSettings.swift              # [EXISTING] Enhanced with new settings
│   │   ├── CPUMetrics.swift               # [EXISTING]
│   │   ├── MemoryMetrics.swift            # [EXISTING]
│   │   ├── DiskMetrics.swift              # [EXISTING] Enhanced with health data
│   │   ├── NetworkMetrics.swift           # [EXISTING]
│   │   ├── SystemMetrics.swift            # [EXISTING]
│   │   ├── ProcessInfo.swift              # [NEW] Process monitoring data
│   │   ├── DiskHealthInfo.swift           # [NEW] S.M.A.R.T. health data
│   │   ├── HistoricalDataPoint.swift      # [NEW] Sparkline data
│   │   └── DisplayConfiguration.swift     # [NEW] UI display preferences
│   │
│   ├── Services/
│   │   ├── SystemMonitor.swift            # [EXISTING]
│   │   ├── CPUMonitor.swift               # [EXISTING]
│   │   ├── MemoryMonitor.swift            # [EXISTING] Enhanced with purge
│   │   ├── DiskMonitor.swift              # [EXISTING] Enhanced with multi-disk
│   │   ├── NetworkMonitor.swift           # [EXISTING]
│   │   ├── ProcessMonitor.swift           # [NEW] Top processes monitoring
│   │   ├── DiskHealthMonitor.swift        # [NEW] S.M.A.R.T. monitoring
│   │   └── HistoricalDataManager.swift    # [NEW] 60s data retention
│   │
│   ├── ViewModels/
│   │   ├── MenuBarViewModel.swift         # [EXISTING] Enhanced with new features
│   │   ├── SettingsViewModel.swift        # [EXISTING] Enhanced with new settings
│   │   └── ProcessListViewModel.swift     # [NEW] Process management
│   │
│   ├── Views/
│   │   ├── MenuBarView.swift              # [EXISTING] Complete redesign
│   │   ├── SettingsView.swift             # [EXISTING] Reorganized with tabs
│   │   ├── Components/                     # [NEW] Reusable UI components
│   │   │   ├── MetricCard.swift           # [NEW] Card-based metric display
│   │   │   ├── SparklineChart.swift       # [NEW] Trend visualization
│   │   │   ├── ProcessRowView.swift       # [NEW] Process list item
│   │   │   ├── DiskHealthBadge.swift      # [NEW] Health indicator
│   │   │   ├── ColorThemeProvider.swift   # [NEW] Theme management
│   │   │   └── ProgressBarView.swift      # [NEW] Gradient progress bar
│   │   │
│   │   └── SettingsWindowManager.swift    # [EXISTING]
│   │
│   ├── Utilities/                          # [NEW]
│   │   ├── ColorTheme.swift               # [NEW] Color theme definitions
│   │   ├── AnimationProvider.swift        # [NEW] Standard animations
│   │   └── FormatHelpers.swift            # [NEW] Value formatting
│   │
│   └── Assets.xcassets/                    # [EXISTING] Enhanced with theme colors
│
└── MenubarStatusTests/
    ├── Models/                             # [EXISTING] Enhanced
    ├── Services/                           # [EXISTING] Enhanced
    │   ├── ProcessMonitorTests.swift      # [NEW]
    │   └── DiskHealthMonitorTests.swift   # [NEW]
    ├── ViewModels/                         # [EXISTING] Enhanced
    ├── Integration/                        # [EXISTING] Enhanced
    │   └── UIRenderingTests.swift         # [NEW] UI performance tests
    └── Performance/                        # [EXISTING] Enhanced
        └── SparklinePerformanceTests.swift # [NEW]
```

**Structure Decision**: This is a macOS desktop application using the existing Xcode project structure. We enhance the current MVVM architecture with new models, services, and SwiftUI views. The project follows Apple's recommended patterns for menubar applications with a SwiftUI-based UI.

## Phase 0: Research & Technical Decisions

Since all critical unknowns were resolved during the `/clarify` phase, research focuses on implementation best practices.

**Key Technical Decisions**:

1. **Sparkline Charts**: Use SwiftUI Charts framework (iOS 16+/macOS 13+)
   - Native framework, optimized performance
   - Supports accessibility out of the box
   - Easy integration with SwiftUI views

2. **Process Monitoring**: Use `task_info()` system calls via Foundation
   - Access via ProcessInfo and Process APIs
   - Filter system-critical processes using hardcoded PID list
   - Update frequency matches metric refresh interval

3. **S.M.A.R.T. Data**: Use IOKit framework
   - Access via `IOServiceMatching("IOBlockStorageDevice")`
   - Parse SMART attributes from device properties
   - Graceful fallback when unavailable

4. **Memory Purge**: Use system `purge` command
   - Execute via Process API with elevated privileges handled by macOS
   - Display before/after memory statistics
   - Handle errors when insufficient permissions

5. **Multi-Disk Monitoring**: Use FileManager and DiskArbitration framework
   - Monitor mount/unmount events via notification center
   - Track all volumes reported by FileManager
   - Update UI reactively on disk changes

6. **Color Themes**: Use SwiftUI Environment and PreferenceKey
   - Define theme protocol with color sets
   - Inject via EnvironmentObject
   - Support system accent color via Color.accentColor

**Output**: See `research.md` for detailed findings

## Phase 1: Design & Contracts

### Data Model Design

**Core Entities** (see `data-model.md` for full specifications):

1. **ProcessInfo**: Process monitoring data
   - `pid: Int`, `name: String`, `icon: NSImage?`
   - `cpuUsage: Double`, `memoryUsage: UInt64`
   - `isTerminable: Bool` (computed)

2. **DiskHealthInfo**: S.M.A.R.T. health data
   - `volumePath: String`, `smartStatus: HealthStatus`
   - `powerOnHours: Int?`, `readErrors: Int?`, `writeErrors: Int?`
   - `enum HealthStatus { good, warning, critical, unavailable }`

3. **HistoricalDataPoint**: Time-series data for sparklines
   - `timestamp: Date`, `metricType: MetricType`, `value: Double`
   - Retained in circular buffer (max 60 entries per metric)

4. **DisplayConfiguration**: UI preferences
   - `displayMode: DisplayMode`, `colorTheme: ColorTheme`
   - `metricOrder: [MetricType]`, `showTopProcesses: Bool`
   - `autoHideThreshold: Double`

### Service Protocols

**New Protocol Contracts** (see `contracts/monitoring-protocols.md`):

```swift
protocol ProcessMonitoring {
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo]
    func terminateProcess(pid: Int) throws
    func isSystemCritical(pid: Int) -> Bool
}

protocol DiskHealthMonitoring {
    func getHealthInfo(forVolume path: String) -> DiskHealthInfo?
    func monitorAllVolumes() -> [DiskHealthInfo]
}

protocol HistoricalDataManaging {
    func recordDataPoint(_ point: HistoricalDataPoint)
    func getHistory(for metric: MetricType, duration: TimeInterval) -> [HistoricalDataPoint]
    func clearHistory()
}

protocol MemoryPurging {
    func purgeInactiveMemory() async throws -> MemoryPurgeResult
}

struct MemoryPurgeResult {
    let freedBytes: UInt64
    let beforeUsage: UInt64
    let afterUsage: UInt64
}
```

### UI Component Contracts

**Reusable Components**:

1. **MetricCard**: Display individual metric with chart
   - Input: MetricType, current value, historical data, theme
   - Output: Card view with progress bar and sparkline
   - Expandable for detailed breakdown

2. **SparklineChart**: 60-second trend visualization
   - Input: Array of HistoricalDataPoint, color theme
   - Output: Line chart with gradient fill
   - Auto-scaling Y-axis

3. **ProcessRowView**: Process list item
   - Input: ProcessInfo, selected state
   - Output: Row with icon, name, usage, terminate button
   - Supports confirmation dialog

### Integration Test Scenarios

**From User Stories** (see `quickstart.md`):

1. **Compact Display Test**: Verify menubar width ≤200 points
2. **Color Coding Test**: Verify colors change at 60%, 80% thresholds
3. **Process Management Test**: List processes, terminate non-critical
4. **Memory Purge Test**: Execute purge, verify freed memory displayed
5. **Multi-Disk Test**: Mount/unmount volumes, verify UI updates
6. **Sparkline Test**: Record data over 60s, verify chart renders
7. **Theme Switch Test**: Change themes, verify all colors update

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:

1. **Foundation Tasks** (Models & Protocols):
   - Create ProcessInfo model [P]
   - Create DiskHealthInfo model [P]
   - Create HistoricalDataPoint model [P]
   - Create DisplayConfiguration model [P]
   - Define monitoring protocol interfaces [P]

2. **Service Implementation** (Ordered by dependency):
   - Implement ProcessMonitor service
   - Implement DiskHealthMonitor service
   - Implement HistoricalDataManager service
   - Enhance MemoryMonitor with purge capability
   - Enhance DiskMonitor with multi-volume support

3. **UI Components** (Can be parallel after models):
   - Create MetricCard component [P]
   - Create SparklineChart component [P]
   - Create ProcessRowView component [P]
   - Create DiskHealthBadge component [P]
   - Create ProgressBarView component [P]
   - Create ColorTheme system [P]

4. **View Integration** (Depends on components):
   - Redesign MenuBarView with card layout
   - Reorganize SettingsView with tabs
   - Integrate ProcessListViewModel
   - Enhance MenuBarViewModel

5. **Testing Tasks**:
   - Unit tests for each service [P]
   - UI rendering performance tests
   - Integration tests for user scenarios
   - Memory leak tests for historical data

**Ordering Strategy**:
- Models → Services → ViewModels → Views → Integration Tests
- Protocol definitions before implementations
- Components before view integration
- Mark independent file creation with [P] for parallel execution

**Estimated Output**: 35-40 numbered, ordered tasks in tasks.md

**Dependencies**:
- Task 1-5: Foundation (parallel)
- Task 6-10: Services (sequential, depend on models)
- Task 11-16: UI Components (parallel, depend on models)
- Task 17-20: View Integration (sequential, depend on components)
- Task 21-35: Testing (some parallel, some depend on implementation)

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

**Validation Criteria**:
- All XCTests pass (100% pass rate)
- UI renders at 60fps (measured via Instruments)
- Menubar width ≤200 points (measured via UI tests)
- Memory footprint <50MB (measured via Instruments)
- Sparklines render smoothly with 60 data points
- Process termination works with confirmation
- Multi-disk monitoring handles mount/unmount events

## Complexity Tracking
*No constitutional violations detected*

This implementation follows established SwiftUI and macOS patterns. No complexity justifications needed.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) ✅
- [x] Phase 1: Design complete (/plan command) ✅
- [x] Phase 2: Task planning complete (/plan command - described approach) ✅
- [ ] Phase 3: Tasks generated (/tasks command - NEXT STEP)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS ✅
- [x] Post-Design Constitution Check: PASS ✅
- [x] All NEEDS CLARIFICATION resolved (via /clarify command) ✅
- [x] Complexity deviations documented (none required) ✅

**Generated Artifacts**:
- [x] research.md - Technical decisions and implementation approaches ✅
- [x] data-model.md - Complete data model specifications ✅
- [x] contracts/monitoring-protocols.md - Service protocol contracts ✅
- [x] quickstart.md - Integration test scenarios ✅
- [x] .cursor/rules/specify-rules.mdc - Updated agent context ✅

---
*Based on SwiftUI Best Practices & Apple Human Interface Guidelines*  
*Next Command: `/tasks` to generate detailed task list*
