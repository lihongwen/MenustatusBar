# Tasks: Mac系统状态监控菜单栏应用

**Feature**: 001-mac-menubar-cpu  
**Branch**: `001-mac-menubar-cpu`  
**Input**: Design documents from `/specs/001-mac-menubar-cpu/`  
**Prerequisites**: plan.md, research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → Extract: Swift 5.9+, SwiftUI, AppKit, macOS 13.0+
2. Load design documents:
   → data-model.md: 8 entities (SystemMetrics, CPUMetrics, etc.)
   → contracts/: Monitor protocols
   → quickstart.md: Test scenarios
3. Generate tasks by category:
   → Setup: Xcode project structure
   → Tests: Contract tests for all monitors
   → Models: All metric structs and settings
   → Services: Monitor implementations
   → Views: MenuBar, Dropdown, Settings
   → Integration: End-to-end flows
   → Polish: Performance tests, documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001-T040)
6. Validate task completeness: ✅ All covered
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions
- Must follow TDD: Write tests first, watch them fail, then implement

## Path Conventions
- **App code**: `MenubarStatus/MenubarStatus/`
- **Unit tests**: `MenubarStatus/MenubarStatusTests/`
- **UI tests**: `MenubarStatus/MenubarStatusUITests/`

---

## Phase 3.1: Project Setup

- [ ] **T001** Verify Xcode project configuration
  - File: `MenubarStatus/MenubarStatus.xcodeproj/project.pbxproj`
  - Tasks:
    - Verify minimum deployment target: macOS 13.0
    - Verify Swift language version: 5.9+
    - Add Service Management capability for auto-launch
    - Configure App Sandbox entitlements
  - Acceptance: Project builds without errors

- [ ] **T002** Create directory structure for Models
  - Create: `MenubarStatus/MenubarStatus/Models/` directory
  - Acceptance: Directory exists and is in Xcode project

- [ ] **T003** Create directory structure for Services
  - Create: `MenubarStatus/MenubarStatus/Services/` directory
  - Acceptance: Directory exists and is in Xcode project

- [ ] **T004** Create directory structure for Views
  - Create: `MenubarStatus/MenubarStatus/Views/` directory
  - Acceptance: Directory exists and is in Xcode project

- [ ] **T005** Create test directory structure
  - Create: `MenubarStatus/MenubarStatusTests/Models/`
  - Create: `MenubarStatus/MenubarStatusTests/Services/`
  - Create: `MenubarStatus/MenubarStatusTests/Integration/`
  - Acceptance: All directories exist and are in test target

---

## Phase 3.2: Models - Tests First ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] **T006** [P] Write tests for CPUMetrics model
  - File: `MenubarStatus/MenubarStatusTests/Models/CPUMetricsTests.swift`
  - Test cases:
    - `testValidCPUMetrics()` - Valid range 0-100
    - `testCPUUsageSum()` - usagePercentage = systemUsage + userUsage
    - `testCPUIdleCalculation()` - usagePercentage + idlePercentage ≈ 100
    - `testInvalidNegativeValues()` - Reject negative values
    - `testInvalidExcessiveValues()` - Reject values > 100
  - Acceptance: Tests written and FAIL (no implementation yet)

- [ ] **T007** [P] Write tests for MemoryMetrics model
  - File: `MenubarStatus/MenubarStatusTests/Models/MemoryMetricsTests.swift`
  - Test cases:
    - `testValidMemoryMetrics()` - Valid byte values
    - `testUsagePercentageCalculation()` - Correct percentage
    - `testGigabytesConversion()` - Correct GB conversion
    - `testComputedProperties()` - All computed properties work
    - `testInvalidTotalBytes()` - Reject totalBytes = 0
  - Acceptance: Tests written and FAIL

- [ ] **T008** [P] Write tests for DiskMetrics model
  - File: `MenubarStatus/MenubarStatusTests/Models/DiskMetricsTests.swift`
  - Test cases:
    - `testValidDiskMetrics()` - Valid disk data
    - `testUsedPlusFreeEqualsTotal()` - usedBytes + freeBytes = totalBytes
    - `testUsagePercentageCalculation()` - Correct percentage
    - `testVolumePathValidation()` - Valid absolute path
    - `testEmptyVolumeNameRejected()` - Volume name not empty
  - Acceptance: Tests written and FAIL

- [ ] **T009** [P] Write tests for NetworkMetrics model
  - File: `MenubarStatus/MenubarStatusTests/Models/NetworkMetricsTests.swift`
  - Test cases:
    - `testValidNetworkMetrics()` - Valid byte rates
    - `testFormatKBPerSecond()` - Format as KB/s when < 1 MB/s
    - `testFormatMBPerSecond()` - Format as MB/s when >= 1 MB/s
    - `testMonotonicTotals()` - Total bytes only increase
    - `testZeroValues()` - Handle network disconnected (0 values)
  - Acceptance: Tests written and FAIL

- [ ] **T010** [P] Write tests for SystemMetrics model
  - File: `MenubarStatus/MenubarStatusTests/Models/SystemMetricsTests.swift`
  - Test cases:
    - `testValidSystemMetrics()` - Create complete snapshot
    - `testTimestamp()` - Timestamp is present and valid
    - `testCompositeStructure()` - All sub-metrics present
  - Acceptance: Tests written and FAIL

- [ ] **T011** [P] Write tests for AppSettings model
  - File: `MenubarStatus/MenubarStatusTests/Models/AppSettingsTests.swift`
  - Test cases:
    - `testDefaultSettings()` - Default values applied
    - `testCodableEncoding()` - Can encode to JSON
    - `testCodableDecoding()` - Can decode from JSON
    - `testRefreshIntervalValidation()` - 1.0 <= interval <= 5.0
    - `testAtLeastOneMetricEnabled()` - At least one show* is true
    - `testUserDefaultsPersistence()` - Save and load from UserDefaults
  - Acceptance: Tests written and FAIL

---

## Phase 3.3: Models - Implementation (ONLY after tests are failing)

- [ ] **T012** [P] Implement CPUMetrics model
  - File: `MenubarStatus/MenubarStatus/Models/CPUMetrics.swift`
  - Requirements:
    - Struct with usagePercentage, systemUsage, userUsage, idlePercentage
    - All Double properties
    - Range validation: 0.0-100.0
    - Implement validation in initializer
  - Acceptance: T006 tests pass

- [ ] **T013** [P] Implement MemoryMetrics model
  - File: `MenubarStatus/MenubarStatus/Models/MemoryMetrics.swift`
  - Requirements:
    - Struct with totalBytes, usedBytes, freeBytes, cachedBytes
    - Computed properties: usagePercentage, usedGigabytes, totalGigabytes
    - Validation: bytes >= 0, totalBytes > 0
  - Acceptance: T007 tests pass

- [ ] **T014** [P] Implement DiskMetrics model
  - File: `MenubarStatus/MenubarStatus/Models/DiskMetrics.swift`
  - Requirements:
    - Struct with volumePath, volumeName, totalBytes, freeBytes, usedBytes
    - Computed properties: usagePercentage, usedGigabytes, totalGigabytes, freeGigabytes
    - Validation: usedBytes + freeBytes = totalBytes, valid path
  - Acceptance: T008 tests pass

- [ ] **T015** [P] Implement NetworkMetrics model
  - File: `MenubarStatus/MenubarStatus/Models/NetworkMetrics.swift`
  - Requirements:
    - Struct with uploadBytesPerSecond, downloadBytesPerSecond, totalUploadBytes, totalDownloadBytes
    - Computed properties: uploadFormatted, downloadFormatted
    - Auto-adapt units: MB/s if >= 1 MB/s, else KB/s
  - Acceptance: T009 tests pass

- [ ] **T016** [P] Implement SystemMetrics model
  - File: `MenubarStatus/MenubarStatus/Models/SystemMetrics.swift`
  - Requirements:
    - Struct with timestamp, cpu, memory, disk, network
    - Composite of all metric types
  - Acceptance: T010 tests pass

- [ ] **T017** [P] Implement AppSettings model
  - File: `MenubarStatus/MenubarStatus/Models/AppSettings.swift`
  - Requirements:
    - Struct conforming to Codable
    - Properties: showCPU, showMemory, showDisk, showNetwork, refreshInterval, selectedDiskPath, launchAtLogin, useCompactMode
    - Default values: CPU+Memory=true, 2s interval, "/" disk, autolaunch=false
    - UserDefaults extension for persistence
    - Validation: 1-5s interval, at least one metric enabled
  - Acceptance: T011 tests pass

---

## Phase 3.4: Service Protocols & Tests - Tests First ⚠️

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [ ] **T018** [P] Write contract tests for CPUMonitor protocol
  - File: `MenubarStatus/MenubarStatusTests/Services/CPUMonitorTests.swift`
  - Test cases:
    - `testGetCurrentMetricsReturnsValidRange()` - Values 0-100
    - `testGetCurrentMetricsCompletesQuickly()` - <20ms execution
    - `testConcurrentCallsAreThreadSafe()` - No crashes with 10 concurrent calls
    - `testIsAvailableProperty()` - Returns Bool
    - `testDeltaCalculation()` - Accurate delta between calls
  - Acceptance: Tests written and FAIL (use mock for now)

- [ ] **T019** [P] Write contract tests for MemoryMonitor protocol
  - File: `MenubarStatus/MenubarStatusTests/Services/MemoryMonitorTests.swift`
  - Test cases:
    - `testGetCurrentMetricsReturnsValidData()` - Non-negative bytes
    - `testGetCurrentMetricsCompletesQuickly()` - <10ms execution
    - `testMemoryInvariants()` - usedBytes <= totalBytes
    - `testNoCache()` - Always returns fresh data
  - Acceptance: Tests written and FAIL

- [ ] **T020** [P] Write contract tests for DiskMonitor protocol
  - File: `MenubarStatus/MenubarStatusTests/Services/DiskMonitorTests.swift`
  - Test cases:
    - `testGetCurrentMetricsForValidPath()` - Returns metrics for "/"
    - `testGetCurrentMetricsForInvalidPath()` - Throws error
    - `testGetAvailableVolumes()` - Returns array including "/"
    - `testExecutionTime()` - <50ms per call
    - `testCaching()` - Can cache for up to 1 second
  - Acceptance: Tests written and FAIL

- [ ] **T021** [P] Write contract tests for NetworkMonitor protocol
  - File: `MenubarStatus/MenubarStatusTests/Services/NetworkMonitorTests.swift`
  - Test cases:
    - `testGetCurrentMetricsReturnsValidRates()` - Non-negative rates
    - `testMonotonicTotals()` - Total bytes increase
    - `testResetCounters()` - Resets totals to 0
    - `testExecutionTime()` - <30ms per call
    - `testThreadSafety()` - Concurrent rate calculations safe
  - Acceptance: Tests written and FAIL

- [ ] **T022** Write contract tests for SystemMonitor protocol
  - File: `MenubarStatus/MenubarStatusTests/Services/SystemMonitorTests.swift`
  - Test cases:
    - `testStartMonitoring()` - Sets isMonitoring = true
    - `testStopMonitoring()` - Sets isMonitoring = false
    - `testRefreshInterval()` - Updates at configured interval (±50ms)
    - `testManualRefresh()` - Can trigger manual update
    - `testSettingsChange()` - Adjusts behavior when settings change
    - `testOnlyEnabledMetrics()` - Only collects enabled metrics
  - Acceptance: Tests written and FAIL (depends on mock monitors)

---

## Phase 3.5: Service Implementations (ONLY after tests are failing)

- [ ] **T023** [P] Implement CPUMonitor service
  - File: `MenubarStatus/MenubarStatus/Services/CPUMonitor.swift`
  - Requirements:
    - Conform to CPUMonitor protocol
    - Use `host_processor_info()` from mach/mach_host.h
    - Store previous ticks for delta calculation
    - Calculate user, system, and idle percentages
    - Return CPUMetrics
    - Thread-safe implementation
  - Acceptance: T018 tests pass

- [ ] **T024** [P] Implement MemoryMonitor service
  - File: `MenubarStatus/MenubarStatus/Services/MemoryMonitor.swift`
  - Requirements:
    - Conform to MemoryMonitor protocol
    - Use `host_statistics64()` with HOST_VM_INFO64
    - Return physical memory stats (not virtual)
    - Return MemoryMetrics with all byte values
    - No caching (always fresh)
  - Acceptance: T019 tests pass

- [ ] **T025** [P] Implement DiskMonitor service
  - File: `MenubarStatus/MenubarStatus/Services/DiskMonitor.swift`
  - Requirements:
    - Conform to DiskMonitor protocol
    - Use `FileManager.attributesOfFileSystem(forPath:)`
    - Validate path is mounted before querying
    - Return DiskMetrics with volume info
    - Implement getAvailableVolumes() using FileManager
    - Optional 1-second caching
  - Acceptance: T020 tests pass

- [ ] **T026** [P] Implement NetworkMonitor service
  - File: `MenubarStatus/MenubarStatus/Services/NetworkMonitor.swift`
  - Requirements:
    - Conform to NetworkMonitor protocol
    - Use `getifaddrs()` or Network framework
    - Calculate rate from delta between calls
    - Track cumulative totals
    - Aggregate all network interfaces
    - Implement resetCounters()
  - Acceptance: T021 tests pass

- [ ] **T027** Implement SystemMonitor service
  - File: `MenubarStatus/MenubarStatus/Services/SystemMonitor.swift`
  - Requirements:
    - Conform to SystemMonitor protocol
    - Coordinate all metric providers (CPU, Memory, Disk, Network)
    - Use DispatchSourceTimer for precise intervals
    - Collect metrics on background queue (.utility QoS)
    - Publish updates on main thread (@MainActor)
    - Only collect enabled metrics per settings
    - Implement start(), stop(), refresh()
  - Dependencies: T023, T024, T025, T026
  - Acceptance: T022 tests pass

---

## Phase 3.6: View Models & Tests - Tests First ⚠️

- [X] **T028** [P] Write tests for MenuBarViewModel
  - File: `MenubarStatus/MenubarStatusTests/ViewModels/MenuBarViewModelTests.swift`
  - Test cases:
    - `testInitialState()` - Starts with nil metrics
    - `testReceivingMetrics()` - Updates currentMetrics from monitor
    - `testDisplayTextFormatting()` - Formats text based on settings
    - `testDetailsTextFormatting()` - Formats details for dropdown
    - `testErrorHandling()` - Sets errorMessage on failure
    - `testSettingsChangePropagation()` - Updates when settings change
  - Acceptance: Tests written and FAIL

- [X] **T029** [P] Write tests for SettingsViewModel
  - File: `MenubarStatus/MenubarStatusTests/ViewModels/SettingsViewModelTests.swift`
  - Test cases:
    - `testLoadSettings()` - Loads from UserDefaults
    - `testSaveSettings()` - Saves to UserDefaults
    - `testResetToDefaults()` - Restores default values
    - `testValidation()` - Validates refresh interval range
    - `testAvailableDisksDiscovery()` - Discovers mounted volumes
  - Acceptance: Tests written and FAIL

---

## Phase 3.7: View Model Implementations

- [X] **T030** [P] Implement MenuBarViewModel
  - File: `MenubarStatus/MenubarStatus/ViewModels/MenuBarViewModel.swift`
  - Requirements:
    - ObservableObject with @Published properties
    - Properties: currentMetrics, settings, isMonitoring, errorMessage
    - Computed properties: displayText, detailsText
    - Format text based on settings (show/hide metrics)
    - Subscribe to SystemMonitor updates
    - @MainActor for thread safety
  - Acceptance: T028 tests pass

- [X] **T031** [P] Implement SettingsViewModel
  - File: `MenubarStatus/MenubarStatus/ViewModels/SettingsViewModel.swift`
  - Requirements:
    - ObservableObject with @Published properties
    - Properties: settings, availableDisks, isSaving, saveError
    - Functions: saveSettings(), resetToDefaults(), testMonitoring()
    - Load/save from UserDefaults
    - Discover available disks using DiskMonitor
    - @MainActor for thread safety
  - Acceptance: T029 tests pass

---

## Phase 3.8: Views & Tests - Tests First ⚠️

- [ ] **T032** Write UI tests for MenuBar interaction
  - File: `MenubarStatus/MenubarStatusUITests/MenuBarInteractionTests.swift`
  - Test cases:
    - `testAppLaunchShowsMenuBarIcon()` - Icon appears in menubar
    - `testClickMenuBarShowsDropdown()` - Clicking shows menu
    - `testDropdownShowsMetrics()` - Metrics displayed
    - `testDropdownHasSettingsOption()` - "Settings..." present
    - `testDropdownHasQuitOption()` - "Quit" present
    - `testMetricsUpdateOverTime()` - Values change after interval
  - Acceptance: Tests written and FAIL

- [ ] **T033** Write UI tests for Settings window
  - File: `MenubarStatus/MenubarStatusUITests/SettingsUITests.swift`
  - Test cases:
    - `testOpenSettingsWindow()` - Settings opens from dropdown
    - `testToggleMetricVisibility()` - Can toggle show/hide
    - `testAdjustRefreshInterval()` - Can change slider (1-5s)
    - `testSelectDisk()` - Can choose different disk
    - `testEnableAutoLaunch()` - Can toggle launch at login
    - `testSaveSettings()` - Settings persist after close
  - Acceptance: Tests written and FAIL

---

## Phase 3.9: View Implementations

- [X] **T034** Implement MenuBarView with MenuBarExtra
  - File: `MenubarStatus/MenubarStatus/Views/MenuBarView.swift`
  - Requirements:
    - Use SwiftUI MenuBarExtra API
    - Display icon with CPU/Memory text (based on settings)
    - Implement dropdown menu content
    - Show detailed metrics in dropdown
    - "Settings..." button opens settings window
    - "Quit" button terminates app
    - Update display when viewModel.currentMetrics changes
    - Support light/dark mode automatically
  - Dependencies: T030 (MenuBarViewModel)
  - Acceptance: T032 tests pass

- [X] **T035** Implement SettingsView
  - File: `MenubarStatus/MenubarStatus/Views/SettingsView.swift`
  - Requirements:
    - SwiftUI form with sections
    - Toggle controls for showCPU, showMemory, showDisk, showNetwork
    - Slider for refresh interval (1-5s) with value label
    - Picker for disk selection (from availableDisks)
    - Toggle for launchAtLogin
    - Save/Cancel buttons
    - Bind to SettingsViewModel
    - Auto-save on changes (optional)
  - Dependencies: T031 (SettingsViewModel)
  - Acceptance: T033 tests pass

- [X] **T036** Update MenubarStatusApp.swift entry point
  - File: `MenubarStatus/MenubarStatus/MenubarStatusApp.swift`
  - Requirements:
    - @main struct MenubarStatusApp: App
    - Use MenuBarExtra scene for menubar
    - Create SystemMonitor instance
    - Create MenuBarViewModel with monitor
    - Initialize with AppSettings from UserDefaults
    - Start monitoring on app launch
    - Handle Settings window scene
    - Implement quit action
  - Dependencies: T027 (SystemMonitor), T030 (MenuBarViewModel), T034 (MenuBarView)
  - Acceptance: App launches and displays in menubar

---

## Phase 3.10: Integration Tests

- [X] **T037** Write end-to-end monitoring flow test
  - File: `MenubarStatus/MenubarStatusTests/Integration/MonitoringIntegrationTests.swift`
  - Test cases:
    - `testFullMonitoringCycle()` - Start → collect → update → stop
    - `testAllMetricsCollected()` - CPU, Memory, Disk, Network all present
    - `testRefreshIntervalAccuracy()` - Updates at configured interval
    - `testDisabledMetricsNotCollected()` - Disabled metrics skipped
    - `testMetricsWithinValidRanges()` - All values in valid ranges
  - Dependencies: T027 (SystemMonitor), all monitor implementations
  - Acceptance: Tests pass with real system data

- [X] **T038** Write settings persistence integration test
  - File: `MenubarStatus/MenubarStatusTests/Integration/SettingsPersistenceTests.swift`
  - Test cases:
    - `testSaveAndLoadSettings()` - Settings survive app restart (simulated)
    - `testSettingsChangeAffectsMonitoring()` - Monitor respects new settings
    - `testInvalidSettingsUseDefaults()` - Bad data reverts to defaults
  - Dependencies: T017 (AppSettings), T031 (SettingsViewModel)
  - Acceptance: Tests pass

---

## Phase 3.11: Performance & Polish

- [X] **T039** [P] Write and run performance benchmark tests
  - File: `MenubarStatus/MenubarStatusTests/Performance/PerformanceBenchmarkTests.swift`
  - Test cases:
    - `testCPUUsageUnder2Percent()` - Use XCTCPUMetric, run for 60s
    - `testMemoryUsageUnder50MB()` - Use XCTMemoryMetric
    - `testRefreshCycleUnder100ms()` - Measure full cycle time
    - `testIndividualMonitorPerformance()` - Each monitor meets contract
  - Requirements:
    - Must run on real hardware (not simulator if possible)
    - Verify against targets: CPU <2%, Memory <50MB
  - Acceptance: All performance targets met

- [X] **T040** [P] Update documentation and README
  - Files:
    - Update `README.md` in repository root
    - Update `MenubarStatus/README.md` if exists
  - Tasks:
    - Add usage instructions
    - Document settings options
    - Include screenshots (optional for now)
    - Add troubleshooting section
    - Document performance characteristics
    - Add build instructions
  - Acceptance: Documentation is clear and complete

---

## Dependencies

### Critical Path
```
Setup (T001-T005)
  ↓
Model Tests (T006-T011) [P] → Model Implementations (T012-T017) [P]
  ↓
Service Tests (T018-T022) [P] → Service Implementations (T023-T027)
  ↓
ViewModel Tests (T028-T029) [P] → ViewModel Implementations (T030-T031) [P]
  ↓
View Tests (T032-T033) → View Implementations (T034-T036)
  ↓
Integration Tests (T037-T038)
  ↓
Performance & Polish (T039-T040) [P]
```

### Specific Dependencies
- T027 (SystemMonitor) requires: T023, T024, T025, T026
- T030 (MenuBarViewModel) requires: T027
- T031 (SettingsViewModel) requires: T017
- T034 (MenuBarView) requires: T030
- T035 (SettingsView) requires: T031
- T036 (App entry) requires: T027, T030, T034
- T037 (Integration) requires: T027 + all monitors
- T038 (Settings persistence) requires: T017, T031

---

## Parallel Execution Examples

### Batch 1: Model Tests (can run simultaneously)
```bash
# All model tests are independent, run in parallel
Task: T006 - Write tests for CPUMetrics
Task: T007 - Write tests for MemoryMetrics
Task: T008 - Write tests for DiskMetrics
Task: T009 - Write tests for NetworkMetrics
Task: T010 - Write tests for SystemMetrics
Task: T011 - Write tests for AppSettings
```

### Batch 2: Model Implementations (after tests fail)
```bash
# All model implementations are independent, run in parallel
Task: T012 - Implement CPUMetrics
Task: T013 - Implement MemoryMetrics
Task: T014 - Implement DiskMetrics
Task: T015 - Implement NetworkMetrics
Task: T016 - Implement SystemMetrics
Task: T017 - Implement AppSettings
```

### Batch 3: Service Tests (after models done)
```bash
# Service tests are independent, run in parallel
Task: T018 - Write tests for CPUMonitor
Task: T019 - Write tests for MemoryMonitor
Task: T020 - Write tests for DiskMonitor
Task: T021 - Write tests for NetworkMonitor
# T022 (SystemMonitor tests) should wait as it depends on others
```

### Batch 4: Service Implementations (after tests fail)
```bash
# Individual monitors can be parallel, SystemMonitor must wait
Task: T023 - Implement CPUMonitor
Task: T024 - Implement MemoryMonitor
Task: T025 - Implement DiskMonitor
Task: T026 - Implement NetworkMonitor
# Then T027 - Implement SystemMonitor (depends on above)
```

---

## Notes

- **[P] tasks**: Different files, no dependencies, can run simultaneously
- **TDD Enforcement**: All tests must be written and failing before implementation
- **Commit frequency**: Commit after each task completion
- **Avoid**: Vague tasks, same file conflicts, skipping tests
- **Performance**: Continuously monitor during development, not just at end

---

## Validation Checklist

*GATE: Checked before marking feature complete*

- [x] All contracts have corresponding tests (T018-T022)
- [x] All entities have model tasks (T006-T017)
- [x] All tests come before implementation (TDD enforced)
- [x] Parallel tasks truly independent (marked [P])
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] Performance targets documented (T039)
- [x] Integration tests cover user stories (T037-T038)
- [x] UI tests cover critical flows (T032-T033)

---

## Task Summary

**Total Tasks**: 40  
**Setup**: 5 tasks (T001-T005)  
**Models**: 12 tasks (T006-T017) - 6 test + 6 implementation  
**Services**: 10 tasks (T018-T027) - 5 test + 5 implementation  
**ViewModels**: 4 tasks (T028-T031) - 2 test + 2 implementation  
**Views**: 5 tasks (T032-T036) - 2 test + 3 implementation  
**Integration**: 2 tasks (T037-T038)  
**Polish**: 2 tasks (T039-T040)  

**Parallel Opportunities**: 22 tasks marked [P] for parallel execution  
**Critical Path Length**: ~18 sequential steps (with parallelization)

---

**Status**: ✅ Tasks generated and ready for execution. Follow TDD: Write tests first, watch them fail, then implement to make them pass.

**Next Step**: Start with T001 (project setup) and proceed sequentially through phases, executing [P] tasks in parallel where possible.





