//
//  AppSettings.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Disk display mode
enum DiskDisplayMode: String, Codable, CaseIterable {
    case capacity = "capacity"  // Show disk usage percentage
    case ioSpeed = "ioSpeed"    // Show read/write speed
    
    var displayName: String {
        let lang = LocalizedStrings.language
        switch self {
        case .capacity:
            return lang == .chinese ? "容量使用" : "Capacity Usage"
        case .ioSpeed:
            return lang == .chinese ? "读写速度" : "Read/Write Speed"
        }
    }
}

/// Application settings and user preferences
struct AppSettings: Codable {
    // Display preferences
    private var _showCPU: Bool
    private var _showMemory: Bool
    private var _showDisk: Bool
    private var _showNetwork: Bool
    
    var showCPU: Bool {
        get { _showCPU }
        set {
            // Check if disabling this would leave no metrics enabled
            if !newValue && !_showMemory && !_showDisk && !_showNetwork {
                // Don't allow - keep current value
                return
            }
            _showCPU = newValue
        }
    }
    
    var showMemory: Bool {
        get { _showMemory }
        set {
            // Check if disabling this would leave no metrics enabled
            if !newValue && !_showCPU && !_showDisk && !_showNetwork {
                // Don't allow - keep current value
                return
            }
            _showMemory = newValue
        }
    }
    
    var showDisk: Bool {
        get { _showDisk }
        set {
            // Check if disabling this would leave no metrics enabled
            if !newValue && !_showCPU && !_showMemory && !_showNetwork {
                // Don't allow - keep current value
                return
            }
            _showDisk = newValue
        }
    }
    
    var showNetwork: Bool {
        get { _showNetwork }
        set {
            // Check if disabling this would leave no metrics enabled
            if !newValue && !_showCPU && !_showMemory && !_showDisk {
                // Don't allow - keep current value
                return
            }
            _showNetwork = newValue
        }
    }
    
    // Monitoring configuration
    private var _refreshInterval: TimeInterval
    var refreshInterval: TimeInterval {
        get { _refreshInterval }
        set {
            // Clamp to valid range [1.0, 5.0]
            _refreshInterval = max(1.0, min(5.0, newValue))
        }
    }
    
    private var _selectedDiskPath: String
    var selectedDiskPath: String {
        get { _selectedDiskPath }
        set {
            // Ensure path is absolute
            _selectedDiskPath = newValue.hasPrefix("/") ? newValue : "/"
        }
    }
    
    // Disk display mode
    var diskDisplayMode: DiskDisplayMode
    
    // Launch configuration
    var launchAtLogin: Bool
    
    // NEW: Display configuration for modern UI
    var displayConfiguration: DisplayConfiguration
    
    // Language preference
    var language: AppLanguage
    
    init(
        showCPU: Bool = true,
        showMemory: Bool = true,
        showDisk: Bool = false,
        showNetwork: Bool = false,
        refreshInterval: TimeInterval = 2.0,
        selectedDiskPath: String = "/",
        diskDisplayMode: DiskDisplayMode = .capacity,
        launchAtLogin: Bool = false,
        displayConfiguration: DisplayConfiguration = DisplayConfiguration(),
        language: AppLanguage = .english
    ) {
        // Ensure at least one metric is enabled
        let atLeastOne = showCPU || showMemory || showDisk || showNetwork
        
        self._showCPU = atLeastOne ? showCPU : true
        self._showMemory = showMemory
        self._showDisk = showDisk
        self._showNetwork = showNetwork
        
        // Apply validation through property setters
        self._refreshInterval = max(1.0, min(5.0, refreshInterval))
        self._selectedDiskPath = selectedDiskPath.hasPrefix("/") ? selectedDiskPath : "/"
        self.diskDisplayMode = diskDisplayMode
        
        self.launchAtLogin = launchAtLogin
        self.displayConfiguration = displayConfiguration
        self.language = language
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case _showCPU = "showCPU"
        case _showMemory = "showMemory"
        case _showDisk = "showDisk"
        case _showNetwork = "showNetwork"
        case _refreshInterval = "refreshInterval"
        case _selectedDiskPath = "selectedDiskPath"
        case diskDisplayMode
        case launchAtLogin
        case displayConfiguration
        case language
        
        // 已删除：useCompactMode (v1.0.1 统一使用紧凑格式)
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    private static let settingsKey = "com.menubar.status.settings"
    
    var appSettings: AppSettings {
        get {
            guard let data = data(forKey: UserDefaults.settingsKey),
                  let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
            else {
                return AppSettings()  // Return defaults if not found
            }
            return settings
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: UserDefaults.settingsKey)
            synchronize()
        }
    }
}

