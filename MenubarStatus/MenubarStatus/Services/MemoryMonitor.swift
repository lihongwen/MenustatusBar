//
//  MemoryMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Darwin

// MARK: - Memory Purge Types

enum MemoryPurgeError: Error, LocalizedError {
    case operationInProgress
    case systemCommandFailed
    case insufficientPermissions
    
    var errorDescription: String? {
        switch self {
        case .operationInProgress:
            return "Memory purge already in progress"
        case .systemCommandFailed:
            return "Failed to execute purge command"
        case .insufficientPermissions:
            return "Insufficient permissions to purge memory"
        }
    }
}

struct MemoryPurgeResult {
    let timestamp: Date
    let beforeUsage: UInt64   // Bytes used before purge
    let afterUsage: UInt64    // Bytes used after purge
    let freedBytes: UInt64    // Amount freed
    
    // Computed
    var formattedFreed: String {
        ByteCountFormatter.string(fromByteCount: Int64(freedBytes), countStyle: .memory)
    }
    
    var percentageFreed: Double {
        guard beforeUsage > 0 else { return 0 }
        return Double(freedBytes) / Double(beforeUsage) * 100
    }
    
    var wasSuccessful: Bool {
        freedBytes > 0
    }
}

// MARK: - Protocol

/// Protocol for freeing inactive system memory on demand
protocol MemoryPurging: AnyObject {
    /// Purge inactive memory
    /// - Returns: Result containing before/after memory stats and amount freed
    /// - Throws: MemoryPurgeError if operation fails
    func purgeInactiveMemory() async throws -> MemoryPurgeResult
    
    /// Check if memory purge is currently available
    /// - Returns: True if purge can be performed, false if already in progress
    func canPurge() -> Bool
}

// MARK: - Implementation

/// Memory monitoring service using mach kernel APIs
final class MemoryMonitorImpl: MemoryPurging {
    private let queue = DispatchQueue(label: "com.menubar.status.memorymonitor", qos: .utility)
    private var isPurging = false
    private let purgeLock = NSLock()
    
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
    
    // MARK: - MemoryPurging Implementation
    
    func purgeInactiveMemory() async throws -> MemoryPurgeResult {
        // Check if already purging
        purgeLock.lock()
        if isPurging {
            purgeLock.unlock()
            throw MemoryPurgeError.operationInProgress
        }
        isPurging = true
        purgeLock.unlock()
        
        defer {
            purgeLock.lock()
            isPurging = false
            purgeLock.unlock()
        }
        
        // Get memory before purge
        let beforeMetrics = try await getCurrentMetrics()
        let beforeUsage = beforeMetrics.usedBytes
        
        // Execute purge command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/purge")
        
        do {
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                throw MemoryPurgeError.systemCommandFailed
            }
        } catch {
            if (error as NSError).code == 13 { // EPERM
                throw MemoryPurgeError.insufficientPermissions
            }
            throw MemoryPurgeError.systemCommandFailed
        }
        
        // Wait a moment for system to update stats
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Get memory after purge
        let afterMetrics = try await getCurrentMetrics()
        let afterUsage = afterMetrics.usedBytes
        
        // Calculate freed amount
        let freedBytes = beforeUsage > afterUsage ? beforeUsage - afterUsage : 0
        
        return MemoryPurgeResult(
            timestamp: Date(),
            beforeUsage: beforeUsage,
            afterUsage: afterUsage,
            freedBytes: freedBytes
        )
    }
    
    func canPurge() -> Bool {
        purgeLock.lock()
        defer { purgeLock.unlock() }
        return !isPurging
    }
}




