//
//  DiskHealthInfo.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import SwiftUI

// MARK: - HealthStatus

/// Enum representing overall disk health condition
enum HealthStatus: String, Codable {
    case good        // No issues detected
    case warning     // Minor issues, monitor closely
    case critical    // Failure imminent, back up immediately
    case unavailable // S.M.A.R.T. data not accessible
    
    var displayName: String {
        switch self {
        case .good: return "Good"
        case .warning: return "Warning"
        case .critical: return "Critical"
        case .unavailable: return "N/A"
        }
    }
    
    var description: String {
        switch self {
        case .good:
            return "Disk is healthy"
        case .warning:
            return "Minor issues detected"
        case .critical:
            return "Backup your data immediately"
        case .unavailable:
            return "Health data unavailable"
        }
    }
    
    /// Determine health status from SMART data
    static func determineStatus(
        smartStatus: String?,
        readErrors: Int,
        writeErrors: Int,
        reallocatedSectors: Int
    ) -> HealthStatus {
        guard smartStatus != nil else { return .unavailable }
        
        if smartStatus == "Failing" || reallocatedSectors > 50 {
            return .critical
        } else if readErrors > 10 || writeErrors > 10 || reallocatedSectors > 10 {
            return .warning
        } else {
            return .good
        }
    }
}

// MARK: - DiskHealthInfo

/// Represents S.M.A.R.T. health information for a disk volume
struct DiskHealthInfo: Identifiable {
    // Identity
    let id: String           // Volume path (e.g., "/", "/Volumes/External")
    let volumeName: String   // User-friendly name
    let bsdName: String      // BSD device name (e.g., "disk0s1")
    
    // Health Status
    let status: HealthStatus
    
    // S.M.A.R.T. Attributes (optional - may be unavailable)
    let powerOnHours: Int?
    let temperature: Int?        // Celsius
    let readErrorCount: Int?
    let writeErrorCount: Int?
    let reallocatedSectorCount: Int?
    
    // Computed Properties
    var healthColor: Color {
        switch status {
        case .good: return .green
        case .warning: return .yellow
        case .critical: return .red
        case .unavailable: return .gray
        }
    }
    
    var healthIcon: String {
        switch status {
        case .good: return "checkmark.shield.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "xmark.shield.fill"
        case .unavailable: return "questionmark.circle.fill"
        }
    }
    
    var formattedPowerOnTime: String? {
        guard let hours = powerOnHours else { return nil }
        let days = hours / 24
        return "\(days) days"
    }
    
    // Validation
    init(
        id: String,
        volumeName: String,
        bsdName: String,
        status: HealthStatus,
        powerOnHours: Int? = nil,
        temperature: Int? = nil,
        readErrorCount: Int? = nil,
        writeErrorCount: Int? = nil,
        reallocatedSectorCount: Int? = nil
    ) {
        precondition(!id.isEmpty, "Volume path must not be empty")
        precondition(!volumeName.isEmpty, "Volume name must not be empty")
        
        self.id = id
        self.volumeName = volumeName
        self.bsdName = bsdName
        self.status = status
        self.powerOnHours = powerOnHours
        self.temperature = temperature
        self.readErrorCount = readErrorCount
        self.writeErrorCount = writeErrorCount
        self.reallocatedSectorCount = reallocatedSectorCount
    }
}

