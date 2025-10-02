//
//  HistoricalDataPoint.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

// MARK: - MetricType

/// Enum identifying different system metrics that can have historical data
enum MetricType: String, Codable, CaseIterable {
    case cpu = "cpu"
    case memory = "memory"
    case disk = "disk"
    case network = "network"
    
    var displayName: String {
        switch self {
        case .cpu: return "CPU"
        case .memory: return "Memory"
        case .disk: return "Disk"
        case .network: return "Network"
        }
    }
    
    var icon: String {
        switch self {
        case .cpu: return "cpu.fill"
        case .memory: return "memorychip.fill"
        case .disk: return "internaldrive.fill"
        case .network: return "network"
        }
    }
}

// MARK: - HistoricalDataPoint

/// Represents a single data point in time-series history for sparkline charts
struct HistoricalDataPoint: Identifiable {
    let id: UUID
    let timestamp: Date
    let metricType: MetricType
    let value: Double
    
    // Computed for Chart framework
    var timeOffset: TimeInterval {
        timestamp.timeIntervalSinceNow
    }
    
    init(id: UUID = UUID(), timestamp: Date, metricType: MetricType, value: Double) {
        precondition(value >= 0, "Value must be non-negative")
        precondition(timestamp <= Date(), "Timestamp must not be in the future")
        
        self.id = id
        self.timestamp = timestamp
        self.metricType = metricType
        self.value = value
    }
}

