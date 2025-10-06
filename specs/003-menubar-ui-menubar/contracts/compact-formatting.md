# Contract: Compact Formatting

**Feature**: 003-menubar-ui-menubar  
**Purpose**: Define interface for compact value formatting with smart units

---

## Interface Definition

```swift
/// Protocol for compact value formatting
protocol CompactFormatting {
    /// Format percentage as integer for menubar
    /// - Parameter percentage: 0.0-100.0
    /// - Returns: Compact string like "45%"
    func formatPercentage(_ percentage: Double) -> String
    
    /// Format network speed with smart units (K/M/G)
    /// - Parameter bytesPerSecond: Raw bytes per second
    /// - Returns: Compact string like "2.3M", "15.3K", "1.2G"
    func formatNetworkSpeed(_ bytesPerSecond: UInt64) -> String
    
    /// Format metric for menubar display
    /// - Parameters:
    ///   - type: Metric type
    ///   - percentage: Exact percentage
    ///   - bytesPerSecond: Optional network speed
    ///   - theme: Color theme
    ///   - showIcon: Include SF Symbols icon
    /// - Returns: Formatted text and color
    func formatForMenubar(
        type: MetricType,
        percentage: Double,
        bytesPerSecond: UInt64?,
        theme: ColorTheme,
        showIcon: Bool
    ) -> (text: String, color: Color)
}
```

---

## Behavior Contract

### `formatPercentage(_ percentage:) -> String`

**Preconditions**: None (handles all input gracefully)

**Postconditions**:
- Returns integer percentage string: "0%" to "100%"
- Rounds to nearest integer (45.7 → "46%")
- Always includes % symbol
- Length: 1-4 characters

**Examples**:
| Input | Output |
|-------|--------|
| 0.0 | "0%" |
| 45.2 | "45%" |
| 45.7 | "46%" |
| 100.0 | "100%" |
| 123.4 | "100%" (clamped) |

---

### `formatNetworkSpeed(_ bytesPerSecond:) -> String`

**Preconditions**: None

**Postconditions**:
- Returns smart unit string: "X.XK", "X.XM", or "X.XG"
- One decimal place for precision
- Automatic unit selection based on magnitude

**Unit Thresholds**:
| Range | Format | Example |
|-------|--------|---------|
| <1024 | "0K" | "0K" |
| 1KB-999KB | "X.XK" | "15.3K" |
| 1MB-999MB | "X.XM" | "2.3M" |
| ≥1GB | "X.XG" | "1.2G" |

**Examples**:
| Input (bytes/s) | Output |
|-----------------|--------|
| 512 | "0K" |
| 15_360 | "15.0K" |
| 2_457_600 | "2.3M" |
| 1_288_490_189 | "1.2G" |

---

### `formatForMenubar(...) -> (text: String, color: Color)`

**Preconditions**:
- `type` must be valid MetricType
- `percentage` typically 0-100 (but handles any Double)

**Postconditions**:
- Returns formatted text string
- Returns color based on exact percentage via theme
- Text format: `"{icon} {value}"` or `"{value}"` depending on showIcon

**Examples**:
| Type | % | Network | showIcon | Result |
|------|---|---------|----------|--------|
| .cpu | 45.0 | nil | true | ("⚡45%", green) |
| .memory | 75.0 | nil | false | ("75%", yellow) |
| .network | 10.0 | 2_457_600 | true | ("🌐↓2.3M", green) |

---

## Default Implementation

```swift
extension CompactFormatting {
    func formatPercentage(_ percentage: Double) -> String {
        let clamped = max(0.0, min(100.0, percentage))
        return "\(Int(round(clamped)))%"
    }
    
    func formatNetworkSpeed(_ bytesPerSecond: UInt64) -> String {
        let bytes = Double(bytesPerSecond)
        if bytes < 1_024 { return "0K" }
        if bytes < 1_048_576 { return String(format: "%.1fK", bytes / 1_024) }
        if bytes < 1_073_741_824 { return String(format: "%.1fM", bytes / 1_048_576) }
        return String(format: "%.1fG", bytes / 1_073_741_824)
    }
}
```

---

## Contract Tests

```swift
class CompactFormattingContractTests: XCTestCase {
    var formatter: CompactFormatting!
    
    func testFormatPercentage_Integers() {
        XCTAssertEqual(formatter.formatPercentage(0.0), "0%")
        XCTAssertEqual(formatter.formatPercentage(45.0), "45%")
        XCTAssertEqual(formatter.formatPercentage(100.0), "100%")
    }
    
    func testFormatPercentage_Rounding() {
        XCTAssertEqual(formatter.formatPercentage(45.2), "45%")
        XCTAssertEqual(formatter.formatPercentage(45.7), "46%")
        XCTAssertEqual(formatter.formatPercentage(99.5), "100%")
    }
    
    func testFormatNetworkSpeed_Units() {
        XCTAssertEqual(formatter.formatNetworkSpeed(512), "0K")
        XCTAssertEqual(formatter.formatNetworkSpeed(15_360), "15.0K")
        XCTAssertEqual(formatter.formatNetworkSpeed(2_457_600), "2.3M")
        XCTAssertEqual(formatter.formatNetworkSpeed(1_288_490_189), "1.2G")
    }
}
```

---

