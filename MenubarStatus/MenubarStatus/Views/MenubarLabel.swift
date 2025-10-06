//
//  MenubarLabel.swift
//  MenubarStatus
//
//  Unified compact menubar display
//

import SwiftUI

/// Menubar summary data structure
struct MenubarSummary {
    struct Item: Identifiable {
        let id: String
        let icon: String
        let title: String
        let primaryText: String
        let secondaryText: String?
        let percentage: Double
        let theme: ColorTheme
    }
    
    let items: [Item]
}

/// Menubar label view - displays metrics in unified compact format
struct MenubarLabel: View {
    let summary: MenubarSummary
    
    var body: some View {
        if summary.items.isEmpty {
            emptyView
        } else {
            compactView
        }
    }
    
    // MARK: - Empty State
    
    private var emptyView: some View {
        Text("---")
            .font(UIStyleConfiguration.menubarFont)
            .foregroundColor(.secondary)
            .padding(.horizontal, UIStyleConfiguration.menubarHorizontalPadding)
            .padding(.vertical, UIStyleConfiguration.menubarVerticalPadding)
    }
    
    // MARK: - Compact Format View
    
    private var compactView: some View {
        // macOS 风格的图标映射 - 经典硬件风格
        let iconEmoji: [String: String] = [
            "cpu.fill": "💻",          // 笔记本电脑 - 代表 CPU 处理器
            "memorychip.fill": "💾",    // 软盘 - 代表内存
            "internaldrive.fill": "💿", // 光盘 - 代表硬盘
            "network": "🌐"             // 地球 - macOS 经典网络图标
        ]
        
        // 构建 AttributedString 以保留颜色
        var attributedString = AttributedString()
        
        for (index, item) in summary.items.enumerated() {
            // 添加间隔（除了第一个）
            if index > 0 {
                attributedString += AttributedString(" ")
            }
            
            // 添加图标和文本
            var itemText = AttributedString()
            if !item.icon.isEmpty, let emoji = iconEmoji[item.icon] {
                itemText += AttributedString(emoji)
            }
            itemText += AttributedString(item.primaryText)
            
            // 设置颜色
            #if os(macOS)
            itemText.foregroundColor = item.theme.statusColor(for: item.percentage)
            #endif
            
            attributedString += itemText
        }
        
        // 使用单一的 Text，支持 AttributedString
        return Text(attributedString)
            .font(UIStyleConfiguration.menubarFont)
            .monospacedDigit()
    }
    
    // MARK: - Tooltip
    
    private func tooltipText(for item: MenubarSummary.Item) -> String {
        let title = item.title
        let value = String(format: "%.2f%%", item.percentage)
        
        if let secondary = item.secondaryText {
            return "\(title): \(value)\n\(secondary)"
        } else {
            return "\(title): \(value)"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MenubarLabel_Previews: PreviewProvider {
    static var previews: some View {
        let theme = SystemDefaultTheme()
        
        let summary = MenubarSummary(items: [
            MenubarSummary.Item(
                id: "cpu",
                icon: "cpu.fill",
                title: "CPU",
                primaryText: "45%",
                secondaryText: nil,
                percentage: 45.0,
                theme: theme
            ),
            MenubarSummary.Item(
                id: "memory",
                icon: "memorychip.fill",
                title: "Memory",
                primaryText: "72%",
                secondaryText: nil,
                percentage: 72.0,
                theme: theme
            ),
            MenubarSummary.Item(
                id: "network",
                icon: "network",
                title: "Network",
                primaryText: "↓2.3M",
                secondaryText: nil,
                percentage: 30.0,
                theme: theme
            )
        ])
        
        MenubarLabel(summary: summary)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
