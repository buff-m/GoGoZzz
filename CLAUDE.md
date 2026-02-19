# CLAUDE.md

本文档为 Claude Code (claude.ai/code) 在本项目中工作时提供指导。

## 项目概述

**GoGoZzz** - 睡觉时间记录应用，帮助用户培养早睡习惯。

## 技术栈

- **框架**：Flutter (优先 Android)
- **存储**：SQLite（本地数据库）
- **分享**：screenshot + share_plus 生成图片

## 项目状态

本项目处于规划阶段，已有以下文档：

- `docs/requirements.md` - 完整需求文档
- `sleep_app_sketch.html` - UI 草图

## 目录结构

标准 Flutter Clean Architecture：
- `lib/` - Dart 源代码
- `lib/models/` - 数据模型
- `lib/screens/` - 页面
- `lib/widgets/` - 复用组件
- `lib/services/` - 业务逻辑服务
- `lib/utils/` - 工具函数

## 核心功能

1. **打卡按钮**：点击记录睡觉时间（仅限 18:00 - 次日 06:00）
2. **7级颜色系统**：根据用户设定的正常睡觉时间，显示7种颜色
3. **日历热力图**：月度视图展示睡眠规律
4. **统计数据**：熬夜天数、最早/最晚记录、月度趋势对比
5. **分享功能**：生成微信长图（统计+热力图）

## 颜色方案

深色主题 + 7级渐变色：
- 1-3级：绿色系（早睡）
- 4级：黄绿色（正常）
- 5-6级：黄色/橙色（略晚）
- 7级：红色（熬夜）
- 未打卡：白色

## 常用命令

```bash
# Flutter 命令（项目初始化后）
flutter pub get    # 安装依赖
flutter run        # 运行项目
flutter build apk  # 构建 Android APK
```

## 数据库设计

### sleep_records 表（打卡记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键自增 |
| date | TEXT | 日期（唯一），格式 `YYYY-MM-DD` |
| time | TEXT | 睡觉时间，格式 `HH:mm` |
| level | INTEGER | 颜色级别（1-7） |
| created_at | TEXT | 记录创建时间 |

### user_settings 表（用户设置）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键（固定为1） |
| normal_time | TEXT | 正常睡觉时间，默认 `23:00` |
| updated_at | TEXT | 更新时间 |

## 备注

- 正常睡觉时间默认值：23:00（可配置 18:00 - 次日 04:00）
- 已记录时间不可修改、不可删除
- 分享功能生成微信长图格式
- 打卡时间限制：18:00 - 次日 06:00
