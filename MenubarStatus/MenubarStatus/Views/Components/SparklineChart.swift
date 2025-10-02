//
//  SparklineChart.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI
import Charts

/// A sparkline chart showing 60-second trend visualization
struct SparklineChart: View {
    let dataPoints: [HistoricalDataPoint]
    let color: Color
    let height: CGFloat
    
    init(dataPoints: [HistoricalDataPoint], color: Color, height: CGFloat = 30) {
        self.dataPoints = dataPoints
        self.color = color
        self.height = height
    }
    
    var body: some View {
        if dataPoints.isEmpty {
            // Show placeholder when no data
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: height)
        } else {
            Chart(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.3), color],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                
                // Area fill under the line
                AreaMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Value", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [color.opacity(0.1), color.opacity(0.3)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...100) // Percentage scale
            .frame(height: height)
            .animation(AnimationProvider.sparklineUpdate, value: dataPoints.count)
        }
    }
}

#if DEBUG
struct SparklineChart_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // With data
            SparklineChart(
                dataPoints: (0..<60).map { i in
                    HistoricalDataPoint(
                        timestamp: Date().addingTimeInterval(TimeInterval(-60 + i)),
                        metricType: .cpu,
                        value: Double.random(in: 20...80)
                    )
                },
                color: .green,
                height: 30
            )
            .padding()
            
            // Empty state
            SparklineChart(
                dataPoints: [],
                color: .blue,
                height: 30
            )
            .padding()
        }
        .frame(width: 300)
    }
}
#endif

