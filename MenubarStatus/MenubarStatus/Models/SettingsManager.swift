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
        // Load from UserDefaults or use defaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = loadedSettings
        } else {
            self.settings = AppSettings()
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

