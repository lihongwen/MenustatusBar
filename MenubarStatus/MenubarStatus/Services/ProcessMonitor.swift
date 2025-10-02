//
//  ProcessMonitor.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import AppKit

// MARK: - Enums and Errors

enum ProcessSortCriteria: String, Codable, CaseIterable {
    case cpu = "cpu"
    case memory = "memory"
    
    var displayName: String {
        let lang = LocalizedStrings.language
        switch self {
        case .cpu: return lang == .chinese ? "CPU 使用率" : "CPU Usage"
        case .memory: return lang == .chinese ? "内存使用" : "Memory Usage"
        }
    }
}

enum ProcessTerminationError: Error, LocalizedError {
    case processNotFound
    case insufficientPermissions
    case systemCriticalProcess
    case terminationFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .processNotFound:
            return "Process not found"
        case .insufficientPermissions:
            return "Insufficient permissions to terminate process"
        case .systemCriticalProcess:
            return "Cannot terminate system-critical process"
        case .terminationFailed(let reason):
            return "Failed to terminate process: \(reason)"
        }
    }
}

// MARK: - Protocol

/// Protocol for monitoring running system processes and their resource usage
protocol ProcessMonitoring: AnyObject {
    /// Get the top N processes sorted by specified criteria
    /// - Parameters:
    ///   - sortBy: CPU or Memory usage
    ///   - limit: Maximum number of processes to return
    /// - Returns: Array of ProcessInfo, sorted by criteria (highest first)
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo]
    
    /// Attempt to terminate a process by PID
    /// - Parameter pid: Process ID to terminate
    /// - Throws: ProcessTerminationError if termination fails
    func terminateProcess(pid: Int) throws
    
    /// Check if a process is system-critical and should not be terminated
    /// - Parameter pid: Process ID to check
    /// - Returns: True if process is protected, false if safe to terminate
    func isSystemCritical(pid: Int) -> Bool
    
    /// Get detailed information about a specific process
    /// - Parameter pid: Process ID
    /// - Returns: ProcessInfo if found, nil otherwise
    func getProcessInfo(pid: Int) -> ProcessInfo?
}

// MARK: - Implementation

/// Process monitor implementation using system APIs
final class ProcessMonitorImpl: ProcessMonitoring {
    
    // System-critical processes that should never be terminated
    private let protectedProcesses: Set<String> = [
        "kernel_task", "launchd", "WindowServer", "loginwindow",
        "SystemUIServer", "Dock", "Finder", "coreaudiod",
        "SystemUIServer", "com.apple.WebKit.WebContent",
        "launchservicesd", "cfprefsd", "accountsd"
    ]
    
    func getTopProcesses(sortBy: ProcessSortCriteria, limit: Int) -> [ProcessInfo] {
        let allProcesses = getAllRunningProcesses()
        
        let sorted = allProcesses.sorted { process1, process2 in
            switch sortBy {
            case .cpu:
                return process1.cpuUsage > process2.cpuUsage
            case .memory:
                return process1.memoryUsage > process2.memoryUsage
            }
        }
        
        return Array(sorted.prefix(limit))
    }
    
    func terminateProcess(pid: Int) throws {
        // Check if process is system critical
        if isSystemCritical(pid: pid) {
            throw ProcessTerminationError.systemCriticalProcess
        }
        
        // Check if process exists
        guard getProcessInfo(pid: pid) != nil else {
            throw ProcessTerminationError.processNotFound
        }
        
        // Attempt to terminate the process
        let result = kill(pid_t(pid), SIGTERM)
        
        if result != 0 {
            let error = String(cString: strerror(errno))
            if errno == EPERM {
                throw ProcessTerminationError.insufficientPermissions
            } else {
                throw ProcessTerminationError.terminationFailed(reason: error)
            }
        }
    }
    
    func isSystemCritical(pid: Int) -> Bool {
        // PIDs below 100 are typically system processes
        if pid < 100 {
            return true
        }
        
        // Check against protected process names
        guard let processName = getProcessName(for: pid) else {
            return true // If we can't determine, be safe
        }
        
        return protectedProcesses.contains(processName)
    }
    
    func getProcessInfo(pid: Int) -> ProcessInfo? {
        guard let processName = getProcessName(for: pid) else {
            return nil
        }
        
        let cpuUsage = getCPUUsage(for: pid)
        let memoryUsage = getMemoryUsage(for: pid)
        let bundleIdentifier = getBundleIdentifier(for: pid)
        let icon = getProcessIcon(for: pid, bundleIdentifier: bundleIdentifier)
        
        return ProcessInfo(
            id: pid,
            name: processName,
            bundleIdentifier: bundleIdentifier,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            icon: icon
        )
    }
    
    // MARK: - Private Helpers
    
    private func getAllRunningProcesses() -> [ProcessInfo] {
        var processes: [ProcessInfo] = []
        
        // Get all process IDs using sysctl
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var length: size_t = 0
        
        // Get the size needed
        sysctl(&name, 4, nil, &length, nil, 0)
        
        let count = length / MemoryLayout<kinfo_proc>.stride
        var procList = Array(repeating: kinfo_proc(), count: count)
        
        // Get the actual process list
        sysctl(&name, 4, &procList, &length, nil, 0)
        
        // Convert to ProcessInfo
        for proc in procList {
            let pid = Int(proc.kp_proc.p_pid)
            
            // Skip kernel_task and very low PIDs
            if pid <= 0 {
                continue
            }
            
            if let processInfo = getProcessInfo(pid: pid) {
                processes.append(processInfo)
            }
        }
        
        return processes
    }
    
    private func getProcessName(for pid: Int) -> String? {
        var name = [CChar](repeating: 0, count: 1024)
        var size = name.count
        
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, Int32(pid)]
        
        guard sysctl(&mib, 3, &name, &size, nil, 0) == 0 else {
            return nil
        }
        
        // Extract process name from the buffer
        // The buffer format: [argc (int32)][argv0_ptr][argv1_ptr]...
        // We want the actual string which starts after the pointers
        let processName = String(cString: name)
        let components = processName.components(separatedBy: "/")
        return components.last ?? processName
    }
    
    private func getCPUUsage(for pid: Int) -> Double {
        // This is a simplified implementation
        // In a real-world scenario, you'd use task_info() for accurate CPU usage
        var taskInfo = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size / MemoryLayout<integer_t>.size)
        
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, Int32(pid), &task) == KERN_SUCCESS else {
            return 0.0
        }
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0.0
        }
        
        // CPU usage calculation would need thread info and time sampling
        // For now, return 0 (proper implementation would track deltas)
        return 0.0
    }
    
    private func getMemoryUsage(for pid: Int) -> UInt64 {
        var taskInfo = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size / MemoryLayout<integer_t>.size)
        
        var task: task_t = 0
        guard task_for_pid(mach_task_self_, Int32(pid), &task) == KERN_SUCCESS else {
            return 0
        }
        
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0
        }
        
        return UInt64(taskInfo.resident_size)
    }
    
    private func getBundleIdentifier(for pid: Int) -> String? {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.first(where: { $0.processIdentifier == pid })?.bundleIdentifier
    }
    
    private func getProcessIcon(for pid: Int, bundleIdentifier: String?) -> NSImage? {
        // Try to get icon from running application
        if let app = NSWorkspace.shared.runningApplications.first(where: { $0.processIdentifier == pid }) {
            return app.icon
        }
        
        // Try to get icon from bundle identifier
        if let bundleID = bundleIdentifier,
           let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            return NSWorkspace.shared.icon(forFile: appURL.path)
        }
        
        // Return generic executable icon
        return NSWorkspace.shared.icon(forFileType: "public.executable")
    }
}

