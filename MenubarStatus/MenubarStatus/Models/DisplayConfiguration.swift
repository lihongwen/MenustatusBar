//
//  DisplayConfiguration.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

// MARK: - DisplayMode

/// Enum defining how metrics appear in the menubar
enum DisplayMode: String, Codable, CaseIterable {
    case iconAndValue = "iconAndValue"  // Icon + numeric value
    case compactText = "compactText"    // Abbreviated text
    case graphMode = "graphMode"        // Tiny sparkline
    case iconsOnly = "iconsOnly"        // Just colored icons
    
    var displayName: String {
        let lang = LocalizedStrings.language
        switch self {
        case .iconAndValue: 
            return lang == .chinese ? "图标 + 数值" : "Icon + Value"
        case .compactText: 
            return lang == .chinese ? "紧凑文本" : "Compact Text"
        case .graphMode: 
            return lang == .chinese ? "图表模式" : "Graph Mode"
        case .iconsOnly: 
            return lang == .chinese ? "仅图标" : "Icons Only"
        }
    }
    
    var description: String {
        switch self {
        case .iconAndValue:
            return "Show SF Symbol icon followed by percentage"
        case .compactText:
            return "Show abbreviated text (e.g., 'CPU 45%')"
        case .graphMode:
            return "Show tiny inline sparkline chart"
        case .iconsOnly:
            return "Show only colored icons (hover for details)"
        }
    }
    
    var estimatedWidth: CGFloat {
        switch self {
        case .iconAndValue: return 60
        case .compactText: return 70
        case .graphMode: return 40
        case .iconsOnly: return 20
        }
    }
}

// MARK: - DisplayConfiguration

/// User preferences for how metrics are displayed in the menubar
struct DisplayConfiguration: Codable {
    // Display Mode
    var displayMode: DisplayMode
    
    // Ordering (array of metric identifiers)
    var metricOrder: [String]  // Serialized MetricType.rawValue
    
    // Auto-hide Settings
    var autoHideEnabled: Bool
    var autoHideThreshold: Double  // 0.0-1.0 (e.g., 0.5 = 50%)
    
    // Color Theme
    var colorThemeIdentifier: String
    
    // Process Display
    var showTopProcesses: Bool
    var processSortCriteria: String  // ProcessSortCriteria.rawValue
    
    // Validation
    init(
        displayMode: DisplayMode = .iconAndValue,
        metricOrder: [String] = MetricType.allCases.map { $0.rawValue },
        autoHideEnabled: Bool = false,
        autoHideThreshold: Double = 0.5,
        colorThemeIdentifier: String = "system",
        showTopProcesses: Bool = false,
        processSortCriteria: String = "cpu"
    ) {
        self.displayMode = displayMode
        self.metricOrder = metricOrder
        self.autoHideEnabled = autoHideEnabled
        self.autoHideThreshold = max(0.0, min(1.0, autoHideThreshold))
        self.colorThemeIdentifier = colorThemeIdentifier
        self.showTopProcesses = showTopProcesses
        self.processSortCriteria = processSortCriteria
    }
    
    // Computed
    var orderedMetrics: [MetricType] {
        metricOrder.compactMap { MetricType(rawValue: $0) }
    }
}

