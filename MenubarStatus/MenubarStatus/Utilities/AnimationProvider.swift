//
//  AnimationProvider.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import SwiftUI

/// Provides standard animation definitions for consistent UI animations
enum AnimationProvider {
    /// Standard spring animation for smooth transitions
    static let standardSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    /// Quick fade animation for appearing/disappearing elements
    static let quickFade = Animation.easeInOut(duration: 0.2)
    
    /// Smooth transition for value changes
    static let smoothTransition = Animation.easeInOut(duration: 0.3)
    
    /// Card expansion/collapse animation
    static let cardExpansion = Animation.spring(response: 0.35, dampingFraction: 0.75)
    
    /// Progress bar animation
    static let progressBar = Animation.linear(duration: 0.25)
    
    /// Sparkline update animation
    static let sparklineUpdate = Animation.linear(duration: 0.1)
    
    /// Disk mount/unmount animation
    static let diskChange = Animation.spring(response: 0.4, dampingFraction: 0.8)
}

