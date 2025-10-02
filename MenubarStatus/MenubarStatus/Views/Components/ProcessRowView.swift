//
//  ProcessRowView.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

/// A row view displaying process information with icon, name, usage stats, and terminate button
struct ProcessRowView: View {
    let process: ProcessInfo
    let onTerminate: (ProcessInfo) -> Void
    @State private var showingTerminateConfirmation = false
    
    var body: some View {
        HStack(spacing: 8) {
            // App icon
            if let icon = process.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)
            }
            
            // Process name and bundle ID
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                
                if let bundleID = process.bundleIdentifier {
                    Text(bundleID)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // CPU usage
            Text(FormatHelpers.formatPercentageCompact(process.cpuUsage))
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 50, alignment: .trailing)
            
            // Memory usage
            Text(process.formattedMemory)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.purple)
                .frame(width: 60, alignment: .trailing)
            
            // Terminate button
            if process.isTerminable {
                Button(action: {
                    showingTerminateConfirmation = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .imageScale(.medium)
                }
                .buttonStyle(.plain)
                .help("Terminate Process")
                .confirmationDialog(
                    "Terminate \(process.name)?",
                    isPresented: $showingTerminateConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Terminate", role: .destructive) {
                        onTerminate(process)
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This will immediately terminate the process. Unsaved data may be lost.")
                }
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .imageScale(.small)
                    .help("System Process (Protected)")
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#if DEBUG
struct ProcessRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            ProcessRowView(
                process: ProcessInfo(
                    id: 1234,
                    name: "Safari",
                    bundleIdentifier: "com.apple.Safari",
                    cpuUsage: 45.2,
                    memoryUsage: 1_234_567_890,
                    icon: NSWorkspace.shared.icon(forFile: "/Applications/Safari.app")
                ),
                onTerminate: { _ in }
            )
            
            ProcessRowView(
                process: ProcessInfo(
                    id: 1,
                    name: "kernel_task",
                    bundleIdentifier: nil,
                    cpuUsage: 12.5,
                    memoryUsage: 234_567_890,
                    icon: nil
                ),
                onTerminate: { _ in }
            )
        }
        .padding()
        .frame(width: 400)
    }
}
#endif

