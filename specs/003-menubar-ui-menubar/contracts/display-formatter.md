# Contract: Display Formatter

**Feature**: 003-menubar-ui-menubar  
**Purpose**: Define interface and behavior for formatting metrics for menubar display

---

## Interface Definition

```swift
/// Protocol for formatting metrics for menubar display
protocol MenubarFormatting {
    /// Formats a metric for menubar display with range-based values
    ///
    /// - Parameters:
    ///   - type: The type of metric (CPU, Memory, Disk, Network)
    ///   - range: The display range for the metric
    ///   - showIcon: Whether to include SF Symbols icon
    /// - Returns: Formatted string ready for menubar display
    func formatForMenubar(
        type: MetricType,
        range: MetricRange,
        showIcon: Bool
    ) -> String
    
    /// Formats a metric with exact value for dropdown display
    ///
    /// - Parameters:
    ///   - type: The type of metric
    ///   - percentage: The exact percentage value
    ///   - showIcon: Whether to include SF Symbols icon
    /// - Returns: Formatted string for dropdown with exact value
    func formatForDropdown(
        type: MetricType,
        percentage: Double,
        showIcon: Bool
    ) -> String
    
    /// Gets SF Symbols icon name for a metric type
    ///
    /// - Parameter type: The metric type
    /// - Returns: SF Symbols name (e.g., "cpu.fill")
    func icon(for type: MetricType) -> String
    
    /// Gets abbreviated title for a metric type
    ///
    /// - Parameter type: The metric type
    /// - Returns: Short title (e.g., "CPU", "Mem")
    func abbreviatedTitle(for type: MetricType) -> String
}
```

---

## Behavior Contract

### `formatForMenubar(type:range:showIcon:) -> String`

**Preconditions**:
- `type` must be a valid MetricType
- `range` must be a valid MetricRange
- `showIcon` can be any Boolean value

**Postconditions**:
- Returns string in one of two formats:
  - With icon: `"{icon} {title} {range}"` (e.g., "⚡ CPU 20-40%")
  - Without icon: `"{title} {range}"` (e.g., "CPU 20-40%")
- Uses localized title based on current language setting
- Uses system-appropriate icon rendering

**Format Specifications**:
| Component | Description | Example |
|-----------|-------------|---------|
| Icon | SF Symbols rendered as emoji/text | "⚡" (cpu.fill) |
| Title | Abbreviated metric name | "CPU", "Mem", "Disk", "Net" |
| Range | Formatted range string | "20-40%" |
| Spacing | Single space between components | " " |

**Examples**:
| Type | Range | showIcon | Expected Output |
|------|-------|----------|-----------------|
| .cpu | [20, 40) | true | "⚡ CPU 20-40%" |
| .cpu | [20, 40) | false | "CPU 20-40%" |
| .memory | [60, 80) | true | "💾 Mem 60-80%" |
| .memory | [60, 80) | false | "Mem 60-80%" |
| .disk | [0, 20) | true | "💿 Disk 0-20%" |
| .network | [80, 100) | true | "🌐 Net 80-100%" |

**Localization**:
| Metric | English | Chinese |
|--------|---------|---------|
| CPU | "CPU" | "处理器" |
| Memory | "Mem" | "内存" |
| Disk | "Disk" | "磁盘" |
| Network | "Net" | "网络" |

**Performance Requirements**:
- Time complexity: O(1) (simple string concatenation)
- Must complete in < 10μs

**Thread Safety**:
- Must be thread-safe
- Reads from LocalizedStrings (which should be thread-safe)

---

### `formatForDropdown(type:percentage:showIcon:) -> String`

**Preconditions**:
- `type` must be a valid MetricType
- `percentage` should be 0.0-100.0 (but handles any Double)
- `showIcon` can be any Boolean value

**Postconditions**:
- Returns string with exact percentage (not range)
- Format: `"{icon} {title}: {percentage}"` or `"{title}: {percentage}"`
- Uses 1 decimal place for precision

**Examples**:
| Type | Percentage | showIcon | Expected Output |
|------|------------|----------|-----------------|
| .cpu | 45.3 | true | "⚡ CPU: 45.3%" |
| .cpu | 45.3 | false | "CPU: 45.3%" |
| .memory | 72.8 | true | "💾 Memory: 72.8%" |
| .disk | 15.0 | false | "Disk: 15.0%" |

**Performance Requirements**:
- Time complexity: O(1)
- Must complete in < 10μs

---

### `icon(for type:) -> String`

**Preconditions**:
- `type` must be a valid MetricType

**Postconditions**:
- Returns SF Symbols name as String
- Symbol must exist in SF Symbols library

**Mapping**:
| MetricType | SF Symbols Name | Visual |
|------------|----------------|--------|
| .cpu | "cpu.fill" | ⚡ |
| .memory | "memorychip.fill" | 💾 |
| .disk | "internaldrive.fill" | 💿 |
| .network | "network" | 🌐 |

**Performance Requirements**:
- Time complexity: O(1) (dictionary lookup or switch)
- Must complete in < 1μs

---

### `abbreviatedTitle(for type:) -> String`

**Preconditions**:
- `type` must be a valid MetricType

**Postconditions**:
- Returns localized abbreviated title
- Maximum 5 characters in English
- Respects current language setting

**Mapping**:
| MetricType | English | Chinese |
|------------|---------|---------|
| .cpu | "CPU" | "CPU" or "处理器" |
| .memory | "Mem" | "内存" |
| .disk | "Disk" | "磁盘" |
| .network | "Net" | "网络" |

**Note**: Abbreviation preferences may vary by language. Chinese may use full characters.

**Performance Requirements**:
- Time complexity: O(1)
- Must complete in < 1μs

---

## Default Implementation

```swift
extension MenubarFormatting {
    func formatForMenubar(
        type: MetricType,
        range: MetricRange,
        showIcon: Bool
    ) -> String {
        let iconStr = showIcon ? "\(icon(for: type)) " : ""
        let title = abbreviatedTitle(for: type)
        let rangeStr = range.displayText
        return "\(iconStr)\(title) \(rangeStr)"
    }
    
    func formatForDropdown(
        type: MetricType,
        percentage: Double,
        showIcon: Bool
    ) -> String {
        let iconStr = showIcon ? "\(icon(for: type)) " : ""
        let title = type.displayName  // Full name for dropdown
        return String(format: "%@%@: %.1f%%", iconStr, title, percentage)
    }
    
    func icon(for type: MetricType) -> String {
        switch type {
        case .cpu:     return "cpu.fill"
        case .memory:  return "memorychip.fill"
        case .disk:    return "internaldrive.fill"
        case .network: return "network"
        }
    }
    
    func abbreviatedTitle(for type: MetricType) -> String {
        let lang = LocalizedStrings.language
        switch type {
        case .cpu:
            return "CPU"
        case .memory:
            return lang == .chinese ? "内存" : "Mem"
        case .disk:
            return lang == .chinese ? "磁盘" : "Disk"
        case .network:
            return lang == .chinese ? "网络" : "Net"
        }
    }
}
```

---

## Concrete Implementation

```swift
/// Default implementation of MenubarFormatting protocol
struct MenubarFormatter: MenubarFormatting {
    // Protocol methods use default implementations from extension
    // No additional state or logic needed
}
```

**Usage**:
```swift
let formatter = MenubarFormatter()
let range = MetricRange(lowerBound: 40, upperBound: 60)

// Menubar display
let menubarText = formatter.formatForMenubar(
    type: .cpu,
    range: range,
    showIcon: true
)
print(menubarText)  // "⚡ CPU 40-60%"

// Dropdown display
let dropdownText = formatter.formatForDropdown(
    type: .cpu,
    percentage: 45.3,
    showIcon: true
)
print(dropdownText)  // "⚡ CPU: 45.3%"
```

---

## Contract Tests

**Test Suite**: `MenubarStatusTests/Contracts/MenubarFormatterContractTests.swift`

```swift
import XCTest
@testable import MenubarStatus

class MenubarFormatterContractTests: XCTestCase {
    var formatter: MenubarFormatting!
    
    override func setUp() {
        super.setUp()
        formatter = MenubarFormatter()
    }
    
    // MARK: - Menubar Format Tests
    
    func testFormatForMenubar_WithIcon() {
        let range = MetricRange(lowerBound: 20, upperBound: 40)
        
        let cpuText = formatter.formatForMenubar(type: .cpu, range: range, showIcon: true)
        XCTAssertTrue(cpuText.contains("CPU"))
        XCTAssertTrue(cpuText.contains("20-40%"))
        
        let memText = formatter.formatForMenubar(type: .memory, range: range, showIcon: true)
        XCTAssertTrue(memText.contains("20-40%"))
    }
    
    func testFormatForMenubar_WithoutIcon() {
        let range = MetricRange(lowerBound: 40, upperBound: 60)
        
        let cpuText = formatter.formatForMenubar(type: .cpu, range: range, showIcon: false)
        XCTAssertEqual(cpuText, "CPU 40-60%")
        
        // Should not contain icon
        XCTAssertFalse(cpuText.contains("cpu.fill"))
    }
    
    func testFormatForMenubar_AllMetricTypes() {
        let range = MetricRange(lowerBound: 60, upperBound: 80)
        
        // Test all metric types format without error
        for type in MetricType.allCases {
            let text = formatter.formatForMenubar(type: type, range: range, showIcon: true)
            XCTAssertFalse(text.isEmpty)
            XCTAssertTrue(text.contains("60-80%"))
        }
    }
    
    func testFormatForMenubar_AllRanges() {
        // Test all possible ranges
        for range in MetricRange.all {
            let text = formatter.formatForMenubar(type: .cpu, range: range, showIcon: false)
            XCTAssertTrue(text.contains(range.displayText))
        }
    }
    
    // MARK: - Dropdown Format Tests
    
    func testFormatForDropdown_ExactPercentage() {
        let cpuText = formatter.formatForDropdown(type: .cpu, percentage: 45.3, showIcon: false)
        XCTAssertTrue(cpuText.contains("45.3"))
        XCTAssertTrue(cpuText.contains("%"))
    }
    
    func testFormatForDropdown_WithIcon() {
        let memText = formatter.formatForDropdown(type: .memory, percentage: 72.8, showIcon: true)
        XCTAssertTrue(memText.contains("72.8"))
    }
    
    func testFormatForDropdown_EdgeCases() {
        // Zero
        let zero = formatter.formatForDropdown(type: .disk, percentage: 0.0, showIcon: false)
        XCTAssertTrue(zero.contains("0.0"))
        
        // 100
        let hundred = formatter.formatForDropdown(type: .cpu, percentage: 100.0, showIcon: false)
        XCTAssertTrue(hundred.contains("100.0"))
        
        // Precise value
        let precise = formatter.formatForDropdown(type: .memory, percentage: 45.67, showIcon: false)
        XCTAssertTrue(precise.contains("45.7"))  // 1 decimal place
    }
    
    // MARK: - Icon Tests
    
    func testIcon_AllMetricTypes() {
        XCTAssertEqual(formatter.icon(for: .cpu), "cpu.fill")
        XCTAssertEqual(formatter.icon(for: .memory), "memorychip.fill")
        XCTAssertEqual(formatter.icon(for: .disk), "internaldrive.fill")
        XCTAssertEqual(formatter.icon(for: .network), "network")
    }
    
    func testIcon_ValidSFSymbols() {
        // Verify all icons are valid SF Symbols (can be rendered)
        for type in MetricType.allCases {
            let iconName = formatter.icon(for: type)
            XCTAssertFalse(iconName.isEmpty)
            
            // On macOS, can test if image exists
            #if os(macOS)
            let image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
            XCTAssertNotNil(image, "SF Symbols '\(iconName)' should exist")
            #endif
        }
    }
    
    // MARK: - Title Tests
    
    func testAbbreviatedTitle_English() {
        // Set language to English
        // (In real test, may need to mock LocalizedStrings.language)
        
        XCTAssertEqual(formatter.abbreviatedTitle(for: .cpu), "CPU")
        // Memory abbreviated as "Mem"
        // Disk abbreviated as "Disk"
        // Network abbreviated as "Net"
    }
    
    func testAbbreviatedTitle_NotEmpty() {
        // Ensure all titles return non-empty strings
        for type in MetricType.allCases {
            let title = formatter.abbreviatedTitle(for: type)
            XCTAssertFalse(title.isEmpty)
            XCTAssertTrue(title.count <= 5, "Abbreviated title '\(title)' should be ≤ 5 characters")
        }
    }
    
    // MARK: - Performance Tests
    
    func testFormatForMenubar_Performance() {
        let range = MetricRange(lowerBound: 40, upperBound: 60)
        
        measure {
            for _ in 0..<1000 {
                _ = formatter.formatForMenubar(type: .cpu, range: range, showIcon: true)
            }
        }
        // Should complete in microseconds per iteration
    }
    
    func testFormatForDropdown_Performance() {
        measure {
            for i in 0..<1000 {
                _ = formatter.formatForDropdown(type: .memory, percentage: Double(i % 100), showIcon: true)
            }
        }
        // Should complete in microseconds per iteration
    }
    
    // MARK: - Integration Tests
    
    func testFormatConsistency_MenubarVsDropdown() {
        let percentage = 45.0
        let range = MetricRange.from(percentage: percentage)
        
        let menubarText = formatter.formatForMenubar(type: .cpu, range: range, showIcon: false)
        let dropdownText = formatter.formatForDropdown(type: .cpu, percentage: percentage, showIcon: false)
        
        // Both should contain CPU identifier
        XCTAssertTrue(menubarText.contains("CPU"))
        XCTAssertTrue(dropdownText.contains("CPU"))
        
        // Menubar shows range
        XCTAssertTrue(menubarText.contains("40-60%"))
        
        // Dropdown shows exact value
        XCTAssertTrue(dropdownText.contains("45.0"))
    }
}
```

---

## Integration Points

**Used By**:
- `MenubarSummaryBuilder`: Formats metrics for menubar display
- `MenuBarView`: Formats metrics for dropdown detail views
- `MetricCard`: May use for consistent formatting

**Dependencies**:
- `MetricType`: Enum of metric types
- `MetricRange`: Range data model
- `LocalizedStrings`: For localization

**Thread Safety**:
- All methods are pure or read-only
- Safe to call from any thread
- LocalizedStrings should be thread-safe

---

## Versioning

**Version**: 1.0  
**Status**: Draft  
**Last Updated**: 2025-10-05

**Breaking Changes**: N/A (new contract)

**Future Considerations**:
- User-customizable abbreviations
- Additional localization options
- Dynamic icon selection based on theme
- Unit conversion for memory/disk (GB vs MB)

---


