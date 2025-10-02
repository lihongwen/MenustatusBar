//
//  ProgressBarView.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

/// A progress bar with gradient fill and color theme support
struct ProgressBarView: View {
    let value: Double // 0-100
    let gradient: LinearGradient
    let height: CGFloat
    
    init(value: Double, gradient: LinearGradient, height: CGFloat = 8) {
        self.value = max(0, min(100, value)) // Clamp to 0-100
        self.gradient = gradient
        self.height = height
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.2))
                
                // Progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(gradient)
                    .frame(width: geometry.size.width * (value / 100))
                    .animation(AnimationProvider.progressBar, value: value)
            }
        }
        .frame(height: height)
    }
}

#if DEBUG
struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ProgressBarView(
                value: 45,
                gradient: LinearGradient(
                    colors: [.green.opacity(0.6), .green],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            ProgressBarView(
                value: 75,
                gradient: LinearGradient(
                    colors: [.yellow.opacity(0.6), .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            ProgressBarView(
                value: 95,
                gradient: LinearGradient(
                    colors: [.red.opacity(0.6), .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .padding()
        .frame(width: 300)
    }
}
#endif

