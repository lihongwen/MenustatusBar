//
//  CardExpansionState.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation
import SwiftUI
import Combine

/// Tracks which metric cards are expanded in the dropdown
class CardExpansionState: ObservableObject {
    @Published var expandedCards: Set<MetricType> = []
    
    /// Toggle expansion state for a metric
    func toggle(_ metric: MetricType) {
        if expandedCards.contains(metric) {
            expandedCards.remove(metric)
        } else {
            expandedCards.insert(metric)
        }
    }
    
    /// Check if a metric card is expanded
    func isExpanded(_ metric: MetricType) -> Bool {
        expandedCards.contains(metric)
    }
    
    /// Collapse all cards
    func collapseAll() {
        expandedCards.removeAll()
    }
    
    /// Expand all cards
    func expandAll() {
        expandedCards = Set(MetricType.allCases)
    }
}

