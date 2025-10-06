//
//  MenubarLabelLayout.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-05.
//

import SwiftUI

struct MenubarLayoutConfig {
    enum Background {
        case material(Material)
        case color(Color)
    }

    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let shape: AnyShape
    let background: Background

    @ViewBuilder
    var backgroundView: some View {
        switch background {
        case .material(let material):
            Rectangle().fill(material)
        case .color(let color):
            color
        }
    }
}
