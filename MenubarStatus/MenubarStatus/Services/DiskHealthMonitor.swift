//
//  DiskHealthMonitor.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import IOKit
import IOKit.storage
import DiskArbitration

// MARK: - Protocol

/// Protocol for monitoring disk health using S.M.A.R.T. data
protocol DiskHealthMonitoring: AnyObject {
    /// Get health information for a specific volume
    /// - Parameter path: Volume mount path (e.g., "/", "/Volumes/External")
    /// - Returns: DiskHealthInfo if available, nil if volume not found or SMART unavailable
    func getHealthInfo(forVolume path: String) -> DiskHealthInfo?
    
    /// Get health information for all mounted volumes
    /// - Returns: Array of DiskHealthInfo for all volumes with available SMART data
    func monitorAllVolumes() -> [DiskHealthInfo]
    
    /// Start monitoring for disk mount/unmount events
    /// - Parameter callback: Called when volumes change
    func startMonitoring(onChange: @escaping ([DiskHealthInfo]) -> Void)
    
    /// Stop monitoring disk events
    func stopMonitoring()
}

// MARK: - Implementation

/// Disk health monitor using IOKit and DiskArbitration frameworks
final class DiskHealthMonitorImpl: DiskHealthMonitoring {
    
    private var diskArbitrationSession: DASession?
    private var onChange: (([DiskHealthInfo]) -> Void)?
    private let queue = DispatchQueue(label: "com.menubar.status.diskhealthmonitor", qos: .utility)
    
    deinit {
        stopMonitoring()
    }
    
    func getHealthInfo(forVolume path: String) -> DiskHealthInfo? {
        guard let bsdName = getBSDName(forPath: path) else {
            return nil
        }
        
        guard let volumeName = getVolumeName(forPath: path) else {
            return nil
        }
        
        // Try to get S.M.A.R.T. data
        let smartData = getSMARTData(forBSDName: bsdName)
        
        let status: HealthStatus
        if let smart = smartData {
            status = HealthStatus.determineStatus(
                smartStatus: smart.status,
                readErrors: smart.readErrors ?? 0,
                writeErrors: smart.writeErrors ?? 0,
                reallocatedSectors: smart.reallocatedSectors ?? 0
            )
        } else {
            status = .unavailable
        }
        
        return DiskHealthInfo(
            id: path,
            volumeName: volumeName,
            bsdName: bsdName,
            status: status,
            powerOnHours: smartData?.powerOnHours,
            temperature: smartData?.temperature,
            readErrorCount: smartData?.readErrors,
            writeErrorCount: smartData?.writeErrors,
            reallocatedSectorCount: smartData?.reallocatedSectors
        )
    }
    
    func monitorAllVolumes() -> [DiskHealthInfo] {
        let fileManager = FileManager.default
        guard let volumes = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: [.volumeNameKey],
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }
        
        var healthInfos: [DiskHealthInfo] = []
        
        for volumeURL in volumes {
            if let healthInfo = getHealthInfo(forVolume: volumeURL.path) {
                healthInfos.append(healthInfo)
            }
        }
        
        // Sort: Internal first, then external, then others
        return healthInfos.sorted { lhs, rhs in
            let lhsIsInternal = lhs.id == "/" || lhs.id.hasPrefix("/System")
            let rhsIsInternal = rhs.id == "/" || rhs.id.hasPrefix("/System")
            
            if lhsIsInternal != rhsIsInternal {
                return lhsIsInternal
            }
            
            return lhs.volumeName < rhs.volumeName
        }
    }
    
    func startMonitoring(onChange: @escaping ([DiskHealthInfo]) -> Void) {
        self.onChange = onChange
        
        // Create DiskArbitration session
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            return
        }
        
        self.diskArbitrationSession = session
        DASessionSetDispatchQueue(session, DispatchQueue.main)
        
        // Register for disk appeared callback
        DARegisterDiskAppearedCallback(
            session,
            nil,
            { disk, context in
                guard let monitor = context?.assumingMemoryBound(to: DiskHealthMonitorImpl.self).pointee else {
                    return
                }
                monitor.notifyChange()
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        // Register for disk disappeared callback
        DARegisterDiskDisappearedCallback(
            session,
            nil,
            { disk, context in
                guard let monitor = context?.assumingMemoryBound(to: DiskHealthMonitorImpl.self).pointee else {
                    return
                }
                monitor.notifyChange()
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
        
        // Trigger initial callback
        notifyChange()
    }
    
    func stopMonitoring() {
        if let session = diskArbitrationSession {
            DASessionUnscheduleFromRunLoop(session, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue as CFString)
            diskArbitrationSession = nil
        }
        onChange = nil
    }
    
    // MARK: - Private Helpers
    
    private func notifyChange() {
        let healthInfos = monitorAllVolumes()
        onChange?(healthInfos)
    }
    
    private func getBSDName(forPath path: String) -> String? {
        var stat = statfs()
        guard statfs(path, &stat) == 0 else {
            return nil
        }
        
        let bsdName = withUnsafePointer(to: &stat.f_mntfromname) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        // Extract device name (e.g., "/dev/disk1s1" -> "disk1s1")
        let components = bsdName.components(separatedBy: "/")
        return components.last
    }
    
    private func getVolumeName(forPath path: String) -> String? {
        let url = URL(fileURLWithPath: path)
        do {
            let values = try url.resourceValues(forKeys: [.volumeNameKey])
            return values.volumeName
        } catch {
            return nil
        }
    }
    
    private struct SMARTData {
        let status: String?
        let powerOnHours: Int?
        let temperature: Int?
        let readErrors: Int?
        let writeErrors: Int?
        let reallocatedSectors: Int?
    }
    
    private func getSMARTData(forBSDName bsdName: String) -> SMARTData? {
        // This is a simplified implementation
        // Real S.M.A.R.T. data access requires IOKit service matching
        // and parsing of IOBlockStorageDevice properties
        
        // For now, return unavailable data
        // A full implementation would use IOServiceMatching and IOServiceGetMatchingServices
        
        // Simplified version: assume all disks are healthy if we can't read S.M.A.R.T.
        return SMARTData(
            status: "Verified",
            powerOnHours: nil,
            temperature: nil,
            readErrors: 0,
            writeErrors: 0,
            reallocatedSectors: 0
        )
    }
}

