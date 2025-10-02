//
//  SettingsView.swift
//  MenubarStatus
//
//  Redesigned by AI Assistant on 2025-10-02.
//

import SwiftUI

/// Settings window with tabbed interface
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var selectedTab: SettingsTab = .display
    @State private var showLanguageChangeAlert = false
    @State private var pendingLanguage: AppLanguage?
    
    enum SettingsTab: String, CaseIterable, Identifiable {
        case display
        case appearance
        case monitoring
        case advanced
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .display: return LocalizedStrings.display
            case .appearance: return LocalizedStrings.appearance
            case .monitoring: return LocalizedStrings.monitoring
            case .advanced: return LocalizedStrings.advanced
            }
        }
        
        var icon: String {
            switch self {
            case .display: return "rectangle.3.group"
            case .appearance: return "paintpalette"
            case .monitoring: return "chart.xyaxis.line"
            case .advanced: return "gearshape.2"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            Picker(LocalizedStrings.settings, selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.displayName, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // Tab Content
            ScrollView {
                Group {
                    switch selectedTab {
                    case .display:
                        displayTab
                    case .appearance:
                        appearanceTab
                    case .monitoring:
                        monitoringTab
                    case .advanced:
                        advancedTab
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Action Buttons
            HStack {
                Button(LocalizedStrings.resetToDefaults) {
                    viewModel.resetToDefaults()
                }
                .help(LocalizedStrings.restoreDefaults)
                
                Spacer()
                
                Button(LocalizedStrings.close) {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
        .alert(LocalizedStrings.restartApplicationTitle, isPresented: $showLanguageChangeAlert) {
            Button(LocalizedStrings.cancel, role: .cancel) {
                pendingLanguage = nil
            }
            Button(LocalizedStrings.restartNow) {
                if let newLanguage = pendingLanguage {
                    applyLanguageAndRestart(newLanguage)
                }
            }
        } message: {
            Text(LocalizedStrings.restartApplicationMessage)
        }
    }
    
    // MARK: - Helper Methods
    
    private func applyLanguageAndRestart(_ newLanguage: AppLanguage) {
        // 保存语言设置
        var newSettings = viewModel.settings
        newSettings.language = newLanguage
        viewModel.settings = newSettings
        
        // 重启应用
        restartApplication()
    }
    
    private func restartApplication() {
        // 获取应用路径
        let appPath = Bundle.main.bundlePath
        
        // 使用 bash 脚本延迟重启
        let script = """
        #!/bin/bash
        sleep 0.5
        open "\(appPath)"
        """
        
        // 写入临时脚本
        let tempScript = NSTemporaryDirectory() + "restart_menubar_status.sh"
        try? script.write(toFile: tempScript, atomically: true, encoding: .utf8)
        
        // 设置执行权限
        let chmod = Process()
        chmod.launchPath = "/bin/chmod"
        chmod.arguments = ["+x", tempScript]
        try? chmod.run()
        chmod.waitUntilExit()
        
        // 启动脚本
        let bash = Process()
        bash.launchPath = "/bin/bash"
        bash.arguments = [tempScript]
        try? bash.run()
        
        // 退出当前应用
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Display Tab
    
    private var displayTab: some View {
        Form {
            Section(header: Text(LocalizedStrings.metricsVisibility)) {
                Toggle(LocalizedStrings.showCPU, isOn: Binding(
                    get: { viewModel.settings.showCPU },
                    set: { viewModel.settings.showCPU = $0 }
                ))
                Toggle(LocalizedStrings.showMemory, isOn: Binding(
                    get: { viewModel.settings.showMemory },
                    set: { viewModel.settings.showMemory = $0 }
                ))
                Toggle(LocalizedStrings.showDisk, isOn: Binding(
                    get: { viewModel.settings.showDisk },
                    set: { viewModel.settings.showDisk = $0 }
                ))
                Toggle(LocalizedStrings.showNetwork, isOn: Binding(
                    get: { viewModel.settings.showNetwork },
                    set: { viewModel.settings.showNetwork = $0 }
                ))
            }
            
            Section(header: Text(LocalizedStrings.displayMode)) {
                Picker(LocalizedStrings.mode, selection: Binding(
                    get: { viewModel.settings.displayConfiguration.displayMode },
                    set: { 
                        var config = viewModel.settings.displayConfiguration
                        config.displayMode = $0
                        viewModel.settings.displayConfiguration = config
                    }
                )) {
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
                
                Text(LocalizedStrings.changesMenubarStyle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text(LocalizedStrings.metricOrder)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStrings.dragToReorder)
                        .font(.subheadline)
                    
                    metricReorderingList
                }
            }
            
            Section(header: Text(LocalizedStrings.processList)) {
                Toggle(LocalizedStrings.showTopProcesses, isOn: Binding(
                    get: { viewModel.settings.displayConfiguration.showTopProcesses },
                    set: { _ in viewModel.toggleShowTopProcesses() }
                ))
                
                if viewModel.settings.displayConfiguration.showTopProcesses {
                    Picker(LocalizedStrings.sortBy, selection: Binding(
                        get: {
                            ProcessSortCriteria(rawValue: viewModel.settings.displayConfiguration.processSortCriteria) ?? .cpu
                        },
                        set: { viewModel.updateProcessSortCriteria($0) }
                    )) {
                        ForEach(ProcessSortCriteria.allCases, id: \.self) { criteria in
                            Text(criteria.displayName).tag(criteria)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Section(header: Text("Auto-Hide")) {
                Toggle("Enable Auto-Hide", isOn: Binding(
                    get: { viewModel.settings.displayConfiguration.autoHideEnabled },
                    set: { enabled in
                        viewModel.updateAutoHide(
                            enabled: enabled,
                            threshold: viewModel.settings.displayConfiguration.autoHideThreshold
                        )
                    }
                ))
                
                if viewModel.settings.displayConfiguration.autoHideEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hide when below:")
                            Spacer()
                            Text(String(format: "%.0f%%", viewModel.settings.displayConfiguration.autoHideThreshold * 100))
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.settings.displayConfiguration.autoHideThreshold },
                                set: { threshold in
                                    viewModel.updateAutoHide(
                                        enabled: true,
                                        threshold: threshold
                                    )
                                }
                            ),
                            in: 0.0...1.0,
                            step: 0.05
                        )
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Appearance Tab
    
    private var appearanceTab: some View {
        Form {
            Section(header: Text(LocalizedStrings.colorTheme)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedStrings.theme)
                        .font(.subheadline)
                    
                    ForEach(viewModel.availableThemes, id: \.identifier) { theme in
                        themeOption(theme: theme)
                    }
                }
            }
            
            Section(header: Text("Display Options")) {
                Toggle(LocalizedStrings.compactMode, isOn: Binding(
                    get: { viewModel.settings.useCompactMode },
                    set: { viewModel.settings.useCompactMode = $0 }
                ))
                    .help(LocalizedStrings.useCompactDisplay)
            }
            
            Section(header: Text("Language")) {
                Picker("Interface Language:", selection: Binding(
                    get: { viewModel.settings.language },
                    set: { newLanguage in
                        // 只有当语言真的改变时才显示确认对话框
                        if newLanguage != viewModel.settings.language {
                            pendingLanguage = newLanguage
                            showLanguageChangeAlert = true
                        }
                    }
                )) {
                    ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                        Text(lang.nativeName).tag(lang)
                    }
                }
                .pickerStyle(.radioGroup)
                
                Text(LocalizedStrings.languageDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(LocalizedStrings.willRestartAutomatically)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Monitoring Tab
    
    private var monitoringTab: some View {
        Form {
            Section(header: Text(LocalizedStrings.refreshSettings)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizedStrings.refreshInterval)
                        Spacer()
                        Text(String(format: "%.1f \(LocalizedStrings.seconds)", viewModel.settings.refreshInterval))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { viewModel.settings.refreshInterval },
                            set: { viewModel.settings.refreshInterval = $0 }
                        ),
                        in: 1.0...5.0,
                        step: 0.5
                    )
                    
                    Text(LocalizedStrings.refreshDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Advanced Tab
    
    private var advancedTab: some View {
        Form {
            Section(header: Text(LocalizedStrings.diskPaths)) {
                Picker(LocalizedStrings.selectedDisk, selection: Binding(
                    get: { viewModel.settings.selectedDiskPath },
                    set: { viewModel.settings.selectedDiskPath = $0 }
                )) {
                    ForEach(viewModel.availableDisks, id: \.path) { disk in
                        Text(disk.displayName).tag(disk.path)
                    }
                }
                
                Button(LocalizedStrings.scanDisks) {
                    viewModel.refreshAvailableDisks()
                }
                .help(LocalizedStrings.scanForNewDisks)
                
                Divider()
                
                Picker("\(LocalizedStrings.displayMode):", selection: Binding(
                    get: { viewModel.settings.diskDisplayMode },
                    set: { 
                        // 🔧 FIX: 触发保存和更新
                        var newSettings = viewModel.settings
                        newSettings.diskDisplayMode = $0
                        viewModel.settings = newSettings
                    }
                )) {
                    ForEach(DiskDisplayMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.radioGroup)
            }
            
            Section(header: Text(LocalizedStrings.networkInterfaces)) {
                Text(LocalizedStrings.autoDetectInterface)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text(LocalizedStrings.startup)) {
                Toggle(LocalizedStrings.launchAtLogin, isOn: Binding(
                    get: { viewModel.settings.launchAtLogin },
                    set: { viewModel.settings.launchAtLogin = $0 }
                ))
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Helper Views
    
    private var metricReorderingList: some View {
        ForEach(viewModel.metricOrderDraft, id: \.self) { metric in
            HStack {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
                
                Image(systemName: metric.icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 20)
                
                Text(metric.displayName)
                
                Spacer()
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
        }
        .onMove { source, destination in
            viewModel.moveMetric(from: source, to: destination)
        }
    }
    
    private func themeOption(theme: ColorTheme) -> some View {
        Button(action: {
            viewModel.selectTheme(theme)
        }) {
            HStack {
                // Radio button
                Image(systemName: viewModel.selectedTheme.identifier == theme.identifier ? "circle.fill" : "circle")
                    .foregroundColor(.accentColor)
                
                // Theme name
                Text(theme.displayName)
                
                Spacer()
                
                // Color preview
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.healthyColor)
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(theme.warningColor)
                        .frame(width: 16, height: 16)
                    Circle()
                        .fill(theme.criticalColor)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(8)
            .background(
                viewModel.selectedTheme.identifier == theme.identifier ?
                Color.accentColor.opacity(0.1) :
                Color.clear
            )
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = SettingsViewModel()
    return SettingsView(viewModel: viewModel)
}
