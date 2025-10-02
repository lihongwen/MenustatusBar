//
//  HistoricalDataManager.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

// MARK: - Protocol

/// Protocol for managing time-series data for sparkline charts
protocol HistoricalDataManaging: AnyObject {
    /// Record a new data point
    /// - Parameter point: Data point to record
    /// - Note: Automatically removes points older than retention period
    func recordDataPoint(_ point: HistoricalDataPoint)
    
    /// Get historical data for a metric
    /// - Parameters:
    ///   - metric: Which metric to retrieve
    ///   - duration: How far back to retrieve (default: 60 seconds)
    /// - Returns: Array of data points within duration, ordered oldest to newest
    func getHistory(for metric: MetricType, duration: TimeInterval) -> [HistoricalDataPoint]
    
    /// Clear all historical data
    func clearHistory()
    
    /// Clear history for a specific metric
    /// - Parameter metric: Which metric to clear
    func clearHistory(for metric: MetricType)
}

// MARK: - Implementation

/// Manages historical data for metrics using circular buffers with 60-second retention
final class HistoricalDataManagerImpl: HistoricalDataManaging {
    private var dataBuffers: [MetricType: CircularBuffer<HistoricalDataPoint>] = [:]
    private let queue = DispatchQueue(label: "com.menubar.status.historicaldata", qos: .utility)
    private let capacity = 60  // 60 data points (1 per second for 60 seconds)
    
    init() {
        // Initialize a buffer for each metric type
        MetricType.allCases.forEach { metric in
            dataBuffers[metric] = CircularBuffer(capacity: capacity)
        }
    }
    
    func recordDataPoint(_ point: HistoricalDataPoint) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.dataBuffers[point.metricType]?.append(point)
        }
    }
    
    func getHistory(for metric: MetricType, duration: TimeInterval = 60) -> [HistoricalDataPoint] {
        return queue.sync {
            guard let buffer = dataBuffers[metric] else { return [] }
            let allPoints = buffer.asArray()
            
            // Filter to points within the specified duration
            let cutoffTime = Date().addingTimeInterval(-duration)
            return allPoints.filter { $0.timestamp >= cutoffTime }
        }
    }
    
    func clearHistory() {
        queue.async { [weak self] in
            guard let self = self else { return }
            MetricType.allCases.forEach { metric in
                self.dataBuffers[metric]?.clear()
            }
        }
    }
    
    func clearHistory(for metric: MetricType) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.dataBuffers[metric]?.clear()
        }
    }
}

