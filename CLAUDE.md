# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

**GoGoZzz** - 睡眠时间记录应用，帮助用户培养早睡习惯。

⚠️ **注意**：Flutter 代码位于 `gogozzz/` 子目录下，执行 Flutter 命令需先进入该目录。

## 技术栈

- **框架**：Flutter (Android 优先)
- **状态管理**：Riverpod (flutter_riverpod)
- **数据库**：SQLite (sqflite)
- **路由**：go_router (ShellRoute 结构)
- **分享**：share_plus + screenshot

## 常用命令

```bash
cd gogozzz                     # 进入项目目录
flutter pub get                # 安装依赖
flutter run                    # 调试运行
flutter build apk --release    # 构建 Release APK
flutter analyze                # 静态分析
flutter test                   # 运行测试

# 应用图标更新（修改 assets/logo/ 后执行）
dart run flutter_launcher_icons
```

## 架构概览

```
gogozzz/lib/
├── main.dart, app.dart           # 入口 + 路由 + 主题
├── config/
│   ├── theme.dart                # ThemeData 配置
│   └── theme_colors.dart         # 抽象主题颜色接口 + 深色/浅色实现
├── models/                       # 数据模型 (含动态计算方法)
├── providers/                    # Riverpod 状态管理
├── repositories/                 # 数据访问层 (CRUD)
├── services/                     # 业务逻辑层
├── utils/                        # 工具类
├── screens/                      # 页面
└── widgets/                      # 复用组件
```

### 数据流

```
UI (ref.read/notifier) → Notifier → Service (业务逻辑) → Repository → DatabaseService (SQLite)
```

### Provider 依赖链

```
databaseServiceProvider
    → sleepRepositoryProvider / settingsRepositoryProvider
        → sleepServiceProvider
            → sleepProvider (StateNotifier)
            → monthlyStatsProvider (FutureProvider.family)

settingsRepositoryProvider
    → settingsProvider
        → normalTimeProvider / themeModeProvider / themeColorsProvider
```

### 路由结构

使用 `ShellRoute` + `PageView` 实现底部导航常驻和滑动切换：
- `/` - 首页 (HomeScreen)
- `/stats` - 统计页 (StatsScreen)
- `/settings` - 设置页 (独立页面，无底部导航)

首页与统计页支持**左右滑动切换**，通过 `PageController` 控制。

## 核心设计

### 主题系统

支持深色/浅色双主题，通过 `AppThemeColors` 抽象接口实现：

```dart
// 获取当前主题颜色
final colors = ref.watch(themeColorsProvider);
colors.background      // 背景色
colors.textPrimary     // 主文字色
colors.buttonGradient  // 按钮渐变
```

主题切换：`ref.read(settingsProvider.notifier).updateThemeMode(AppThemeMode.light/dark)`

### 归属日期逻辑

凌晨 00:00-05:59 的打卡记录归属到**前一天**，由 `AppDateUtils.getBelongDateString()` 处理。

### 动态颜色计算

`SleepRecord` 提供动态计算方法，颜色根据当前 `normalTime` 设置实时计算：
- `record.getLevel(normalTime)` - 计算级别 (1-7)
- `record.isLate(normalTime)` - 判断是否熬夜
- `record.getColor(normalTime)` - 获取对应颜色

### 7级颜色阈值

相对于 `normalTime` 的分钟偏移量：`[-40, -25, -10, 10, 25, 40]`

| 偏移范围 | 级别 | 颜色 |
|---------|------|------|
| < -40min | 1 | 深绿 |
| -40 ~ -25 | 2 | 绿色 |
| -25 ~ -10 | 3 | 浅绿 |
| -10 ~ +10 | 4 | 黄绿 (正常) |
| +10 ~ +25 | 5 | 黄色 |
| +25 ~ +40 | 6 | 橙色 |
| > +40min | 7 | 红色 (熬夜) |

### ClockButton 状态模式

使用 sealed class 实现三态：
- `ClockButtonCanClock` - 可打卡
- `ClockButtonClocked(time, normalTime)` - 已打卡
- `ClockButtonDisabled` - 时间外禁用

### 补卡功能

支持为过去的日期补录睡眠记录，限制条件：
- 只能补录**过去**的日期（今天及未来不可补）
- 睡眠时间范围：**18:00 - 次日 05:59**
- 每个日期只能有一条记录

调用方式：`ref.read(sleepProvider.notifier).addMakeupRecord(date: '2026-02-21', time: '23:30')`

UI 入口：`SleepRecordBottomSheet.show()` 点击未打卡日期后显示补卡按钮。

## 数据库表

### sleep_records

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键自增 |
| date | TEXT | 归属日期 YYYY-MM-DD (唯一) |
| time | TEXT | 睡觉时间 HH:mm |
| level | INTEGER | 缓存级别 (实际使用动态计算) |
| created_at | TEXT | 创建时间 ISO8601 |

### user_settings

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 (固定为1) |
| normal_time | TEXT | 正常睡觉时间，默认 23:00 |
| theme_mode | TEXT | 主题模式，'dark' 或 'light' |
| updated_at | TEXT | 更新时间 |

## 关键文件

| 文件 | 职责 |
|------|------|
| `config/theme_colors.dart` | 主题颜色抽象接口 + 深色/浅色实现 + 7级颜色定义 |
| `config/theme.dart` | ThemeData 配置，向后兼容的 const 颜色 |
| `services/database_service.dart` | SQLite 单例，表结构定义 |
| `services/sleep_service.dart` | 打卡业务逻辑 (时间验证、level 计算、补卡) |
| `services/share_service.dart` | 截图分享功能 |
| `utils/date_utils.dart` | 日期格式化、归属日期计算、时间偏移 |
| `utils/level_utils.dart` | 级别计算、打卡时间验证 (18:00-06:00) |
| `utils/constants.dart` | 应用常量 (表名、时间范围、级别偏移量) |
| `widgets/clock_button.dart` | 打卡按钮 (动画 + sealed class 状态模式) |
| `widgets/calendar_heatmap.dart` | 月度热力图 |
| `widgets/sleep_record_bottom_sheet.dart` | 记录详情抽屉 + 补卡时间选择器 |
| `providers/sleep_provider.dart` | 状态管理 (打卡、补卡、月度统计) |
| `providers/settings_provider.dart` | 设置状态管理 (normalTime、主题) |

## 开发注意事项

- **代码注释语言**：与代码库保持一致（当前为中文）
- **测试**：目前仅有默认 `widget_test.dart`，暂无单元测试覆盖
- **代码生成**：配置了 `riverpod_generator` 和 `build_runner`，但当前未使用生成的代码
