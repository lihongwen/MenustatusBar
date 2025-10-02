//
//  MenubarStatusApp.swift
//  MenubarStatus
//
//  Created by 李宏文 on 2025/10/2.
//

import SwiftUI
import ServiceManagement

@main
struct MenubarStatusApp: App {
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var viewModel: MenuBarViewModel
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Initialize with shared settings manager
        let manager = SettingsManager.shared
        let monitor = SystemMonitorImpl(settings: manager.settings)
        let viewModel = MenuBarViewModel(monitor: monitor, settingsManager: manager)
        
        _viewModel = StateObject(wrappedValue: viewModel)
        
        // Start monitoring on launch
        viewModel.startMonitoring()
        
        // Configure launch at login if enabled
        if manager.settings.launchAtLogin {
            configureLaunchAtLogin(enabled: true)
        }
    }
    
    var body: some Scene {
        MenuBarExtra {
            // Dropdown content
            MenuBarView(viewModel: viewModel, settingsManager: settingsManager)
        } label: {
            // Menu bar label
            HStack(spacing: 4) {
                Image(systemName: "chart.xyaxis.line")
                    .imageScale(.small)
                
                Text(viewModel.displayText)
                    .font(.system(size: 11, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    // MARK: - Launch at Login Configuration
    
    private func configureLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to configure launch at login: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set app as accessory (menu bar only app)
        // This hides the app from Dock by default
        NSApp.setActivationPolicy(.accessory)
    }
}

