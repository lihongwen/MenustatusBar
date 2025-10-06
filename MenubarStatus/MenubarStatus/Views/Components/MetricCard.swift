//
//  MetricCard.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

/// A card displaying a metric with expandable/collapsible state, progress bar, sparkline, and detailed breakdown
struct MetricCard: View {
    let title: String
    let icon: String
    let value: Double // Percentage 0-100
    let valueText: String
    let gradient: LinearGradient
    let sparklineData: [HistoricalDataPoint]
    let sparklineColor: Color
    let isExpanded: Bool
    let detailContent: AnyView?
    let onToggleExpand: () -> Void
    
    init(
        title: String,
        icon: String,
        value: Double,
        valueText: String,
        gradient: LinearGradient,
        sparklineData: [HistoricalDataPoint],
        sparklineColor: Color,
        isExpanded: Bool,
        detailContent: AnyView? = nil,
        onToggleExpand: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.value = value
        self.valueText = valueText
        self.gradient = gradient
        self.sparklineData = sparklineData
        self.sparklineColor = sparklineColor
        self.isExpanded = isExpanded
        self.detailContent = detailContent
        self.onToggleExpand = onToggleExpand
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Always visible
            Button(action: onToggleExpand) {
                HStack(spacing: UIStyleConfiguration.spacingM) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(sparklineColor)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(sparklineColor.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: UIStyleConfiguration.spacingXS) {
                        // Title
                        Text(title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Progress bar
                        ProgressBarView(
                            value: value,
                            gradient: gradient,
                            height: 6
                        )
                        .frame(width: 180)
                    }
                    
                    Spacer()
                    
                    // Value
                    Text(valueText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(sparklineColor)
                        .frame(minWidth: 60, alignment: .trailing)
                    
                    // Expand/Collapse indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, UIStyleConfiguration.spacingM)
                .padding(.vertical, UIStyleConfiguration.spacingM)
            }
            .buttonStyle(.plain)
            
            // Sparkline - Always visible
            SparklineChart(
                dataPoints: sparklineData,
                color: sparklineColor,
                height: 24
            )
            .padding(.horizontal, UIStyleConfiguration.spacingM)
            .padding(.bottom, UIStyleConfiguration.spacingS)
            
            // Expanded details
            if isExpanded, let content = detailContent {
                Divider()
                    .padding(.horizontal, UIStyleConfiguration.spacingM)
                
                content
                    .padding(.horizontal, UIStyleConfiguration.spacingM)
                    .padding(.vertical, UIStyleConfiguration.spacingM)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: UIStyleConfiguration.cornerRadiusL)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: UIStyleConfiguration.cardShadow, radius: 2, x: 0, y: 1)
        )
        .animation(AnimationProvider.cardExpansion, value: isExpanded)
    }
}

#if DEBUG
struct MetricCard_Previews: PreviewProvider {
    @State static var isExpanded = false
    
    static var previews: some View {
        VStack(spacing: 16) {
            MetricCard(
                title: "CPU",
                icon: "cpu.fill",
                value: 45.2,
                valueText: "45%",
                gradient: LinearGradient(
                    colors: [.green.opacity(0.6), .green],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                sparklineData: (0..<60).map { i in
                    HistoricalDataPoint(
                        timestamp: Date().addingTimeInterval(TimeInterval(-60 + i)),
                        metricType: .cpu,
                        value: Double.random(in: 30...60)
                    )
                },
                sparklineColor: .green,
                isExpanded: false,
                detailContent: AnyView(
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("User:")
                            Spacer()
                            Text("25%").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("System:")
                            Spacer()
                            Text("15%").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Idle:")
                            Spacer()
                            Text("60%").foregroundColor(.secondary)
                        }
                    }
                    .font(.system(size: 12))
                ),
                onToggleExpand: {}
            )
        }
        .padding()
        .frame(width: 400)
    }
}
#endif

