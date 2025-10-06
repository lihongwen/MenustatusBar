# Data Model: Menubar Compact Display & UI Modernization

**Feature**: 003-menubar-ui-menubar  
**Date**: 2025-10-05  
**Purpose**: Define data structures for compact precise display implementation

---

## Overview

This document defines the data models needed to implement compact precise menubar display. The design focuses on:
- **Simplicity**: Remove DisplayMode enum, use single format
- **Precision**: Store and display exact values, not ranges
- **Compactness**: Efficient string formatting (K/M/G units)
- **Testability**: Pure functions for formatting logic

---

## Core Models

### 1. DisplayConfiguration (Modified - Simplified)

**Purpose**: User preferences for menubar display

**Type**: Struct (Codable for persistence)

**Changes from Existing**:
- ❌ **REMOVE**: `displayMode: DisplayMode` field entirely
- ✅ **KEEP**: All other fields unchanged
- ➕ **ADD**: `showMenubarIcons: Bool` for icon toggle

**Updated Definition**:
```swift
/// User preferences for how metrics are displayed in the menubar
struct DisplayConfiguration: Codable, Equatable {
    // ===== EXISTING FIELDS (UNCHANGED) =====
    
    /// Ordering of metrics in menubar (serialized MetricType.rawValue)
    var metricOrder: [String]
    
    /// Auto-hide metrics below threshold
    var autoHideEnabled: Bool
    
    /// Threshold for auto-hide (0.0-1.0, e.g., 0.5 = 50%)
    var autoHideThreshold: Double
    
    /// Color theme identifier
    var colorThemeIdentifier: String
    
    /// Show top processes in dropdown
    var showTopProcesses: Bool
    
    /// Process sorting criteria
    var processSortCriteria: String
    
    /// Maximum metrics visible in menubar
    var maxVisibleMetrics: Int
    
    // ===== NEW FIELD =====
    
    /// Whether to show SF Symbols icons in menubar
    /// Replaces displayMode functionality
    var showMenubarIcons: Bool
    
    // ===== REMOVED FIELD =====
    // var displayMode: DisplayMode  ← DELETE THIS ENUM AND FIELD
    
    /// Default initializer
    init(
        metricOrder: [String] = MetricType.allCases.map { $0.rawValue },
        autoHideEnabled: Bool = false,
        autoHideThreshold: Double = 0.5,
        colorThemeIdentifier: String = "system",
        showTopProcesses: Bool = false,
        processSortCriteria: String = "cpu",
        maxVisibleMetrics: Int = 4,
        showMenubarIcons: Bool = true  // NEW: Default to showing icons
    ) {
        self.metricOrder = metricOrder
        self.autoHideEnabled = autoHideEnabled
        self.autoHideThreshold = max(0.0, min(1.0, autoHideThreshold))
        self.colorThemeIdentifier = colorThemeIdentifier
        self.showTopProcesses = showTopProcesses
        self.processSortCriteria = processSortCriteria
        self.maxVisibleMetrics = maxVisibleMetrics
        self.showMenubarIcons = showMenubarIcons
    }
    
    /// Computed: Ordered metric types
    var orderedMetrics: [MetricType] {
        metricOrder.compactMap { MetricType(rawValue: $0) }
    }
}
```

**Migration Strategy**:
```swift
// In SettingsManager or migration code
extension DisplayConfiguration {
    /// Migrate from version with DisplayMode to version without
    static func migrate(from oldData: Data) -> DisplayConfiguration {
        // Try to decode old format first
        struct OldConfiguration: Codable {
            var metricOrder: [String]
            var autoHideEnabled: Bool
            var autoHideThreshold: Double
            var colorThemeIdentifier: String
            var showTopProcesses: Bool
            var processSortCriteria: String
            var maxVisibleMetrics: Int
            var displayMode: String?  // Old field, might exist
        }
        
        guard let old = try? JSONDecoder().decode(OldConfiguration.self, from: oldData) else {
            return DisplayConfiguration()  // Use defaults if can't decode
        }
        
        // Map old displayMode to showMenubarIcons
        let showIcons: Bool
        if let mode = old.displayMode {
            // graphMode was the only one without traditional icons
            showIcons = (mode != "graphMode")
        } else {
            showIcons = true  // Default
        }
        
        return DisplayConfiguration(
            metricOrder: old.metricOrder,
            autoHideEnabled: old.autoHideEnabled,
            autoHideThreshold: old.autoHideThreshold,
            colorThemeIdentifier: old.colorThemeIdentifier,
            showTopProcesses: old.showTopProcesses,
            processSortCriteria: old.processSortCriteria,
            maxVisibleMetrics: old.maxVisibleMetrics,
            showMenubarIcons: showIcons
        )
    }
}
```

---

### 2. UIStyleConfiguration (New)

**Purpose**: Centralized design system constants

**Type**: Enum with static properties (namespace, not instantiated)

**Definition**:
```swift
/// Design system constants for consistent UI styling
enum UIStyleConfiguration {
    
    // MARK: - Spacing (8px base scale)
    
    /// Small spacing: 8pt (for tight layouts, icon-text gaps)
    static let spacingSmall: CGFloat = 8
    
    /// Medium spacing: 16pt (for card padding, section gaps)
    static let spacingMedium: CGFloat = 16
    
    /// Large spacing: 24pt (for major section separation)
    static let spacingLarge: CGFloat = 24
    
    // MARK: - Menubar Specific
    
    /// Spacing between icon and value in menubar
    static let menubarIconValueSpacing: CGFloat = 2
    
    /// Spacing between metrics in menubar
    static let menubarMetricSpacing: CGFloat = 6
    
    // MARK: - Corner Radius
    
    /// Button corner radius
    static let cornerRadiusButton: CGFloat = 8
    
    /// Card corner radius
    static let cornerRadiusCard: CGFloat = 12
    
    /// Sheet/window corner radius
    static let cornerRadiusSheet: CGFloat = 16
    
    // MARK: - Shadow
    
    /// Shadow offset (subtle depth)
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    /// Shadow blur radius
    static let shadowRadius: CGFloat = 4
    
    /// Shadow opacity (light for subtlety)
    static let shadowOpacity: Double = 0.1
    
    // MARK: - Typography
    
    /// Menubar value font (precise numbers)
    static let fontMenubarValue: Font = .system(size: 11, weight: .bold, design: .rounded)
    
    /// Menubar unit font (%, K, M, G)
    static let fontMenubarUnit: Font = .system(size: 9, weight: .medium)
    
    /// Menubar icon size
    static let iconMenubarSize: CGFloat = 11
    
    /// Card title font
    static let fontCardTitle: Font = .system(size: 14, weight: .semibold)
    
    /// Card large value font (main metric display)
    static let fontCardValue: Font = .system(size: 24, weight: .bold, design: .rounded)
    
    /// Card secondary text font
    static let fontCardSecondary: Font = .system(size: 12, weight: .regular)
    
    /// Settings label font
    static let fontSettingsLabel: Font = .system(size: 13, weight: .medium)
    
    // MARK: - Animation
    
    /// Quick animation for hover effects
    static let animationDurationQuick: Double = 0.15
    
    /// Standard animation duration for color transitions
    static let animationDurationStandard: Double = 0.3
    
    // MARK: - Colors (use system colors for light/dark mode support)
    
    /// Text primary color (adapts to light/dark)
    static let colorTextPrimary: Color = .primary
    
    /// Text secondary color (70% opacity)
    static let colorTextSecondary: Color = .secondary
}
```

---

### 3. CompactFormatter (New Utility)

**Purpose**: Format values compactly with smart units

**Type**: Enum with static methods (stateless utility)

**Definition**:
```swift
/// Utilities for compact value formatting
enum CompactFormatter {
    
    /// Format percentage as integer for menubar
    /// - Parameter percentage: 0.0-100.0
    /// - Returns: Compact string like "45%"
    static func formatPercentage(_ percentage: Double) -> String {
        let rounded = Int(round(percentage))
        return "\(rounded)%"
    }
    
    /// Format network speed with smart units (K/M/G)
    /// - Parameter bytesPerSecond: Raw bytes per second
    /// - Returns: Compact string like "2.3M", "15.3K", "1.2G"
    static func formatNetworkSpeed(_ bytesPerSecond: UInt64) -> String {
        let bytes = Double(bytesPerSecond)
        
        if bytes < 1_024 {
            return "0K"  // Less than 1 KB/s
        } else if bytes < 1_048_576 {
            // KB range (1 KB - 999 KB)
            let kb = bytes / 1_024
            return String(format: "%.1fK", kb)
        } else if bytes < 1_073_741_824 {
            // MB range (1 MB - 999 MB)
            let mb = bytes / 1_048_576
            return String(format: "%.1fM", mb)
        } else {
            // GB range (≥1 GB)
            let gb = bytes / 1_073_741_824
            return String(format: "%.1fG", gb)
        }
    }
    
    /// Format metric with icon for menubar display
    /// - Parameters:
    ///   - type: Metric type (CPU, Memory, etc.)
    ///   - percentage: Exact percentage value
    ///   - bytesPerSecond: Optional network speed
    ///   - theme: Color theme for icon coloring
    ///   - showIcon: Whether to include icon
    /// - Returns: Formatted display text
    static func formatForMenubar(
        type: MetricType,
        percentage: Double,
        bytesPerSecond: UInt64? = nil,
        theme: ColorTheme,
        showIcon: Bool
    ) -> (text: String, color: Color) {
        let icon = showIcon ? type.sfSymbol + " " : ""
        let value: String
        
        switch type {
        case .cpu, .memory, .disk:
            value = formatPercentage(percentage)
        case .network:
            if let bytes = bytesPerSecond {
                let speed = formatNetworkSpeed(bytes)
                value = "↓\(speed)"  // Assume download for simplicity
            } else {
                value = "0K"
            }
        }
        
        let color = theme.statusColor(for: percentage)
        return (text: icon + value, color: color)
    }
    
    /// Format metric with full precision for dropdown
    /// - Parameters:
    ///   - type: Metric type
    ///   - percentage: Exact percentage value
    /// - Returns: Formatted string with decimal precision
    static func formatForDropdown(type: MetricType, percentage: Double) -> String {
        return String(format: "%.2f%%", percentage)
    }
}
```

---

### 4. MenubarSummary.Item (Modified)

**Purpose**: Display item for menubar

**Type**: Struct (within MenubarSummary)

**Changes from Existing**:
- `primaryText` now holds compact formatted string (e.g., "45%")
- `percentage` continues to hold exact value for color calculation
- No mode-specific fields needed

**Updated Definition**:
```swift
struct MenubarSummary {
    struct Item: Identifiable {
        let id: String
        let icon: String               // SF Symbols name (e.g., "cpu.fill")
        let title: String              // Short label (e.g., "CPU") - for dropdown
        let primaryText: String        // Compact formatted text (e.g., "45%")
        let secondaryText: String?     // Optional detail (rarely used in compact mode)
        let percentage: Double         // Original exact value (for color calculation)
        let theme: ColorTheme          // Color scheme
    }
    
    let items: [Item]
    // No mode field needed anymore
}
```

**Example Creation** (in MenubarSummaryBuilder):
```swift
// Using CompactFormatter
let formatted = CompactFormatter.formatForMenubar(
    type: .cpu,
    percentage: metrics.cpu.usagePercentage,
    theme: theme,
    showIcon: settings.displayConfiguration.showMenubarIcons
)

return MenubarSummary.Item(
    id: "cpu",
    icon: "cpu.fill",
    title: "CPU",
    primaryText: formatted.text,  // "⚡45%" or "45%" depending on showIcon
    secondaryText: nil,  // Not used in compact mode
    percentage: metrics.cpu.usagePercentage,  // Keep exact 45.23 for colors
    theme: theme
)
```

---

## Supporting Models

### 5. MetricType (Existing, Add SF Symbols Property)

**Purpose**: Enumeration of available metrics

**Enhancement**: Add SF Symbols name property

**Updated Definition**:
```swift
enum MetricType: String, CaseIterable, Codable {
    case cpu
    case memory
    case disk
    case network
    
    var displayName: String {
        // Existing localized names
        let lang = LocalizedStrings.language
        switch self {
        case .cpu: return "CPU"
        case .memory: return lang == .chinese ? "内存" : "Memory"
        case .disk: return lang == .chinese ? "磁盘" : "Disk"
        case .network: return lang == .chinese ? "网络" : "Network"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .cpu: return "cpu.fill"
        case .memory: return "memorychip.fill"
        case .disk: return "internaldrive.fill"
        case .network: return "network"
        }
    }
    
    var icon: String {
        // Existing emoji icons (deprecated, use sfSymbol instead)
        switch self {
        case .cpu: return "⚡"
        case .memory: return "💾"
        case .disk: return "💿"
        case .network: return "🌐"
        }
    }
}
```

---

### 6. ColorTheme (Existing, No Changes)

**Purpose**: Color scheme for health status

**Definition** (existing, reference only):
```swift
struct ColorTheme {
    let healthyColor: Color    // Green for 0-60%
    let warningColor: Color    // Yellow for 60-80%
    let criticalColor: Color   // Red for 80-100%
    
    /// Get status color for exact percentage
    func statusColor(for percentage: Double) -> Color {
        if percentage < 60 { return healthyColor }
        if percentage < 80 { return warningColor }
        return criticalColor
    }
}
```

**Integration**: Uses exact percentages for smooth color gradients (no changes needed)

---

## Data Flow Diagram

```
System Metrics (Exact Values: 45.23%, 2,457,600 bytes/s)
         ↓
   [SystemMonitor Services]
         ↓
   MenuBarViewModel (currentMetrics)
         ↓
   MenubarSummaryBuilder
         ↓
    CompactFormatter
    - formatPercentage(45.23) → "45%"
    - formatNetworkSpeed(2457600) → "2.3M"
         ↓
    MenubarSummary.Item
    - primaryText: "⚡45%"  (for display)
    - percentage: 45.23     (for color calculation)
    - theme: ColorTheme     (for statusColor)
         ↓
    MenubarLabel View
    - Renders: Text(item.primaryText) with color from theme.statusColor(item.percentage)
    - Result: "⚡45%" in green color
         ↓
    User sees: ⚡45% 💾72% 💿15% 🌐↓2.3M
```

**Key Insight**: Exact values preserved throughout. Compact formatting happens only at presentation layer (CompactFormatter → primaryText). Color calculation continues using exact percentages.

---

## Validation Rules

### DisplayConfiguration
- ✅ `autoHideThreshold`: 0.0 ≤ t ≤ 1.0 (clamped in init)
- ✅ `metricOrder`: Contains valid MetricType.rawValue strings
- ✅ `maxVisibleMetrics`: Positive integer (typically 1-4)
- ✅ No `displayMode` field (removed)
- ✅ `showMenubarIcons`: Boolean (default true)

### CompactFormatter
- ✅ `formatPercentage`: Accepts 0.0-100.0, returns "X%" (0-3 chars)
- ✅ `formatNetworkSpeed`: Accepts any UInt64, returns "X.XK/M/G" (3-5 chars)
- ✅ Output strings optimized for compactness

---

## State Management

### Persistence
- `DisplayConfiguration`: Saved to UserDefaults via SettingsManager
- `UIStyleConfiguration`: Static constants, not persisted
- `CompactFormatter`: Stateless utility, not persisted

### Reactivity
- `MenuBarViewModel`: `@Published var currentMetrics: SystemMetrics?`
- When `currentMetrics` updates → triggers view refresh
- MenubarSummaryBuilder recomputes formatted strings
- SwiftUI automatically updates views with changed `primaryText`

---

## Testing Strategy

### Unit Tests

**CompactFormatter**:
```swift
func testFormatPercentage() {
    XCTAssertEqual(CompactFormatter.formatPercentage(45.2), "45%")
    XCTAssertEqual(CompactFormatter.formatPercentage(45.7), "46%")  // Rounds
    XCTAssertEqual(CompactFormatter.formatPercentage(0.0), "0%")
    XCTAssertEqual(CompactFormatter.formatPercentage(100.0), "100%")
}

func testFormatNetworkSpeed() {
    XCTAssertEqual(CompactFormatter.formatNetworkSpeed(512), "0K")
    XCTAssertEqual(CompactFormatter.formatNetworkSpeed(15_360), "15.0K")
    XCTAssertEqual(CompactFormatter.formatNetworkSpeed(2_457_600), "2.3M")
    XCTAssertEqual(CompactFormatter.formatNetworkSpeed(1_288_490_189), "1.2G")
}
```

**DisplayConfiguration**:
```swift
func testMigration() {
    // Test that old settings migrate correctly
    let oldData = /* create old format data */
    let migrated = DisplayConfiguration.migrate(from: oldData)
    XCTAssertTrue(migrated.showMenubarIcons)
    XCTAssertEqual(migrated.metricOrder, oldMetricOrder)
}
```

### Integration Tests

**Compact Display**:
```swift
func testCompactDisplay() {
    viewModel.updateMetrics(cpu: 45.23)
    let display = menubarLabel.text
    XCTAssertTrue(display.contains("45%"))  // Integer rounding
    XCTAssertFalse(display.contains("45.23"))  // No decimals in menubar
}
```

---

## Summary

**New Models**:
1. `UIStyleConfiguration`: Design system constants
2. `CompactFormatter`: Value formatting utilities

**Modified Models**:
1. `DisplayConfiguration`: Remove displayMode, add showMenubarIcons
2. `MenubarSummary.Item`: primaryText holds compact strings
3. `MetricType`: Add sfSymbol property

**Removed Models**:
1. `DisplayMode` enum: **DELETED ENTIRELY**

**Key Principles**:
- ✅ Pure formatting functions (CompactFormatter)
- ✅ Exact values preserved (percentage field)
- ✅ Compact strings for display (primaryText)
- ✅ Backward-compatible migration
- ✅ Testable in isolation

---

**Next Steps**: Proceed to contracts/ directory for interface definitions
