# MenubarStatus v1.0.1 Release Notes

**Release Date**: October 6, 2025  
**Branch**: main  
**Previous Version**: v1.0.0

---

## 🎉 Major Features

### Unified Compact Display
- **Removed 4 display modes**, replaced with single optimized format
- **Space-efficient**: 4 metrics fit in ~150pt of menubar space
- **Precise values**: Shows exact real-time data, not approximations
- **Smart formatting**: Integer percentages for at-a-glance monitoring

### New Display Formats
- **CPU**: Shows usage percentage (e.g., `💻18%`)
- **Memory**: Shows actual usage in GB (e.g., `💾11.8G`)
- **Disk**: 
  - Capacity mode: Shows percentage (e.g., `💿79%`)
  - I/O Speed mode: Shows read/write speed (e.g., `💿↓15.3K`)
- **Network**: Shows download speed with smart units (e.g., `🌐↓2.3M`)

### Icon Customization
- **New emoji icons**: 💻 CPU, 💾 Memory, 💿 Disk, 🌐 Network
- **Toggle control**: Show/hide icons from settings
- **Instant sync**: Changes apply immediately to menubar

---

## ✨ UI Modernization

### Design System
- **UIStyleConfiguration**: Centralized design constants
- **Consistent spacing**: 8/16/24px scale throughout
- **Modern styling**: 12pt corner radius, subtle shadows
- **Smooth animations**: 150ms/300ms transitions

### Enhanced Views
- **MenuBarView**: Updated dropdown with modern card styling
- **MetricCard**: Consistent padding and corner radius
- **SettingsView**: Improved spacing and typography
- **Hover tooltips**: Show exact decimal values on hover

---

## 🔧 Technical Improvements

### New Components
- `CompactFormatter.swift`: Smart value formatting with K/M/G units
- `UIStyleConfiguration.swift`: Design system constants
- `DesignSystem.swift`: Layout utilities
- `MenubarLabel.swift`: Unified menubar display component
- `MenubarSummaryBuilder.swift`: Metric formatting logic

### Code Quality
- **Simplified codebase**: Removed ~700 lines of display mode code
- **Better architecture**: Pure formatting functions
- **Settings migration**: Preserves user preferences from v1.0.0
- **Comprehensive tests**: 40+ test cases for edge cases and performance

---

## 🐛 Bug Fixes
- Fixed settings sync issues with menubar display
- Improved real-time updates for metric changes
- Enhanced color coding precision

---

## 📦 Installation

1. Download `MenubarStatus-v1.0.1.dmg`
2. Open the DMG file
3. Drag MenubarStatus.app to Applications folder
4. Launch from Applications

---

## ⚙️ Upgrade Notes

- **Automatic migration**: Old settings will be preserved
- **Icon preference**: Previous display mode converts to icon visibility setting
- **No action needed**: Just install and run

---

## 📊 Performance

- **Frame rate**: <16ms render time (60fps)
- **Memory**: <50MB footprint
- **CPU usage**: <5% at idle
- **Menubar width**: ~150pt for 4 metrics

---

## 🙏 Acknowledgments

Feature implemented following TDD methodology with 28 tasks completed across 5 phases.

---

**Download**: [MenubarStatus-v1.0.1.dmg](./MenubarStatus-v1.0.1.dmg)

