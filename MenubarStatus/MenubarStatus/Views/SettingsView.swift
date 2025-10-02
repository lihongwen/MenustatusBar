//
//  SettingsView.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import SwiftUI

/// Settings window view
struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @State private var availableDisks: [DiskInfo] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            Form {
                // Metrics Display Section
                Section(header: Text("Display Metrics")) {
                    Toggle("Show CPU", isOn: $settingsManager.settings.showCPU)
                        .help("Display CPU usage in menu bar")
                    
                    Toggle("Show Memory", isOn: $settingsManager.settings.showMemory)
                        .help("Display memory usage in menu bar")
                    
                    Toggle("Show Disk", isOn: $settingsManager.settings.showDisk)
                        .help("Display disk usage in menu bar")
                    
                    Toggle("Show Network", isOn: $settingsManager.settings.showNetwork)
                        .help("Display network speed in menu bar")
                    
                    Text("Changes take effect immediately")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Refresh Interval Section
                Section(header: Text("Monitoring")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Refresh Interval:")
                            Spacer()
                            Text("\(String(format: "%.1f", settingsManager.settings.refreshInterval))s")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $settingsManager.settings.refreshInterval,
                            in: 1.0...5.0,
                            step: 0.5
                        )
                        .help("How often to update metrics (1-5 seconds)")
                        
                        Text("Lower values provide more frequent updates but may use more resources")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Disk Selection Section
                Section(header: Text("Disk Monitor")) {
                    Picker("Monitor Disk:", selection: $settingsManager.settings.selectedDiskPath) {
                        ForEach(availableDisks) { disk in
                            Text(disk.displayName).tag(disk.path)
                        }
                    }
                    .help("Select which disk to monitor")
                    
                    Button("Refresh Disk List") {
                        refreshAvailableDisks()
                    }
                    .help("Scan for newly mounted disks")
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Mode:")
                            .font(.subheadline)
                        
                        Picker("", selection: $settingsManager.settings.diskDisplayMode) {
                            ForEach(DiskDisplayMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.radioGroup)
                        .help("Choose what disk information to display in menu bar")
                        
                        Text("• Capacity Usage: Shows disk space usage percentage\n• Read/Write Speed: Shows disk I/O speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Startup Section
                Section(header: Text("Startup")) {
                    Toggle("Launch at Login", isOn: $settingsManager.settings.launchAtLogin)
                        .help("Automatically start MenubarStatus when you log in")
                    
                    Text("Note: You may need to grant permissions in System Settings > Login Items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Display Options
                Section(header: Text("Display Options")) {
                    Toggle("Compact Mode", isOn: $settingsManager.settings.useCompactMode)
                        .help("Use shorter text format in menu bar")
                }
            }
            .formStyle(.grouped)
            .padding()
            
            Divider()
            
            // Action Buttons
            HStack {
                Button("Reset to Defaults") {
                    settingsManager.resetToDefaults()
                }
                .help("Restore default settings")
                
                Spacer()
                
                Button("Close") {
                    // Close the window
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
        .navigationTitle("Settings")
        .onAppear {
            refreshAvailableDisks()
        }
    }
    
    private func refreshAvailableDisks() {
        let diskMonitor = DiskMonitorImpl()
        availableDisks = diskMonitor.getAvailableVolumes()
    }
}

// MARK: - Preview

#Preview {
    SettingsView(settingsManager: SettingsManager.shared)
}

