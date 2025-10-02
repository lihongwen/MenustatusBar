# MenubarStatus - macOS 系统监控菜单栏应用

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13.0+-blue.svg" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/github/v/release/lihongwen/MenustatusBar" alt="Release">
  <img src="https://img.shields.io/github/downloads/lihongwen/MenustatusBar/total" alt="Downloads">
  <img src="https://img.shields.io/badge/Tests-115%20passing-brightgreen.svg" alt="Tests">
  <img src="https://img.shields.io/badge/Coverage-100%25-success.svg" alt="Coverage">
</p>

一款现代化、功能丰富的 macOS 菜单栏系统监控工具，实时显示 CPU、内存、磁盘和网络使用情况。支持 5 种颜色主题、4 种显示模式，完整中英文双语支持。

## ✨ 特性

- 🚀 **轻量高效**: CPU 占用 < 2%, 内存占用 < 30MB
- 📊 **实时监控**: 1-10秒可配置刷新间隔，支持实时数据刷新
- 🎨 **5种颜色主题**: 系统默认 🟢🟡🔴 / 单色 ⚪⚫⬛ / 交通灯 / 冷色调 🔵🟣 / 暖色调 🟡🟠
- 📱 **4种显示模式**: 图标+数值 / 紧凑文本 / 图表模式 / 仅图标
- 🌐 **多语言支持**: 完整的中英文双语支持，一键切换
- 📋 **进程管理**: 显示前5个资源占用最高的进程
- 🌓 **主题适配**: 自动支持浅色/深色模式
- ⚙️ **灵活配置**: 自由选择显示的监控项目和顺序
- 💾 **实时保存**: 所有设置即改即存，无需手动保存

## 📦 监控项目

### CPU 监控
- 总体使用率 (%)
- 用户态/系统态分离
- 空闲百分比

### 内存监控
- 总内存容量
- 已用/可用内存
- 缓存内存
- 使用率百分比

### 磁盘监控
- 支持多磁盘选择
- 总容量/已用/可用空间
- 使用率百分比
- **两种显示模式**: 容量使用 / 读写速度
- 自动磁盘发现

### 网络监控
- 实时上传/下载速率
- 自动单位转换 (B/s, KB/s, MB/s)
- 累计流量统计
- 聚合所有网络接口

## 🛠️ 技术栈

- **语言**: Swift 5.9+
- **框架**: SwiftUI, AppKit
- **最低系统**: macOS 13.0 (Ventura)
- **架构**: MVVM
- **并发**: Swift Concurrency (async/await)
- **测试**: XCTest (115 tests, 100% passing)

## 📥 安装

### 方式 1: DMG 安装（推荐）

1. 前往 [**Releases 页面**](https://github.com/lihongwen/MenustatusBar/releases/latest)
2. 下载最新版本的 **MenubarStatus-v1.0.0.dmg**
3. 双击打开 DMG 文件
4. 拖拽 `MenubarStatus.app` 到 `Applications` 文件夹
5. 在"启动台"或"应用程序"文件夹中找到并启动

### 方式 2: 直接下载

[![下载 DMG](https://img.shields.io/badge/下载-MenubarStatus%20v1.0.0-blue?style=for-the-badge&logo=apple)](https://github.com/lihongwen/MenustatusBar/releases/download/v1.0.0/MenubarStatus-v1.0.0.dmg)

### 方式 3: 从源码构建

```bash
# 1. 克隆仓库
git clone https://github.com/lihongwen/MenustatusBar.git
cd MenustatusBar/MenubarStatus

# 2. 打开 Xcode 项目
open MenubarStatus.xcodeproj

# 3. 选择 MenubarStatus scheme
# 4. 点击 Run (⌘R)
```

## 🎯 使用指南

### 首次启动

1. 应用启动后，菜单栏会显示系统监控图标
2. 默认显示 CPU 和内存使用情况
3. 点击图标查看详细信息

### 菜单栏显示

菜单栏文本格式：
```
CPU 45% | Mem 8.0GB
```

### 下拉菜单

点击菜单栏图标，显示详细信息：

```
System Monitor
Updated: 14:30:45

CPU Usage: 45.5%
  User: 30.0%
  System: 15.5%
  Idle: 54.5%

Memory: 8.0GB / 16.0GB (50.0%)
  Free: 8.0GB

Disk (Macintosh HD): 250.0GB / 500.0GB (50.0%)
  Free: 250.0GB

Network:
  ↑ Upload: 1.0 KB/s
  ↓ Download: 2.0 KB/s
  Total ↑: 10.00 KB
  Total ↓: 20.00 KB

────────────────
⚙️ Settings...
⏻ Quit
```

## ⚙️ 设置选项

### 显示设置
- ✅ **显示指标**: 自由选择显示 CPU/内存/磁盘/网络
- ✅ **显示模式**: 4 种显示风格
  - **图标 + 数值**: 完整的指标信息
  - **紧凑文本**: 节省菜单栏空间
  - **图表模式**: 实时动态图表显示 (▁▃▅▇)
  - **仅图标**: 极简主义设计
- ✅ **指标顺序**: 拖拽调整指标显示顺序
- ✅ **进程列表**: 显示前 5 个资源占用最高的进程

> ⚠️ 至少需要启用一个监控项目

### 外观设置
- 🎨 **颜色主题**: 5 种精心设计的主题
  - **系统默认**: 经典绿黄红配色 🟢🟡🔴
  - **单色**: 简约灰度设计 ⚪⚫⬛
  - **交通灯**: 清晰的信号灯配色 🟢🟡🔴
  - **冷色调**: 蓝紫红渐变 🔵🟣🔴
  - **暖色调**: 黄橙红渐变 🟡🟠🔴
- 🌐 **界面语言**: 中文 / English
- 💫 **紧凑模式**: 使用更短的文本格式

### 监控配置
- **刷新频率**: 1-10 秒 (默认: 2秒)
  - 较低值：更实时，略微增加资源占用
  - 较高值：降低资源占用，更新较慢
- **磁盘监控**: 选择要监控的磁盘
- **磁盘显示**: 容量使用 / 读写速度

### 高级设置
- **开机启动**: 开机自动启动 _(macOS 13+)_
- **重置设置**: 恢复默认设置

## 🏗️ 项目结构

```
MenubarStatus/
├── Models/                 # 数据模型
│   ├── CPUMetrics.swift
│   ├── MemoryMetrics.swift
│   ├── DiskMetrics.swift
│   ├── NetworkMetrics.swift
│   ├── SystemMetrics.swift
│   └── AppSettings.swift
├── Services/               # 系统监控服务
│   ├── CPUMonitor.swift    # mach kernel APIs
│   ├── MemoryMonitor.swift # host_statistics64
│   ├── DiskMonitor.swift   # FileManager
│   ├── NetworkMonitor.swift # getifaddrs
│   └── SystemMonitor.swift # 协调器
├── ViewModels/             # 业务逻辑层
│   ├── MenuBarViewModel.swift
│   └── SettingsViewModel.swift
├── Views/                  # UI 层
│   ├── MenuBarView.swift
│   └── SettingsView.swift
└── MenubarStatusApp.swift  # App 入口

Tests/
├── Models/                 # 48 tests
├── Services/               # 37 tests
├── ViewModels/             # 14 tests
├── Integration/            # 11 tests
└── Performance/            # 5 tests
```

## 🧪 测试

项目拥有完整的测试覆盖：

```bash
# 运行所有测试
xcodebuild test \
  -project MenubarStatus.xcodeproj \
  -scheme MenubarStatus \
  -destination 'platform=macOS'

# 测试统计
Total: 115 tests
✅ Passed: 115
❌ Failed: 0
Coverage: 100%
```

### 测试分层
- **单元测试**: 模型、服务、ViewModel (99 tests)
- **集成测试**: 端到端流程、持久化 (11 tests)
- **性能测试**: 内存、响应时间、稳定性 (5 tests)

## 📊 性能指标

经过严格测试，性能表现优异：

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| CPU 占用 | < 2% | ~0.5-1% | ✅ |
| 内存占用 | < 50MB | ~20-30MB | ✅ |
| 刷新周期 | < 100ms | ~10-30ms | ✅ |
| CPU 监控 | < 20ms | ~5ms | ✅ |
| 内存监控 | < 10ms | ~2ms | ✅ |
| 磁盘监控 | < 50ms | ~10ms | ✅ |
| 网络监控 | < 30ms | ~5ms | ✅ |

## 🔧 开发

### 环境要求

- Xcode 15.0+
- macOS 13.0+ (开发机)
- Swift 5.9+

### 构建

```bash
# Debug 构建
xcodebuild \
  -project MenubarStatus.xcodeproj \
  -scheme MenubarStatus \
  -configuration Debug

# Release 构建
xcodebuild \
  -project MenubarStatus.xcodeproj \
  -scheme MenubarStatus \
  -configuration Release
```

### 调试

1. 在 Xcode 中打开项目
2. 设置断点
3. Run (⌘R)
4. 应用会显示在菜单栏

## 🐛 故障排除

### 应用不显示在菜单栏
- 确保使用 macOS 13.0 或更高版本
- 检查系统偏好设置 > 控制中心，确保未隐藏菜单栏图标
- 重启应用

### 监控数据不更新
- 检查设置中的刷新间隔
- 确保至少启用了一个监控项目
- 查看控制台日志 (Console.app)

### 磁盘不显示
- 点击"Refresh Disk List"刷新磁盘列表
- 确保磁盘已正确挂载
- 选择系统磁盘 "/" 作为默认选项

### 设置不保存
- 确保应用有权限访问 UserDefaults
- 检查 ~/Library/Preferences/ 下的 plist 文件
- 重置设置：点击"Reset to Defaults"

### Launch at Login 不工作
- macOS 13+: 系统设置 > 通用 > 登录项
- 手动添加应用到登录项
- 确保应用已授予必要权限

## 📝 待办事项

- [ ] App Store 发布
- [x] ✅ 添加应用图标
- [x] ✅ 图表可视化（图表模式）
- [x] ✅ 多语言支持（中英文）
- [x] ✅ 颜色主题系统
- [x] ✅ 进程列表显示
- [ ] 支持更多监控项（GPU、温度）
- [ ] 导出历史数据
- [ ] 通知提醒功能

## 🤝 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献指南

- 遵循现有代码风格
- 添加单元测试
- 更新文档
- 确保所有测试通过

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- macOS 系统 API 文档
- SwiftUI 和 AppKit 框架
- XCTest 测试框架

## 📮 联系方式

- 作者: 李宏文
- 项目主页: [GitHub](https://github.com/lihongwen/MenustatusBar)
- 问题反馈: [Issues](https://github.com/lihongwen/MenustatusBar/issues)
- 下载地址: [Releases](https://github.com/lihongwen/MenustatusBar/releases)

---

## 📝 更新日志

### v1.0.0 (2025-10-02)

**新增功能**:
- ✅ 5 种颜色主题系统
- ✅ 4 种显示模式（图标+数值/紧凑/图表/仅图标）
- ✅ 进程列表显示（前 5 个高占用进程）
- ✅ 中英文双语支持
- ✅ 磁盘双模式显示（容量/速度）
- ✅ 现代化 UI 设计
- ✅ 设置实时保存

**技术优化**:
- ✅ 主题颜色应用到 MenuBar 图标
- ✅ 下拉菜单高度自适应
- ✅ 图表模式实时数据
- ✅ 完整的本地化支持

[查看完整更新日志](https://github.com/lihongwen/MenustatusBar/releases)

---

**Made with ❤️ using Swift and SwiftUI**

