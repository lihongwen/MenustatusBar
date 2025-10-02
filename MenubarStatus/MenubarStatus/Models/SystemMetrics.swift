//
//  SystemMetrics.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Complete system metrics snapshot at a specific point in time
struct SystemMetrics {
    let timestamp: Date
    let cpu: CPUMetrics
    let memory: MemoryMetrics
    let disk: DiskMetrics
    let network: NetworkMetrics
    
    init(timestamp: Date, cpu: CPUMetrics, memory: MemoryMetrics, disk: DiskMetrics, network: NetworkMetrics) {
        self.timestamp = timestamp
        self.cpu = cpu
        self.memory = memory
        self.disk = disk
        self.network = network
    }
}




