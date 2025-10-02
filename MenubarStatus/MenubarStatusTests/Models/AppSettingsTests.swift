//
//  AppSettingsTests.swift
//  MenubarStatusTests
//
//  Created by Specify Agent on 2025/10/2.
//

import XCTest
@testable import MenubarStatus

final class AppSettingsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func testDefaultSettings() throws {
        // Test that default values are applied
        let settings = AppSettings()
        
        XCTAssertTrue(settings.showCPU, "CPU should be shown by default")
        XCTAssertTrue(settings.showMemory, "Memory should be shown by default")
        XCTAssertFalse(settings.showDisk, "Disk should be hidden by default")
        XCTAssertFalse(settings.showNetwork, "Network should be hidden by default")
        XCTAssertEqual(settings.refreshInterval, 2.0, "Default refresh interval should be 2 seconds")
        XCTAssertEqual(settings.selectedDiskPath, "/", "Default disk should be system disk")
        XCTAssertFalse(settings.launchAtLogin, "Auto-launch should be disabled by default")
        XCTAssertTrue(settings.useCompactMode, "Compact mode should be enabled by default")
    }
    
    func testCodableEncoding() throws {
        // Test that settings can be encoded to JSON
        let settings = AppSettings()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        
        XCTAssertFalse(data.isEmpty, "Encoded data should not be empty")
    }
    
    func testCodableDecoding() throws {
        // Test that settings can be decoded from JSON
        let original = AppSettings(
            showCPU: false,
            showMemory: true,
            showDisk: true,
            showNetwork: false,
            refreshInterval: 3.0,
            selectedDiskPath: "/Volumes/Data",
            launchAtLogin: true,
            useCompactMode: false
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppSettings.self, from: data)
        
        XCTAssertEqual(decoded.showCPU, original.showCPU)
        XCTAssertEqual(decoded.showMemory, original.showMemory)
        XCTAssertEqual(decoded.showDisk, original.showDisk)
        XCTAssertEqual(decoded.showNetwork, original.showNetwork)
        XCTAssertEqual(decoded.refreshInterval, original.refreshInterval)
        XCTAssertEqual(decoded.selectedDiskPath, original.selectedDiskPath)
        XCTAssertEqual(decoded.launchAtLogin, original.launchAtLogin)
        XCTAssertEqual(decoded.useCompactMode, original.useCompactMode)
    }
    
    func testRefreshIntervalValidation() throws {
        // Test that refresh interval is within 1.0 - 5.0 range
        var settings = AppSettings()
        
        // Test minimum boundary
        settings.refreshInterval = 1.0
        XCTAssertGreaterThanOrEqual(settings.refreshInterval, 1.0)
        
        // Test maximum boundary
        settings.refreshInterval = 5.0
        XCTAssertLessThanOrEqual(settings.refreshInterval, 5.0)
        
        // Test below minimum - should be clamped or rejected
        settings.refreshInterval = 0.5
        XCTAssertGreaterThanOrEqual(settings.refreshInterval, 1.0,
                                   "Refresh interval should be clamped to minimum 1.0")
        
        // Test above maximum - should be clamped or rejected
        settings.refreshInterval = 10.0
        XCTAssertLessThanOrEqual(settings.refreshInterval, 5.0,
                                "Refresh interval should be clamped to maximum 5.0")
    }
    
    func testAtLeastOneMetricEnabled() throws {
        // Test that at least one show* is true
        var settings = AppSettings()
        
        // Try to disable all metrics
        settings.showCPU = false
        settings.showMemory = false
        settings.showDisk = false
        settings.showNetwork = false
        
        // Validation should prevent all being false
        let atLeastOneEnabled = settings.showCPU || settings.showMemory || 
                               settings.showDisk || settings.showNetwork
        
        XCTAssertTrue(atLeastOneEnabled,
                     "At least one metric must be enabled")
    }
    
    func testUserDefaultsPersistence() throws {
        // Test save and load from UserDefaults
        let settings = AppSettings(
            showCPU: true,
            showMemory: false,
            showDisk: true,
            showNetwork: true,
            refreshInterval: 4.0,
            selectedDiskPath: "/Volumes/External",
            launchAtLogin: true,
            useCompactMode: false
        )
        
        // Save to UserDefaults
        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)
        UserDefaults.standard.set(data, forKey: "appSettings")
        UserDefaults.standard.synchronize()
        
        // Load from UserDefaults
        let loadedData = UserDefaults.standard.data(forKey: "appSettings")
        XCTAssertNotNil(loadedData, "Data should be saved in UserDefaults")
        
        let decoder = JSONDecoder()
        let loadedSettings = try decoder.decode(AppSettings.self, from: loadedData!)
        
        XCTAssertEqual(loadedSettings.showCPU, settings.showCPU)
        XCTAssertEqual(loadedSettings.showMemory, settings.showMemory)
        XCTAssertEqual(loadedSettings.refreshInterval, settings.refreshInterval)
        XCTAssertEqual(loadedSettings.selectedDiskPath, settings.selectedDiskPath)
        XCTAssertEqual(loadedSettings.launchAtLogin, settings.launchAtLogin)
    }
    
    func testMutability() throws {
        // Test that settings can be modified
        var settings = AppSettings()
        
        settings.showCPU = false
        XCTAssertFalse(settings.showCPU)
        
        settings.refreshInterval = 3.5
        XCTAssertEqual(settings.refreshInterval, 3.5)
        
        settings.selectedDiskPath = "/Volumes/Data"
        XCTAssertEqual(settings.selectedDiskPath, "/Volumes/Data")
    }
    
    func testDiskPathValidation() throws {
        // Test that disk path is a valid absolute path
        let settings = AppSettings(
            showCPU: true,
            showMemory: true,
            showDisk: true,
            showNetwork: false,
            refreshInterval: 2.0,
            selectedDiskPath: "relative/path",  // Invalid - not absolute
            launchAtLogin: false,
            useCompactMode: true
        )
        
        // Should validate that path starts with /
        XCTAssertTrue(settings.selectedDiskPath.hasPrefix("/"),
                     "Disk path should be absolute (start with /)")
    }
}




