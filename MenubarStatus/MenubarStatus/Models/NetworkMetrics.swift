//
//  NetworkMetrics.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Network transfer rate metrics
struct NetworkMetrics {
    let uploadBytesPerSecond: UInt64    // Current upload rate
    let downloadBytesPerSecond: UInt64  // Current download rate
    let totalUploadBytes: UInt64        // Cumulative since app start
    let totalDownloadBytes: UInt64      // Cumulative since app start
    
    init(uploadBytesPerSecond: UInt64, downloadBytesPerSecond: UInt64, totalUploadBytes: UInt64, totalDownloadBytes: UInt64) {
        self.uploadBytesPerSecond = uploadBytesPerSecond
        self.downloadBytesPerSecond = downloadBytesPerSecond
        self.totalUploadBytes = totalUploadBytes
        self.totalDownloadBytes = totalDownloadBytes
    }
    
    /// Formatted upload rate with appropriate unit (KB/s or MB/s)
    var uploadFormatted: String {
        formatBytesPerSecond(uploadBytesPerSecond)
    }
    
    /// Formatted download rate with appropriate unit (KB/s or MB/s)
    var downloadFormatted: String {
        formatBytesPerSecond(downloadBytesPerSecond)
    }
    
    private func formatBytesPerSecond(_ bytes: UInt64) -> String {
        let megabytes = Double(bytes) / 1_048_576.0  // 1024^2
        if megabytes >= 1.0 {
            return String(format: "%.1f MB/s", megabytes)
        } else {
            let kilobytes = Double(bytes) / 1024.0
            return String(format: "%.0f KB/s", kilobytes)
        }
    }
}




