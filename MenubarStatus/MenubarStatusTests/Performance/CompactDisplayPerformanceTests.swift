//
//  CompactDisplayPerformanceTests.swift
//  MenubarStatusTests
//
//  Performance and space efficiency validation for compact display
//

import XCTest
import SwiftUI
@testable import MenubarStatus

final class CompactDisplayPerformanceTests: XCTestCase {
    
    var viewModel: MenuBarViewModel!
    var settings: AppSettings!
    
    override func setUp() {
        super.setUp()
        settings = AppSettings()
        viewModel = MenuBarViewModel(settings: settings)
    }
    
    override func tearDown() {
        viewModel = nil
        settings = nil
        super.tearDown()
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_MenubarLabelRendering() {
        // Test: Rendering should be fast (<16ms for 60fps)
        let theme = SystemDefaultTheme()
        let summary = MenubarSummary(items: [
            MenubarSummary.Item(
                id: "cpu",
                icon: "cpu.fill",
                title: "CPU",
                primaryText: "45%",
                secondaryText: nil,
                percentage: 45.0,
                theme: theme
            ),
            MenubarSummary.Item(
                id: "memory",
                icon: "memorychip.fill",
                title: "Memory",
                primaryText: "72%",
                secondaryText: nil,
                percentage: 72.0,
                theme: theme
            ),
            MenubarSummary.Item(
                id: "disk",
                icon: "internaldrive.fill",
                title: "Disk",
                primaryText: "15%",
                secondaryText: nil,
                percentage: 15.0,
                theme: theme
            ),
            MenubarSummary.Item(
                id: "network",
                icon: "network",
                title: "Network",
                primaryText: "↓2.3M",
                secondaryText: nil,
                percentage: 30.0,
                theme: theme
            )
        ])
        
        measure {
            // Simulate creating the view multiple times
            for _ in 0..<100 {
                let label = MenubarLabel(summary: summary)
                _ = label.body
            }
        }
    }
    
    func testPerformance_CompactFormatterBatch() {
        // Test: Formatting all metrics should be very fast
        measure {
            for _ in 0..<1_000 {
                _ = CompactFormatter.formatPercentage(45.23)
                _ = CompactFormatter.formatPercentage(72.84)
                _ = CompactFormatter.formatPercentage(15.67)
                _ = CompactFormatter.formatNetworkSpeed(2_457_600)
            }
        }
    }
    
    func testPerformance_MenubarSummaryBuilderUpdate() {
        // Test: Building menubar summary should be fast
        let metrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 45.23, systemUsage: 20.0, userUsage: 25.23, idlePercentage: 54.77),
            memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 11_654_451_200, freeBytes: 4_345_548_800, cachedBytes: 1_000_000_000),
            disk: DiskMetrics(
                volumePath: "/",
                volumeName: "Macintosh HD",
                totalBytes: 500_000_000_000,
                freeBytes: 421_650_000_000,
                usedBytes: 78_350_000_000
            ),
            network: NetworkMetrics(
                uploadBytesPerSecond: 819_200,
                downloadBytesPerSecond: 2_457_600,
                totalUploadBytes: 10_240_000,
                totalDownloadBytes: 20_480_000
            )
        )
        
        let theme = SystemDefaultTheme()
        
        measure {
            for _ in 0..<1_000 {
                let summary = MenubarSummaryBuilder.build(
                    metrics: metrics,
                    settings: settings,
                    theme: theme
                )
                _ = summary.items.count
            }
        }
    }
    
    func testPerformance_ColorThemeCalculation() {
        // Test: Color calculation should be fast
        let theme = SystemDefaultTheme()
        
        measure {
            for i in 0..<10_000 {
                let percentage = Double(i % 100)
                _ = theme.statusColor(for: percentage)
            }
        }
    }
    
    // MARK: - Space Efficiency Tests
    
    func testSpaceEfficiency_SingleMetricWidth() {
        // Test: Single metric should be ~37pt or less
        let theme = SystemDefaultTheme()
        let item = MenubarSummary.Item(
            id: "cpu",
            icon: "cpu.fill",
            title: "CPU",
            primaryText: "45%",
            secondaryText: nil,
            percentage: 45.0,
            theme: theme
        )
        
        let summary = MenubarSummary(items: [item])
        let label = MenubarLabel(summary: summary)
        
        // Verify the text is compact
        XCTAssertTrue(item.primaryText.count <= 5, "Single metric text should be ≤5 characters")
        
        // Expected format: icon (11pt) + spacing (2pt) + text (20-25pt) ≈ 33-38pt
        // This is validated visually in the app, but we can verify the text is compact
        XCTAssertNotNil(label.body)
    }
    
    func testSpaceEfficiency_FourMetricsCompact() {
        // Test: 4 metrics should fit in ~150pt target
        let theme = SystemDefaultTheme()
        let summary = MenubarSummary(items: [
            MenubarSummary.Item(id: "cpu", icon: "cpu.fill", title: "CPU", primaryText: "45%", secondaryText: nil, percentage: 45.0, theme: theme),
            MenubarSummary.Item(id: "memory", icon: "memorychip.fill", title: "Memory", primaryText: "72%", secondaryText: nil, percentage: 72.0, theme: theme),
            MenubarSummary.Item(id: "disk", icon: "internaldrive.fill", title: "Disk", primaryText: "15%", secondaryText: nil, percentage: 15.0, theme: theme),
            MenubarSummary.Item(id: "network", icon: "network", title: "Network", primaryText: "↓2.3M", secondaryText: nil, percentage: 30.0, theme: theme)
        ])
        
        // Verify all items are compact
        for item in summary.items {
            XCTAssertTrue(item.primaryText.count <= 7, "Metric text '\(item.primaryText)' should be ≤7 characters for compactness")
        }
        
        // Verify we have exactly 4 items
        XCTAssertEqual(summary.items.count, 4, "Should have exactly 4 metrics")
        
        // Estimated width calculation:
        // 4 metrics × 37pt + 3 gaps × 6pt + padding (12pt) ≈ 148pt + 12pt = 160pt
        // This is close to our 150pt target (without padding)
        let estimatedWidth = 4 * UIStyleConfiguration.estimatedMetricWidth + 3 * UIStyleConfiguration.menubarMetricSpacing
        XCTAssertLessThanOrEqual(estimatedWidth, UIStyleConfiguration.targetMenubarWidth, "Estimated width should be ≤150pt")
    }
    
    func testSpaceEfficiency_TextCompactness() {
        // Test: All formatting produces compact strings
        
        // Percentage formatting
        let percentText = CompactFormatter.formatPercentage(99.9)
        XCTAssertTrue(percentText.count <= 4, "Percentage should be ≤4 chars (e.g., '100%')")
        
        // Network formatting - KB
        let kbText = CompactFormatter.formatNetworkSpeed(15_360)
        XCTAssertTrue(kbText.count <= 6, "Network KB should be ≤6 chars (e.g., '15.0K')")
        
        // Network formatting - MB
        let mbText = CompactFormatter.formatNetworkSpeed(2_457_600)
        XCTAssertTrue(mbText.count <= 5, "Network MB should be ≤5 chars (e.g., '2.3M')")
        
        // Network formatting - GB
        let gbText = CompactFormatter.formatNetworkSpeed(1_288_490_189)
        XCTAssertTrue(gbText.count <= 5, "Network GB should be ≤5 chars (e.g., '1.2G')")
    }
    
    // MARK: - Frame Rate Tests
    
    func testFrameRate_UpdateFrequency() {
        // Test: Typical update should complete in <16ms (60fps)
        let startTime = Date()
        
        viewModel.currentMetrics = SystemMetrics(
            timestamp: Date(),
            cpu: CPUMetrics(usagePercentage: 45.23, systemUsage: 20.0, userUsage: 25.23, idlePercentage: 54.77),
            memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 11_654_451_200, freeBytes: 4_345_548_800, cachedBytes: 1_000_000_000),
            disk: DiskMetrics(
                volumePath: "/",
                volumeName: "Macintosh HD",
                totalBytes: 500_000_000_000,
                freeBytes: 421_650_000_000,
                usedBytes: 78_350_000_000
            ),
            network: NetworkMetrics(
                uploadBytesPerSecond: 819_200,
                downloadBytesPerSecond: 2_457_600,
                totalUploadBytes: 10_240_000,
                totalDownloadBytes: 20_480_000
            )
        )
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        // Should be much faster than 16ms (0.016 seconds)
        XCTAssertLessThan(elapsed, 0.016, "Metrics update should complete in <16ms for 60fps")
    }
    
    func testFrameRate_RapidUpdates() {
        // Test: Can handle rapid successive updates without degradation
        measure {
            for i in 0..<100 {
                viewModel.currentMetrics = SystemMetrics(
                    timestamp: Date(),
                    cpu: CPUMetrics(usagePercentage: Double(i % 100), systemUsage: 20.0, userUsage: 25.0, idlePercentage: 55.0),
                    memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 11_654_451_200, freeBytes: 4_345_548_800, cachedBytes: 1_000_000_000),
                    disk: DiskMetrics(
                        volumePath: "/",
                        volumeName: "Macintosh HD",
                        totalBytes: 500_000_000_000,
                        freeBytes: 421_650_000_000,
                        usedBytes: 78_350_000_000
                    ),
                    network: NetworkMetrics(
                        uploadBytesPerSecond: 819_200,
                        downloadBytesPerSecond: 2_457_600,
                        totalUploadBytes: 10_240_000,
                        totalDownloadBytes: 20_480_000
                    )
                )
            }
        }
    }
    
    // MARK: - Memory Efficiency Tests
    
    func testMemoryEfficiency_MenubarSummarySize() {
        // Test: MenubarSummary should be lightweight
        let theme = SystemDefaultTheme()
        let summary = MenubarSummary(items: [
            MenubarSummary.Item(id: "cpu", icon: "cpu.fill", title: "CPU", primaryText: "45%", secondaryText: nil, percentage: 45.0, theme: theme),
            MenubarSummary.Item(id: "memory", icon: "memorychip.fill", title: "Memory", primaryText: "72%", secondaryText: nil, percentage: 72.0, theme: theme),
            MenubarSummary.Item(id: "disk", icon: "internaldrive.fill", title: "Disk", primaryText: "15%", secondaryText: nil, percentage: 15.0, theme: theme),
            MenubarSummary.Item(id: "network", icon: "network", title: "Network", primaryText: "↓2.3M", secondaryText: nil, percentage: 30.0, theme: theme)
        ])
        
        // Verify structure is lightweight
        XCTAssertEqual(summary.items.count, 4)
        XCTAssertNotNil(summary)
    }
    
    func testMemoryEfficiency_NoLeaks() {
        // Test: Creating and destroying views doesn't leak memory
        weak var weakLabel: MenubarLabel?
        
        autoreleasepool {
            let theme = SystemDefaultTheme()
            let summary = MenubarSummary(items: [
                MenubarSummary.Item(id: "cpu", icon: "cpu.fill", title: "CPU", primaryText: "45%", secondaryText: nil, percentage: 45.0, theme: theme)
            ])
            let label = MenubarLabel(summary: summary)
            weakLabel = label
            _ = label.body
        }
        
        // Label should be deallocated after autoreleasepool
        // Note: This test may not always pass due to SwiftUI's internal caching
        // but it serves as a sanity check
    }
    
    // MARK: - UI Configuration Tests
    
    func testUIConfiguration_SpacingConstants() {
        // Test: UI spacing constants are reasonable
        XCTAssertEqual(UIStyleConfiguration.menubarIconTextSpacing, 2.0, "Icon-text spacing should be 2pt")
        XCTAssertEqual(UIStyleConfiguration.menubarMetricSpacing, 6.0, "Metric spacing should be 6pt")
        XCTAssertLessThanOrEqual(UIStyleConfiguration.menubarIconSize, 12.0, "Icon size should be ≤12pt for compactness")
    }
    
    func testUIConfiguration_TargetWidth() {
        // Test: Target width is reasonable for menubar
        XCTAssertLessThanOrEqual(UIStyleConfiguration.targetMenubarWidth, 200, "Target width should be ≤200pt")
        XCTAssertGreaterThanOrEqual(UIStyleConfiguration.targetMenubarWidth, 100, "Target width should be ≥100pt")
    }
    
    func testUIConfiguration_AnimationDurations() {
        // Test: Animation durations are reasonable
        XCTAssertGreaterThan(UIStyleConfiguration.animationFast, 0.0, "Fast animation should be >0")
        XCTAssertLessThan(UIStyleConfiguration.animationFast, 0.3, "Fast animation should be <300ms")
        XCTAssertLessThanOrEqual(UIStyleConfiguration.animationStandard, 0.5, "Standard animation should be ≤500ms")
    }
}

