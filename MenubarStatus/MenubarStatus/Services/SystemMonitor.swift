//
//  SystemMonitor.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation
import Combine

/// System monitoring coordinator that aggregates all metric providers
@MainActor
class SystemMonitorImpl: ObservableObject {
    @Published var currentMetrics: SystemMetrics?
    @Published var isMonitoring: Bool = false
    @Published var settings: AppSettings
    
    private let cpuMonitor: CPUMonitorImpl
    private let memoryMonitor: MemoryMonitorImpl
    private let diskMonitor: DiskMonitorImpl
    private let networkMonitor: NetworkMonitorImpl
    
    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.menubar.status.systemmonitor.timer", qos: .utility)
    
    init(settings: AppSettings) {
        self.settings = settings
        self.cpuMonitor = CPUMonitorImpl()
        self.memoryMonitor = MemoryMonitorImpl()
        self.diskMonitor = DiskMonitorImpl()
        self.networkMonitor = NetworkMonitorImpl()
    }
    
    func start(interval: TimeInterval) {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        
        // Create timer
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        self.timer = timer
        
        // Configure timer to fire at interval
        timer.schedule(
            deadline: .now(),
            repeating: interval,
            leeway: .milliseconds(50)
        )
        
        timer.setEventHandler { [weak self] in
            Task { @MainActor [weak self] in
                try? await self?.refresh()
            }
        }
        
        timer.resume()
    }
    
    func stop() {
        guard isMonitoring else { return }
        
        timer?.cancel()
        timer = nil
        isMonitoring = false
    }
    
    func refresh() async throws {
        // Collect all metrics in parallel for efficiency
        async let cpu = cpuMonitor.getCurrentMetrics()
        async let memory = memoryMonitor.getCurrentMetrics()
        async let disk = diskMonitor.getCurrentMetrics(for: settings.selectedDiskPath)
        async let network = networkMonitor.getCurrentMetrics()
        
        // Wait for all to complete
        let cpuMetrics = try await cpu
        let memoryMetrics = try await memory
        let diskMetrics = try await disk
        let networkMetrics = try await network
        
        // Create system metrics snapshot
        let metrics = SystemMetrics(
            timestamp: Date(),
            cpu: cpuMetrics,
            memory: memoryMetrics,
            disk: diskMetrics,
            network: networkMetrics
        )
        
        // Update on main thread
        await MainActor.run {
            self.currentMetrics = metrics
        }
    }
}




