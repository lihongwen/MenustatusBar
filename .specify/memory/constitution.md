# MenubarStatus Project Constitution

## Core Principles

### I. SwiftUI Best Practices

**Principle**: Follow Apple's SwiftUI framework patterns and Human Interface Guidelines

**Requirements**:
- Use native SwiftUI components (Cards, Progress bars, SF Symbols)
- Implement MVVM architecture pattern consistently
- Leverage @ObservedObject and Combine for reactive updates
- Apply vibrancy effects and native animations
- Follow Apple Human Interface Guidelines for macOS

**Rationale**: Native patterns ensure optimal performance, maintainability, and user experience consistency with macOS ecosystem.

**Status**: MANDATORY

---

### II. Separation of Concerns

**Principle**: Clear separation between Models, ViewModels, Views, and Services

**Requirements**:
- **Models**: Pure data structures, no business logic
- **Services**: System monitoring and data collection, protocol-based interfaces
- **ViewModels**: Business logic and state management, bridge between services and views
- **Views**: Pure presentation layer, declarative SwiftUI only

**Rationale**: Enables independent testing, parallel development, and easier maintenance.

**Status**: MANDATORY

---

### III. Performance & Responsiveness (NON-NEGOTIABLE)

**Principle**: Maintain 60fps and responsive UI even with real-time monitoring

**Requirements**:
- Frame time MUST be <16ms (60fps minimum)
- Background thread for all system metric collection
- Debounced UI updates (no more than refresh interval)
- Lazy loading for process lists
- Efficient sparkline rendering (max 60 data points)
- Memory footprint MUST be <50MB
- CPU usage MUST be <5% at idle

**Rationale**: Performance is non-negotiable for a system monitoring app. Poor performance undermines the app's purpose.

**Status**: MANDATORY - Validated via automated performance tests

---

### IV. User Privacy & System Safety

**Principle**: Respect system boundaries and user safety

**Requirements**:
- Prevent termination of system-critical processes (hardcoded protection list)
- Confirmation dialogs for all destructive actions
- Graceful degradation when APIs unavailable (no crashes)
- No persistent storage of sensitive data
- Clear error messages without exposing system internals

**Protected Processes** (minimum):
- kernel_task, launchd, WindowServer, loginwindow, SystemUIServer, Dock, Finder, coreaudiod
- Any process with PID < 100

**Rationale**: System stability and user trust are paramount. App must be safe to use.

**Status**: MANDATORY

---

### V. Testability

**Principle**: All features must be unit-testable and integration-testable

**Requirements**:
- **Test-First Development**: Tests written BEFORE implementation
- **Protocol-based service interfaces**: Enables mocking and dependency injection
- **Dependency injection for ViewModels**: All dependencies injected, not created
- **Separate business logic from UI**: ViewModels contain testable logic
- **Integration tests for monitoring workflows**: Real-world scenario validation
- **Contract tests for protocols**: Verify interface behavior guarantees

**Test Coverage Requirements**:
- Unit tests: All models, services, ViewModels
- Contract tests: All protocol implementations
- Integration tests: All user scenarios from quickstart.md
- Performance tests: Frame rate, memory, CPU benchmarks
- UI tests: Critical user flows

**Rationale**: Testability ensures quality, enables refactoring, and prevents regressions.

**Status**: MANDATORY - Gates deployment

---

## Technical Standards

### Platform Requirements
- **Minimum**: macOS 13.0+ (Ventura)
- **Frameworks**: SwiftUI, AppKit, IOKit, DiskArbitration, Charts
- **Language**: Swift 5.9+
- **Architecture**: MVVM with protocol-oriented design

### Code Quality Standards
- **SwiftLint**: Enforce Swift style guidelines
- **No force unwrapping**: Use optional binding or guard statements
- **Error handling**: All errors must be handled gracefully
- **Thread safety**: Mark thread-safe operations explicitly
- **Documentation**: Public APIs must have doc comments

### Performance Benchmarks
| Metric | Target | Gate |
|--------|--------|------|
| Frame Rate | ≥55fps | MUST |
| Memory Usage | <50MB | MUST |
| CPU at Idle | <5% | MUST |
| CPU Active | <10% | SHOULD |
| Sparkline Render | <5ms | MUST |
| Metric Collection | <100ms | MUST |

---

## Development Workflow

### Phase Structure
1. **Specification** (`/specify`): Define requirements and user stories
2. **Planning** (`/plan`): Technical design and architecture
3. **Task Generation** (`/tasks`): Detailed, ordered task breakdown
4. **Analysis** (`/analyze`): Cross-artifact consistency validation
5. **Implementation** (`/implement`): Execute tasks following TDD
6. **Validation**: Integration tests and performance benchmarks

### Quality Gates

**Pre-Implementation Gate**:
- [ ] Specification complete and approved
- [ ] Implementation plan documented
- [ ] Tasks generated and ordered
- [ ] Analysis shows no CRITICAL issues
- [ ] Constitution compliance verified

**Pre-Deployment Gate**:
- [ ] All tests pass (100% pass rate)
- [ ] Performance benchmarks met
- [ ] Integration tests validate user scenarios
- [ ] No memory leaks detected
- [ ] UI responsive at 60fps
- [ ] Code review completed

### Test-Driven Development (TDD) Enforcement

**Red-Green-Refactor Cycle**:
1. **Red**: Write failing tests first (contract tests, unit tests)
2. **Green**: Implement minimum code to pass tests
3. **Refactor**: Improve code quality while tests remain green

**TDD Verification**:
- Contract tests (Phase 3.2) MUST be written before implementation (Phase 3.3)
- Tests MUST fail initially (proves they test something)
- Implementation MUST make tests pass
- No implementation without corresponding tests

---

## Complexity Management

### Simplicity Principles
- **YAGNI** (You Aren't Gonna Need It): Don't build for hypothetical future needs
- **Start Simple**: Implement simplest solution that works
- **Incremental Enhancement**: Add complexity only when proven necessary
- **Refactor Continuously**: Simplify as understanding grows

### Justification Required For
- Introducing new dependencies
- Creating new architectural patterns
- Deviating from MVVM structure
- Performance optimizations (must measure first)
- Complex abstractions

---

## Governance

### Authority
- This constitution supersedes all other development practices
- All pull requests must verify constitution compliance
- Violations must be justified and documented
- Constitution amendments require explicit approval

### Amendment Process
1. Document proposed change with rationale
2. Identify affected code/practices
3. Create migration plan if breaking change
4. Seek approval from maintainers
5. Update version and last amended date

### Compliance
- Code reviews verify principle adherence
- Automated tests enforce performance benchmarks
- Analysis command validates consistency
- Manual testing confirms user scenarios

### Enforcement
- CRITICAL constitution violations block deployment
- HIGH severity issues require remediation plan
- MEDIUM/LOW issues tracked for future improvement
- Performance gate failures prevent merge

---

**Version**: 1.0.0  
**Ratified**: 2025-10-02  
**Last Amended**: 2025-10-02  
**Next Review**: 2026-01-02
