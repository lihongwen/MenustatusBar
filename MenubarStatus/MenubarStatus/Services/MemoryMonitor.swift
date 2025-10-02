//
//  MemoryMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Darwin

/// Memory monitoring service using mach kernel APIs
final class MemoryMonitorImpl {
    private let queue = DispatchQueue(label: "com.menubar.status.memorymonitor", qos: .utility)
    
    var isAvailable: Bool {
        return true // Memory monitoring is always available on macOS
    }
    
    func getCurrentMetrics() async throws -> MemoryMetrics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let metrics = try self.collectMemoryMetrics()
                    continuation.resume(returning: metrics)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func collectMemoryMetrics() throws -> MemoryMetrics {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &vmStats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count
                )
            }
        }
        
        guard result == KERN_SUCCESS else {
            throw MetricError.systemAPIUnavailable
        }
        
        // Get page size
        let pageSize = UInt64(vm_page_size)
        
        // Calculate memory values
        let freePages = UInt64(vmStats.free_count)
        let activePages = UInt64(vmStats.active_count)
        let inactivePages = UInt64(vmStats.inactive_count)
        let wiredPages = UInt64(vmStats.wire_count)
        let compressedPages = UInt64(vmStats.compressor_page_count)
        
        let freeBytes = freePages * pageSize
        let activeBytes = activePages * pageSize
        let inactiveBytes = inactivePages * pageSize
        let wiredBytes = wiredPages * pageSize
        let compressedBytes = compressedPages * pageSize
        
        // Used memory = active + wired + compressed
        let usedBytes = activeBytes + wiredBytes + compressedBytes
        
        // Cached = inactive pages
        let cachedBytes = inactiveBytes
        
        // Total physical memory
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)
        
        return MemoryMetrics(
            totalBytes: totalMemory,
            usedBytes: usedBytes,
            freeBytes: freeBytes,
            cachedBytes: cachedBytes
        )
    }
}




