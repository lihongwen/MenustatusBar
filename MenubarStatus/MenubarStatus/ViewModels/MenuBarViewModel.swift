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
    
    // MARK: - Private Properties
    
    private let monitor: SystemMonitorImpl
    private let settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties (use settings from manager)
    
    private var settings: AppSettings {
        settingsManager.settings
    }
    
    // MARK: - Computed Properties
    
    /// Text to display in the menubar
    var displayText: String {
        guard let metrics = currentMetrics else {
            return "---"
        }
        
        var components: [String] = []
        
        if settings.showCPU {
            let cpuValue = Int(metrics.cpu.usagePercentage)
            components.append("CPU \(cpuValue)%")
        }
        
        if settings.showMemory {
            let memoryGB = Double(metrics.memory.usedBytes) / 1_000_000_000
            components.append("Mem \(String(format: "%.1f", memoryGB))GB")
        }
        
        if settings.showDisk {
            switch settings.diskDisplayMode {
            case .capacity:
                let diskPercent = Int(metrics.disk.usagePercentage)
                components.append("Disk \(diskPercent)%")
            case .ioSpeed:
                let readMBps = Double(metrics.disk.readBytesPerSecond) / 1_048_576  // MB/s
                let writeMBps = Double(metrics.disk.writeBytesPerSecond) / 1_048_576
                if readMBps >= 1.0 || writeMBps >= 1.0 {
                    components.append("I/O ↓\(String(format: "%.0f", readMBps))↑\(String(format: "%.0f", writeMBps))MB/s")
                } else {
                    let readKBps = Double(metrics.disk.readBytesPerSecond) / 1024  // KB/s
                    let writeKBps = Double(metrics.disk.writeBytesPerSecond) / 1024
                    components.append("I/O ↓\(String(format: "%.0f", readKBps))↑\(String(format: "%.0f", writeKBps))KB/s")
                }
            }
        }
        
        if settings.showNetwork {
            let downloadMBps = Double(metrics.network.downloadBytesPerSecond) / 1_000_000
            components.append("↓\(String(format: "%.1f", downloadMBps))MB/s")
        }
        
        return components.isEmpty ? "---" : components.joined(separator: " | ")
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
    
    convenience init() {
        let manager = SettingsManager.shared
        let monitor = SystemMonitorImpl(settings: manager.settings)
        self.init(monitor: monitor, settingsManager: manager)
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        monitor.start(interval: settings.refreshInterval)
        isMonitoring = true
    }
    
    func stopMonitoring() {
        monitor.stop()
        isMonitoring = false
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

