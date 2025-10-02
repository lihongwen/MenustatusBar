//
//  DiskMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import IOKit
import IOKit.storage

/// Disk I/O statistics tracker
private struct DiskIOStats {
    let readBytes: UInt64
    let writeBytes: UInt64
    let timestamp: Date
}

/// Disk monitoring service using FileManager and IOKit APIs
final class DiskMonitorImpl {
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.menubar.status.diskmonitor", qos: .utility)
    private var cache: [String: (metrics: DiskMetrics, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 1.0 // 1 second cache
    
    // Track previous I/O stats for speed calculation
    private var previousIOStats: [String: DiskIOStats] = [:]
    
    var isAvailable: Bool {
        return true // Disk monitoring is always available
    }
    
    func getCurrentMetrics(for volumePath: String) async throws -> DiskMetrics {
        return try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let metrics = try self.collectDiskMetrics(for: volumePath)
                    continuation.resume(returning: metrics)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getAvailableVolumes() -> [DiskInfo] {
        // Get mounted volumes
        let volumes = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: [.volumeNameKey, .volumeIsLocalKey, .volumeIsRemovableKey],
            options: [.skipHiddenVolumes]
        ) ?? []
        
        var diskInfos: [DiskInfo] = []
        
        for volume in volumes {
            let path = volume.path
            
            // Get volume name
            var volumeName = ""
            if let resourceValues = try? volume.resourceValues(forKeys: [.volumeNameKey]),
               let name = resourceValues.volumeName {
                volumeName = name
            } else {
                volumeName = volume.lastPathComponent
            }
            
            // Skip empty or system-hidden volumes
            if volumeName.isEmpty && path != "/" {
                continue
            }
            
            diskInfos.append(DiskInfo(path: path, name: volumeName))
        }
        
        // Ensure root volume is included
        if !diskInfos.contains(where: { $0.path == "/" }) {
            diskInfos.insert(DiskInfo(path: "/", name: "System"), at: 0)
        }
        
        return diskInfos.sorted { $0.path < $1.path }
    }
    
    private func collectDiskMetrics(for volumePath: String) throws -> DiskMetrics {
        // Check cache
        if let cached = cache[volumePath],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            return cached.metrics
        }
        
        // Verify path exists and is accessible
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: volumePath, isDirectory: &isDirectory) else {
            throw MetricError.pathNotFound(volumePath)
        }
        
        // Get file system attributes
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: volumePath) else {
            throw MetricError.invalidData
        }
        
        guard let totalBytes = attributes[.systemSize] as? UInt64,
              let freeBytes = attributes[.systemFreeSize] as? UInt64 else {
            throw MetricError.invalidData
        }
        
        let usedBytes = totalBytes - freeBytes
        
        // Get volume name
        let url = URL(fileURLWithPath: volumePath)
        let volumeName: String
        if let name = try? url.resourceValues(forKeys: [.volumeNameKey]).volumeName {
            volumeName = name
        } else {
            // Fallback to last path component
            volumeName = url.lastPathComponent.isEmpty ? "System" : url.lastPathComponent
        }
        
        // Get I/O statistics
        let (readSpeed, writeSpeed) = getDiskIOSpeed(for: volumePath)
        
        let metrics = DiskMetrics(
            volumePath: volumePath,
            volumeName: volumeName,
            totalBytes: totalBytes,
            freeBytes: freeBytes,
            usedBytes: usedBytes,
            readBytesPerSecond: readSpeed,
            writeBytesPerSecond: writeSpeed
        )
        
        // Update cache
        cache[volumePath] = (metrics, Date())
        
        return metrics
    }
    
    /// Get disk I/O speed for a volume
    private func getDiskIOSpeed(for volumePath: String) -> (readSpeed: UInt64, writeSpeed: UInt64) {
        // Get current I/O stats
        guard let (currentReadBytes, currentWriteBytes) = getDiskIOBytes() else {
            return (0, 0)
        }
        
        let now = Date()
        
        // Check if we have previous stats
        if let previous = previousIOStats[volumePath] {
            let timeDelta = now.timeIntervalSince(previous.timestamp)
            guard timeDelta > 0 else {
                return (0, 0)
            }
            
            // Calculate bytes per second
            let readDelta = currentReadBytes > previous.readBytes ? currentReadBytes - previous.readBytes : 0
            let writeDelta = currentWriteBytes > previous.writeBytes ? currentWriteBytes - previous.writeBytes : 0
            
            let readSpeed = UInt64(Double(readDelta) / timeDelta)
            let writeSpeed = UInt64(Double(writeDelta) / timeDelta)
            
            // Store current stats for next calculation
            previousIOStats[volumePath] = DiskIOStats(
                readBytes: currentReadBytes,
                writeBytes: currentWriteBytes,
                timestamp: now
            )
            
            return (readSpeed, writeSpeed)
        } else {
            // First measurement - store and return 0
            previousIOStats[volumePath] = DiskIOStats(
                readBytes: currentReadBytes,
                writeBytes: currentWriteBytes,
                timestamp: now
            )
            return (0, 0)
        }
    }
    
    /// Get total disk I/O bytes from system
    private func getDiskIOBytes() -> (readBytes: UInt64, writeBytes: UInt64)? {
        // Use IOKit to get disk statistics
        var totalReadBytes: UInt64 = 0
        var totalWriteBytes: UInt64 = 0
        
        // Get the list of all drives
        let matchingDict = IOServiceMatching("IOBlockStorageDriver")
        var iterator: io_iterator_t = 0
        
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator) == KERN_SUCCESS else {
            return nil
        }
        
        defer {
            IOObjectRelease(iterator)
        }
        
        var drive = IOIteratorNext(iterator)
        while drive != 0 {
            defer {
                IOObjectRelease(drive)
                drive = IOIteratorNext(iterator)
            }
            
            var properties: Unmanaged<CFMutableDictionary>?
            guard IORegistryEntryCreateCFProperties(drive, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
                  let props = properties?.takeRetainedValue() as? [String: Any],
                  let statistics = props["Statistics"] as? [String: Any] else {
                continue
            }
            
            if let bytesRead = statistics["Bytes (Read)"] as? UInt64 {
                totalReadBytes += bytesRead
            }
            
            if let bytesWritten = statistics["Bytes (Write)"] as? UInt64 {
                totalWriteBytes += bytesWritten
            }
        }
        
        return (totalReadBytes, totalWriteBytes)
    }
}




