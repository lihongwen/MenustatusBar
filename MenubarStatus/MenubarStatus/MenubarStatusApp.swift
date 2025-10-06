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
        let viewModel = MenuBarViewModel(settings: manager.settings)
        
        _viewModel = StateObject(wrappedValue: viewModel)
        
        // Initialize language
        LocalizedStrings.language = manager.settings.language
        
        // 🔧 FIX: 应用启动时就开始监控
        Task { @MainActor in
            // 延迟一点启动，确保UI已经初始化
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            viewModel.startMonitoring()
        }
        
        // Configure launch at login if enabled
        if manager.settings.launchAtLogin {
            configureLaunchAtLogin(enabled: true)
        }
    }
    
    // MARK: - Menubar Label
    
    /// 菜单栏标签 - 使用统一的紧凑格式  
    private var menubarLabel: some View {
        MenubarLabelWrapper(
            metrics: viewModel.currentMetrics,
            settingsManager: settingsManager
        )
    }
    
    var body: some Scene {
        MenuBarExtra {
            // Dropdown content
            MenuBarView(viewModel: viewModel)
        } label: {
            // Menu bar label - 使用新的 MenubarLabel 组件
            menubarLabel
        }
        .menuBarExtraStyle(.window)
        // T087: Keyboard shortcuts
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    let settingsVM = SettingsViewModel()
                    Task { @MainActor in
                        SettingsWindowManager.shared.showSettings(viewModel: settingsVM)
                    }
                }
                .keyboardShortcut(",", modifiers: .command) // ⌘,
            }
            
            CommandGroup(replacing: .appInfo) {
                Button("Refresh Now") {
                    Task { @MainActor in
                        await viewModel.stopMonitoring()
                        await viewModel.startMonitoring()
                    }
                }
                .keyboardShortcut("r", modifiers: .command) // ⌘R
            }
        }
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
        
        // 🔧 FIX: 启动监控 - 确保应用启动时就开始实时更新
        Task { @MainActor in
            if let app = NSApplication.shared.delegate as? MenubarStatusApp {
                // 通过通知启动监控
                NotificationCenter.default.post(name: .startMonitoring, object: nil)
            }
        }
    }
}

// 自定义通知
extension Notification.Name {
    static let startMonitoring = Notification.Name("startMonitoring")
    static let settingsDidChange = Notification.Name("settingsDidChange")
}

// MARK: - Menubar Label Wrapper

/// 包装器视图，用于正确响应设置变化
struct MenubarLabelWrapper: View {
    let metrics: SystemMetrics?
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        // 构建 summary
        let summary: MenubarSummary = {
            if let metrics = metrics {
                return MenubarSummaryBuilder.build(from: metrics, settings: settingsManager.settings)
            } else {
                return MenubarSummary(items: [])
            }
        }()
        
        // 使用 MenubarLabel 组件显示
        return MenubarLabel(summary: summary)
    }
}

