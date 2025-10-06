//
//  MenubarSummaryBuilder.swift
//  MenubarStatus
//
//  Builds menubar summary using unified compact format
//

import Foundation

enum MenubarSummaryBuilder {
    /// Build menubar summary from system metrics
    static func build(from metrics: SystemMetrics, settings: AppSettings) -> MenubarSummary {
        // Get ordered metric types
        var orderedMetricTypes: [MetricType] = settings.displayConfiguration.metricOrder.compactMap { MetricType(rawValue: $0) }
        if orderedMetricTypes.isEmpty {
            orderedMetricTypes = MetricType.allCases
        }
        
        // Ensure uniqueness and append missing ones in default order
        var seen = Set<MetricType>()
        orderedMetricTypes = orderedMetricTypes.compactMap { seen.insert($0).inserted ? $0 : nil }
        for metric in MetricType.allCases where !seen.contains(metric) {
            orderedMetricTypes.append(metric)
        }
        
        // Get theme
        let theme = ThemeManager.shared.getTheme(identifier: settings.displayConfiguration.colorThemeIdentifier) ?? SystemDefaultTheme()
        
        let maxVisible = settings.displayConfiguration.maxVisibleMetrics
        let items = Array(
            orderedMetricTypes
                .compactMap { metricItem(for: $0, metrics: metrics, settings: settings, theme: theme) }
                .filter { !$0.primaryText.isEmpty }
                .prefix(maxVisible)
        )
        
        return MenubarSummary(items: items)
    }
    
    /// Build menubar summary (legacy signature for compatibility)
    static func build(metrics: SystemMetrics?, settings: AppSettings, theme: ColorTheme) -> MenubarSummary {
        guard let metrics else {
            return MenubarSummary(items: [])
        }
        return build(from: metrics, settings: settings)
    }
    
    private static func metricItem(for type: MetricType, metrics: SystemMetrics, settings: AppSettings, theme: ColorTheme) -> MenubarSummary.Item? {
        let showIcon = settings.displayConfiguration.showMenubarIcons
        
        switch type {
        case .cpu:
            guard settings.showCPU else { return nil }
            let percentage = metrics.cpu.usagePercentage
            
            // Use CompactFormatter for menubar display
            let formatted = CompactFormatter.formatForMenubar(
                type: .cpu,
                percentage: percentage,
                bytesPerSecond: nil,
                theme: theme,
                showIcon: showIcon
            )
            
            return MenubarSummary.Item(
                id: "cpu",
                icon: formatted.icon,
                title: "CPU",
                primaryText: formatted.text,
                secondaryText: String(format: "Sys %.0f%%", metrics.cpu.systemUsage),
                percentage: percentage,
                theme: theme
            )
            
        case .memory:
            guard settings.showMemory else { return nil }
            let percentage = Double(metrics.memory.usedBytes) / Double(metrics.memory.totalBytes) * 100
            
            // 内存显示实际使用量，不是百分比
            let usedGB = Double(metrics.memory.usedBytes) / 1_073_741_824.0
            let memoryText = String(format: "%.1fG", usedGB)
            
            let iconName = showIcon ? "memorychip.fill" : ""
            let used = formatBytes(metrics.memory.usedBytes)
            let total = formatBytes(metrics.memory.totalBytes)
            
            return MenubarSummary.Item(
                id: "memory",
                icon: iconName,
                title: "Memory",
                primaryText: memoryText,
                secondaryText: "\(used) of \(total)",
                percentage: percentage,
                theme: theme
            )
            
        case .disk:
            guard settings.showDisk else { return nil }
            
            // 根据 diskDisplayMode 决定显示内容
            switch settings.diskDisplayMode {
            case .capacity:
                // 显示容量使用百分比
                let percentage = metrics.disk.usagePercentage
                let formatted = CompactFormatter.formatForMenubar(
                    type: .disk,
                    percentage: percentage,
                    bytesPerSecond: nil,
                    theme: theme,
                    showIcon: showIcon
                )
                
                return MenubarSummary.Item(
                    id: "disk",
                    icon: formatted.icon,
                    title: "Disk",
                    primaryText: formatted.text,
                    secondaryText: metrics.disk.volumeName,
                    percentage: percentage,
                    theme: theme
                )
                
            case .ioSpeed:
                // 显示读写速度（压缩格式：只显示读或写中较大的那个）
                // TODO: 需要从 DiskMetrics 获取实际的读写速度
                let readBytes: UInt64 = 0 // 占位符 - 需要实际数据
                let writeBytes: UInt64 = 0 // 占位符 - 需要实际数据
                
                // 选择较大的速度显示
                let maxSpeed = max(readBytes, writeBytes)
                let isRead = readBytes >= writeBytes
                let arrow = isRead ? "↓" : "↑"
                let speedText = "\(arrow)\(CompactFormatter.formatNetworkSpeed(maxSpeed))"
                
                // 对于 IO 速度，使用较低的百分比以保持绿色
                let percentage: Double = 20.0
                
                let iconName = showIcon ? "internaldrive.fill" : ""
                
                return MenubarSummary.Item(
                    id: "disk",
                    icon: iconName,
                    title: "Disk I/O",
                    primaryText: speedText,
                    secondaryText: metrics.disk.volumeName,
                    percentage: percentage,
                    theme: theme
                )
            }
            
        case .network:
            guard settings.showNetwork else { return nil }
            let downloadRate = metrics.network.downloadBytesPerSecond
            let uploadRate = metrics.network.uploadBytesPerSecond
            
            // Calculate "usage" percentage for color coding (arbitrary scale)
            let downMB = Double(downloadRate) / 1_048_576
            let upMB = Double(uploadRate) / 1_048_576
            let percentage = min(100, (downMB + upMB) * 10)
            
            // Use CompactFormatter for menubar display
            let formatted = CompactFormatter.formatForMenubar(
                type: .network,
                percentage: percentage,
                bytesPerSecond: downloadRate,
                theme: theme,
                showIcon: showIcon
            )
            
            return MenubarSummary.Item(
                id: "network",
                icon: formatted.icon,
                title: "Network",
                primaryText: formatted.text,
                secondaryText: "↑\(CompactFormatter.formatNetworkSpeed(uploadRate))",
                percentage: percentage,
                theme: theme
            )
        }
    }
    
    private static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
