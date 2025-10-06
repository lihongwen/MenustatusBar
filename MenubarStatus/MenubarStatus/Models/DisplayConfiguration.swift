//
//  DisplayConfiguration.swift
//  MenubarStatus
//
//  Simplified display configuration without display modes
//  Using unified compact format for all metrics
//

import Foundation

// MARK: - DisplayConfiguration

/// User preferences for how metrics are displayed in the menubar
struct DisplayConfiguration: Codable {
    // Menubar Display (SIMPLIFIED - no display mode)
    var showMenubarIcons: Bool  // Show SF Symbols icons in menubar
    var maxVisibleMetrics: Int  // Maximum number of metrics to show in menubar
    
    // Ordering (array of metric identifiers)
    var metricOrder: [String]  // Serialized MetricType.rawValue
    
    // Auto-hide Settings
    var autoHideEnabled: Bool
    var autoHideThreshold: Double  // 0.0-1.0 (e.g., 0.5 = 50%)
    
    // Process Display
    var showTopProcesses: Bool
    var processSortCriteria: String  // ProcessSortCriteria.rawValue
    
    // Note: colorThemeIdentifier removed in v1.0.1 - always use SystemDefaultTheme
    
    // Validation
    init(
        showMenubarIcons: Bool = true,
        maxVisibleMetrics: Int = 4,
        metricOrder: [String] = MetricType.allCases.map { $0.rawValue },
        autoHideEnabled: Bool = false,
        autoHideThreshold: Double = 0.5,
        showTopProcesses: Bool = false,
        processSortCriteria: String = "cpu"
    ) {
        self.showMenubarIcons = showMenubarIcons
        self.maxVisibleMetrics = max(1, min(10, maxVisibleMetrics))
        self.metricOrder = metricOrder
        self.autoHideEnabled = autoHideEnabled
        self.autoHideThreshold = max(0.0, min(1.0, autoHideThreshold))
        self.showTopProcesses = showTopProcesses
        self.processSortCriteria = processSortCriteria
    }
    
    // Computed
    var orderedMetrics: [MetricType] {
        metricOrder.compactMap { MetricType(rawValue: $0) }
    }
}

