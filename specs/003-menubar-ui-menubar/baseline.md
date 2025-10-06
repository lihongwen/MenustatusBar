# DisplayMode Behavior Baseline

**Date**: 2025-10-05  
**Purpose**: Document current menubar display modes before refactoring

---

## Current Display Modes

### 1. Icon + Value (iconAndValue)
**Implementation**: `MenubarLabel.iconAndValue()`

**Format**: `[Icon] [Percentage]%`
- Icon: SF Symbols (e.g., ⚡ for CPU)
- Value: Integer percentage (e.g., `45%`)
- Spacing: Icon-value 2px, between metrics 6px
- Width: ~60pt per metric

**Example**: ⚡ 45% 💾 72% 💿 15% 🌐 ↓2.3M

---

### 2. Compact Text (compactText)
**Implementation**: `MenubarLabel.compactText()`

**Format**: `[Abbreviated Label] [Value]%`
- Label: "CPU", "Mem", "Disk", "Net"
- Value: Integer percentage
- Width: ~70pt per metric

**Example**: CPU 45% Mem 72% Disk 15%

---

### 3. Graph Mode (graphMode)  
**Implementation**: `MenubarLabel.graphMark()`

**Format**: Mini sparkline/bar indicator
- Visual: Small colored bar/graph
- No text, just visual indicator
- Width: ~40pt per metric
- Color: Status-based (green/yellow/red)

---

### 4. Icons Only (iconsOnly)
**Implementation**: `MenubarLabel.iconOnly()`

**Format**: Just colored SF Symbols icons
- Icon color reflects status (green/yellow/red)
- No numeric values
- Width: ~20pt per metric
- Hover shows full details in dropdown

---

## Code Structure Before Refactor

### DisplayMode Enum
**File**: `Models/DisplayConfiguration.swift`
```swift
enum DisplayMode: String, Codable, CaseIterable {
    case iconAndValue = "iconAndValue"
    case compactText = "compactText"
    case graphMode = "graphMode"
    case iconsOnly = "iconsOnly"
}
```

### MenubarLabel Rendering
**File**: `Views/MenubarLabel.swift`

**Mode Switch**:
```swift
switch summary.mode {
case .iconAndValue:
    iconAndValue(item)
case .compactText:
    compactText(item)
case .graphMode:
    graphMark(item)
case .iconsOnly:
    iconOnly(item)
}
```

### Settings UI
**File**: `Views/SettingsView.swift`

**Mode Picker** (lines ~175-193):
- Picker control for selecting display mode
- Shows all 4 modes with displayName
- Bound to `settings.displayConfiguration.displayMode`

---

## Behavior Notes

### Current Issues (to be fixed)
1. **No real-time precision**: Icons change color by ranges (0-20%, 20-40%, etc), not exact values
2. **Inconsistent spacing**: Different modes have different spacing
3. **Mode complexity**: 4 different implementations to maintain
4. **User confusion**: Users don't know which mode to choose
5. **Space inefficiency**: Some modes waste space (compactText), others lack info (iconsOnly)

### What Works Well (to preserve)
1. **Color coding**: Green/yellow/red status indication is intuitive
2. **SF Symbols**: Icons are recognizable (⚡ CPU, 💾 Memory, etc.)
3. **Dropdown details**: Clicking shows full metrics
4. **Performance**: All modes render at 60fps
5. **Theme support**: Works with all color themes

---

## Migration Strategy

### Delete (after new implementation)
1. `DisplayMode` enum from `DisplayConfiguration.swift`
2. `displayMode` field from `DisplayConfiguration` struct
3. Mode switch statement from `MenubarLabel.swift`
4. Mode-specific rendering methods (iconAndValue, compactText, graphMark, iconOnly)
5. Display mode picker from `SettingsView.swift`
6. Estimated ~700 lines of code to remove

### Replace With
1. Single unified compact format: `⚡45% 💾72% 💿15% 🌐↓2.3M`
2. `CompactFormatter` utility for consistent formatting
3. `showMenubarIcons` boolean toggle (replace mode picker)
4. Precise real-time values (not ranges)
5. Estimated ~200 lines of new code

---

## Visual Comparison Target

### Before (Icon + Value mode)
```
⚡ 45%   💾 72%   💿 15%   🌐 ↓2.3M
```
- Width: ~240pt for 4 metrics
- Icons and values, but switch between modes

### After (Unified Compact)
```
⚡45% 💾72% 💿15% 🌐↓2.3M
```
- Width: ~150pt for 4 metrics (37% smaller!)
- No space after icon, tighter spacing
- Always shows icons + precise values
- No mode switching needed

---

## Testing Checklist

Before starting refactor, verify:
- [x] Current build succeeds
- [x] All 4 display modes render correctly
- [x] Color coding works (green/yellow/red)
- [x] Dropdown shows detailed metrics
- [x] Settings mode picker functional
- [x] No console errors or warnings

After refactor, verify:
- [ ] New compact format displays correctly
- [ ] Precise percentages (not ranges)
- [ ] Exact color coding per value
- [ ] Width ≤150pt for 4 metrics
- [ ] Settings migration works
- [ ] No DisplayMode references remain

---

**Status**: Baseline documented ✓  
**Next**: Begin TDD phase with failing tests


