//
//  MenuBarView.swift
//  MenubarStatus
//
//  Redesigned by AI Assistant on 2025-10-02.
//

import SwiftUI

/// Main menu bar dropdown view with modern card-based layout
struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // 🔧 FIX: 添加 ScrollView 并限制最大高度为半个屏幕
        let maxHeight = (NSScreen.main?.visibleFrame.height ?? 900) / 2
        
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // MARK: - Header
                headerView
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(AnimationProvider.smoothTransition, value: viewModel.isMonitoring)
                
                // MARK: - Metrics
                if let metrics = viewModel.currentMetrics {
                    metricsSection(metrics: metrics)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .animation(AnimationProvider.smoothTransition, value: metrics.timestamp)
                } else {
                    loadingView
                        .transition(.opacity)
                        .animation(AnimationProvider.quickFade, value: viewModel.currentMetrics == nil)
                }
                
                // MARK: - Quick Actions
                actionsView
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            .padding(16)
        }
        .frame(width: 360)
        .frame(maxHeight: maxHeight)
        .background(vibrancyBackground)
        .colorTheme(themeManager.currentTheme)
    }
    
    // T071: Vibrancy background
    private var vibrancyBackground: some View {
        ZStack {
            // Base background
            Color(NSColor.windowBackgroundColor)
            
            // Subtle gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(colorScheme == .dark ? 0.1 : 0.0),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStrings.systemMonitor)
                        .font(.headline)
                    
                    if let metrics = viewModel.currentMetrics {
                        Text("\(LocalizedStrings.updated) \(formatRelativeTime(metrics.timestamp))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(LocalizedStrings.initializing)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Circle()
                    .fill(viewModel.isMonitoring ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                    .help("\(LocalizedStrings.monitoringStatus): \(viewModel.isMonitoring ? LocalizedStrings.active : LocalizedStrings.inactive)") // T072: Tooltip
                    .accessibilityLabel(viewModel.isMonitoring ? LocalizedStrings.monitoringActive : LocalizedStrings.monitoringInactive) // T089: Accessibility
            }
        }
        .padding(12)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Metrics Section
    
    @ViewBuilder
    private func metricsSection(metrics: SystemMetrics) -> some View {
        cpuMetricView(cpu: metrics.cpu)
        memoryMetricView(memory: metrics.memory)
        diskMetricView(disk: metrics.disk)
        networkMetricView(network: metrics.network)
        
        // 🔧 FIX: 显示进程列表（如果在设置中启用）
        if viewModel.settings.displayConfiguration.showTopProcesses,
           let processVM = viewModel.processListViewModel {
            processListSection(processVM: processVM)
        }
    }
    
    // MARK: - Process List Section
    
    private func processListSection(processVM: ProcessListViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.blue)
                Text(LocalizedStrings.processList)
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            if processVM.topProcesses.isEmpty {
                Text(LocalizedStrings.loading)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(processVM.topProcesses.prefix(5)) { process in
                        processRowView(process: process)
                    }
                }
            }
        }
        .padding(12)
        .background(modernCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func processRowView(process: ProcessInfo) -> some View {
        HStack(spacing: 8) {
            if let icon = process.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app.fill")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.caption)
                    .lineLimit(1)
                Text("CPU: \(String(format: "%.1f%%", process.cpuUsage)) · \(process.formattedMemory)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - CPU Metric
    
    private func cpuMetricView(cpu: CPUMetrics) -> some View {
        let theme = themeManager.currentTheme
        let metricColor = getColorForPercentage(cpu.usagePercentage, theme: theme)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(metricColor)
                    .help(LocalizedStrings.cpuUsage) // T072: Tooltip
                Text(LocalizedStrings.cpu)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f%%", cpu.usagePercentage))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundColor(metricColor)
                    .help("Current CPU usage: \(String(format: "%.1f%%", cpu.usagePercentage))") // T072: Tooltip
            }
            
            ProgressView(value: cpu.usagePercentage / 100.0)
                .tint(metricColor)
                .animation(AnimationProvider.smoothTransition, value: cpu.usagePercentage) // T070: Animate value changes
                .accessibilityLabel("CPU usage: \(String(format: "%.1f", cpu.usagePercentage)) percent") // T089: Accessibility
            
            Divider()
            
            metricRow(label: "User", value: String(format: "%.1f%%", cpu.userUsage))
            metricRow(label: "System", value: String(format: "%.1f%%", cpu.systemUsage))
            metricRow(label: "Idle", value: String(format: "%.1f%%", cpu.idlePercentage))
        }
        .padding(12)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Memory Metric
    
    private func memoryMetricView(memory: MemoryMetrics) -> some View {
        let theme = themeManager.currentTheme
        let percentage = Double(memory.usedBytes) / Double(memory.totalBytes) * 100
        let metricColor = getColorForPercentage(percentage, theme: theme)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "memorychip")
                    .foregroundColor(metricColor)
                    .help(LocalizedStrings.memoryUsage) // T072: Tooltip
                Text(LocalizedStrings.memory)
                    .font(.headline)
                Spacer()
                Text(formatMemory(memory.usedBytes))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundColor(metricColor)
                    .help("\(formatMemory(memory.usedBytes)) of \(formatMemory(memory.totalBytes)) used") // T072: Tooltip
            }
            
            ProgressView(value: Double(memory.usedBytes) / Double(memory.totalBytes))
                .tint(metricColor)
                .animation(AnimationProvider.smoothTransition, value: memory.usedBytes) // T070: Animate value changes
                .accessibilityLabel("Memory usage: \(formatMemory(memory.usedBytes)) of \(formatMemory(memory.totalBytes))") // T089: Accessibility
            
            Divider()
            
            metricRow(label: "Total", value: formatMemory(memory.totalBytes))
            metricRow(label: "Used", value: formatMemory(memory.usedBytes))
            metricRow(label: "Free", value: formatMemory(memory.freeBytes))
            
            if memory.cachedBytes > 0 {
                metricRow(label: "Cached", value: formatMemory(memory.cachedBytes))
            }
        }
        .padding(12)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Disk Metric
    
    private func diskMetricView(disk: DiskMetrics) -> some View {
        let theme = themeManager.currentTheme
        let metricColor = getColorForPercentage(disk.usagePercentage, theme: theme)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(metricColor)
                    .help("Disk Usage for \(disk.volumeName)") // T072: Tooltip
                Text(LocalizedStrings.disk)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f%%", disk.usagePercentage))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundColor(metricColor)
                    .help("Disk usage: \(String(format: "%.1f%%", disk.usagePercentage))") // T072: Tooltip
            }
            
            ProgressView(value: disk.usagePercentage / 100.0)
                .tint(metricColor)
                .animation(AnimationProvider.smoothTransition, value: disk.usagePercentage) // T070: Animate value changes
                .accessibilityLabel("Disk usage: \(String(format: "%.1f", disk.usagePercentage)) percent") // T089: Accessibility
            
            Divider()
            
            Text(disk.volumeName)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .help("Volume: \(disk.volumePath)") // T072: Tooltip
            
            metricRow(label: "Total", value: formatMemory(disk.totalBytes))
            metricRow(label: "Used", value: formatMemory(disk.usedBytes))
            metricRow(label: "Free", value: formatMemory(disk.freeBytes))
        }
        .padding(12)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Network Metric
    
    private func networkMetricView(network: NetworkMetrics) -> some View {
        let theme = themeManager.currentTheme
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(theme.accentColor)
                    .help(LocalizedStrings.networkActivity) // T072: Tooltip
                Text(LocalizedStrings.network)
                    .font(.headline)
                Spacer()
            }
            
            Divider()
            
            metricRow(
                label: "↑ Upload",
                value: network.uploadFormatted,
                icon: "arrow.up.circle.fill"
            )
            .help("Upload speed: \(network.uploadFormatted)") // T072: Tooltip
            
            metricRow(
                label: "↓ Download",
                value: network.downloadFormatted,
                icon: "arrow.down.circle.fill"
            )
            .help("Download speed: \(network.downloadFormatted)") // T072: Tooltip
        }
        .padding(12)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Actions
    
    private var actionsView: some View {
        VStack(spacing: 0) {
            actionButton(icon: "gear", title: "Settings...") {
                NSApp.keyWindow?.close()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let settingsVM = SettingsViewModel()
                    SettingsWindowManager.shared.showSettings(viewModel: settingsVM)
                }
            }
            .help("Open Settings window") // T072: Tooltip
            
            Divider()
            
            actionButton(icon: "power", title: "Quit", destructive: true) {
                NSApplication.shared.terminate(nil)
            }
            .help("Quit MenubarStatus") // T072: Tooltip
        }
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // MARK: - Helper Views
    
    private func actionButton(
        icon: String,
        title: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        HoverButton(action: action) { // T072: Hover state
            HStack {
                Image(systemName: icon)
                    .foregroundColor(destructive ? .red : .accentColor)
                    .frame(width: 20)
                Text(title)
                    .foregroundColor(destructive ? .red : .primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
    }
    
    // T072: Hover button with visual feedback
    private struct HoverButton<Content: View>: View {
        let action: () -> Void
        @ViewBuilder let content: Content
        @State private var isHovering = false
        
        var body: some View {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovering ? Color.accentColor.opacity(0.1) : Color.clear) // T072: Hover effect
            )
            .onHover { hovering in
                withAnimation(AnimationProvider.quickFade) {
                    isHovering = hovering
                }
            }
        }
    }
    
    private func metricRow(
        label: String,
        value: String,
        icon: String? = nil
    ) -> some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .monospacedDigit()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(.circular)
            Text("Loading metrics...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(modernCardBackground) // T071: Modern styling
        .cornerRadius(12) // T071: Increased corner radius
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2) // T071: Subtle shadow
    }
    
    // T071: Modern card background with translucent effect
    private var modernCardBackground: some View {
        ZStack {
            // Base translucent background
            Color(NSColor.controlBackgroundColor)
                .opacity(colorScheme == .dark ? 0.4 : 0.6)
            
            // Subtle border for definition
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    Color.primary.opacity(0.1),
                    lineWidth: 0.5
                )
        }
    }
    
    // MARK: - Formatters
    
    private func formatMemory(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        if gb >= 1.0 {
            return String(format: "%.1f GB", gb)
        } else {
            let mb = Double(bytes) / 1_048_576.0
            return String(format: "%.0f MB", mb)
        }
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let interval = -date.timeIntervalSinceNow
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Theme Color Helper
    
    /// 根据百分比和主题返回对应的颜色
    /// - 0-59%: 健康（绿色/主题健康色）
    /// - 60-79%: 警告（黄色/主题警告色）
    /// - 80-100%: 严重（红色/主题严重色）
    private func getColorForPercentage(_ percentage: Double, theme: ColorTheme) -> Color {
        if percentage < 60 {
            return theme.healthyColor
        } else if percentage < 80 {
            return theme.warningColor
        } else {
            return theme.criticalColor
        }
    }
}

// MARK: - Preview

#Preview {
    let settings = AppSettings()
    let viewModel = MenuBarViewModel(settings: settings)
    
    viewModel.currentMetrics = SystemMetrics(
        timestamp: Date(),
        cpu: CPUMetrics(usagePercentage: 45.5, systemUsage: 20.0, userUsage: 25.5, idlePercentage: 54.5),
        memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 8_000_000_000, freeBytes: 8_000_000_000, cachedBytes: 1_000_000_000),
        disk: DiskMetrics(
            volumePath: "/",
            volumeName: "Macintosh HD",
            totalBytes: 500_000_000_000,
            freeBytes: 250_000_000_000,
            usedBytes: 250_000_000_000
        ),
        network: NetworkMetrics(
            uploadBytesPerSecond: 1_024_000,
            downloadBytesPerSecond: 2_048_000,
            totalUploadBytes: 10_240_000,
            totalDownloadBytes: 20_480_000
        )
    )
    
    return MenuBarView(viewModel: viewModel)
}
