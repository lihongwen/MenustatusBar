//
//  CPUMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Darwin

/// CPU monitoring service using mach kernel APIs
final class CPUMonitorImpl {
    private var previousCPUTicks: (user: UInt64, system: UInt64, idle: UInt64, nice: UInt64)?
    private let queue = DispatchQueue(label: "com.menubar.status.cpumonitor", qos: .utility)
    
    var isAvailable: Bool {
        return true // CPU monitoring is always available on macOS
    }
    
    func getCurrentMetrics() async throws -> CPUMetrics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let metrics = try self.collectCPUMetrics()
                    continuation.resume(returning: metrics)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func collectCPUMetrics() throws -> CPUMetrics {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t!
        var numCPUInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )
        
        guard result == KERN_SUCCESS else {
            throw MetricError.systemAPIUnavailable
        }
        
        defer {
            vm_deallocate(
                mach_task_self_,
                vm_address_t(bitPattern: cpuInfo),
                vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.size)
            )
        }
        
        let cpuLoadInfo = cpuInfo.withMemoryRebound(to: processor_cpu_load_info.self, capacity: Int(numCPUs)) { $0 }
        
        var totalUser: UInt64 = 0
        var totalSystem: UInt64 = 0
        var totalIdle: UInt64 = 0
        var totalNice: UInt64 = 0
        
        for i in 0..<Int(numCPUs) {
            let cpu = cpuLoadInfo[i]
            totalUser += UInt64(cpu.cpu_ticks.0)   // CPU_STATE_USER
            totalSystem += UInt64(cpu.cpu_ticks.1) // CPU_STATE_SYSTEM
            totalIdle += UInt64(cpu.cpu_ticks.2)   // CPU_STATE_IDLE
            totalNice += UInt64(cpu.cpu_ticks.3)   // CPU_STATE_NICE
        }
        
        // Calculate percentages based on delta from previous reading
        let (userUsage, systemUsage, idlePercentage) = calculatePercentages(
            currentUser: totalUser,
            currentSystem: totalSystem,
            currentIdle: totalIdle,
            currentNice: totalNice
        )
        
        // Store current ticks for next delta calculation
        previousCPUTicks = (totalUser, totalSystem, totalIdle, totalNice)
        
        let usagePercentage = userUsage + systemUsage
        
        return CPUMetrics(
            usagePercentage: usagePercentage,
            systemUsage: systemUsage,
            userUsage: userUsage,
            idlePercentage: idlePercentage
        )
    }
    
    private func calculatePercentages(
        currentUser: UInt64,
        currentSystem: UInt64,
        currentIdle: UInt64,
        currentNice: UInt64
    ) -> (user: Double, system: Double, idle: Double) {
        guard let previous = previousCPUTicks else {
            // First call - return current state as percentage
            let total = currentUser + currentSystem + currentIdle + currentNice
            guard total > 0 else { return (0, 0, 100) }
            
            let userPercent = Double(currentUser + currentNice) / Double(total) * 100.0
            let systemPercent = Double(currentSystem) / Double(total) * 100.0
            let idlePercent = Double(currentIdle) / Double(total) * 100.0
            
            return (userPercent, systemPercent, idlePercent)
        }
        
        // Calculate deltas
        let userDelta = currentUser - previous.user
        let systemDelta = currentSystem - previous.system
        let idleDelta = currentIdle - previous.idle
        let niceDelta = currentNice - previous.nice
        
        let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
        
        guard totalDelta > 0 else {
            return (0, 0, 100)
        }
        
        let userPercent = Double(userDelta + niceDelta) / Double(totalDelta) * 100.0
        let systemPercent = Double(systemDelta) / Double(totalDelta) * 100.0
        let idlePercent = Double(idleDelta) / Double(totalDelta) * 100.0
        
        return (userPercent, systemPercent, idlePercent)
    }
}

