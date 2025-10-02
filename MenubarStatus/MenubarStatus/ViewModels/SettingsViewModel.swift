//
//  SettingsViewModel.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel for the settings window
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var settings: AppSettings
    @Published var availableDisks: [DiskInfo] = []
    @Published var isSaving: Bool = false
    @Published var saveError: String?
    @Published var validationError: String?
    
    // MARK: - Private Properties
    
    private let diskMonitor: DiskMonitorImpl
    private let userDefaultsKey = "appSettings"
    
    // MARK: - Initialization
    
    init() {
        self.diskMonitor = DiskMonitorImpl()
        
        // Load settings from UserDefaults
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            self.settings = loadedSettings
        } else {
            // Use default settings
            self.settings = AppSettings()
        }
        
        // Discover available disks
        refreshAvailableDisks()
    }
    
    // MARK: - Public Methods
    
    /// Save settings to UserDefaults
    func saveSettings() async throws {
        // Validate before saving
        guard validateSettings() else {
            throw SettingsError.validationFailed(validationError ?? "Invalid settings")
        }
        
        isSaving = true
        saveError = nil
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(settings)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            
            // Small delay to show saving state
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            
            isSaving = false
        } catch {
            isSaving = false
            saveError = error.localizedDescription
            throw error
        }
    }
    
    /// Reset settings to default values
    func resetToDefaults() {
        settings = AppSettings()
        validationError = nil
        saveError = nil
    }
    
    /// Validate current settings
    @discardableResult
    func validateSettings() -> Bool {
        validationError = nil
        
        // Note: refreshInterval validation is already done in AppSettings init
        // via property setter, so we just need to check the result
        // Validate refresh interval (1-5 seconds)
        if settings.refreshInterval < 1.0 || settings.refreshInterval > 5.0 {
            validationError = "Refresh interval must be between 1 and 5 seconds"
            return false
        }
        
        // Validate selected disk path exists
        if !availableDisks.contains(where: { $0.path == settings.selectedDiskPath }) {
            // Auto-fix: use system disk
            settings.selectedDiskPath = "/"
        }
        
        return true
    }
    
    /// Refresh the list of available disks
    func refreshAvailableDisks() {
        availableDisks = diskMonitor.getAvailableVolumes()
    }
    
    /// Test monitoring with current settings
    func testMonitoring() async -> Bool {
        do {
            // Try to collect metrics with current settings
            let cpuMonitor = CPUMonitorImpl()
            _ = try await cpuMonitor.getCurrentMetrics()
            
            let memoryMonitor = MemoryMonitorImpl()
            _ = try await memoryMonitor.getCurrentMetrics()
            
            let diskMonitor = DiskMonitorImpl()
            _ = try await diskMonitor.getCurrentMetrics(for: settings.selectedDiskPath)
            
            let networkMonitor = NetworkMonitorImpl()
            _ = try await networkMonitor.getCurrentMetrics()
            
            return true
        } catch {
            saveError = "Monitoring test failed: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - Settings Error

enum SettingsError: LocalizedError {
    case validationFailed(String)
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .saveFailed(let message):
            return "Save failed: \(message)"
        }
    }
}

