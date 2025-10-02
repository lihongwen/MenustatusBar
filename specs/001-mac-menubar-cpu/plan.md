
# Implementation Plan: Mac系统状态监控菜单栏应用

**Branch**: `001-mac-menubar-cpu` | **Date**: 2025-10-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-mac-menubar-cpu/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 8. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
A lightweight macOS menubar application that monitors and displays system metrics (CPU, memory, disk, network) in real-time. The app prioritizes minimal resource usage (CPU <2%, Memory <50MB) while providing configurable monitoring options through a settings interface. Users can customize display preferences, refresh rates (1-5 seconds), and enable auto-launch on startup. All settings persist using UserDefaults.

## Technical Context
**Language/Version**: Swift 5.9+ (macOS native)  
**Primary Dependencies**: 
- SwiftUI (UI framework)
- AppKit (menubar integration via NSStatusBar)
- Foundation (system metrics and UserDefaults)

**Storage**: UserDefaults (settings persistence)  
**Testing**: XCTest (unit, integration, and UI tests)  
**Target Platform**: macOS 13.0+ (Ventura and later)  
**Project Type**: single (macOS menubar application)  
**Performance Goals**: 
- CPU usage: <2% average
- Memory usage: <50MB average
- Refresh rate: 1-5 seconds (default 2s, user configurable)
- Launch time: <1 second

**Constraints**: 
- Minimal resource footprint (no heavy dependencies)
- Native macOS APIs only (no third-party monitoring libraries)
- Support for light/dark mode
- Must not impact system performance

**Scale/Scope**: 
- Single user (local system monitoring)
- 4 metric types (CPU, Memory, Disk, Network)
- Configurable refresh intervals
- Multi-disk support

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Status**: ✅ PASS - Constitution file contains only template placeholders, no specific requirements defined yet.

**Notes**: 
- No custom constitution requirements exist
- Will follow standard macOS development best practices
- TDD approach: Tests first, implementation second
- SwiftUI + AppKit integration for menubar functionality
- Direct system API usage for monitoring (no unnecessary abstractions)

## Project Structure

### Documentation (this feature)
```
specs/001-mac-menubar-cpu/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── system-metrics-api.md
│   └── settings-api.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
MenubarStatus/
├── MenubarStatus/
│   ├── MenubarStatusApp.swift       # App entry point
│   ├── ContentView.swift            # Existing view (may be refactored)
│   ├── Models/
│   │   ├── SystemMetrics.swift      # CPU, Memory, Disk, Network data
│   │   └── UserSettings.swift       # Settings model + UserDefaults
│   ├── Services/
│   │   ├── SystemMonitor.swift      # Core monitoring service
│   │   ├── CPUMonitor.swift         # CPU metrics collection
│   │   ├── MemoryMonitor.swift      # Memory metrics collection
│   │   ├── DiskMonitor.swift        # Disk metrics collection
│   │   └── NetworkMonitor.swift     # Network metrics collection
│   ├── Views/
│   │   ├── MenuBarView.swift        # Menubar icon + dropdown content (MenuBarExtra)
│   │   └── SettingsView.swift       # Settings window
│   └── Assets.xcassets/             # Existing assets
│
├── MenubarStatus.xcodeproj/         # Existing Xcode project
│
├── MenubarStatusTests/
│   ├── MenubarStatusTests.swift     # Existing test file
│   ├── Models/
│   │   ├── SystemMetricsTests.swift
│   │   └── UserSettingsTests.swift
│   ├── Services/
│   │   ├── SystemMonitorTests.swift
│   │   ├── CPUMonitorTests.swift
│   │   ├── MemoryMonitorTests.swift
│   │   ├── DiskMonitorTests.swift
│   │   └── NetworkMonitorTests.swift
│   └── Integration/
│       ├── MonitoringIntegrationTests.swift
│       └── SettingsPersistenceTests.swift
│
└── MenubarStatusUITests/
    ├── MenubarStatusUITests.swift           # Existing UI test
    ├── MenubarStatusUITestsLaunchTests.swift  # Existing launch test
    ├── MenuBarInteractionTests.swift        # New: menubar click tests
    └── SettingsUITests.swift                # New: settings window tests
```

**Structure Decision**: Single macOS application structure using Xcode project. The app follows Model-Service-View separation with SwiftUI for views and AppKit for menubar integration. Services encapsulate system monitoring logic, Models represent data structures, and Views handle UI presentation.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - System APIs for monitoring: Need to identify specific APIs for CPU, memory, disk, network
   - MenuBar integration: NSStatusBar vs SwiftUI MenuBarExtra
   - Launch agent: SMAppService vs Login Items API
   - Performance optimization: Efficient system polling strategies
   - Testing menubar apps: Best practices for testing NSStatusBar applications

2. **Generate and dispatch research agents**:
   ```
   Task 1: Research macOS system monitoring APIs (CPU, Memory, Disk, Network)
   Task 2: Research NSStatusBar vs MenuBarExtra for macOS 13+
   Task 3: Research auto-launch implementation (SMAppService vs ServiceManagement)
   Task 4: Research performance optimization for polling-based monitoring
   Task 5: Research testing strategies for menubar applications
   Task 6: Research UserDefaults best practices for settings persistence
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all technical decisions documented

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`:
   - SystemMetrics: CPU, memory, disk, network data structure
   - UserSettings: Configuration and preferences
   - MenuBarDisplay: Display state and formatting
   - Validation rules: Value ranges, refresh intervals
   - State transitions: Settings updates, monitoring lifecycle

2. **Generate API contracts** from functional requirements:
   - SystemMonitor protocol: Monitor lifecycle and data retrieval
   - MetricProvider protocols: CPU, Memory, Disk, Network providers
   - SettingsManager protocol: Settings CRUD operations
   - Output Swift protocol definitions to `/contracts/`

3. **Generate contract tests** from contracts:
   - Test files for each monitor service
   - Assert data format and value ranges
   - Mock implementations for testing
   - Tests must fail (no implementation yet)

4. **Extract test scenarios** from user stories:
   - Launch and auto-display scenario
   - Click menubar → view details scenario
   - Settings modification scenario
   - Auto-launch configuration scenario
   - Data refresh scenario
   - Settings persistence scenario

5. **Update agent file incrementally** (O(1) operation):
   - Run `.specify/scripts/bash/update-agent-context.sh cursor`
   - Add Swift/SwiftUI/AppKit context
   - Document menubar architecture
   - Note performance requirements

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, .cursorrules or CURSOR.md

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs

**Ordering**:
1. **Foundation Layer** (Models) [P]:
   - Create SystemMetrics model with validation
   - Create UserSettings model with UserDefaults integration
   
2. **Service Layer Tests** [P after models]:
   - Write tests for CPUMonitor
   - Write tests for MemoryMonitor  
   - Write tests for DiskMonitor
   - Write tests for NetworkMonitor
   - Write tests for SystemMonitor coordinator

3. **Service Layer Implementation** [P]:
   - Implement CPUMonitor using system APIs
   - Implement MemoryMonitor using system APIs
   - Implement DiskMonitor using system APIs
   - Implement NetworkMonitor using system APIs
   - Implement SystemMonitor coordinator

4. **View Layer Tests**:
   - Write tests for MenuBarView (includes dropdown functionality)
   - Write tests for SettingsView

5. **View Layer Implementation**:
   - Implement MenuBarView with MenuBarExtra (icon + dropdown content)
   - Implement SettingsView with UserDefaults binding

6. **Integration Tests**:
   - Monitor lifecycle integration test
   - Settings persistence integration test
   - End-to-end monitoring flow test

7. **UI Tests**:
   - Menubar interaction test
   - Settings window interaction test
   - Auto-launch verification test

8. **Performance Validation**:
   - CPU usage benchmark test
   - Memory usage benchmark test
   - Refresh rate validation test

**Ordering Strategy**:
- TDD order: Tests before implementation
- Dependency order: Models → Services → Views → Integration
- Mark [P] for parallel execution (independent components)

**Estimated Output**: 35-40 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following TDD principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

No complexity violations detected. The design follows straightforward patterns:
- Direct system API usage (no unnecessary abstractions)
- SwiftUI + AppKit integration (standard for menubar apps)
- UserDefaults for simple key-value storage (appropriate for settings)
- Service layer for testability and separation of concerns

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) - ✅ research.md created
- [x] Phase 1: Design complete (/plan command) - ✅ data-model.md, contracts/, quickstart.md created
- [x] Phase 2: Task planning complete (/plan command - describe approach only) - ✅ Strategy documented
- [x] Phase 3: Tasks generated (/tasks command) - ✅ tasks.md with 40 ordered tasks
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] Complexity deviations documented (none)
- [x] Agent context file updated (.cursor/rules/specify-rules.mdc)

---
*Based on Constitution template - No custom requirements defined*
