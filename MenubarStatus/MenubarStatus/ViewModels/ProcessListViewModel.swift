//
//  ProcessListViewModel.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import Combine

/// ViewModel for managing process list display and termination
@MainActor
class ProcessListViewModel: ObservableObject {
    @Published var topProcesses: [ProcessInfo] = []
    @Published var sortCriteria: ProcessSortCriteria = .cpu
    @Published var limit: Int = 5
    @Published var errorMessage: String?
    
    private let processMonitor: ProcessMonitoring
    private var refreshTimer: Timer?
    
    init(processMonitor: ProcessMonitoring) {
        self.processMonitor = processMonitor
    }
    
    deinit {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Public Methods
    
    func startRefreshing(interval: TimeInterval = 2.0) {
        stopRefreshing()
        
        // Initial refresh
        refreshProcesses()
        
        // Set up timer
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshProcesses()
            }
        }
    }
    
    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refreshProcesses() {
        topProcesses = processMonitor.getTopProcesses(sortBy: sortCriteria, limit: limit)
    }
    
    func updateSortCriteria(_ criteria: ProcessSortCriteria) {
        sortCriteria = criteria
        refreshProcesses()
    }
    
    func terminateProcess(_ process: ProcessInfo) {
        // Check if process is system critical
        guard !processMonitor.isSystemCritical(pid: process.id) else {
            errorMessage = "Cannot terminate system-critical process: \(process.name)"
            return
        }
        
        do {
            try processMonitor.terminateProcess(pid: process.id)
            
            // Refresh list after a brief delay to allow process to terminate
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                await MainActor.run {
                    refreshProcesses()
                    errorMessage = nil
                }
            }
        } catch {
            errorMessage = "Failed to terminate \(process.name): \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

