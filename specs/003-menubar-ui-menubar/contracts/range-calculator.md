# Contract: Range Calculator

**Feature**: 003-menubar-ui-menubar  
**Purpose**: Define interface and behavior for converting exact percentages to display ranges

---

## Interface Definition

```swift
/// Protocol for calculating metric display ranges
protocol RangeCalculating {
    /// Converts an exact percentage to its corresponding display range
    ///
    /// - Parameter percentage: The exact metric value (0.0-100.0)
    /// - Returns: MetricRange with appropriate bounds
    /// - Note: Values < 0 are treated as 0, values > 100 as 100
    func range(for percentage: Double) -> MetricRange
    
    /// Formats a range for display in menubar
    ///
    /// - Parameter range: The MetricRange to format
    /// - Returns: Formatted string (e.g., "20-40%")
    func formatRange(_ range: MetricRange) -> String
    
    /// Formats a range with localization
    ///
    /// - Parameters:
    ///   - range: The MetricRange to format
    ///   - language: Target language for localization
    /// - Returns: Localized formatted string
    func formatRange(_ range: MetricRange, for language: AppLanguage) -> String
}
```

---

## Behavior Contract

### `range(for percentage:) -> MetricRange`

**Preconditions**:
- None (method handles all input values gracefully)

**Postconditions**:
- Returns one of exactly 5 possible MetricRange values:
  - [0, 20) for percentage ∈ [0, 20)
  - [20, 40) for percentage ∈ [20, 40)
  - [40, 60) for percentage ∈ [40, 60)
  - [60, 80) for percentage ∈ [60, 80)
  - [80, 100] for percentage ∈ [80, 100]

**Edge Cases**:
| Input | Expected Output | Rationale |
|-------|----------------|-----------|
| -10.0 | MetricRange(0, 20) | Negative clamped to 0 |
| 0.0 | MetricRange(0, 20) | Lower bound of first range |
| 19.999 | MetricRange(0, 20) | Just below boundary |
| 20.0 | MetricRange(20, 40) | Boundary (lower-inclusive) |
| 39.999 | MetricRange(20, 40) | Just below boundary |
| 40.0 | MetricRange(40, 60) | Boundary (lower-inclusive) |
| 59.5 | MetricRange(40, 60) | Mid-range value |
| 60.0 | MetricRange(60, 80) | Critical threshold boundary |
| 80.0 | MetricRange(80, 100) | High usage boundary |
| 99.999 | MetricRange(80, 100) | Maximum range |
| 100.0 | MetricRange(80, 100) | Exact maximum |
| 150.0 | MetricRange(80, 100) | Over-maximum clamped |

**Performance Requirements**:
- Time complexity: O(1) (simple integer division)
- Must complete in < 1μs (trivial calculation)

**Thread Safety**:
- Must be thread-safe (pure function, no state)

---

### `formatRange(_ range:) -> String`

**Preconditions**:
- `range` must be a valid MetricRange (constructor ensures validity)

**Postconditions**:
- Returns string in format: `"{lower}-{upper}%"`
- No localization (English format)

**Examples**:
| Input Range | Expected Output |
|-------------|-----------------|
| MetricRange(0, 20) | "0-20%" |
| MetricRange(20, 40) | "20-40%" |
| MetricRange(40, 60) | "40-60%" |
| MetricRange(60, 80) | "60-80%" |
| MetricRange(80, 100) | "80-100%" |

**Performance Requirements**:
- Time complexity: O(1) (simple string interpolation)
- Must complete in < 1μs

---

### `formatRange(_ range:, for language:) -> String`

**Preconditions**:
- `range` must be a valid MetricRange
- `language` must be a valid AppLanguage case

**Postconditions**:
- Returns localized string
- Chinese: Uses full-width characters if applicable
- English: Same as `formatRange(_ range:)`

**Examples**:
| Input Range | Language | Expected Output |
|-------------|----------|-----------------|
| MetricRange(20, 40) | .english | "20-40%" |
| MetricRange(20, 40) | .chinese | "20-40%" |
| MetricRange(60, 80) | .english | "60-80%" |
| MetricRange(60, 80) | .chinese | "60-80%" |

**Note**: Percentage format is universal, minimal localization needed. Reserved for future localization of "percent" text if needed.

**Performance Requirements**:
- Time complexity: O(1)
- Must complete in < 1μs

---

## Default Implementation

```swift
extension RangeCalculating {
    /// Default implementation of range calculation
    func range(for percentage: Double) -> MetricRange {
        // Clamp percentage to valid range
        let clamped = max(0.0, min(100.0, percentage))
        
        // Calculate range index (0-4)
        let index = min(4, Int(clamped / 20.0))
        
        // Return corresponding MetricRange
        return MetricRange.all[index]
    }
    
    /// Default implementation of range formatting
    func formatRange(_ range: MetricRange) -> String {
        return range.displayText  // Uses MetricRange's computed property
    }
    
    /// Default implementation of localized range formatting
    func formatRange(_ range: MetricRange, for language: AppLanguage) -> String {
        // Currently, format is universal
        return range.displayText
    }
}
```

---

## Concrete Implementation

```swift
/// Default implementation of RangeCalculating protocol
struct RangeCalculator: RangeCalculating {
    // Protocol methods use default implementations from extension
    // No additional state or logic needed
}
```

**Usage**:
```swift
let calculator = RangeCalculator()

let range1 = calculator.range(for: 45.0)
print(calculator.formatRange(range1))  // "40-60%"

let range2 = calculator.range(for: 75.0)
print(calculator.formatRange(range2))  // "60-80%"
```

---

## Contract Tests

**Test Suite**: `MenubarStatusTests/Contracts/RangeCalculatorContractTests.swift`

```swift
import XCTest
@testable import MenubarStatus

class RangeCalculatorContractTests: XCTestCase {
    var calculator: RangeCalculating!
    
    override func setUp() {
        super.setUp()
        calculator = RangeCalculator()
    }
    
    // MARK: - Range Calculation Tests
    
    func testRangeCalculation_ZeroToTwenty() {
        XCTAssertEqual(calculator.range(for: 0.0), MetricRange(lowerBound: 0, upperBound: 20))
        XCTAssertEqual(calculator.range(for: 10.0), MetricRange(lowerBound: 0, upperBound: 20))
        XCTAssertEqual(calculator.range(for: 19.999), MetricRange(lowerBound: 0, upperBound: 20))
    }
    
    func testRangeCalculation_TwentyToForty() {
        XCTAssertEqual(calculator.range(for: 20.0), MetricRange(lowerBound: 20, upperBound: 40))
        XCTAssertEqual(calculator.range(for: 30.0), MetricRange(lowerBound: 20, upperBound: 40))
        XCTAssertEqual(calculator.range(for: 39.999), MetricRange(lowerBound: 20, upperBound: 40))
    }
    
    func testRangeCalculation_FortyToSixty() {
        XCTAssertEqual(calculator.range(for: 40.0), MetricRange(lowerBound: 40, upperBound: 60))
        XCTAssertEqual(calculator.range(for: 50.0), MetricRange(lowerBound: 40, upperBound: 60))
        XCTAssertEqual(calculator.range(for: 59.999), MetricRange(lowerBound: 40, upperBound: 60))
    }
    
    func testRangeCalculation_SixtyToEighty() {
        XCTAssertEqual(calculator.range(for: 60.0), MetricRange(lowerBound: 60, upperBound: 80))
        XCTAssertEqual(calculator.range(for: 70.0), MetricRange(lowerBound: 60, upperBound: 80))
        XCTAssertEqual(calculator.range(for: 79.999), MetricRange(lowerBound: 60, upperBound: 80))
    }
    
    func testRangeCalculation_EightyToHundred() {
        XCTAssertEqual(calculator.range(for: 80.0), MetricRange(lowerBound: 80, upperBound: 100))
        XCTAssertEqual(calculator.range(for: 90.0), MetricRange(lowerBound: 80, upperBound: 100))
        XCTAssertEqual(calculator.range(for: 100.0), MetricRange(lowerBound: 80, upperBound: 100))
    }
    
    func testRangeCalculation_EdgeCases() {
        // Negative values
        XCTAssertEqual(calculator.range(for: -10.0), MetricRange(lowerBound: 0, upperBound: 20))
        
        // Over 100
        XCTAssertEqual(calculator.range(for: 150.0), MetricRange(lowerBound: 80, upperBound: 100))
        
        // Exact boundaries
        XCTAssertEqual(calculator.range(for: 40.0), MetricRange(lowerBound: 40, upperBound: 60))
        XCTAssertEqual(calculator.range(for: 60.0), MetricRange(lowerBound: 60, upperBound: 80))
        XCTAssertEqual(calculator.range(for: 80.0), MetricRange(lowerBound: 80, upperBound: 100))
    }
    
    // MARK: - Formatting Tests
    
    func testFormatRange() {
        let ranges = [
            (MetricRange(lowerBound: 0, upperBound: 20), "0-20%"),
            (MetricRange(lowerBound: 20, upperBound: 40), "20-40%"),
            (MetricRange(lowerBound: 40, upperBound: 60), "40-60%"),
            (MetricRange(lowerBound: 60, upperBound: 80), "60-80%"),
            (MetricRange(lowerBound: 80, upperBound: 100), "80-100%")
        ]
        
        for (range, expected) in ranges {
            XCTAssertEqual(calculator.formatRange(range), expected)
        }
    }
    
    func testFormatRange_Localized() {
        let range = MetricRange(lowerBound: 20, upperBound: 40)
        
        // Currently same for both languages
        XCTAssertEqual(calculator.formatRange(range, for: .english), "20-40%")
        XCTAssertEqual(calculator.formatRange(range, for: .chinese), "20-40%")
    }
    
    // MARK: - Performance Tests
    
    func testRangeCalculation_Performance() {
        measure {
            for i in 0...100 {
                _ = calculator.range(for: Double(i))
            }
        }
        // Should complete in microseconds
    }
    
    func testFormatRange_Performance() {
        let ranges = MetricRange.all
        measure {
            for _ in 0..<1000 {
                for range in ranges {
                    _ = calculator.formatRange(range)
                }
            }
        }
        // Should complete in microseconds per iteration
    }
}
```

---

## Integration Points

**Used By**:
- `MenubarSummaryBuilder`: Converts metrics to ranges for menubar display
- `FormatHelpers`: Utility functions may delegate to this contract

**Dependencies**:
- `MetricRange`: Data model for ranges
- `AppLanguage`: Enum for localization

**Thread Safety**:
- All methods are pure functions (no state)
- Safe to call from any thread
- Recommend using on main thread for UI updates

---

## Versioning

**Version**: 1.0  
**Status**: Draft  
**Last Updated**: 2025-10-05

**Breaking Changes**: N/A (new contract)

**Future Considerations**:
- Custom range intervals (user-configurable)
- Additional localization for percentage symbol
- Animation hints for range transitions

---


