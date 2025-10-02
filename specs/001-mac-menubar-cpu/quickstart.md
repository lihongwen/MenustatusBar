# Quickstart Guide: Mac系统状态监控菜单栏应用

**Feature**: 001-mac-menubar-cpu  
**Date**: 2025-10-02  
**Status**: Ready for Development

## Overview
This quickstart guide provides step-by-step instructions for building, testing, and running the macOS menubar system monitor application. Follow these steps after implementing the design specified in `data-model.md` and `contracts/`.

---

## Prerequisites

### System Requirements
- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later

### Required Knowledge
- Swift programming
- SwiftUI basics
- Basic understanding of macOS app development
- Familiarity with XCTest

---

## Setup Instructions

### 1. Clone and Open Project

```bash
cd /Users/lihongwen/Projects/memubar-status
open MenubarStatus/MenubarStatus.xcodeproj
```

### 2. Verify Project Configuration

In Xcode:
1. Select the project in Navigator
2. Select "MenubarStatus" target
3. Verify **General** tab:
   - **Minimum Deployments**: macOS 13.0
   - **Bundle Identifier**: com.example.MenubarStatus (or your identifier)
4. Verify **Signing & Capabilities** tab:
   - Enable App Sandbox
   - Add capability: **Service Management** (for auto-launch)
5. Verify **Build Settings** tab:
   - **Swift Language Version**: Swift 5

### 3. Install Dependencies

No external dependencies required! This app uses only native macOS frameworks:
- SwiftUI
- AppKit
- Foundation
- ServiceManagement

### 4. Build the Project

**Command Line**:
```bash
cd MenubarStatus
xcodebuild -project MenubarStatus.xcodeproj -scheme MenubarStatus -configuration Debug clean build
```

**In Xcode**:
- Press `⌘B` or
- Menu: Product → Build

**Expected outcome**: Build succeeds with 0 errors

---

## Running the Application

### Development Mode

**In Xcode**:
1. Select "MenubarStatus" scheme
2. Press `⌘R` or click Run button
3. App icon should appear in menubar (top-right)

**Command Line**:
```bash
xcodebuild -project MenubarStatus.xcodeproj -scheme MenubarStatus -configuration Debug
open build/Debug/MenubarStatus.app
```

### Testing the Menubar

Once running:

1. **Verify menubar icon appears**
   - Look for app icon in menubar
   - Should display CPU and Memory by default
   
2. **Click menubar icon**
   - Dropdown menu should appear
   - Should show detailed metrics:
     - CPU: XX%
     - Memory: X.X/X.X GB
     - Disk: XX% (if enabled)
     - Network: ↑ XX KB/s ↓ XX KB/s (if enabled)
   - Should show "Settings..." option
   - Should show "Quit" option

3. **Open Settings**
   - Click "Settings..." in dropdown
   - Settings window should open
   - Verify controls:
     - [ ] Show CPU
     - [ ] Show Memory
     - [ ] Show Disk
     - [ ] Show Network
     - Refresh interval slider (1-5 seconds)
     - Disk selection dropdown
     - [ ] Launch at Login

4. **Modify Settings**
   - Toggle "Show Disk"
   - Verify menubar updates to include disk metrics
   - Change refresh interval to 1 second
   - Verify metrics update faster

5. **Quit Application**
   - Click "Quit" in dropdown
   - App should terminate
   - Menubar icon should disappear

---

## Running Tests

### Run All Tests

**In Xcode**:
- Press `⌘U` or
- Menu: Product → Test

**Command Line**:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus -destination 'platform=macOS'
```

### Run Specific Test Suites

**Unit Tests Only**:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' -only-testing:MenubarStatusTests
```

**UI Tests Only**:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' -only-testing:MenubarStatusUITests
```

**Specific Test Class**:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' \
  -only-testing:MenubarStatusTests/SystemMetricsTests
```

### Expected Test Results

✅ **All tests should pass**:
- Models: 15-20 tests
- Services: 20-25 tests
- Integration: 5-10 tests
- UI Tests: 5-8 tests
- **Total**: ~50-60 tests

---

## Performance Validation

### Manual Performance Check

1. **Open Activity Monitor**:
   ```bash
   open -a "Activity Monitor"
   ```

2. **Find MenubarStatus process**:
   - Search for "MenubarStatus" in process list
   
3. **Verify Resource Usage**:
   - **CPU**: Should be <2% (average over 1 minute)
   - **Memory**: Should be <50MB
   - Check after running for 5+ minutes

### Automated Performance Tests

Run performance tests in Xcode:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' \
  -only-testing:MenubarStatusTests/PerformanceTests
```

**Performance Benchmarks**:
- CPU Monitor: <20ms per call
- Memory Monitor: <10ms per call
- Disk Monitor: <50ms per call
- Network Monitor: <30ms per call
- Full refresh cycle: <100ms

---

## Troubleshooting

### App doesn't appear in menubar

**Check**:
1. Verify app is running (Activity Monitor)
2. Check console for errors: `log stream --predicate 'process == "MenubarStatus"'`
3. Ensure MenuBarExtra is properly initialized

**Fix**:
```swift
// In MenubarStatusApp.swift
@main
struct MenubarStatusApp: App {
    var body: some Scene {
        MenuBarExtra("MenubarStatus", systemImage: "cpu") {
            // Menu content
        }
    }
}
```

### Metrics show as 0 or "--"

**Check**:
1. Verify system monitoring permissions
2. Check if monitors are initialized
3. Verify timer is running

**Debug**:
```swift
// Add logging to SystemMonitor
print("Refresh called, interval: \(settings.refreshInterval)")
print("CPU: \(metrics.cpu.usagePercentage)%")
```

### High CPU or Memory Usage

**Check**:
1. Verify refresh interval (should be ≥1 second)
2. Check for retain cycles (use Instruments)
3. Verify caching is working

**Profile with Instruments**:
```bash
open -a Instruments
# Choose "Time Profiler" or "Allocations"
# Profile MenubarStatus.app
```

### Auto-launch not working

**Check**:
1. Verify `SMAppService` configuration
2. Check System Settings → Login Items
3. Verify Service Management capability is enabled

**Debug**:
```swift
import ServiceManagement

let status = SMAppService.mainApp.status
print("Launch service status: \(status)")
```

### Tests failing

**Common issues**:
1. **Async tests timeout**: Increase timeout in XCTestExpectation
2. **UI tests can't find elements**: Add accessibility identifiers
3. **Performance tests fail**: May need to adjust thresholds on slower Macs

**Run with verbose output**:
```bash
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' -verbose
```

---

## Development Workflow

### TDD Workflow (Recommended)

1. **Write failing test first**:
   ```bash
   # Open test file
   open MenubarStatusTests/Services/CPUMonitorTests.swift
   # Write test
   # Run test - should fail (⌘U)
   ```

2. **Implement minimum code to pass**:
   ```bash
   # Open implementation file
   open MenubarStatus/Services/CPUMonitor.swift
   # Write implementation
   # Run test - should pass (⌘U)
   ```

3. **Refactor**:
   - Clean up code
   - Remove duplication
   - Run tests to ensure still passing

4. **Repeat** for next feature

### Git Workflow

```bash
# Create feature branch (already on 001-mac-menubar-cpu)
git status

# Commit frequently
git add MenubarStatus/Services/CPUMonitor.swift
git add MenubarStatusTests/Services/CPUMonitorTests.swift
git commit -m "Implement CPU monitoring service"

# Push to remote
git push origin 001-mac-menubar-cpu
```

---

## Validation Checklist

Before considering the feature complete, verify:

### Functional Requirements
- [ ] App appears in menubar on launch
- [ ] Menubar displays CPU and Memory by default
- [ ] Clicking menubar shows detailed metrics
- [ ] Settings window can be opened
- [ ] All metrics can be toggled on/off
- [ ] Refresh interval can be adjusted (1-5s)
- [ ] Disk can be selected from available volumes
- [ ] Auto-launch can be enabled/disabled
- [ ] Settings persist after app restart
- [ ] App can be quit from menubar menu

### Performance Requirements
- [ ] CPU usage <2% average (checked in Activity Monitor)
- [ ] Memory usage <50MB (checked in Activity Monitor)
- [ ] Metrics update at configured interval
- [ ] No UI freezing or lag
- [ ] Smooth transitions and animations

### User Experience
- [ ] App respects system light/dark mode
- [ ] Menubar icon is readable in both modes
- [ ] All text is clear and properly formatted
- [ ] Settings window is intuitive
- [ ] No crashes or errors during normal use

### Code Quality
- [ ] All tests pass (⌘U)
- [ ] No compiler warnings
- [ ] Code follows Swift style guidelines
- [ ] All public APIs documented
- [ ] No force unwraps in production code

---

## Next Steps

After completing implementation:

1. **Code Review**: Have another developer review the code
2. **Manual Testing**: Follow this quickstart guide end-to-end
3. **Performance Testing**: Run for extended period (1+ hour)
4. **Beta Testing**: Distribute to 2-3 users for feedback
5. **Documentation**: Update README.md with user instructions
6. **Release**: Build archive and distribute

---

## Useful Commands

### Build Commands
```bash
# Clean build
xcodebuild clean -project MenubarStatus.xcodeproj -scheme MenubarStatus

# Build for release
xcodebuild -project MenubarStatus.xcodeproj -scheme MenubarStatus -configuration Release

# Archive for distribution
xcodebuild archive -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -archivePath build/MenubarStatus.xcarchive
```

### Debugging Commands
```bash
# View console logs
log stream --predicate 'process == "MenubarStatus"' --level debug

# Monitor CPU usage
top -pid $(pgrep MenubarStatus) -stats pid,cpu,mem

# Check launch agents
launchctl list | grep MenubarStatus
```

### Testing Commands
```bash
# Test with coverage
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' -enableCodeCoverage YES

# Generate test results
xcodebuild test -project MenubarStatus.xcodeproj -scheme MenubarStatus \
  -destination 'platform=macOS' -resultBundlePath TestResults.xcresult
```

---

## Support

### Documentation
- [data-model.md](./data-model.md) - Data structure reference
- [contracts/](./contracts/) - API protocol contracts
- [research.md](./research.md) - Technical decisions and rationale

### Resources
- [Apple: MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra)
- [Apple: ServiceManagement](https://developer.apple.com/documentation/servicemanagement)
- [Swift: Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)

---

**Status**: ✅ Quickstart guide complete and ready for development





