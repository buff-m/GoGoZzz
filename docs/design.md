# GoGoZzz 详细设计文档

## 文档信息

| 项目 | 内容 |
|------|------|
| 应用名称 | GoGoZzz |
| 版本 | V1.0 |
| 状态 | 规划 |
| 创建日期 | 2026-02-19 |

---

## 1. 技术架构设计

### 1.1 整体架构

采用 **Clean Architecture** 原则，将应用分为三层：

```
┌─────────────────────────────────────┐
│           Presentation Layer        │
│  (Screens, Widgets, Providers)      │
├─────────────────────────────────────┤
│             Domain Layer             │
│   (Models, Services, Business Logic)│
├─────────────────────────────────────┤
│              Data Layer             │
│   (Database, Repositories)          │
└─────────────────────────────────────┘
```

### 1.2 目录结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # MaterialApp 配置
├── config/
│   └── theme.dart            # 主题配置
├── models/                   # 数据模型
│   ├── sleep_record.dart     # 打卡记录模型
│   └── user_settings.dart    # 用户设置模型
├── services/                 # 业务逻辑服务
│   ├── database_service.dart # SQLite 数据库服务
│   ├── sleep_service.dart    # 打卡业务逻辑
│   └── share_service.dart    # 分享服务
├── repositories/             # 数据仓库
│   ├── sleep_repository.dart # 打卡记录仓库
│   └── settings_repository.dart # 设置仓库
├── providers/                # 状态管理
│   ├── sleep_provider.dart   # 打卡状态管理
│   └── settings_provider.dart # 设置状态管理
├── screens/                  # 页面
│   ├── home_screen.dart      # 打卡首页
│   ├── stats_screen.dart     # 统计页面
│   └── settings_screen.dart  # 设置页面
├── widgets/                  # 复用组件
│   ├── clock_button.dart     # 打卡按钮
│   ├── week_view.dart        # 最近7天视图
│   ├── calendar_heatmap.dart # 日历热力图
│   ├── stat_card.dart        # 统计卡片
│   ├── trend_chart.dart      # 趋势对比组件
│   └── bottom_nav.dart       # 底部导航
└── utils/                    # 工具函数
    ├── date_utils.dart       # 日期工具
    ├── level_utils.dart      # 颜色级别计算
    └── constants.dart        # 常量定义
```

### 1.3 技术选型

| 类别 | 技术方案 | 版本 |
|------|----------|------|
| 框架 | Flutter | 3.x |
| 语言 | Dart | 3.x |
| 状态管理 | Riverpod | ^2.4.0 |
| 本地存储 | sqflite | ^2.3.0 |
| 分享 | share_plus | ^7.2.0 |
| 截图 | screenshot | ^2.1.0 |
| 时间选择 | flutter_time_picker | 内置 |

---

## 2. 界面设计

### 2.1 页面结构

采用 **底部 Tab 导航**，两个主页面：

```
┌──────────────────────────────┐
│         Status Bar           │
├──────────────────────────────┤
│                              │
│     [Clock Button Area]      │  ← 首页
│                              │
│     [Week View - 7 days]     │
│                              │
├──────────────────────────────┤
│    [Home]      [Stats]       │  ← Bottom Nav
└──────────────────────────────┘
```

### 2.2 首页 (Home Screen)

#### 2.2.1 打卡按钮区域

| 元素 | 设计规范 |
|------|----------|
| 容器尺寸 | 200x200 px |
| 形状 | 圆形 (borderRadius: 100) |
| 背景 | 渐变 #1a1a1a → #0d0d0d |
| 边框 | 2px solid #2a2a2a |
| 阴影 | 0 10px 40px rgba(0,0,0,0.4) |

**状态 1：未打卡**
- 图标：🌙 (48px)
- 文字："点击打卡" (#888)
- 时间显示：--:--

**状态 2：已打卡**
- 边框色：#4ade80 (对应级别颜色)
- 背景渐变：#0d1f0d → #061406
- 文字："已入睡" (绿色)
- 时间显示：实际打卡时间 (绿色)

**状态 3：不可打卡时段**
- 边框色：#333333 (灰色)
- 背景：纯色 #0d0d0d
- 文字：时段提示 (如"仅18:00-06:00可打卡")

#### 2.2.2 最近7天视图

| 元素 | 设计规范 |
|------|----------|
| 布局 | 水平排列，7列均分 |
| 日期标签 | 11px, #666 |
| 圆角方块 | 32x32 px, borderRadius: 8px |
| 间距 | 8px |

**星期显示**：周一到周日 (一 二 三 四 五 六 日)

### 2.3 统计页面 (Stats Screen)

#### 2.3.1 月份选择器

| 元素 | 设计规范 |
|------|----------|
| 布局 | 左侧箭头 + 年月 + 右侧箭头 |
| 按钮 | 20px, 无边框, #666 |
| 年月格式 | "2026年2月" |

#### 2.3.2 日历热力图

| 元素 | 设计规范 |
|------|----------|
| 背景 | #0d0d0d, borderRadius: 16px |
| 内边距 | 20px |
| 网格 | 7列, gap: 6px |
| 日期格 | aspect-ratio: 1, borderRadius: 6px |
| 星期头 | 11px, #666 |

**空日期格**（非当月）：透明背景

#### 2.3.3 统计卡片

两个卡片并排：
- 熬夜天数（7级）- 红色数字
- 打卡天数 - 白色数字

#### 2.3.4 极值记录

| 元素 | 设计规范 |
|------|----------|
| 背景 | #0d0d0d, borderRadius: 12px |
| 内边距 | 16px |
| 间隔线 | 1px solid #1a1a1a |

- 最早记录：🌅 图标 + "本月最早" + "2月1日 21:30"
- 最晚记录：🌙 图标 + "本月最晚" + "2月12日 00:15"

#### 2.3.5 趋势对比

| 元素 | 设计规范 |
|------|----------|
| 背景 | #0d0d0d, borderRadius: 12px |
| 布局 | 左月 - 箭头 - 右月 |
| 进步箭头 | ↓ 绿色 (#22c55e) |
| 退步箭头 | ↑ 红色 (#ef4444) |

### 2.4 颜色系统

#### 2.4.1 七级颜色（设定23:00为例）

| 级别 | 颜色名称 | 色值 | 时间范围 |
|:---:|:---:|:---:|---|
| 1 | 深绿 | #15803d | < 22:20 |
| 2 | 绿色 | #22c55e | 22:20 ~ 22:35 |
| 3 | 浅绿 | #4ade80 | 22:35 ~ 22:50 |
| 4 | 黄绿色 | #a3e635 | 22:50 ~ 23:10 (正常) |
| 5 | 黄色 | #eab308 | 23:10 ~ 23:25 |
| 6 | 橙色 | #f97316 | 23:25 ~ 23:40 |
| 7 | 红色 | #ef4444 | > 23:40 (熬夜) |

**特殊颜色**：
- 未打卡：#FFFFFF (白色)
- 禁用状态：#333333 (灰色)
- 背景：#111111, #0d0d0d

#### 2.4.2 颜色计算公式

```
offset = 实际时间 - 设定时间(分钟)

if offset < -40:      level = 1  (深绿)
elif offset < -25:    level = 2  (绿色)
elif offset < -10:    level = 3  (浅绿)
elif offset < 10:     level = 4  (黄绿-正常)
elif offset < 25:     level = 5  (黄色)
elif offset < 40:     level = 6  (橙色)
else:                 level = 7  (红色-熬夜)
```

### 2.5 设置页面 (Settings Screen)

从首页右上角入口进入：

| 元素 | 设计规范 |
|------|----------|
| 入口按钮 | 首页右上角，设置图标 ⚙️ |
| 布局 | 列表形式 |
| 正常时间选择 | 时间选择器 (18:00 - 次日04:00) |
| 默认值 | 23:00 |

---

## 3. 数据库设计

### 3.1 表结构

#### 3.1.1 sleep_records (打卡记录表)

```sql
CREATE TABLE sleep_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL UNIQUE,
    time TEXT NOT NULL,
    level INTEGER NOT NULL,
    created_at TEXT NOT NULL
);

CREATE INDEX idx_sleep_records_date ON sleep_records(date);
```

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INTEGER | PK, AUTOINCREMENT | 主键 |
| date | TEXT | NOT NULL, UNIQUE | 日期 YYYY-MM-DD |
| time | TEXT | NOT NULL | 睡觉时间 HH:mm |
| level | INTEGER | NOT NULL | 颜色级别 1-7 |
| created_at | TEXT | NOT NULL | 创建时间 ISO8601 |

#### 3.1.2 user_settings (用户设置表)

```sql
CREATE TABLE user_settings (
    id INTEGER PRIMARY KEY,
    normal_time TEXT NOT NULL DEFAULT '23:00',
    updated_at TEXT NOT NULL
);
```

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | INTEGER | PK (固定为1) | 主键 |
| normal_time | TEXT | NOT NULL, DEFAULT '23:00' | 正常睡觉时间 |
| updated_at | TEXT | NOT NULL | 更新时间 ISO8601 |

### 3.2 初始化数据

首次启动时自动创建默认设置：

```dart
INSERT INTO user_settings (id, normal_time, updated_at)
VALUES (1, '23:00', datetime('now'));
```

---

## 4. 模块设计

### 4.1 DatabaseService

**职责**：SQLite 数据库初始化和基础操作

```dart
class DatabaseService {
  static Database? _database;

  Future<Database> get database;
  Future<void> init();
  Future<void> close();
}
```

**公开方法**：
- `init()` - 初始化数据库，创建表
- `get database` - 获取数据库实例

### 4.2 SleepRepository

**职责**：打卡记录的数据访问层

```dart
class SleepRepository {
  final DatabaseService _db;

  Future<void> insert(SleepRecord record);
  Future<SleepRecord?> getByDate(String date);
  Future<List<SleepRecord>> getByDateRange(String start, String end);
  Future<List<SleepRecord>> getRecentDays(int days);
  Future<MonthlyStats> getMonthlyStats(int year, int month);
}
```

### 4.3 SettingsRepository

**职责**：用户设置的数据访问层

```dart
class SettingsRepository {
  final DatabaseService _db;

  Future<UserSettings> getSettings();
  Future<void> updateNormalTime(String time);
}
```

### 4.4 SleepService

**职责**：打卡业务逻辑

```dart
class SleepService {
  // 打卡
  Future<void> clockIn(DateTime now);

  // 验证打卡时间是否有效 (18:00 - 次日06:00)
  bool isClockTimeValid(DateTime time);

  // 计算颜色级别
  int calculateLevel(DateTime sleepTime, String normalTime);

  // 获取今日打卡记录
  Future<SleepRecord?> getTodayRecord();

  // 获取最近N天记录
  Future<List<SleepRecord>> getRecentRecords(int days);
}
```

### 4.5 ShareService

**职责**：生成和分享图片

```dart
class ShareService {
  // 生成分享图片
  Future<Uint8List> generateShareImage(ShareData data);

  // 分享图片
  Future<void> shareImage(Uint8List imageBytes);
}
```

---

## 5. 状态管理

### 5.1 Riverpod Providers

```dart
// 设置 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>

// 打卡 Provider
final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>

// 今日记录 Provider (派生)
final todayRecordProvider = FutureProvider<SleepRecord?>

// 最近7天记录 Provider (派生)
final recentRecordsProvider = FutureProvider<List<SleepRecord>>

// 月度统计 Provider (派生)
final monthlyStatsProvider = FutureProvider.family<MonthlyStats, int>
```

### 5.2 SleepState 结构

```dart
class SleepState {
  final SleepRecord? todayRecord;
  final List<SleepRecord> recentRecords;
  final bool isClocking; // 打卡中
  final String? error;
}
```

### 5.3 SettingsNotifier

```dart
class SettingsNotifier extends StateNotifier<UserSettings> {
  Future<void> loadSettings();
  Future<void> updateNormalTime(String time);
}
```

### 5.4 SleepNotifier

```dart
class SleepNotifier extends StateNotifier<SleepState> {
  Future<void> clockIn();
  Future<void> loadTodayRecord();
  Future<void> loadRecentRecords(int days);
}
```

---

## 6. 路由设计

### 6.1 路由配置

使用 Flutter Navigator 2.0 (GoRouter)：

```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomeScreen()),
        GoRoute(path: '/stats', builder: (context, state) => StatsScreen()),
      ],
    ),
    GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
  ],
);
```

### 6.2 MainShell

包含底部导航和页面容器：

```dart
class MainShell extends StatelessWidget {
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
```

---

## 7. 业务逻辑流程

### 7.1 打卡流程

```
用户点击打卡按钮
       ↓
[时间校验] 检查是否在 18:00 - 次日 06:00
       ↓ (不在)
显示提示："仅18:00-06:00可打卡"
       ↓ (在)
[获取设置] 从数据库读取 normal_time (默认23:00)
       ↓
[计算级别] 根据 normal_time 计算颜色级别 1-7
       ↓
[写入数据库] INSERT sleep_records (date 唯一)
       ↓ (重复打卡)
忽略或提示"今日已打卡"
       ↓ (成功)
[更新状态] 刷新今日记录和最近7天
       ↓
[UI 更新] 显示打卡成功动画和时间
```

### 7.2 统计查询流程

```
用户进入统计页面
       ↓
[获取当前月] 默认为本月
       ↓
[查询记录] SELECT * FROM sleep_records
            WHERE date LIKE '2026-02-%'
       ↓
[计算统计]
  - 打卡天数: 记录数
  - 熬夜天数: level >= 7 的记录数
  - 最早时间: MIN(time)
  - 最晚时间: MAX(time)
       ↓
[趋势对比] 查询上月数据，计算差值
       ↓
[渲染页面] 展示热力图和统计卡片
```

### 7.3 分享流程

```
用户点击分享按钮
       ↓
[生成数据] 读取当前月热力图数据 + 统计
       ↓
[截图渲染] 使用 screenshot 库截取统计页面
       ↓
[调用分享] 使用 share_plus 打开系统分享面板
       ↓
[选择渠道] 微信/朋友圈/保存图片等
```

---

## 8. 错误处理

### 8.1 异常类型

| 异常 | 场景 | 处理 |
|------|------|------|
| DatabaseException | 数据库操作失败 | 重试，显示错误提示 |
| ClockTimeException | 不在打卡时间 | 显示提示文案 |
| DuplicateRecordException | 重复打卡 | 忽略或提示 |
| ShareException | 分享失败 | 显示错误，允许重试 |

### 8.2 空状态处理

| 场景 | 处理 |
|------|------|
| 今日未打卡 | 显示空白打卡按钮 |
| 本月无记录 | 显示空日历 + 提示 |
| 无上月数据 | 趋势对比显示"--" |

---

## 9. 依赖配置

### 9.1 pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # 数据库
  sqflite: ^2.3.0
  path: ^1.8.3

  # 分享
  share_plus: ^7.2.0
  screenshot: ^2.1.0

  # UI
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

---

## 10. 验收标准

### 10.1 功能验收

| 序号 | 功能点 | 验收条件 |
|------|--------|----------|
| 1 | 打卡功能 | 18:00-次日06:00可打卡，其他时间禁用 |
| 2 | 颜色显示 | 打卡后根据设定时间显示对应颜色级别 |
| 3 | 数据保护 | 已打卡记录不可修改、不可删除 |
| 4 | 最近7天 | 首页正确显示最近7天打卡情况 |
| 5 | 日历热力图 | 统计页显示当月每天打卡情况 |
| 6 | 月份切换 | 可切换查看不同月份统计 |
| 7 | 极值记录 | 正确显示本月最早/最晚时间 |
| 8 | 趋势对比 | 正确显示本月vs上月熬夜趋势 |
| 9 | 分享功能 | 可生成并分享图片到微信 |
| 10 | 设置修改 | 可修改正常睡觉时间 |

### 10.2 UI验收

| 序号 | 检查点 | 验收条件 |
|------|--------|----------|
| 1 | 深色主题 | 背景色为 #111111 / #0d0d0d |
| 2 | 打卡按钮 | 200x200px 圆形，带渐变和阴影 |
| 3 | 七级颜色 | 按规范显示对应颜色 |
| 4 | 底部导航 | 首页 + 统计 两个Tab |
| 5 | 热力图 | 7列网格，正确显示颜色 |

### 10.3 数据验收

| 序号 | 检查点 | 验收条件 |
|------|--------|----------|
| 1 | 唯一性 | 每天只能有一条打卡记录 |
| 2 | 默认值 | 正常时间默认为 23:00 |
| 3 | 时间格式 | 存储格式符合规范 (YYYY-MM-DD, HH:mm) |

---

## 11. 后续迭代（V2.0）

以下功能暂不在 V1.0 实现：

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 连续打卡 streak | 显示连续打卡天数 | 中 |
| 睡前提醒推送 | 定时推送提醒 | 中 |
| 密码/指纹保护 | 应用锁 | 低 |
| 云端同步 | 数据备份到云端 | 低 |

---

*文档版本：V1.0*
*创建日期：2026-02-19*
