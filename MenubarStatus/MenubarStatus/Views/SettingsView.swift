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
    
    enum SettingsTab: String, CaseIterable, Identifiable {
        case display = "Display"
        case appearance = "Appearance"
        case monitoring = "Monitoring"
        case advanced = "Advanced"
        
        var id: String { rawValue }
        
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
            Picker("Settings Tab", selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
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
                Button("Reset to Defaults") {
                    viewModel.resetToDefaults()
                }
                .help("Restore default settings")
                
                Spacer()
                
                Button("Close") {
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
    
    // MARK: - Display Tab
    
    private var displayTab: some View {
        Form {
            Section(header: Text("Metrics Visibility")) {
                Toggle("Show CPU", isOn: Binding(
                    get: { viewModel.settings.showCPU },
                    set: { viewModel.settings.showCPU = $0 }
                ))
                Toggle("Show Memory", isOn: Binding(
                    get: { viewModel.settings.showMemory },
                    set: { viewModel.settings.showMemory = $0 }
                ))
                Toggle("Show Disk", isOn: Binding(
                    get: { viewModel.settings.showDisk },
                    set: { viewModel.settings.showDisk = $0 }
                ))
                Toggle("Show Network", isOn: Binding(
                    get: { viewModel.settings.showNetwork },
                    set: { viewModel.settings.showNetwork = $0 }
                ))
            }
            
            Section(header: Text("Display Mode")) {
                Picker("Mode:", selection: Binding(
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
                
                Text("Changes the menubar display style")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Metric Order")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drag to reorder metrics:")
                        .font(.subheadline)
                    
                    metricReorderingList
                }
            }
            
            Section(header: Text("Process List")) {
                Toggle("Show Top Processes", isOn: Binding(
                    get: { viewModel.settings.displayConfiguration.showTopProcesses },
                    set: { _ in viewModel.toggleShowTopProcesses() }
                ))
                
                if viewModel.settings.displayConfiguration.showTopProcesses {
                    Picker("Sort by:", selection: Binding(
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
            Section(header: Text("Color Theme")) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Theme:")
                        .font(.subheadline)
                    
                    ForEach(viewModel.availableThemes, id: \.identifier) { theme in
                        themeOption(theme: theme)
                    }
                }
            }
            
            Section(header: Text("Display Options")) {
                Toggle("Compact Mode", isOn: Binding(
                    get: { viewModel.settings.useCompactMode },
                    set: { viewModel.settings.useCompactMode = $0 }
                ))
                    .help("Use shorter text format in menu bar")
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Monitoring Tab
    
    private var monitoringTab: some View {
        Form {
            Section(header: Text("Refresh Interval")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Update every:")
                        Spacer()
                        Text(String(format: "%.1f seconds", viewModel.settings.refreshInterval))
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
                    
                    Text("Lower values provide more frequent updates but may use more resources")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Thresholds")) {
                Text("Configure alert thresholds (Future feature)")
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }
    
    // MARK: - Advanced Tab
    
    private var advancedTab: some View {
        Form {
            Section(header: Text("Disk Selection")) {
                Picker("Monitor Disk:", selection: Binding(
                    get: { viewModel.settings.selectedDiskPath },
                    set: { viewModel.settings.selectedDiskPath = $0 }
                )) {
                    ForEach(viewModel.availableDisks, id: \.path) { disk in
                        Text(disk.displayName).tag(disk.path)
                    }
                }
                
                Button("Refresh Disk List") {
                    viewModel.refreshAvailableDisks()
                }
                .help("Scan for newly mounted disks")
                
                Divider()
                
                Picker("Display Mode:", selection: Binding(
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
            
            Section(header: Text("Network Interfaces")) {
                Text("Auto-detect active network interface")
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("Startup")) {
                Toggle("Launch at Login", isOn: Binding(
                    get: { viewModel.settings.launchAtLogin },
                    set: { viewModel.settings.launchAtLogin = $0 }
                ))
                    .help("Automatically start MenubarStatus when you log in")
                
                Text("Note: You may need to grant permissions in System Settings > Login Items")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
