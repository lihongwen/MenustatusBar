# Feature Specification: Modern UI & Compact Menubar Display Enhancement

**Feature Branch**: `002-ui-menubar-ui`  
**Created**: October 2, 2025  
**Status**: Draft  
**Input**: User description: "请你根据我目前的代码 帮我完善项目的整体UI和menubar的显示，我的想法是UI需要变的更加好看和现代一些，然后menubar的显示要求简洁一些，即以更少的所占的内容来显示更多的内容！同时我希望，你再添加一些好的意见和功能！"

## Execution Flow (main)
```
1. Parse user description from Input
   → Feature request: Improve UI aesthetics and menubar compactness
2. Extract key concepts from description
   → Actors: macOS users monitoring system performance
   → Actions: View metrics, customize display, manage processes, free memory
   → Data: System metrics (CPU, memory, disk, network), processes, disk health
   → Constraints: Limited menubar space, real-time updates
3. For each unclear aspect:
   → [RESOLVED via clarification]: User wants top processes, memory cleaning, multi-disk, disk health
   → [RESOLVED via clarification]: User does NOT want temperature, battery, alerts, export features
   → [RESOLVED]: Color coding thresholds determined
4. Fill User Scenarios & Testing section
   → Primary flow: User installs app → sees compact metrics → clicks for details → manages system
5. Generate Functional Requirements
   → All requirements testable and implementation-ready
6. Identify Key Entities
   → Metrics display configuration, color themes, process info, disk info
7. Run Review Checklist
   → All sections completed, no implementation details
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## Clarifications

### Session 2025-10-02

- Q: 进程管理功能 - 您觉得在下拉菜单中添加"进程管理"功能怎么样？ → A: 显示资源占用 TOP 5 进程，可在设置界面选择是否开启
- Q: 快捷操作功能 - 您觉得添加"快捷操作"功能怎么样？ → A: 一键清理内存功能
- Q: 网络监控增强 - 目前网络监控只显示上传/下载速度，您想要增强网络监控功能吗？ → A: 保持现状，只显示上传下载速度
- Q: 磁盘监控增强 - 目前磁盘监控显示容量和读写速度，您想要增强磁盘监控功能吗？ → A: 多磁盘同时监控 + 磁盘健康状态
- Q: 菜单栏点击行为 - 关于点击菜单栏图标的交互方式，您更喜欢哪种？ → A: 保持当前左键点击方式，重点改进下拉面板的视觉设计

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a macOS power user, I want to monitor my system's performance at a glance from the menubar without it taking up too much space, while having access to detailed information when I need it. The interface should be modern, visually appealing, and provide actionable insights about my system's health.

### Acceptance Scenarios

1. **Given** the app is running, **When** I look at the menubar, **Then** I see compact metrics displayed with icons and color-coded values that show my system status at a glance (occupying ≤50% less space than current text-only display)

2. **Given** CPU usage is above 80%, **When** I view the menubar, **Then** the CPU metric is displayed in red/warning color to alert me

3. **Given** I click on the menubar icon, **When** the dropdown opens, **Then** I see a modern dashboard with visual charts, progress bars, and detailed metrics organized in a clean card-based layout

4. **Given** I want to customize the display, **When** I open settings, **Then** I can choose between multiple display modes (icons-only, compact, detailed, graph), reorder metrics, and configure color themes

5. **Given** I enable "Show Top Processes" in settings, **When** I open the dropdown, **Then** I see the top 5 processes consuming the most CPU/Memory with their usage percentages and ability to terminate them

6. **Given** my system is running low on free memory, **When** I click "Free Memory" in the dropdown, **Then** the system clears inactive memory and shows the amount of memory freed

7. **Given** I have multiple disks connected, **When** I view the dropdown, **Then** I see separate cards for each mounted disk (internal and external) with their respective usage metrics

8. **Given** I want to monitor disk health, **When** I view a disk card in the dropdown, **Then** I see S.M.A.R.T. health status, total hours used, and health indicator (good/warning/critical)

9. **Given** I want historical context, **When** I view the dropdown, **Then** I see mini sparkline graphs showing the last 60 seconds of trend data for each metric

10. **Given** I have limited menubar space, **When** I enable "auto-hide low metrics" mode, **Then** only metrics above 50% usage are shown in the menubar

### Edge Cases
- What happens when all metrics are disabled? → System must prevent this and keep at least one metric enabled
- How does the system handle when menubar space is extremely limited? → Graceful truncation with ellipsis, prioritizing enabled metrics
- What happens when trying to terminate a system-critical process? → Show warning dialog, prevent termination of protected processes
- What happens when S.M.A.R.T. data is unavailable for a disk? → Show "Not Available" instead of health status, no errors
- What happens when a disk is unmounted while viewing? → Card gracefully disappears with smooth animation, no crash
- How does dark/light mode transition affect color coding? → Colors automatically adapt to maintain readability in both modes
- What happens when network interfaces are disconnected? → Show "N/A" or "---" instead of 0 bytes, prevent confusion
- What happens when memory cleaning fails or has no effect? → Show error message explaining why (e.g., "No inactive memory to free")

---

## Requirements *(mandatory)*

### Functional Requirements - Menubar Display

- **FR-001**: System MUST support multiple display modes selectable by user:
  - **Icon + Value**: SF Symbol icon followed by numeric value (e.g., "⚡ 45%")
  - **Compact Text**: Abbreviated text with symbols (e.g., "CPU 45%")
  - **Graph Mode**: Tiny inline sparkline showing trend
  - **Icons Only**: Just colored SF Symbol icons (hoverable for tooltip)

- **FR-002**: System MUST use color-coded visual indicators for metric values:
  - Green: 0-60% usage (healthy)
  - Yellow: 61-80% usage (moderate)
  - Red: 81-100% usage (high/critical)
  - Colors MUST adapt to system dark/light mode for optimal contrast

- **FR-003**: System MUST allow users to reorder metrics in the menubar via drag-and-drop in settings

- **FR-004**: System MUST support "auto-hide" mode where metrics below a user-defined threshold (default 50%) are hidden from menubar to save space

- **FR-005**: System MUST display menubar metrics in order of user priority (left to right based on settings)

### Functional Requirements - Dropdown Dashboard

- **FR-006**: System MUST display dropdown content in a modern card-based layout with:
  - Header card: System name, uptime, current time
  - Metric cards: One card per metric (CPU, Memory, Disk(s), Network)
  - Process card: Top 5 resource-consuming processes (optional, toggled in settings)
  - Action card: Quick action buttons and utilities

- **FR-007**: Each metric card MUST show:
  - Large percentage/value display
  - Horizontal progress bar with gradient color
  - Detailed breakdown (e.g., CPU: user/system/idle)
  - 60-second mini sparkline chart showing historical trend
  - Last updated timestamp

- **FR-008**: System MUST support expandable/collapsible metric cards to show additional details on demand

- **FR-009**: Dashboard MUST include quick action buttons:
  - "Free Memory" - clear inactive memory and show amount freed
  - "Activity Monitor" - launch system Activity Monitor
  - "Refresh Now" - force immediate metric update
  - "Copy Stats" - copy current metrics to clipboard
  - "Settings" - open settings window
  - "Quit" - exit application

- **FR-010**: System MUST display smooth animated transitions when metric values change (avoiding jarring jumps)

### Functional Requirements - Visual Enhancements

- **FR-011**: System MUST use SF Symbols icons consistently throughout the interface for:
  - CPU: bolt.fill or cpu.fill
  - Memory: memorychip.fill
  - Disk: internaldrive.fill
  - Network: network or antenna.radiowaves.left.and.right
  - Processes: list.bullet.rectangle.portrait.fill
  - Health/Status: checkmark.shield.fill (good), exclamationmark.triangle.fill (warning)

- **FR-012**: System MUST apply modern macOS design patterns:
  - Translucent backgrounds (vibrancy effects)
  - Rounded corners on all cards
  - Subtle drop shadows for depth
  - Proper spacing and padding (8pt, 12pt, 16pt grid)

- **FR-013**: Settings window MUST be reorganized into tabbed sections:
  - "Display" tab: Metrics visibility, display mode, ordering, show top processes toggle
  - "Appearance" tab: Color themes, icon style, compact mode
  - "Monitoring" tab: Refresh interval, thresholds
  - "Advanced" tab: Disk selection, network interfaces, launch options, memory management

- **FR-014**: System MUST provide preset color themes selectable in settings:
  - System Default (adapts to macOS accent color)
  - Monochrome (grayscale only)
  - Traffic Light (red/yellow/green)
  - Cool (blue/cyan gradients)
  - Warm (orange/red gradients)

### Functional Requirements - New Features

- **FR-015**: System MUST display top resource-consuming processes (user-toggleable in settings):
  - Show top 5 processes by CPU or Memory usage (user selectable)
  - Display process name, icon (if available), and resource percentage
  - Provide "Terminate" button for each process with confirmation dialog
  - Prevent termination of system-critical processes (kernel, launchd, etc.)
  - Update process list with same refresh interval as metrics
  - Toggle visibility in "Display" settings tab

- **FR-016**: System MUST provide memory management functionality:
  - "Free Memory" action button in dropdown dashboard
  - Execute memory purge to clear inactive memory
  - Display before/after memory statistics (e.g., "Freed 2.3 GB")
  - Show progress indicator during memory clearing operation
  - Handle errors gracefully when no memory can be freed

- **FR-017**: System MUST monitor multiple disks simultaneously:
  - Automatically detect all mounted volumes (internal and external)
  - Display separate metric card for each disk in dropdown
  - Show disk name, mount point, capacity, and usage for each
  - Each disk card includes individual sparkline chart
  - Gracefully handle disk mounting/unmounting events with smooth animations

- **FR-018**: System MUST display disk health information:
  - Show S.M.A.R.T. health status for each disk (Good, Warning, Critical)
  - Display total power-on hours for each disk
  - Show read/write error counts if available
  - Display health indicator icon with color coding (green/yellow/red)
  - Gracefully handle when S.M.A.R.T. data is unavailable ("Not Available")

- **FR-019**: System MUST track and display historical trend data:
  - Last 60 seconds of data shown as mini sparkline chart in each metric card
  - Sparklines update in real-time with smooth animations
  - Color-coded sparklines matching current health status (green/yellow/red)
  - Data cleared on app restart (not persisted long-term)

- **FR-020**: System MUST provide keyboard shortcuts for common actions:
  - ⌘, (Cmd+Comma): Open Settings
  - ⌘R (Cmd+R): Refresh metrics immediately
  - ⌘Q (Cmd+Q): Quit application
  - Shortcuts shown in menu items

### Functional Requirements - Performance & Polish

- **FR-021**: Menubar text width MUST not exceed 200 points in total width, truncating with "..." if necessary

- **FR-022**: Dropdown window MUST be resizable within bounds:
  - Minimum: 320x400 points
  - Maximum: 600x800 points
  - User's last used size is remembered

- **FR-023**: System MUST animate metric value changes with smooth transitions (200ms duration)

- **FR-024**: System MUST support hover tooltips on all menubar metrics showing:
  - Full metric name
  - Current exact value (not rounded)
  - Last update time

- **FR-025**: System MUST provide visual feedback for all interactive elements:
  - Hover state: subtle background highlight
  - Click state: slight scale down animation
  - Disabled state: 50% opacity

### Key Entities *(data involved)*

- **DisplayConfiguration**: User preferences for how metrics appear
  - Display mode (icon+value, compact, graph, icons-only)
  - Enabled metrics and their order
  - Auto-hide threshold
  - Color theme selection
  - Show top processes toggle (on/off)
  - Process sorting preference (CPU or Memory)

- **MetricThreshold**: Defines when a metric shows warning/critical states
  - Low threshold (0-60%, green)
  - Medium threshold (61-80%, yellow)  
  - High threshold (81-100%, red)
  - User-customizable per metric type

- **ProcessInfo**: Information about running processes
  - Process ID (PID)
  - Process name
  - Application icon
  - CPU usage percentage
  - Memory usage percentage
  - Terminable status (boolean)

- **DiskInfo**: Information about mounted disks
  - Volume path and name
  - Total capacity in bytes
  - Used and free space in bytes
  - S.M.A.R.T. health status
  - Power-on hours
  - Read/write error counts
  - Mount status (mounted/unmounted)

- **HistoricalDataPoint**: Time-series data for sparkline charts
  - Timestamp
  - Metric type
  - Value
  - Retained for last 60 seconds only

- **ColorTheme**: Visual styling configuration
  - Theme name
  - Color values for low/medium/high states
  - Icon style preference
  - Background style (solid, gradient, translucent)

- **MetricCard**: Visual representation in dropdown
  - Metric type and current value
  - Progress bar representation
  - Sparkline chart data (last 60s)
  - Expanded/collapsed state
  - Detailed breakdown values

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous  
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked (and resolved)
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---

## Success Metrics

The feature will be considered successful when:

1. **Space Efficiency**: Menubar display occupies ≤200 points total width while showing same or more information
2. **Visual Appeal**: User feedback rates new UI as "modern" and "visually appealing" (subjective but trackable via user testing)
3. **Information Density**: Dropdown shows at least 3 additional data points (sparklines, process list, disk health, multiple disks) compared to current version
4. **Customization**: Users can choose from at least 4 display modes and 5 color themes
5. **Feature Adoption**: At least 1 new feature (top processes, memory cleaning, or disk health) is used by >30% of users within first week
6. **Performance**: UI remains responsive with <16ms frame time even with all features enabled (including process monitoring)
7. **Accessibility**: All interactive elements have proper hover states and tooltips
8. **Cross-theme**: UI maintains readability and proper contrast in both light and dark modes
9. **Utility**: Memory cleaning feature successfully frees memory in >80% of attempts
10. **Reliability**: Multi-disk monitoring handles mount/unmount events without crashes or errors

---

## Out of Scope

The following are explicitly NOT part of this feature:

- Cloud sync of settings across devices
- Historical data persistence beyond 60 seconds (no 24-hour history)
- Third-party plugin system
- Custom metric creation
- Advanced scripting or automation
- Integration with external monitoring services
- Multi-language localization (English only for now)
- Accessibility features beyond standard macOS support
- GPU usage monitoring
- Per-app network monitoring (only overall network speed)
- Temperature monitoring (sensors)
- Battery monitoring
- Alert/notification system
- Export/share metrics functionality

---

## Dependencies & Assumptions

### Dependencies
- Requires macOS 13.0+ for modern SF Symbols and vibrancy effects
- Requires process enumeration APIs for top process monitoring
- Requires disk I/O APIs for S.M.A.R.T. data access
- Requires elevated privileges for memory purge operations (handled via system calls)
- Requires disk management APIs for multi-disk monitoring

### Assumptions
- Users understand basic system monitoring concepts (CPU %, memory usage, etc.)
- Users have sufficient permissions to read system metrics and process information
- System provides accurate S.M.A.R.T. data via standard macOS APIs
- Menubar space is available (app may be hidden if too many menubar items exist)
- Users prefer visual over text-heavy interfaces for quick scanning
- Users will use process termination feature responsibly (with confirmation dialogs)
- Multiple disks may be mounted/unmounted during app runtime

---

## Future Enhancements (Post-MVP)

Ideas to consider for future iterations:

1. **Menubar Graphs**: Replace text with tiny bar graphs showing real-time activity
2. **Extended Historical Data**: 24-hour history view with detailed charts
3. **Per-App Network Monitoring**: Show which apps are using network bandwidth
4. **Temperature Monitoring**: CPU/GPU temperature sensors with alerts
5. **Battery Monitoring**: Battery health and time remaining for MacBooks
6. **Smart Alerts**: Notifications for critical system conditions
7. **Export/Share**: Export metrics to clipboard or share via macOS share sheet
8. **Presets**: One-click preset configurations (Developer, Designer, Gamer)
9. **Custom Themes**: User-created themes with color pickers
10. **Widgets**: macOS Notification Center widget support
11. **Shortcuts**: Siri Shortcuts integration
12. **Process Details**: Click on process to see detailed resource breakdown
13. **Network Interface Selection**: Monitor specific network interfaces
14. **Disk Space Analyzer**: Deep dive into what's using disk space
15. **Automatic Memory Management**: Auto-clean memory when threshold reached

---
