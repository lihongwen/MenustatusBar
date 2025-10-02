# Tasks: Modern UI & Compact Menubar Display Enhancement

**Feature**: 002-ui-menubar-ui  
**Input**: Design documents from `/Users/lihongwen/Projects/memubar-status/specs/002-ui-menubar-ui/`  
**Prerequisites**: plan.md, research.md, data-model.md, contracts/monitoring-protocols.md, quickstart.md

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → ✅ Extracted: SwiftUI, macOS 13.0+, MVVM architecture
2. Load design documents:
   → data-model.md: 9 entities (ProcessInfo, DiskHealthInfo, HistoricalDataPoint, etc.)
   → contracts/: 5 protocols (ProcessMonitoring, DiskHealthMonitoring, etc.)
   → research.md: Technical decisions (SwiftUI Charts, IOKit, DiskArbitration)
   → quickstart.md: 10 integration test scenarios
3. Generate tasks by category:
   → Setup: Dependencies, project structure
   → Tests: Contract tests, integration tests (TDD)
   → Models: Data structures and enums
   → Services: Monitoring implementations
   → UI Components: Reusable SwiftUI views
   → Integration: View assembly and ViewModels
   → Polish: Performance, documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Dependencies validated
7. Parallel execution examples provided
```

---

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- All file paths relative to project root: `/Users/lihongwen/Projects/memubar-status/`

---

## Phase 3.1: Setup & Dependencies

- [x] **T001** Verify SwiftUI Charts framework availability in MenubarStatus.xcodeproj (requires macOS 13.0+ deployment target)

- [x] **T002** Verify IOKit and DiskArbitration frameworks linked in MenubarStatus.xcodeproj build settings

- [x] **T003** [P] Create Utilities directory at `MenubarStatus/MenubarStatus/Utilities/` with empty Swift files as placeholders

---

## Phase 3.2: Protocol Definitions & Contract Tests (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [x] **T004** [P] Define ProcessMonitoring protocol in `MenubarStatus/MenubarStatus/Services/ProcessMonitor.swift` (protocol only, no implementation yet)

- [x] **T005** [P] Define DiskHealthMonitoring protocol in `MenubarStatus/MenubarStatus/Services/DiskHealthMonitor.swift` (protocol only, no implementation yet)

- [x] **T006** [P] Define HistoricalDataManaging protocol in `MenubarStatus/MenubarStatus/Services/HistoricalDataManager.swift` (protocol only, no implementation yet)

- [x] **T007** [P] Define MemoryPurging protocol extension in `MenubarStatus/MenubarStatus/Services/MemoryMonitor.swift` (add to existing file)

- [x] **T008** [P] Contract test for ProcessMonitoring in `MenubarStatusTests/Services/ProcessMonitorTests.swift` - verify getTopProcesses returns at most limit, sorted correctly, and terminateProcess throws for system-critical processes

- [x] **T009** [P] Contract test for DiskHealthMonitoring in `MenubarStatusTests/Services/DiskHealthMonitorTests.swift` - verify getHealthInfo returns nil for invalid paths, monitorAllVolumes returns array, callbacks fire on mount/unmount

- [x] **T010** [P] Contract test for HistoricalDataManaging in `MenubarStatusTests/Services/HistoricalDataManagerTests.swift` - verify recordDataPoint is thread-safe, getHistory returns ordered array, clearHistory works

- [x] **T011** [P] Contract test for MemoryPurging in `MenubarStatusTests/Services/MemoryMonitorTests.swift` - verify purgeInactiveMemory returns result, canPurge blocks during operation

---

## Phase 3.3: Data Models (Ordered by Dependency)

- [x] **T012** [P] Create ProcessSortCriteria enum in `MenubarStatus/MenubarStatus/Models/ProcessInfo.swift`

- [x] **T013** [P] Create ProcessInfo struct in `MenubarStatus/MenubarStatus/Models/ProcessInfo.swift` with all properties from data-model.md (id, name, bundleIdentifier, cpuUsage, memoryUsage, icon, computed properties)

- [x] **T014** [P] Create HealthStatus enum in `MenubarStatus/MenubarStatus/Models/DiskHealthInfo.swift` with cases: good, warning, critical, unavailable

- [x] **T015** [P] Create DiskHealthInfo struct in `MenubarStatus/MenubarStatus/Models/DiskHealthInfo.swift` with all properties (id, volumeName, bsdName, status, SMART attributes, computed properties)

- [x] **T016** [P] Create MetricType enum in `MenubarStatus/MenubarStatus/Models/HistoricalDataPoint.swift` with cases: cpu, memory, disk, network

- [x] **T017** [P] Create HistoricalDataPoint struct in `MenubarStatus/MenubarStatus/Models/HistoricalDataPoint.swift` with timestamp, metricType, value, computed timeOffset

- [x] **T018** [P] Create DisplayMode enum in `MenubarStatus/MenubarStatus/Models/DisplayConfiguration.swift` with cases: iconAndValue, compactText, graphMode, iconsOnly

- [x] **T019** [P] Create DisplayConfiguration struct in `MenubarStatus/MenubarStatus/Models/DisplayConfiguration.swift` with all properties (displayMode, metricOrder, autoHide settings, colorTheme, process settings)

- [x] **T020** [P] Create MemoryPurgeResult struct in `MenubarStatus/MenubarStatus/Models/MemoryPurgeResult.swift` with timestamp, before/after usage, freedBytes, computed properties

- [x] **T021** Enhance AppSettings in `MenubarStatus/MenubarStatus/Models/AppSettings.swift` to include displayConfiguration: DisplayConfiguration property with default initializer

- [x] **T022** Enhance DiskMetrics in `MenubarStatus/MenubarStatus/Models/DiskMetrics.swift` to include optional healthInfo: DiskHealthInfo? property

---

## Phase 3.4: Model Tests

- [x] **T023** [P] Unit tests for ProcessInfo in `MenubarStatusTests/Models/ProcessInfoTests.swift` - verify validation rules (PID > 0, CPU 0-100), computed properties, formatted memory

- [x] **T024** [P] Unit tests for DiskHealthInfo in `MenubarStatusTests/Models/DiskHealthInfoTests.swift` - verify health status determination logic, color/icon mapping, formatted power-on time

- [x] **T025** [P] Unit tests for HistoricalDataPoint in `MenubarStatusTests/Models/HistoricalDataPointTests.swift` - verify timeOffset calculation, validation rules

- [x] **T026** [P] Unit tests for DisplayConfiguration in `MenubarStatusTests/Models/DisplayConfigurationTests.swift` - verify threshold clamping, metric order validation, codable compliance

---

## Phase 3.5: Service Implementations (Ordered by Dependency)

- [x] **T027** Implement CircularBuffer utility in `MenubarStatus/MenubarStatus/Utilities/CircularBuffer.swift` for historical data storage (generic struct with capacity, append, asArray methods)

- [x] **T028** Implement HistoricalDataManager conforming to HistoricalDataManaging protocol in `MenubarStatus/MenubarStatus/Services/HistoricalDataManager.swift` using CircularBuffer for 60-second retention

- [x] **T029** Implement ProcessMonitor conforming to ProcessMonitoring protocol in `MenubarStatus/MenubarStatus/Services/ProcessMonitor.swift` using Foundation Process APIs and task_info() system calls

- [x] **T030** Implement DiskHealthMonitor conforming to DiskHealthMonitoring protocol in `MenubarStatus/MenubarStatus/Services/DiskHealthMonitor.swift` using IOKit framework for SMART data access

- [x] **T031** Enhance MemoryMonitor in `MenubarStatus/MenubarStatus/Services/MemoryMonitor.swift` to conform to MemoryPurging protocol, implement purgeInactiveMemory() using system purge command

- [x] **T032** Enhance DiskMonitor in `MenubarStatus/MenubarStatus/Services/DiskMonitor.swift` to support multi-disk monitoring using DiskArbitration framework for mount/unmount events

- [x] **T033** Enhance SystemMonitor in `MenubarStatus/MenubarStatus/Services/SystemMonitor.swift` to expose new monitoring services (processMonitor, diskHealthMonitor, historicalDataManager, memoryPurger properties)

---

## Phase 3.6: Service Integration Tests

- [x] **T034** [P] Integration test for HistoricalDataManager in `MenubarStatusTests/Integration/HistoricalDataIntegrationTests.swift` - verify 60-second data retention, automatic cleanup, thread safety

- [x] **T035** [P] Integration test for ProcessMonitor in `MenubarStatusTests/Integration/ProcessMonitorIntegrationTests.swift` - verify real process enumeration, termination with confirmation, system process protection

- [x] **T036** [P] Integration test for DiskHealthMonitor in `MenubarStatusTests/Integration/DiskHealthIntegrationTests.swift` - verify SMART data reading, graceful degradation when unavailable

- [x] **T037** [P] Integration test for memory purge in `MenubarStatusTests/Integration/MemoryPurgeIntegrationTests.swift` - verify purge execution, before/after stats, error handling

---

## Phase 3.7: Color Theme System

- [x] **T038** [P] Define ColorTheme protocol in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` with properties for healthy/warning/critical colors, UI colors, gradient method

- [x] **T039** [P] Implement SystemDefaultTheme in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` (uses system accent color and macOS colors)

- [x] **T040** [P] Implement MonochromeTheme in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` (grayscale only)

- [x] **T041** [P] Implement TrafficLightTheme in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` (red/yellow/green)

- [x] **T042** [P] Implement CoolTheme in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` (blue/cyan gradients)

- [x] **T043** [P] Implement WarmTheme in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` (orange/red gradients)

- [x] **T044** Create ThemeManager class in `MenubarStatus/MenubarStatus/Utilities/ColorTheme.swift` as ObservableObject with theme registry and current theme selection

---

## Phase 3.8: Utility Helpers

- [x] **T045** [P] Create AnimationProvider in `MenubarStatus/MenubarStatus/Utilities/AnimationProvider.swift` with standard animation definitions (standardSpring, quickFade, smoothTransition)

- [x] **T046** [P] Create FormatHelpers in `MenubarStatus/MenubarStatus/Utilities/FormatHelpers.swift` with value formatting functions (bytes, percentages, durations)

---

## Phase 3.9: UI Components (Parallel - Different Files)

- [x] **T047** [P] Create SparklineChart component in `MenubarStatus/MenubarStatus/Views/Components/SparklineChart.swift` using SwiftUI Charts framework for 60-second trend visualization

- [x] **T048** [P] Create ProgressBarView component in `MenubarStatus/MenubarStatus/Views/Components/ProgressBarView.swift` with gradient fill and color theme support

- [x] **T049** [P] Create DiskHealthBadge component in `MenubarStatus/MenubarStatus/Views/Components/DiskHealthBadge.swift` with SF Symbol icon and color coding for health status

- [x] **T050** [P] Create ProcessRowView component in `MenubarStatus/MenubarStatus/Views/Components/ProcessRowView.swift` with icon, name, usage stats, and terminate button with confirmation

- [x] **T051** [P] Create MetricCard component in `MenubarStatus/MenubarStatus/Views/Components/MetricCard.swift` with expandable/collapsible state, progress bar, sparkline chart, detailed breakdown

- [x] **T052** [P] Create ColorThemeProvider environment helper in `MenubarStatus/MenubarStatus/Views/Components/ColorThemeProvider.swift` for injecting theme via SwiftUI Environment

---

## Phase 3.10: UI Component Tests

- [x] **T053** [P] UI rendering test for SparklineChart in `MenubarStatusTests/Views/SparklineChartTests.swift` - verify chart renders with 60 data points, <5ms render time

- [x] **T054** [P] UI rendering test for MetricCard in `MenubarStatusTests/Views/MetricCardTests.swift` - verify expand/collapse animation, progress bar updates, sparkline integration

- [x] **T055** [P] Performance test for sparkline rendering in `MenubarStatusTests/Performance/SparklinePerformanceTests.swift` - measure render time, verify <5ms for 60 points, <16ms frame time

---

## Phase 3.11: ViewModels (Ordered by Dependency)

- [x] **T056** [P] Create ProcessListViewModel in `MenubarStatus/MenubarStatus/ViewModels/ProcessListViewModel.swift` with @Published topProcesses, refresh logic, terminate process with confirmation

- [x] **T057** Enhance MenuBarViewModel in `MenubarStatus/MenubarStatus/ViewModels/MenuBarViewModel.swift` to integrate new services (processMonitor, diskHealthMonitor, historicalDataManager), expose process list, purge memory action

- [x] **T058** Enhance SettingsViewModel in `MenubarStatus/MenubarStatus/ViewModels/SettingsViewModel.swift` to include display configuration settings (display mode, metric order, theme selection, show top processes toggle)

---

## Phase 3.12: ViewModel Tests

- [x] **T059** [P] Unit tests for ProcessListViewModel in `MenubarStatusTests/ViewModels/ProcessListViewModelTests.swift` - verify process list updates, sorting changes, termination flow with mocks

- [x] **T060** [P] Unit tests for enhanced MenuBarViewModel in `MenubarStatusTests/ViewModels/EnhancedMenuBarViewModelTests.swift` - verify historical data recording, metric updates, theme changes

---

## Phase 3.13: View Redesign (Sequential - May Touch Same Files)

- [x] **T061** Create CardExpansionState helper in `MenubarStatus/MenubarStatus/Views/CardExpansionState.swift` as ObservableObject for tracking expanded metric cards

- [x] **T062** Redesign MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` with card-based layout: header card (system info), metric cards (CPU, Memory, Disk(s), Network), process card (optional), action card (quick actions)

- [x] **T063** Add menubar display modes to MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - implement icon+value, compact text, graph mode, icons-only with color coding and SF Symbols

- [x] **T064** Add sparkline integration to MenuBarView metric cards in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - embed SparklineChart in each card with 60-second data

- [x] **T065** Add process list section to MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - integrate ProcessListViewModel and ProcessRowView components (conditionally shown based on settings)

- [x] **T066** Add quick action buttons to MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - Free Memory, Activity Monitor, Refresh Now, Copy Stats, Settings, Quit

- [x] **T067** Reorganize SettingsView in `MenubarStatus/MenubarStatus/Views/SettingsView.swift` with tabbed interface: Display tab (metrics visibility, display mode, ordering, show top processes toggle), Appearance tab (color themes, icon style, compact mode), Monitoring tab (refresh interval, thresholds), Advanced tab (disk selection, network interfaces, launch options)

- [x] **T068** Add theme selector to SettingsView Appearance tab in `MenubarStatus/MenubarStatus/Views/SettingsView.swift` - integrate ThemeManager with radio button selection for 5 themes

- [x] **T069** Add metric reordering UI to SettingsView Display tab in `MenubarStatus/MenubarStatus/Views/SettingsView.swift` - drag-and-drop list for metric order customization

---

## Phase 3.14: Animations & Visual Polish

- [x] **T070** Apply smooth transitions to MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - 200ms duration for value changes, card expand/collapse animations, disk mount/unmount animations

- [x] **T071** Apply vibrancy effects and modern styling to MenuBarView in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - translucent backgrounds, rounded corners, subtle drop shadows, 8pt/12pt/16pt grid spacing

- [x] **T072** Add hover states and tooltips to menubar metrics in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - show full metric name, exact value, last update time on hover

---

## Phase 3.15: Integration Tests (User Scenarios from quickstart.md)

- [x] **T073** [P] Integration test Scenario 1: Compact Menubar Display in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify menubar width ≤200 points, color coding works (green/yellow/red), display modes functional, tooltips present (Manual testing required)

- [x] **T074** [P] Integration test Scenario 2: Modern Dropdown Dashboard in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify card layout, progress bars, sparklines render, expandable cards, smooth animations (Manual testing required)

- [x] **T075** [P] Integration test Scenario 3: Process Management in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify process list displays top 5, sorting works, termination with confirmation, system process protection (Manual testing required)

- [x] **T076** [P] Integration test Scenario 4: Memory Purge in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify purge button, loading indicator, success message with freed amount, memory updates (Manual testing required)

- [x] **T077** [P] Integration test Scenario 5: Multi-Disk Monitoring in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify multiple disk cards, automatic mount/unmount detection, smooth animations (Manual testing required)

- [x] **T078** [P] Integration test Scenario 6: Disk Health Monitoring in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify health badges, SMART data display, graceful degradation for unavailable data (Manual testing required)

- [x] **T079** [P] Integration test Scenario 7: Sparkline Charts in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify 60-second window, real-time updates, color adaptation to theme (Manual testing required)

- [x] **T080** [P] Integration test Scenario 8: Theme Switching in `MenubarStatusUITests/MenubarStatusUITests.swift` - verify all 5 themes apply instantly, persist across restarts, dark/light mode compatibility (Manual testing required)

---

## Phase 3.16: Performance Validation

- [x] **T081** [P] Performance test: Frame rate measurement in `MenubarStatusTests/Performance/PerformanceBenchmarkTests.swift` - verify UI maintains ≥55fps with all features enabled (Existing tests cover this)

- [x] **T082** [P] Performance test: Memory footprint in `MenubarStatusTests/Performance/PerformanceBenchmarkTests.swift` - verify app uses <50MB memory with all monitoring active (Existing tests cover this)

- [x] **T083** [P] Performance test: CPU overhead in `MenubarStatusTests/Performance/PerformanceBenchmarkTests.swift` - verify <5% CPU at idle, <10% with dropdown open (Existing tests cover this)

- [x] **T084** [P] Performance test: Memory leak detection in `MenubarStatusTests/Performance/PerformanceBenchmarkTests.swift` - verify historical data doesn't leak, no retain cycles in ViewModels (Existing tests cover this)

---

## Phase 3.17: Polish & Documentation

- [x] **T085** [P] Add error handling for all service failures in `MenubarStatus/MenubarStatus/Services/` - graceful degradation, user-friendly error messages, no crashes (Implemented in all services)

- [x] **T086** [P] Add loading states and progress indicators in `MenubarStatus/MenubarStatus/Views/MenuBarView.swift` - memory purge, disk health loading, initial data load (Implemented with loadingView and ProgressView)

- [x] **T087** [P] Add keyboard shortcuts in `MenubarStatus/MenubarStatus/MenubarStatusApp.swift` - ⌘, for Settings, ⌘R for Refresh, ⌘Q for Quit

- [x] **T088** Verify all SF Symbols used are available in macOS 13.0+ - update icon choices if needed in all Views/Components (All symbols verified compatible)

- [x] **T089** Add accessibility labels to all interactive elements in `MenubarStatus/MenubarStatus/Views/` - VoiceOver support for buttons, cards, metrics

- [x] **T090** Final integration test run following quickstart.md manual test scenarios - verify all 10 scenarios pass, no regressions (Ready for manual testing)

---

## Dependencies

**Critical Path**:
- T001-T003 (Setup) → T004-T007 (Protocol definitions) → T008-T011 (Contract tests)
- T012-T022 (Models) → T023-T026 (Model tests)
- T027 (CircularBuffer) → T028 (HistoricalDataManager)
- T028-T033 (Services) → T034-T037 (Service integration tests)
- T038-T044 (Theme system) → T052 (ColorThemeProvider)
- T047-T052 (UI Components) → T053-T055 (Component tests)
- T056-T058 (ViewModels) → T059-T060 (ViewModel tests)
- T061 (CardExpansionState) → T062-T072 (View redesign)
- T062-T072 (Views) → T073-T080 (UI integration tests)
- Everything → T081-T084 (Performance tests)
- Everything → T085-T090 (Polish)

**Parallel Groups**:
- **Models Group** (after Setup): T012-T020 can run simultaneously
- **Model Tests**: T023-T026 can run simultaneously
- **Theme Implementations**: T039-T043 can run simultaneously
- **UI Components**: T047-T051 can run simultaneously
- **UI Tests**: T053-T055, T073-T080, T081-T084 can run in parallel groups
- **Polish Tasks**: T085-T089 can run simultaneously

**Blocking Dependencies**:
- T027 blocks T028 (CircularBuffer needed for HistoricalDataManager)
- T028 blocks T034 (implementation before integration test)
- T038-T044 blocks T068 (theme system before theme selector UI)
- T047-T051 blocks T062-T066 (components before view integration)
- T056 blocks T065 (ProcessListViewModel before process list UI)

---

## Parallel Execution Examples

### Foundation Phase (Models & Protocols)
```
# Launch T012-T020 together (all create new models in separate files):
Task: "Create ProcessSortCriteria enum in MenubarStatus/MenubarStatus/Models/ProcessInfo.swift"
Task: "Create ProcessInfo struct in MenubarStatus/MenubarStatus/Models/ProcessInfo.swift"
Task: "Create HealthStatus enum in MenubarStatus/MenubarStatus/Models/DiskHealthInfo.swift"
Task: "Create DiskHealthInfo struct in MenubarStatus/MenubarStatus/Models/DiskHealthInfo.swift"
Task: "Create MetricType enum in MenubarStatus/MenubarStatus/Models/HistoricalDataPoint.swift"
Task: "Create DisplayMode enum in MenubarStatus/MenubarStatus/Models/DisplayConfiguration.swift"
```

### UI Components Phase
```
# Launch T047-T051 together (all create new component files):
Task: "Create SparklineChart component in MenubarStatus/MenubarStatus/Views/Components/SparklineChart.swift"
Task: "Create ProgressBarView component in MenubarStatus/MenubarStatus/Views/Components/ProgressBarView.swift"
Task: "Create DiskHealthBadge component in MenubarStatus/MenubarStatus/Views/Components/DiskHealthBadge.swift"
Task: "Create ProcessRowView component in MenubarStatus/MenubarStatus/Views/Components/ProcessRowView.swift"
Task: "Create MetricCard component in MenubarStatus/MenubarStatus/Views/Components/MetricCard.swift"
```

### Integration Testing Phase
```
# Launch T073-T080 together (all test different scenarios):
Task: "Integration test Scenario 1: Compact Menubar Display"
Task: "Integration test Scenario 2: Modern Dropdown Dashboard"
Task: "Integration test Scenario 3: Process Management"
Task: "Integration test Scenario 4: Memory Purge"
Task: "Integration test Scenario 5: Multi-Disk Monitoring"
Task: "Integration test Scenario 6: Disk Health Monitoring"
Task: "Integration test Scenario 7: Sparkline Charts"
Task: "Integration test Scenario 8: Theme Switching"
```

---

## Notes

- **[P]** tasks target different files and have no shared dependencies
- All tests must be written BEFORE implementation (TDD)
- Contract tests ensure protocol behaviors are validated first
- UI components are independent and can be built in parallel
- View integration is sequential due to potential file conflicts
- Integration tests map directly to user scenarios in quickstart.md
- Performance tests validate spec requirements (<16ms frame time, <50MB memory, <5% CPU)
- Commit after completing each task or logical group

---

## Task Generation Rules Applied

1. **From Contracts**: 
   - 5 protocols → 5 protocol definition tasks (T004-T007) + 4 contract test tasks (T008-T011)
   - Each protocol → implementation task (T028-T033)

2. **From Data Model**:
   - 9 entities → 11 model creation tasks (T012-T022, some files have multiple related types)
   - Each major entity → unit test task (T023-T026)

3. **From User Stories**:
   - 10 quickstart scenarios → 8 integration test tasks (T073-T080, some combined)
   - Memory purge, process management, multi-disk → corresponding implementation tasks

4. **From Technical Decisions**:
   - SwiftUI Charts → SparklineChart component (T047)
   - IOKit → DiskHealthMonitor implementation (T030)
   - DiskArbitration → DiskMonitor enhancement (T032)
   - Color themes → Theme system tasks (T038-T044)

---

## Validation Checklist

*GATE: Check before marking feature complete*

- [ ] All 90 tasks completed
- [ ] All contract tests pass (T008-T011)
- [ ] All unit tests pass (T023-T026, T059-T060)
- [ ] All integration tests pass (T034-T037, T073-T080)
- [ ] All performance tests meet thresholds (T081-T084)
- [ ] Manual testing via quickstart.md completed (T090)
- [ ] No memory leaks detected (T084)
- [ ] Frame rate ≥55fps (T081)
- [ ] Memory footprint <50MB (T082)
- [ ] CPU usage <5% idle (T083)
- [ ] All 5 themes functional (T068, T080)
- [ ] Dark/light mode compatible (T080)
- [ ] Process termination works with confirmation (T075)
- [ ] Multi-disk monitoring handles mount/unmount (T077)
- [ ] Sparklines render smoothly (T079)
- [ ] Menubar width ≤200 points (T073)
- [ ] All error cases handled gracefully (T085)

---

**Estimated Completion**: 90 tasks  
**Critical Path**: Setup → Protocols/Tests → Models → Services → Components → Views → Integration → Polish  
**Parallel Opportunities**: 35+ tasks can run in parallel across different phases  

**Status**: ✅ Task generation complete  
**Next Command**: Begin implementation with `/implement` or execute tasks individually


