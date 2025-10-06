//
//  SettingsViewModel.swift
//  MenubarStatus
//
//  Enhanced with draft mode by AI Assistant on 2025-10-02.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel for the settings window with real-time updates
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // 🔧 FIX: 直接使用 SettingsManager.settings - 实时保存
    var settings: AppSettings {
        get { settingsManager.settings }
        set { 
            settingsManager.settings = newValue
            // 立即通知系统设置已更改
            NotificationCenter.default.post(name: .settingsDidChange, object: newValue)
            // 🔧 FIX: 触发 UI 更新
            objectWillChange.send()
        }
    }
    
    @Published var availableDisks: [DiskInfo] = []
    
    // Display configuration
    @Published var metricOrderDraft: [MetricType] = []
    
    // MARK: - Private Properties
    
    private let diskMonitor: DiskMonitorImpl
    private let themeManager: ThemeManager
    private let settingsManager: SettingsManager
    
    // MARK: - Initialization
    
    init(themeManager: ThemeManager = .shared, settingsManager: SettingsManager = .shared) {
        self.diskMonitor = DiskMonitorImpl()
        self.themeManager = themeManager
        self.settingsManager = settingsManager
        
        // Initialize metric order draft
        self.metricOrderDraft = settingsManager.settings.displayConfiguration.orderedMetrics
        
        // Initialize language setting
        LocalizedStrings.language = settingsManager.settings.language
        
        // Discover available disks
        refreshAvailableDisks()
    }
    
    // MARK: - Public Methods
    
    /// Refresh the list of available disks
    func refreshAvailableDisks() {
        availableDisks = diskMonitor.getAvailableVolumes()
    }
    
    /// Reset to default settings
    func resetToDefaults() {
        settings = AppSettings()
        metricOrderDraft = settings.displayConfiguration.orderedMetrics
    }
    
    // MARK: - Display Configuration Methods
    
    func toggleShowTopProcesses() {
        var config = settings.displayConfiguration
        config.showTopProcesses.toggle()
        settings.displayConfiguration = config
    }
    
    func updateProcessSortCriteria(_ criteria: ProcessSortCriteria) {
        var config = settings.displayConfiguration
        config.processSortCriteria = criteria.rawValue
        settings.displayConfiguration = config
    }
    
    func updateAutoHide(enabled: Bool, threshold: Double) {
        var config = settings.displayConfiguration
        config.autoHideEnabled = enabled
        config.autoHideThreshold = threshold
        settings.displayConfiguration = config
    }
    
    func moveMetric(from source: IndexSet, to destination: Int) {
        metricOrderDraft.move(fromOffsets: source, toOffset: destination)
        // 立即更新设置
        var config = settings.displayConfiguration
        config.metricOrder = metricOrderDraft.map { $0.rawValue }
        settings.displayConfiguration = config
    }
}

