//
//  SettingsManager.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Combine

/// Shared settings manager for the application
@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var settings: AppSettings {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaultsKey = "appSettings"
    
    private init() {
        // Migrate old settings if needed (static method)
        Self.migrateOldDisplayModeIfNeeded()
        
        // Load from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = loadedSettings
        } else {
            self.settings = AppSettings()
        }
    }
    
    /// Migrate from old DisplayMode to new showMenubarIcons setting
    private static func migrateOldDisplayModeIfNeeded() {
        let oldModeKey = "displayMode"
        
        // Check if old displayMode exists in UserDefaults
        if let oldMode = UserDefaults.standard.string(forKey: oldModeKey) {
            // Determine new showMenubarIcons value based on old mode
            let showIcons: Bool
            switch oldMode {
            case "iconAndValue", "compactText":
                showIcons = true
            case "graphMode", "iconsOnly":
                showIcons = false
            default:
                showIcons = true
            }
            
            // Store the migrated value
            UserDefaults.standard.set(showIcons, forKey: "showMenubarIcons_migrated")
            
            // Remove old key
            UserDefaults.standard.removeObject(forKey: oldModeKey)
            
            print("✅ Migrated displayMode '\(oldMode)' → showMenubarIcons: \(showIcons)")
        }
    }
    
    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func resetToDefaults() {
        settings = AppSettings()
    }
}

