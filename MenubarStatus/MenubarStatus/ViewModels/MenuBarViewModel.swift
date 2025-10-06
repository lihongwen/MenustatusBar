//
//  MenuBarViewModel.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel for the menubar display and dropdown
@MainActor
final class MenuBarViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentMetrics: SystemMetrics?
    @Published var isMonitoring: Bool = false
    @Published var errorMessage: String?
    
    // NEW: Process list support
    @Published var processListViewModel: ProcessListViewModel?
    @Published var showProcessList: Bool = false
    
    // NEW: Memory purge state
    @Published var isPurgingMemory: Bool = false
    @Published var lastPurgeResult: MemoryPurgeResult?
    
    // MARK: - Private Properties
    
    private let monitor: SystemMonitorImpl
    private let settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    private let themeManager = ThemeManager.shared
    
    // MARK: - Computed Properties (use settings from manager)
    
    var settings: AppSettings {
        settingsManager.settings
    }
    
    // NEW: Expose services for UI
    var memoryPurger: MemoryPurging {
        monitor.memoryPurger
    }
    
    var processMonitor: ProcessMonitoring {
        monitor.processMonitor
    }
    
    var diskHealthMonitor: DiskHealthMonitoring {
        monitor.diskHealthMonitor
    }
    
    var historicalDataManager: HistoricalDataManaging {
        monitor.historicalDataManager
    }
    
    // MARK: - Computed Properties
    
    /// Text to display in the menubar - using unified compact format
    var displayText: String {
        guard let metrics = currentMetrics else {
            return "---"
        }
        
        // Use unified compact format (Icon + Value style)
        return iconAndValueText(metrics: metrics)
    }
    
    // MARK: - Display Mode Implementations
    
    /// Icon + Value 模式: 🖥️ 45%
    private func iconAndValueText(metrics: SystemMetrics) -> String {
        var components: [String] = []
        
        if settings.showCPU {
            components.append("🖥️ \(Int(metrics.cpu.usagePercentage))%")
        }
        if settings.showMemory {
            let memGB = Double(metrics.memory.usedBytes) / 1_073_741_824
            components.append("💾 \(String(format: "%.1f", memGB))G")
        }
        if settings.showDisk {
            // 🔧 根据 diskDisplayMode 决定显示内容
            switch settings.diskDisplayMode {
            case .capacity:
                components.append("💿 \(Int(metrics.disk.usagePercentage))%")
            case .ioSpeed:
                let totalMB = Double(metrics.disk.totalIOBytesPerSecond) / 1_048_576
                components.append("💿 \(String(format: "%.1f", totalMB))MB/s")
            }
        }
        if settings.showNetwork {
            let downMB = Double(metrics.network.downloadBytesPerSecond) / 1_048_576
            components.append("🌐 ↓\(String(format: "%.1f", downMB))")
        }
        
        return components.isEmpty ? "---" : components.joined(separator: "  ")
    }
    
    /// Compact Text 模式: CPU 45% | Mem 8.0GB
    private func compactText(metrics: SystemMetrics) -> String {
        var components: [String] = []
        
        if settings.showCPU {
            components.append("CPU \(Int(metrics.cpu.usagePercentage))%")
        }
        if settings.showMemory {
            let memGB = Double(metrics.memory.usedBytes) / 1_073_741_824
            components.append("Mem \(String(format: "%.1f", memGB))G")
        }
        if settings.showDisk {
            // 🔧 根据 diskDisplayMode 决定显示内容
            switch settings.diskDisplayMode {
            case .capacity:
                components.append("Disk \(Int(metrics.disk.usagePercentage))%")
            case .ioSpeed:
                let totalMB = Double(metrics.disk.totalIOBytesPerSecond) / 1_048_576
                components.append("Disk \(String(format: "%.1f", totalMB))MB/s")
            }
        }
        if settings.showNetwork {
            let downMB = Double(metrics.network.downloadBytesPerSecond) / 1_048_576
            components.append("Net ↓\(String(format: "%.1f", downMB))")
        }
        
        return components.isEmpty ? "---" : components.joined(separator: " | ")
    }
    
    /// Graph Mode 模式: ▁▃▅▇ 表示强度
    private func graphModeText(metrics: SystemMetrics) -> String {
        var components: [String] = []
        
        if settings.showCPU {
            let graph = getGraphBar(percentage: metrics.cpu.usagePercentage)
            components.append("C:\(graph)")
        }
        if settings.showMemory {
            let memPercent = Double(metrics.memory.usedBytes) / Double(metrics.memory.totalBytes) * 100
            let graph = getGraphBar(percentage: memPercent)
            components.append("M:\(graph)")
        }
        if settings.showDisk {
            // 🔧 根据 diskDisplayMode 决定显示内容
            let percentage: Double
            switch settings.diskDisplayMode {
            case .capacity:
                percentage = metrics.disk.usagePercentage
            case .ioSpeed:
                // IO速度：最大100MB/s = 100%
                let speedMB = Double(metrics.disk.totalIOBytesPerSecond) / 1_048_576
                percentage = min(speedMB / 100.0 * 100, 100)
            }
            let graph = getGraphBar(percentage: percentage)
            components.append("D:\(graph)")
        }
        if settings.showNetwork {
            // Network 用速度来表示强度 (最大 100MB/s)
            let speedMB = Double(metrics.network.downloadBytesPerSecond) / 1_048_576
            let percent = min(speedMB / 10.0 * 100, 100) // 10MB/s = 100%
            let graph = getGraphBar(percentage: percent)
            components.append("N:\(graph)")
        }
        
        return components.isEmpty ? "---" : components.joined(separator: " ")
    }
    
    /// Icons Only 模式: 🟢 🟡 🔴 (颜色表示状态)
    private func iconsOnlyText(metrics: SystemMetrics) -> String {
        var components: [String] = []
        
        if settings.showCPU {
            let icon = getColorIcon(percentage: metrics.cpu.usagePercentage)
            components.append(icon)
        }
        if settings.showMemory {
            let memPercent = Double(metrics.memory.usedBytes) / Double(metrics.memory.totalBytes) * 100
            let icon = getColorIcon(percentage: memPercent)
            components.append(icon)
        }
        if settings.showDisk {
            // 🔧 根据 diskDisplayMode 决定显示内容
            let percentage: Double
            switch settings.diskDisplayMode {
            case .capacity:
                percentage = metrics.disk.usagePercentage
            case .ioSpeed:
                // IO速度：最大100MB/s = 100%
                let speedMB = Double(metrics.disk.totalIOBytesPerSecond) / 1_048_576
                percentage = min(speedMB / 100.0 * 100, 100)
            }
            let icon = getColorIcon(percentage: percentage)
            components.append(icon)
        }
        if settings.showNetwork {
            // Network 用速度表示（绿色=低，黄色=中，红色=高）
            let speedMB = Double(metrics.network.downloadBytesPerSecond) / 1_048_576
            let percent = min(speedMB / 10.0 * 100, 100)
            let icon = getColorIcon(percentage: percent)
            components.append(icon)
        }
        
        return components.isEmpty ? "---" : components.joined(separator: " ")
    }
    
    // MARK: - Helper Methods
    
    /// 根据百分比返回图形条: ▁▃▅▇
    private func getGraphBar(percentage: Double) -> String {
        let bars = ["▁", "▃", "▅", "▇"]
        let index = min(Int(percentage / 25), 3)
        return bars[index]
    }
    
    /// 根据百分比和主题返回颜色图标符号
    /// 使用 emoji 彩色圆点，在所有系统上都能正确显示
    private func getColorIcon(percentage: Double) -> String {
        let theme = themeManager.currentTheme
        
        // 🔧 FIX: 使用可靠的 emoji 圆点，根据主题调整符号风格
        switch theme.identifier {
        case "monochrome":
            // 单色主题：使用灰色系 emoji 圆点（更清晰可见）
            if percentage < 60 {
                return "⚪" // 白色圆点 - 良好
            } else if percentage < 80 {
                return "⚫" // 灰色圆点 - 警告
            } else {
                return "⬛" // 黑色方块 - 危险
            }
            
        case "traffic":
            // 交通灯主题：使用标准 emoji 颜色圆点（最清晰）
            if percentage < 60 {
                return "🟢" // 绿色圆点 - 良好
            } else if percentage < 80 {
                return "🟡" // 黄色圆点 - 警告
            } else {
                return "🔴" // 红色圆点 - 危险
            }
            
        case "cool":
            // 冷色调：使用蓝色系 emoji
            if percentage < 60 {
                return "🔵" // 蓝色圆点 - 良好
            } else if percentage < 80 {
                return "🟣" // 紫色圆点 - 警告
            } else {
                return "🔴" // 红色圆点 - 危险
            }
            
        case "warm":
            // 暖色调：使用暖色系 emoji
            if percentage < 60 {
                return "🟡" // 黄色圆点 - 良好
            } else if percentage < 80 {
                return "🟠" // 橙色圆点 - 警告
            } else {
                return "🔴" // 红色圆点 - 危险
            }
            
        default:
            // 系统默认：使用标准交通灯配色（最通用）
            if percentage < 60 {
                return "🟢" // 绿色圆点 - 良好
            } else if percentage < 80 {
                return "🟡" // 黄色圆点 - 警告
            } else {
                return "🔴" // 红色圆点 - 危险
            }
        }
    }
    
    /// 获取当前指标的颜色（用于 MenuBar 图标着色）
    var menuBarIconColor: Color {
        guard let metrics = currentMetrics else {
            return .secondary
        }
        
        let theme = themeManager.currentTheme
        
        // 使用 CPU 作为主要指标来决定颜色
        let percentage = metrics.cpu.usagePercentage
        
        if percentage < 60 {
            return theme.healthyColor
        } else if percentage < 80 {
            return theme.warningColor
        } else {
            return theme.criticalColor
        }
    }
    
    /// Detailed text for dropdown menu
    var detailsText: String {
        guard let metrics = currentMetrics else {
            return "No data available"
        }
        
        var details: [String] = []
        
        // CPU
        details.append("CPU Usage: \(String(format: "%.1f", metrics.cpu.usagePercentage))%")
        details.append("  User: \(String(format: "%.1f", metrics.cpu.userUsage))%")
        details.append("  System: \(String(format: "%.1f", metrics.cpu.systemUsage))%")
        details.append("  Idle: \(String(format: "%.1f", metrics.cpu.idlePercentage))%")
        
        // Memory
        let totalGB = Double(metrics.memory.totalBytes) / 1_000_000_000
        let usedGB = Double(metrics.memory.usedBytes) / 1_000_000_000
        let freeGB = Double(metrics.memory.freeBytes) / 1_000_000_000
        details.append("")
        details.append("Memory: \(String(format: "%.1f", usedGB))GB / \(String(format: "%.1f", totalGB))GB (\(String(format: "%.1f", metrics.memory.usagePercentage))%)")
        details.append("  Free: \(String(format: "%.1f", freeGB))GB")
        
        // Disk
        let totalDiskGB = Double(metrics.disk.totalBytes) / 1_000_000_000
        let freeDiskGB = Double(metrics.disk.freeBytes) / 1_000_000_000
        let usedDiskGB = Double(metrics.disk.usedBytes) / 1_000_000_000
        details.append("")
        details.append("Disk (\(metrics.disk.volumeName)): \(String(format: "%.1f", usedDiskGB))GB / \(String(format: "%.1f", totalDiskGB))GB (\(String(format: "%.1f", metrics.disk.usagePercentage))%)")
        details.append("  Free: \(String(format: "%.1f", freeDiskGB))GB")
        details.append("  Read Speed: \(metrics.disk.readSpeedFormatted)")
        details.append("  Write Speed: \(metrics.disk.writeSpeedFormatted)")
        
        // Network
        details.append("")
        details.append("Network:")
        details.append("  ↑ Upload: \(metrics.network.uploadFormatted)")
        details.append("  ↓ Download: \(metrics.network.downloadFormatted)")
        details.append("  Total ↑: \(formatBytes(metrics.network.totalUploadBytes))")
        details.append("  Total ↓: \(formatBytes(metrics.network.totalDownloadBytes))")
        
        return details.joined(separator: "\n")
    }
    
    // MARK: - Initialization
    
    init(monitor: SystemMonitorImpl, settingsManager: SettingsManager) {
        self.monitor = monitor
        self.settingsManager = settingsManager
        self.isMonitoring = monitor.isMonitoring
        
        setupSubscriptions()
    }
    
    convenience init(settings: AppSettings) {
        let manager = SettingsManager.shared
        let monitor = SystemMonitorImpl(settings: settings)
        self.init(monitor: monitor, settingsManager: manager)
    }
    
    convenience init() {
        let manager = SettingsManager.shared
        let monitor = SystemMonitorImpl(settings: manager.settings)
        self.init(monitor: monitor, settingsManager: manager)
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        monitor.start(interval: settings.refreshInterval)
        isMonitoring = true
        
        // Start process list if enabled
        if settings.displayConfiguration.showTopProcesses {
            startProcessListMonitoring()
        }
    }
    
    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
        
        // Stop process list
        processListViewModel?.stopRefreshing()
    }
    
    // MARK: - NEW: Process List Methods
    
    func startProcessListMonitoring() {
        if processListViewModel == nil {
            processListViewModel = ProcessListViewModel(processMonitor: monitor.processMonitor)
        }
        processListViewModel?.startRefreshing(interval: settings.refreshInterval)
        showProcessList = true
    }
    
    func stopProcessListMonitoring() {
        processListViewModel?.stopRefreshing()
        showProcessList = false
    }
    
    // MARK: - NEW: Memory Purge Methods
    
    func purgeMemory() async {
        guard !isPurgingMemory else { return }
        
        isPurgingMemory = true
        defer { isPurgingMemory = false }
        
        do {
            let result = try await monitor.memoryPurger.purgeInactiveMemory()
            lastPurgeResult = result
            errorMessage = nil
        } catch {
            errorMessage = "Memory purge failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - NEW: Historical Data Access
    
    func getHistoricalData(for metric: MetricType) -> [HistoricalDataPoint] {
        return monitor.historicalDataManager.getHistory(for: metric, duration: 60)
    }
    
    // MARK: - NEW: Disk Health Access
    
    func getAllDiskHealth() -> [DiskHealthInfo] {
        return monitor.diskHealthMonitor.monitorAllVolumes()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Subscribe to monitor's currentMetrics
        monitor.$currentMetrics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metrics in
                self?.currentMetrics = metrics
            }
            .store(in: &cancellables)
        
        // Subscribe to monitor's isMonitoring state
        monitor.$isMonitoring
            .receive(on: DispatchQueue.main)
            .sink { [weak self] monitoring in
                self?.isMonitoring = monitoring
            }
            .store(in: &cancellables)
        
        // Subscribe to settings changes
        settingsManager.$settings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newSettings in
                guard let self = self else { return }
                
                // Update monitor settings
                self.monitor.settings = newSettings
                
                // Restart monitoring with new interval if changed
                if self.isMonitoring {
                    self.monitor.stop()
                    self.monitor.start(interval: newSettings.refreshInterval)
                }
                
                // Force UI update
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func formatBytes(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024
        let mb = kb / 1024
        let gb = mb / 1024
        
        if gb >= 1.0 {
            return String(format: "%.2f GB", gb)
        } else if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1.0 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(bytes) B"
        }
    }
}

