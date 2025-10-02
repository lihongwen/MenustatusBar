//
//  LocalizedStrings.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

/// Centralized localization for UI strings
struct LocalizedStrings {
    static var language: AppLanguage = .english
    
    // MARK: - Common
    static var ok: String { language == .chinese ? "确定" : "OK" }
    static var cancel: String { language == .chinese ? "取消" : "Cancel" }
    static var close: String { language == .chinese ? "关闭" : "Close" }
    static var save: String { language == .chinese ? "保存" : "Save" }
    static var reset: String { language == .chinese ? "重置" : "Reset" }
    static var refresh: String { language == .chinese ? "刷新" : "Refresh" }
    
    // MARK: - MenuBar View
    static var systemMonitor: String { language == .chinese ? "系统监控" : "System Monitor" }
    static var updated: String { language == .chinese ? "更新于" : "Updated" }
    static var initializing: String { language == .chinese ? "初始化中..." : "Initializing..." }
    static var loading: String { language == .chinese ? "加载中..." : "Loading..." }
    static var monitoringStatus: String { language == .chinese ? "监控状态" : "Monitoring status" }
    static var active: String { language == .chinese ? "活跃" : "Active" }
    static var inactive: String { language == .chinese ? "非活跃" : "Inactive" }
    static var monitoringActive: String { language == .chinese ? "监控已激活" : "Monitoring active" }
    static var monitoringInactive: String { language == .chinese ? "监控未激活" : "Monitoring inactive" }
    
    // MARK: - Metrics
    static var cpu: String { language == .chinese ? "处理器" : "CPU" }
    static var cpuUsage: String { language == .chinese ? "CPU 使用率" : "CPU Usage" }
    static var memory: String { language == .chinese ? "内存" : "Memory" }
    static var memoryUsage: String { language == .chinese ? "内存使用" : "Memory Usage" }
    static var disk: String { language == .chinese ? "磁盘" : "Disk" }
    static var diskUsage: String { language == .chinese ? "磁盘使用" : "Disk Usage" }
    static var network: String { language == .chinese ? "网络" : "Network" }
    static var networkActivity: String { language == .chinese ? "网络活动" : "Network Activity" }
    
    // Color indicators
    static func colorIndicator(green: Bool, yellow: Bool, red: Bool) -> String {
        if green { return language == .chinese ? "🟢 正常" : "🟢 Good" }
        if yellow { return language == .chinese ? "🟡 警告" : "🟡 Warning" }
        if red { return language == .chinese ? "🔴 高负载" : "🔴 High" }
        return ""
    }
    
    static var used: String { language == .chinese ? "已用" : "Used" }
    static var free: String { language == .chinese ? "可用" : "Free" }
    static var total: String { language == .chinese ? "总计" : "Total" }
    static var download: String { language == .chinese ? "下载" : "Download" }
    static var upload: String { language == .chinese ? "上传" : "Upload" }
    
    // MARK: - Actions
    static var quickActions: String { language == .chinese ? "快速操作" : "Quick Actions" }
    static var openSettings: String { language == .chinese ? "打开设置" : "Open Settings" }
    static var customizeAppearance: String { language == .chinese ? "自定义外观和监控选项" : "Customize appearance and monitoring" }
    static var refreshNow: String { language == .chinese ? "立即刷新" : "Refresh Now" }
    static var updateMetrics: String { language == .chinese ? "更新所有指标" : "Update all metrics" }
    static var purgeMemory: String { language == .chinese ? "清理内存" : "Purge Memory" }
    static var freeInactiveMemory: String { language == .chinese ? "释放非活跃内存" : "Free inactive memory" }
    static var purging: String { language == .chinese ? "清理中..." : "Purging..." }
    static var quit: String { language == .chinese ? "退出" : "Quit" }
    static var quitApplication: String { language == .chinese ? "退出应用程序" : "Quit application" }
    
    // MARK: - Settings Tabs
    static var settings: String { language == .chinese ? "设置" : "Settings" }
    static var display: String { language == .chinese ? "显示" : "Display" }
    static var appearance: String { language == .chinese ? "外观" : "Appearance" }
    static var monitoring: String { language == .chinese ? "监控" : "Monitoring" }
    static var advanced: String { language == .chinese ? "高级" : "Advanced" }
    
    // MARK: - Display Tab
    static var metricsVisibility: String { language == .chinese ? "指标可见性" : "Metrics Visibility" }
    static var showCPU: String { language == .chinese ? "显示 CPU" : "Show CPU" }
    static var showMemory: String { language == .chinese ? "显示内存" : "Show Memory" }
    static var showDisk: String { language == .chinese ? "显示磁盘" : "Show Disk" }
    static var showNetwork: String { language == .chinese ? "显示网络" : "Show Network" }
    
    static var displayMode: String { language == .chinese ? "显示模式" : "Display Mode" }
    static var mode: String { language == .chinese ? "模式：" : "Mode:" }
    static var changesMenubarStyle: String { language == .chinese ? "更改菜单栏显示风格" : "Changes the menubar display style" }
    
    static var iconAndValue: String { language == .chinese ? "图标 + 数值" : "Icon + Value" }
    static var compactText: String { language == .chinese ? "紧凑文本" : "Compact Text" }
    static var graphMode: String { language == .chinese ? "图表模式" : "Graph Mode" }
    static var iconsOnly: String { language == .chinese ? "仅图标" : "Icons Only" }
    
    static var metricOrder: String { language == .chinese ? "指标顺序" : "Metric Order" }
    static var dragToReorder: String { language == .chinese ? "拖动以重新排序指标：" : "Drag to reorder metrics:" }
    
    static var processList: String { language == .chinese ? "进程列表" : "Process List" }
    static var showTopProcesses: String { language == .chinese ? "显示热门进程" : "Show Top Processes" }
    static var sortBy: String { language == .chinese ? "排序方式：" : "Sort by:" }
    static var cpuUsageSort: String { language == .chinese ? "CPU 使用率" : "CPU Usage" }
    static var memoryUsageSort: String { language == .chinese ? "内存使用" : "Memory Usage" }
    static var processName: String { language == .chinese ? "进程名称" : "Process Name" }
    
    // MARK: - Appearance Tab
    static var colorTheme: String { language == .chinese ? "颜色主题" : "Color Theme" }
    static var theme: String { language == .chinese ? "主题：" : "Theme:" }
    static var selectColorScheme: String { language == .chinese ? "选择颜色方案" : "Select color scheme" }
    
    static var systemDefault: String { language == .chinese ? "系统默认" : "System Default" }
    static var monochrome: String { language == .chinese ? "单色" : "Monochrome" }
    static var trafficLight: String { language == .chinese ? "交通灯" : "Traffic Light" }
    static var cool: String { language == .chinese ? "冷色调" : "Cool" }
    static var warm: String { language == .chinese ? "暖色调" : "Warm" }
    
    static var languageLabel: String { language == .chinese ? "语言" : "Language" }
    static var interfaceLanguage: String { language == .chinese ? "界面语言：" : "Interface Language:" }
    static var languageDescription: String { language == .chinese ? "更改应用界面语言" : "Change application interface language" }
    static var restartRequired: String { language == .chinese ? "更改后需重启应用" : "Restart required after change" }
    
    // MARK: - Monitoring Tab
    static var refreshSettings: String { language == .chinese ? "刷新设置" : "Refresh Settings" }
    static var refreshInterval: String { language == .chinese ? "刷新间隔：" : "Refresh Interval:" }
    static var seconds: String { language == .chinese ? "秒" : "seconds" }
    static var refreshDescription: String { language == .chinese ? "监控数据更新频率（1-5 秒）" : "How often metrics are updated (1-5 sec)" }
    
    static var diskPaths: String { language == .chinese ? "磁盘路径" : "Disk Paths" }
    static var selectedDisk: String { language == .chinese ? "选择的磁盘：" : "Selected Disk:" }
    static var scanDisks: String { language == .chinese ? "扫描磁盘" : "Scan Disks" }
    static var scanForNewDisks: String { language == .chinese ? "扫描新挂载的磁盘" : "Scan for newly mounted disks" }
    
    static var capacityUsage: String { language == .chinese ? "容量使用" : "Capacity Usage" }
    static var readWriteSpeed: String { language == .chinese ? "读写速度" : "Read/Write Speed" }
    
    static var networkInterfaces: String { language == .chinese ? "网络接口" : "Network Interfaces" }
    static var autoDetectInterface: String { language == .chinese ? "自动检测活跃网络接口" : "Auto-detect active network interface" }
    
    static var startup: String { language == .chinese ? "启动" : "Startup" }
    static var launchAtLogin: String { language == .chinese ? "登录时启动" : "Launch at Login" }
    
    // MARK: - Advanced Tab
    static var dataRetention: String { language == .chinese ? "数据保留" : "Data Retention" }
    static var historicalDataDuration: String { language == .chinese ? "历史数据时长：" : "Historical Data Duration:" }
    static var minutes: String { language == .chinese ? "分钟" : "minutes" }
    static var durationDescription: String { language == .chinese ? "保存用于图表的历史数据时长" : "How long to keep data for charts" }
    
    static var compactMode: String { language == .chinese ? "紧凑模式" : "Compact Mode" }
    static var useCompactDisplay: String { language == .chinese ? "使用紧凑显示" : "Use compact display" }
    
    static var resetToDefaults: String { language == .chinese ? "恢复默认设置" : "Reset to Defaults" }
    static var restoreDefaults: String { language == .chinese ? "恢复默认设置" : "Restore default settings" }
    
    // MARK: - Memory Purge
    static var memoryPurged: String { language == .chinese ? "内存已清理" : "Memory Purged" }
    static var freed: String { language == .chinese ? "释放了" : "Freed" }
    static var purgeFailed: String { language == .chinese ? "清理失败" : "Purge Failed" }
    
    // MARK: - Language Change Dialog
    static var restartApplicationTitle: String { language == .chinese ? "重启应用？" : "Restart Application?" }
    static var restartApplicationMessage: String { 
        language == .chinese 
            ? "应用需要重启以应用语言更改。是否立即重启？" 
            : "The application needs to restart to apply the language change. Do you want to restart now?"
    }
    static var restartNow: String { language == .chinese ? "立即重启" : "Restart Now" }
    static var willRestartAutomatically: String { language == .chinese ? "✨ 确认后将自动重启" : "✨ Will restart automatically after confirmation" }
}

