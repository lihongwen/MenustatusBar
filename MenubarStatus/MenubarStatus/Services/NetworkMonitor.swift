//
//  NetworkMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import SystemConfiguration

/// Network monitoring service using system network APIs
final class NetworkMonitorImpl {
    private let queue = DispatchQueue(label: "com.menubar.status.networkmonitor", qos: .utility)
    
    // Track previous values for rate calculation
    private var previousUploadBytes: UInt64 = 0
    private var previousDownloadBytes: UInt64 = 0
    private var previousTimestamp: Date?
    
    // Cumulative totals since app start (or last reset)
    private var cumulativeUploadBytes: UInt64 = 0
    private var cumulativeDownloadBytes: UInt64 = 0
    
    var isAvailable: Bool {
        return true // Network monitoring is always available
    }
    
    func getCurrentMetrics() async throws -> NetworkMetrics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let metrics = try self.collectNetworkMetrics()
                    continuation.resume(returning: metrics)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func resetCounters() {
        queue.async {
            self.cumulativeUploadBytes = 0
            self.cumulativeDownloadBytes = 0
            self.previousUploadBytes = 0
            self.previousDownloadBytes = 0
            self.previousTimestamp = nil
        }
    }
    
    private func collectNetworkMetrics() throws -> NetworkMetrics {
        // Get network interface statistics
        let (currentUpload, currentDownload) = try getNetworkInterfaceStats()
        
        let now = Date()
        
        // Calculate rates
        let (uploadRate, downloadRate) = calculateRates(
            currentUpload: currentUpload,
            currentDownload: currentDownload,
            timestamp: now
        )
        
        // Update cumulative totals
        if previousUploadBytes > 0 && currentUpload >= previousUploadBytes {
            cumulativeUploadBytes += (currentUpload - previousUploadBytes)
        }
        if previousDownloadBytes > 0 && currentDownload >= previousDownloadBytes {
            cumulativeDownloadBytes += (currentDownload - previousDownloadBytes)
        }
        
        // Store current values for next calculation
        previousUploadBytes = currentUpload
        previousDownloadBytes = currentDownload
        previousTimestamp = now
        
        return NetworkMetrics(
            uploadBytesPerSecond: uploadRate,
            downloadBytesPerSecond: downloadRate,
            totalUploadBytes: cumulativeUploadBytes,
            totalDownloadBytes: cumulativeDownloadBytes
        )
    }
    
    private func getNetworkInterfaceStats() throws -> (upload: UInt64, download: UInt64) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0 else {
            throw MetricError.systemAPIUnavailable
        }
        
        defer {
            freeifaddrs(ifaddr)
        }
        
        var totalUpload: UInt64 = 0
        var totalDownload: UInt64 = 0
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            guard let interface = ptr?.pointee else { continue }
            
            // Only process AF_LINK (data link layer) interfaces
            let addr = interface.ifa_addr.pointee
            guard addr.sa_family == UInt8(AF_LINK) else { continue }
            
            // Get interface name
            let name = String(cString: interface.ifa_name)
            
            // Skip loopback and other non-physical interfaces
            guard !name.starts(with: "lo"),
                  !name.starts(with: "gif"),
                  !name.starts(with: "stf"),
                  !name.starts(with: "awdl"),
                  !name.starts(with: "bridge"),
                  !name.starts(with: "utun"),
                  !name.starts(with: "llw") else {
                continue
            }
            
            // Get link-layer data
            if let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                let ifData = data.pointee
                totalUpload += UInt64(ifData.ifi_obytes)
                totalDownload += UInt64(ifData.ifi_ibytes)
            }
        }
        
        return (totalUpload, totalDownload)
    }
    
    private func calculateRates(
        currentUpload: UInt64,
        currentDownload: UInt64,
        timestamp: Date
    ) -> (uploadRate: UInt64, downloadRate: UInt64) {
        guard let previousTime = previousTimestamp,
              previousUploadBytes > 0,
              previousDownloadBytes > 0 else {
            // First call - no rate yet
            return (0, 0)
        }
        
        let timeDelta = timestamp.timeIntervalSince(previousTime)
        guard timeDelta > 0 else {
            return (0, 0)
        }
        
        // Calculate byte deltas
        let uploadDelta = currentUpload >= previousUploadBytes
            ? currentUpload - previousUploadBytes
            : 0
        let downloadDelta = currentDownload >= previousDownloadBytes
            ? currentDownload - previousDownloadBytes
            : 0
        
        // Calculate bytes per second
        let uploadRate = UInt64(Double(uploadDelta) / timeDelta)
        let downloadRate = UInt64(Double(downloadDelta) / timeDelta)
        
        return (uploadRate, downloadRate)
    }
}




