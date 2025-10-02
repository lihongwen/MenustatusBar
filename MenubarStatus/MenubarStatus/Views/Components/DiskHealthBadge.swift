//
//  DiskHealthBadge.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

/// A badge displaying disk health status with SF Symbol icon and color coding
struct DiskHealthBadge: View {
    let healthInfo: DiskHealthInfo
    let compact: Bool
    
    init(healthInfo: DiskHealthInfo, compact: Bool = false) {
        self.healthInfo = healthInfo
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: healthInfo.healthIcon)
                .foregroundColor(healthInfo.healthColor)
                .imageScale(compact ? .small : .medium)
            
            if !compact {
                Text(healthInfo.status.displayName)
                    .font(.caption)
                    .foregroundColor(healthInfo.healthColor)
            }
        }
        .padding(.horizontal, compact ? 4 : 6)
        .padding(.vertical, compact ? 2 : 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(healthInfo.healthColor.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(healthInfo.healthColor.opacity(0.3), lineWidth: 1)
        )
        .help(healthInfo.status.description)
    }
}

#if DEBUG
struct DiskHealthBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            DiskHealthBadge(
                healthInfo: DiskHealthInfo(
                    id: "/",
                    volumeName: "Macintosh HD",
                    bsdName: "disk1s1",
                    status: .good
                )
            )
            
            DiskHealthBadge(
                healthInfo: DiskHealthInfo(
                    id: "/",
                    volumeName: "Macintosh HD",
                    bsdName: "disk1s1",
                    status: .warning
                )
            )
            
            DiskHealthBadge(
                healthInfo: DiskHealthInfo(
                    id: "/",
                    volumeName: "Macintosh HD",
                    bsdName: "disk1s1",
                    status: .critical
                )
            )
            
            DiskHealthBadge(
                healthInfo: DiskHealthInfo(
                    id: "/",
                    volumeName: "Macintosh HD",
                    bsdName: "disk1s1",
                    status: .unavailable
                ),
                compact: true
            )
        }
        .padding()
    }
}
#endif

