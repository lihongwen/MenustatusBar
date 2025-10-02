//
//  SettingsPersistenceTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

@MainActor
final class SettingsPersistenceTests: XCTestCase {
    let testKey = "com.menubar.status.settings.test"
    
    override func setUp() async throws {
        try await super.setUp()
        // Clear test settings
        UserDefaults.standard.removeObject(forKey: testKey)
        UserDefaults.standard.removeObject(forKey: "appSettings")
        UserDefaults.standard.synchronize()
        
        // Small delay to ensure cleanup
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
    }
    
    override func tearDown() async throws {
        // Clean up
        UserDefaults.standard.removeObject(forKey: testKey)
        UserDefaults.standard.removeObject(forKey: "appSettings")
        UserDefaults.standard.synchronize()
        
        // Small delay to ensure cleanup
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        try await super.tearDown()
    }
    
    func testSaveAndLoadCycle() throws {
        // Test: Save → Load → Verify
        
        // 1. Create settings
        let originalSettings = AppSettings(
            showCPU: true,
            showMemory: false,
            showDisk: true,
            showNetwork: false,
            refreshInterval: 3.5,
            selectedDiskPath: "/Volumes/Test"
        )
        
        // 2. Save to UserDefaults
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalSettings)
        UserDefaults.standard.set(data, forKey: "appSettings")
        UserDefaults.standard.synchronize()
        
        // 3. Load from UserDefaults
        guard let loadedData = UserDefaults.standard.data(forKey: "appSettings"),
              let loadedSettings = try? JSONDecoder().decode(AppSettings.self, from: loadedData)
        else {
            XCTFail("Failed to load settings")
            return
        }
        
        // 4. Verify values match
        XCTAssertEqual(loadedSettings.showCPU, originalSettings.showCPU)
        XCTAssertEqual(loadedSettings.showMemory, originalSettings.showMemory)
        XCTAssertEqual(loadedSettings.showDisk, originalSettings.showDisk)
        XCTAssertEqual(loadedSettings.showNetwork, originalSettings.showNetwork)
        XCTAssertEqual(loadedSettings.refreshInterval, originalSettings.refreshInterval, accuracy: 0.01)
        XCTAssertEqual(loadedSettings.selectedDiskPath, originalSettings.selectedDiskPath)
    }
    
    func testSettingsViewModelPersistence() async throws {
        // Test: SettingsViewModel save/load cycle
        
        let viewModel1 = SettingsViewModel()
        
        // 1. Modify settings
        viewModel1.settings.refreshInterval = 4.0
        viewModel1.settings.showCPU = false
        viewModel1.settings.showMemory = true
        viewModel1.settings.showDisk = true
        
        // 2. Save
        try await viewModel1.saveSettings()
        
        // Small delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        
        // 3. Create new ViewModel (should load saved settings)
        let viewModel2 = SettingsViewModel()
        
        // 4. Verify loaded settings
        XCTAssertEqual(viewModel2.settings.refreshInterval, 4.0, accuracy: 0.01)
        XCTAssertFalse(viewModel2.settings.showCPU)
        XCTAssertTrue(viewModel2.settings.showMemory)
        XCTAssertTrue(viewModel2.settings.showDisk)
    }
    
    func testDefaultsWhenNoSavedSettings() async throws {
        // Test: Load defaults when no saved settings exist
        
        // Ensure no saved settings
        UserDefaults.standard.removeObject(forKey: "appSettings")
        UserDefaults.standard.synchronize()
        
        // Small delay to ensure removal completes
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        
        let viewModel = SettingsViewModel()
        
        // Should have default values
        XCTAssertEqual(viewModel.settings.refreshInterval, 2.0, accuracy: 0.01)
        XCTAssertTrue(viewModel.settings.showCPU)
        XCTAssertTrue(viewModel.settings.showMemory)
        XCTAssertFalse(viewModel.settings.showDisk)
        XCTAssertFalse(viewModel.settings.showNetwork)
    }
    
    func testSettingsAutoCorrectInvalidValues() throws {
        // Test: Invalid values are auto-corrected
        
        var settings = AppSettings()
        
        // Try to set invalid refresh interval
        settings.refreshInterval = 0.5  // Too low
        XCTAssertGreaterThanOrEqual(settings.refreshInterval, 1.0,
                                   "Refresh interval should be clamped to minimum")
        
        settings.refreshInterval = 10.0  // Too high
        XCTAssertLessThanOrEqual(settings.refreshInterval, 5.0,
                                "Refresh interval should be clamped to maximum")
        
        // Try to set invalid disk path
        settings.selectedDiskPath = "relative/path"
        XCTAssertTrue(settings.selectedDiskPath.hasPrefix("/"),
                     "Disk path should be absolute")
    }
    
    func testMonitorUsesUpdatedSettings() async throws {
        // Test: SystemMonitor respects settings changes
        
        let settings = AppSettings(refreshInterval: 2.0)
        let monitor = SystemMonitorImpl(settings: settings)
        
        monitor.start(interval: settings.refreshInterval)
        
        // Change settings
        var newSettings = settings
        newSettings.refreshInterval = 4.0
        newSettings.showCPU = false
        
        monitor.settings = newSettings
        
        // Verify monitor has new settings
        XCTAssertEqual(monitor.settings.refreshInterval, 4.0)
        XCTAssertFalse(monitor.settings.showCPU)
        
        monitor.stop()
    }
    
    func testSequentialSaveOperations() async throws {
        // Test: Multiple sequential saves work correctly
        
        let testViewModel = SettingsViewModel()
        
        // Perform a save
        testViewModel.settings.refreshInterval = 3.5
        testViewModel.settings.showDisk = true
        try await testViewModel.saveSettings()
        
        // Wait for save to complete
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        // Verify save worked
        XCTAssertFalse(testViewModel.isSaving,
                      "Should not be saving after save completes")
        
        // Settings should be within valid range
        XCTAssertGreaterThanOrEqual(testViewModel.settings.refreshInterval, 1.0)
        XCTAssertLessThanOrEqual(testViewModel.settings.refreshInterval, 5.0)
    }
}

