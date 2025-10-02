//
//  SettingsWindowManager.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import SwiftUI
import AppKit
import Combine

/// Manager for the settings window
@MainActor
final class SettingsWindowManager {
    static let shared = SettingsWindowManager()
    
    private var settingsWindow: NSWindow?
    
    private init() {}
    
    func showSettings(viewModel: SettingsViewModel) {
        // If window already exists, bring it to front
        if let window = settingsWindow {
            // Make sure app appears in Dock
            NSApp.setActivationPolicy(.regular)
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Change to regular app (shows in Dock)
        NSApp.setActivationPolicy(.regular)
        
        // Create settings view
        let settingsView = SettingsView(viewModel: viewModel)
        
        // Create hosting controller
        let hostingController = NSHostingController(rootView: settingsView)
        
        // Create window
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.level = .normal  // Use normal level instead of floating
        window.center()
        
        // Handle window close
        window.isReleasedWhenClosed = false
        
        // Make sure it appears in front
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Store reference
        settingsWindow = window
        
        // Show window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Listen for close notifications
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleWindowClose()
            }
        }
    }
    
    private func handleWindowClose() {
        settingsWindow = nil
        
        // Change back to accessory (hides from Dock)
        // Small delay to ensure smooth transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    func closeSettings() {
        // Just close the window, handleWindowClose will be called by notification
        settingsWindow?.close()
    }
}

