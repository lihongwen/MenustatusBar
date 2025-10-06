# Quickstart: Menubar Compact Display & UI Modernization

**Feature**: 003-menubar-ui-menubar  
**Date**: 2025-10-05  
**Purpose**: Integration test scenarios for compact precise display

---

## Test Scenario 1: Compact Format Display

**User Story**: Display shows precise values in compact format

**Steps**:
1. Launch app
2. Observe menubar display

**Expected**:
✅ Format: `⚡45% 💾72% 💿15% 🌐↓2.3M`
✅ Icons colored (green/yellow/red based on value)
✅ Integer percentages (no decimals)
✅ Smart network units (K/M/G)
✅ Total width: ~120-150pt

---

## Test Scenario 2: Display Mode Removal

**User Story**: Settings has no display mode picker

**Steps**:
1. Open Settings (⌘,)
2. Go to Display tab
3. Scan for display mode options

**Expected**:
✅ No "Display Mode" section
✅ No picker with 4 options
✅ Only "Show Icons" toggle visible
✅ Metric order reordering still available

---

## Test Scenario 3: Precise Real-Time Updates

**User Story**: Values update every refresh with exact data

**Steps**:
1. Monitor CPU at 45%
2. Wait 2 seconds (refresh)
3. CPU increases to 47%
4. Observe menubar

**Expected**:
✅ Display updates from "⚡45%" to "⚡47%"
✅ No ranges (not "40-60%")
✅ Icon color adjusts smoothly
✅ Update happens every refresh cycle

---

## Test Scenario 4: Color Coding Precision

**User Story**: Icon colors reflect exact values

**Steps**:
1. CPU at 30% (green)
2. CPU at 65% (yellow)
3. CPU at 85% (red)

**Expected**:
✅ 30%: Green icon
✅ 65%: Yellow/orange icon
✅ 85%: Red icon
✅ Smooth 300ms color transitions

---

## Test Scenario 5: Network Smart Units

**User Story**: Network speeds display compactly

**Steps**:
1. Download at 15 KB/s → "↓15.0K"
2. Download at 2.3 MB/s → "↓2.3M"
3. Download at 1.2 GB/s → "↓1.2G"

**Expected**:
✅ Automatic unit selection
✅ One decimal place
✅ Compact format (3-5 chars)

---

## Test Scenario 6: Dropdown Exact Values

**User Story**: Dropdown shows decimal precision

**Steps**:
1. Menubar shows "⚡45%"
2. Click menubar to open dropdown
3. View CPU card

**Expected**:
✅ Menubar: "45%" (integer)
✅ Dropdown: "45.23%" (decimal)
✅ Both values from same source

---

## Test Scenario 7: Space Efficiency

**User Story**: 4 metrics fit in ~150pt

**Steps**:
1. Enable all 4 metrics
2. Measure menubar width

**Expected**:
✅ Total width ≤ 150pt
✅ All metrics visible
✅ Clear separation between metrics
✅ No text overlap

---

## Test Scenario 8: Settings Migration

**User Story**: Old settings preserved

**Preconditions**:
- Old version with displayMode setting

**Steps**:
1. Upgrade to new version
2. Launch app
3. Check settings

**Expected**:
✅ App launches successfully
✅ Metric order preserved
✅ Theme preserved
✅ Icons shown (unless was graphMode)

---

## Test Scenario 9: Hover Tooltips

**User Story**: Tooltips show exact values

**Steps**:
1. Hover over "⚡45%" in menubar
2. Wait for tooltip

**Expected**:
✅ Tooltip appears
✅ Shows "CPU Usage: 45.23%"
✅ Includes decimal precision
✅ Follows macOS tooltip style

---

## Test Scenario 10: UI Modernization

**User Story**: Modern spacing and typography

**Steps**:
1. Open dropdown dashboard
2. Open settings window
3. Inspect visual design

**Expected**:
✅ Consistent 8/16/24px spacing
✅ SF Pro fonts throughout
✅ 12pt card corner radius
✅ Subtle shadows
✅ Smooth animations (150ms/300ms)

---

**Total Scenarios**: 10  
**Status**: Ready for implementation

