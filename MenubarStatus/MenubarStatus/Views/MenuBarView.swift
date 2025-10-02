//
//  MenuBarView.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import SwiftUI

/// Main menu bar view with dropdown content
struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with current metrics
            VStack(alignment: .leading, spacing: 4) {
                Text("System Monitor")
                    .font(.headline)
                
                if let metrics = viewModel.currentMetrics {
                    Text("Updated: \(formatTime(metrics.timestamp))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Detailed metrics
            if viewModel.currentMetrics != nil {
                ScrollView {
                    Text(viewModel.detailsText)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal)
                }
                .frame(maxHeight: 300)
            } else {
                Text("Waiting for data...")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Divider()
            
            // Action buttons
            VStack(spacing: 0) {
                Button(action: {
                    // Close the menu bar extra dropdown first
                    NSApp.keyWindow?.close()
                    
                    // Small delay to ensure menu closes before opening settings
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        SettingsWindowManager.shared.showSettings(settingsManager: settingsManager)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings...")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.clear)
                .onHover { hovering in
                    // Visual feedback on hover
                }
                
                Divider()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.clear)
            }
        }
        .frame(width: 320)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    let settingsManager = SettingsManager.shared
    let monitor = SystemMonitorImpl(settings: settingsManager.settings)
    let viewModel = MenuBarViewModel(monitor: monitor, settingsManager: settingsManager)
    
    // Provide sample data for preview
    viewModel.currentMetrics = SystemMetrics(
        timestamp: Date(),
        cpu: CPUMetrics(usagePercentage: 45.5, systemUsage: 20.0, userUsage: 25.5, idlePercentage: 54.5),
        memory: MemoryMetrics(totalBytes: 16_000_000_000, usedBytes: 8_000_000_000, freeBytes: 8_000_000_000, cachedBytes: 0),
        disk: DiskMetrics(volumePath: "/", volumeName: "Macintosh HD", totalBytes: 500_000_000_000, freeBytes: 250_000_000_000, usedBytes: 250_000_000_000),
        network: NetworkMetrics(uploadBytesPerSecond: 1024, downloadBytesPerSecond: 2048, totalUploadBytes: 10240, totalDownloadBytes: 20480)
    )
    
    return MenuBarView(viewModel: viewModel, settingsManager: settingsManager)
}

