# Quickstart: Modern UI & Menubar Enhancement

**Feature**: 002-ui-menubar-ui  
**Date**: 2025-10-02  
**Status**: Complete

## Overview

This quickstart guide provides step-by-step integration test scenarios that validate the feature's user-facing functionality. Each scenario maps to acceptance criteria from the spec and can be executed manually or automated via XCUITest.

---

## Prerequisites

Before running these scenarios:

1. **Build the app**: Ensure MenubarStatus.app builds successfully
2. **Grant permissions**: System may prompt for monitoring permissions on first run
3. **Test environment**: 
   - macOS 13.0+ (Ventura or later)
   - At least 2 mounted volumes (internal + external) for multi-disk tests
   - Some running applications for process monitoring tests

---

## Scenario 1: Compact Menubar Display

**Goal**: Verify menubar display is compact and visually appealing

**User Story**: AS-1 from spec - "I see compact metrics displayed with icons and color-coded values"

### Steps

1. **Launch the app**
   ```
   Open MenubarStatus.app
   ```

2. **Observe menubar**
   - ✅ App icon appears in menubar (right side)
   - ✅ Metrics displayed next to icon
   - ✅ Icons visible (SF Symbols for CPU, memory, etc.)

3. **Measure space usage**
   - ✅ Total menubar width ≤ 200 points
   - ✅ At least 50% reduction from old text-only display

4. **Verify color coding**
   - Open Activity Monitor, stress CPU to >80%
   - ✅ CPU metric turns yellow/red in menubar
   - Reduce CPU load to <60%
   - ✅ CPU metric returns to green

5. **Test display modes** (via Settings)
   - Open Settings → Display tab
   - Switch to "Icon + Value" mode
   - ✅ See icons with percentages (e.g., "⚡ 45%")
   - Switch to "Icons Only" mode
   - ✅ See only colored icons
   - Hover over icon
   - ✅ Tooltip shows full metric name and value

### Expected Results

- Menubar display occupies ≤200 points width
- Color transitions smooth (green→yellow→red)
- All display modes functional
- Tooltips provide detailed information

### Automated Test

```swift
func testCompactMenubarDisplay() {
    let app = XCUIApplication()
    app.launch()
    
    // Find menubar extra
    let menubarItem = app.menuBarExtraItems.firstMatch
    XCTAssertTrue(menubarItem.exists)
    
    // Verify width constraint
    let width = menubarItem.frame.width
    XCTAssertLessThanOrEqual(width, 200)
    
    // Verify icons present
    XCTAssertTrue(menubarItem.images.count > 0)
}
```

---

## Scenario 2: Modern Dropdown Dashboard

**Goal**: Verify dropdown has modern card-based UI with charts

**User Story**: AS-3 from spec - "I see a modern dashboard with visual charts, progress bars, and detailed metrics"

### Steps

1. **Open dropdown**
   - Click menubar icon
   - ✅ Dropdown appears with smooth animation

2. **Verify card layout**
   - ✅ Header card shows system name, uptime, current time
   - ✅ Metric cards for CPU, Memory, Disk, Network
   - ✅ Each card has rounded corners, subtle shadow
   - ✅ Translucent background (vibrancy effect)

3. **Check card contents**
   - For each metric card:
     - ✅ Large percentage/value display
     - ✅ Horizontal progress bar with gradient
     - ✅ Detailed breakdown (e.g., CPU: user/system/idle)
     - ✅ Sparkline chart showing last 60 seconds
     - ✅ Last updated timestamp

4. **Test expandable cards**
   - Click CPU card
   - ✅ Card expands to show additional details
   - Click again
   - ✅ Card collapses

5. **Verify animations**
   - Watch metric updates
   - ✅ Values change with smooth transitions (no jarring jumps)
   - ✅ Progress bars animate smoothly
   - ✅ Sparklines update fluidly

### Expected Results

- Modern, visually appealing design
- All cards display correct information
- Animations smooth and polished
- UI responsive (no lag)

### Automated Test

```swift
func testDropdownDashboard() {
    let app = XCUIApplication()
    app.launch()
    
    // Open dropdown
    app.menuBarExtraItems.firstMatch.click()
    
    // Verify cards exist
    XCTAssertTrue(app.staticTexts["System Monitor"].exists)
    XCTAssertTrue(app.staticTexts["CPU"].exists)
    XCTAssertTrue(app.staticTexts["Memory"].exists)
    
    // Verify progress bars
    XCTAssertGreaterThan(app.progressIndicators.count, 0)
    
    // Verify charts (sparklines)
    XCTAssertGreaterThan(app.otherElements.matching(identifier: "sparkline").count, 0)
}
```

---

## Scenario 3: Process Management

**Goal**: View and terminate resource-consuming processes

**User Story**: AS-5 from spec - "I see the top 5 processes consuming the most CPU/Memory"

### Steps

1. **Enable process display**
   - Open Settings → Display tab
   - Toggle "Show Top Processes" ON
   - ✅ Setting saved

2. **View process list**
   - Open dropdown
   - Scroll to process card
   - ✅ "Top Processes" card visible
   - ✅ Up to 5 processes listed
   - ✅ Each shows icon, name, CPU%, and memory usage

3. **Verify sorting**
   - In Settings, select "Sort by CPU"
   - ✅ Processes sorted by CPU usage (highest first)
   - Switch to "Sort by Memory"
   - ✅ Processes sorted by memory usage (highest first)

4. **Test process termination**
   - Launch TextEdit (non-critical app)
   - Find TextEdit in process list
   - Click "Terminate" button
   - ✅ Confirmation dialog appears
   - Click "Confirm"
   - ✅ TextEdit quits
   - ✅ Process removed from list

5. **Test system process protection**
   - Find "kernel_task" or "WindowServer" in list (if visible)
   - ✅ "Terminate" button disabled or missing
   - ✅ Cannot terminate system-critical processes

### Expected Results

- Process list updates every refresh interval
- Sorting works correctly
- Non-critical processes can be terminated
- System processes are protected
- Confirmation required for termination

### Automated Test

```swift
func testProcessManagement() {
    let app = XCUIApplication()
    app.launch()
    
    // Enable process display
    app.menuBarExtraItems.firstMatch.click()
    app.buttons["Settings"].click()
    app.checkboxes["Show Top Processes"].click()
    
    // Verify process list
    app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()
    app.menuBarExtraItems.firstMatch.click()
    
    let processList = app.scrollViews["Top Processes"]
    XCTAssertTrue(processList.exists)
    XCTAssertLessThanOrEqual(processList.cells.count, 5)
}
```

---

## Scenario 4: Memory Purge

**Goal**: Free inactive memory with one click

**User Story**: AS-6 from spec - "I click 'Free Memory' and the system clears inactive memory"

### Steps

1. **Record initial memory**
   - Open dropdown
   - Note current memory usage (e.g., "8.2 GB used")

2. **Trigger memory purge**
   - Click "Free Memory" button in action card
   - ✅ Loading indicator appears
   - ✅ Button disabled during operation

3. **Verify result**
   - After 1-3 seconds, operation completes
   - ✅ Success message shows amount freed (e.g., "Freed 1.2 GB")
   - ✅ Memory card updates with new usage
   - ✅ Before/after statistics displayed

4. **Test error handling**
   - Click "Free Memory" again immediately
   - ✅ If no memory to free, shows message "No inactive memory to free"

5. **Verify UI updates**
   - ✅ Memory metric in menubar updates
   - ✅ Sparkline shows dip in memory usage
   - ✅ Progress bar reflects new value

### Expected Results

- Purge completes within 3 seconds
- Shows actual amount freed (may be 0)
- Memory metrics update automatically
- UI remains responsive during purge

### Automated Test

```swift
func testMemoryPurge() async throws {
    let app = XCUIApplication()
    app.launch()
    
    app.menuBarExtraItems.firstMatch.click()
    
    // Record before memory
    let memoryCard = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'GB'")).firstMatch
    let beforeText = memoryCard.label
    
    // Trigger purge
    app.buttons["Free Memory"].click()
    
    // Wait for completion
    let successAlert = app.alerts.firstMatch
    XCTAssertTrue(successAlert.waitForExistence(timeout: 5))
    
    // Verify freed amount shown
    XCTAssertTrue(successAlert.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Freed'")).firstMatch.exists)
}
```

---

## Scenario 5: Multi-Disk Monitoring

**Goal**: Monitor multiple mounted volumes simultaneously

**User Story**: AS-7 from spec - "I see separate cards for each mounted disk"

### Steps

1. **Verify current disks**
   - Open dropdown
   - ✅ See card for internal disk (e.g., "Macintosh HD")
   - ✅ Shows capacity, usage percentage, read/write speeds

2. **Mount external disk**
   - Plug in USB drive or mount network volume
   - ✅ New disk card appears automatically
   - ✅ Smooth animation on appearance
   - ✅ Shows disk name, capacity, usage

3. **Verify each disk card**
   - For each disk:
     - ✅ Unique icon (internal vs. external)
     - ✅ Progress bar for usage
     - ✅ Individual sparkline chart
     - ✅ Read/write speed metrics

4. **Unmount disk**
   - Eject external disk
   - ✅ Disk card disappears smoothly
   - ✅ No errors or crashes
   - ✅ Remaining disks unaffected

5. **Test ordering**
   - ✅ Internal disks listed first
   - ✅ External disks second
   - ✅ Network volumes last

### Expected Results

- All mounted volumes detected
- Cards appear/disappear dynamically
- No crashes on mount/unmount events
- Each disk monitored independently

### Automated Test

```swift
func testMultiDiskMonitoring() {
    let app = XCUIApplication()
    app.launch()
    
    app.menuBarExtraItems.firstMatch.click()
    
    // Should see at least one disk (internal)
    let diskCards = app.scrollViews.matching(NSPredicate(format: "identifier CONTAINS 'disk'"))
    XCTAssertGreaterThanOrEqual(diskCards.count, 1)
    
    // Each disk should have progress bar
    for diskCard in diskCards.allElementsBoundByIndex {
        XCTAssertTrue(diskCard.progressIndicators.firstMatch.exists)
    }
}
```

---

## Scenario 6: Disk Health Monitoring

**Goal**: Display S.M.A.R.T. health status for disks

**User Story**: AS-8 from spec - "I see S.M.A.R.T. health status, total hours used, and health indicator"

### Steps

1. **View disk health**
   - Open dropdown
   - Locate disk card
   - ✅ Health badge visible (icon + color)
   - ✅ Shows one of: Good, Warning, Critical, N/A

2. **Expand disk details**
   - Click disk card to expand
   - ✅ Shows power-on hours (e.g., "1,234 days")
   - ✅ Shows read/write error counts (if available)
   - ✅ Shows health status description

3. **Verify health indicators**
   - For "Good" status:
     - ✅ Green color
     - ✅ Checkmark icon
   - For "Warning" status (if testable):
     - ✅ Yellow color
     - ✅ Warning triangle icon
   - For "Unavailable" status (network drive):
     - ✅ Gray color
     - ✅ Question mark icon
     - ✅ "Not Available" text

4. **Test graceful degradation**
   - Mount network volume (no SMART support)
   - ✅ Shows "N/A" instead of crashing
   - ✅ Other health data hidden gracefully

### Expected Results

- Health status accurate and up-to-date
- Color coding matches status
- Graceful handling of unavailable data
- Icons match macOS design language

### Automated Test

```swift
func testDiskHealthDisplay() {
    let app = XCUIApplication()
    app.launch()
    
    app.menuBarExtraItems.firstMatch.click()
    
    // Find disk card with health indicator
    let healthBadge = app.images.matching(NSPredicate(format: "identifier CONTAINS 'health'")).firstMatch
    XCTAssertTrue(healthBadge.exists)
    
    // Should have a color (not gray means status available)
    // Actual color depends on disk health, just verify presence
    XCTAssertNotNil(healthBadge.value)
}
```

---

## Scenario 7: Sparkline Charts

**Goal**: View 60-second historical trends

**User Story**: AS-9 from spec - "I see mini sparkline graphs showing the last 60 seconds of trend data"

### Steps

1. **Open dropdown (fresh start)**
   - Wait at least 10 seconds for data to accumulate
   - Open dropdown
   - ✅ Each metric card shows sparkline

2. **Verify sparkline contents**
   - For each metric:
     - ✅ Line chart visible
     - ✅ Shows trend over time
     - ✅ Color matches theme (green/yellow/red)

3. **Test real-time updates**
   - Keep dropdown open
   - Stress CPU (open many apps)
   - ✅ CPU sparkline updates in real-time
   - ✅ Line extends to the right
   - ✅ Old data scrolls off the left

4. **Verify 60-second window**
   - Wait 65 seconds
   - ✅ Sparkline shows approximately 60 data points
   - ✅ Oldest points (>60s) removed

5. **Test color adaptation**
   - Switch theme (Settings → Appearance → Cool Theme)
   - ✅ Sparklines change color to match theme
   - ✅ Gradient applied correctly

### Expected Results

- Sparklines render smoothly (60fps)
- Data updates every refresh interval
- Automatic time window management
- Theme-aware coloring

### Automated Test

```swift
func testSparklineCharts() {
    let app = XCUIApplication()
    app.launch()
    
    // Let data accumulate
    sleep(15)
    
    app.menuBarExtraItems.firstMatch.click()
    
    // Find sparkline charts
    let sparklines = app.otherElements.matching(identifier: "sparkline")
    XCTAssertGreaterThanOrEqual(sparklines.count, 4) // CPU, Memory, Disk, Network
    
    // Verify charts are visible (have non-zero frame)
    for sparkline in sparklines.allElementsBoundByIndex {
        XCTAssertGreaterThan(sparkline.frame.width, 0)
        XCTAssertGreaterThan(sparkline.frame.height, 0)
    }
}
```

---

## Scenario 8: Theme Switching

**Goal**: Change color themes dynamically

**User Story**: AS-4 from spec - "I can configure color themes"

### Steps

1. **Open theme settings**
   - Open Settings → Appearance tab
   - ✅ Theme selector visible
   - ✅ 5 themes listed:
     - System Default
     - Monochrome
     - Traffic Light
     - Cool
     - Warm

2. **Switch to Monochrome theme**
   - Select "Monochrome"
   - ✅ All colors become grayscale
   - ✅ Menubar updates immediately
   - ✅ Dropdown updates (if open)

3. **Switch to Traffic Light theme**
   - Select "Traffic Light"
   - ✅ High contrast red/yellow/green
   - ✅ Progress bars use new colors
   - ✅ Sparklines use new colors
   - ✅ Health indicators use new colors

4. **Test persistence**
   - Close app
   - Relaunch app
   - ✅ Theme setting remembered
   - ✅ UI shows last selected theme

5. **Verify dark mode compatibility**
   - Switch macOS to Dark Mode (System Settings)
   - ✅ App UI adapts to dark mode
   - ✅ Theme colors remain distinguishable
   - ✅ Text remains readable

### Expected Results

- All themes apply instantly
- Themes persist across restarts
- Dark/light mode compatibility
- No visual glitches during switch

### Automated Test

```swift
func testThemeSwitching() {
    let app = XCUIApplication()
    app.launch()
    
    app.menuBarExtraItems.firstMatch.click()
    app.buttons["Settings"].click()
    
    // Switch to Appearance tab
    app.buttons["Appearance"].click()
    
    // Select Monochrome theme
    app.radioButtons["Monochrome"].click()
    
    // Close settings
    app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()
    
    // Verify theme applied (check for grayscale colors)
    // This would require inspecting actual rendered colors
    // For now, just verify no crash
    app.menuBarExtraItems.firstMatch.click()
    XCTAssertTrue(app.staticTexts["CPU"].exists)
}
```

---

## Scenario 9: Settings Persistence

**Goal**: Verify all settings persist across app restarts

**Steps**

1. **Configure all settings**
   - Display tab:
     - ✅ Enable CPU, Memory, Disk
     - ✅ Set display mode to "Icon + Value"
     - ✅ Enable "Show Top Processes"
     - ✅ Reorder metrics (drag-and-drop)
   - Appearance tab:
     - ✅ Select "Cool" theme
     - ✅ Enable compact mode
   - Monitoring tab:
     - ✅ Set refresh interval to 3.0 seconds

2. **Restart app**
   - Quit app completely
   - Relaunch app

3. **Verify persistence**
   - ✅ All metrics still enabled
   - ✅ Display mode unchanged
   - ✅ Top processes still showing
   - ✅ Metric order preserved
   - ✅ Theme still "Cool"
   - ✅ Refresh interval still 3.0s

### Expected Results

- All settings persisted via UserDefaults
- No reset to defaults on restart
- UI reflects saved settings immediately

---

## Scenario 10: Performance Validation

**Goal**: Ensure UI performs at 60fps with minimal resource usage

**Steps**

1. **Monitor frame rate**
   - Open Xcode → Debug → View Debugging → FPS
   - ✅ Frame rate consistently ≥55fps
   - ✅ No dropped frames during animations

2. **Check memory usage**
   - Open Activity Monitor
   - Find MenubarStatus process
   - ✅ Memory footprint <50MB
   - ✅ No memory leaks (stays stable over time)

3. **Measure CPU overhead**
   - ✅ CPU usage <5% when idle (menubar only)
   - ✅ CPU usage <10% when dropdown open
   - ✅ CPU spikes brief during updates (<16ms)

4. **Test with all features enabled**
   - Enable all metrics
   - Enable top processes
   - Enable multi-disk monitoring
   - Keep dropdown open
   - ✅ Still maintains 60fps
   - ✅ Memory stays under 50MB

### Expected Results

- Smooth, responsive UI
- Low resource footprint
- No memory leaks
- Efficient metric collection

---

## Validation Checklist

Before marking feature complete, verify:

- [ ] All 10 scenarios pass
- [ ] No crashes or errors
- [ ] Visual design polished
- [ ] Animations smooth
- [ ] Settings persist correctly
- [ ] Performance targets met
- [ ] Dark/light mode compatible
- [ ] Accessibility support (VoiceOver basics)
- [ ] All error cases handled gracefully
- [ ] User-facing text clear and helpful

---

## Automated Test Suite

Run complete test suite:

```bash
cd /Users/lihongwen/Projects/memubar-status
xcodebuild test \
  -project MenubarStatus/MenubarStatus.xcodeproj \
  -scheme MenubarStatus \
  -destination 'platform=macOS'
```

**Expected Output**:
- All unit tests pass (100%)
- All integration tests pass (100%)
- UI tests pass (≥95% - some may be flaky)
- Performance tests meet thresholds

---

**Status**: ✅ Quickstart guide complete  
**Ready For**: Implementation and testing


