# Unison

Unison 是一个专注力追踪和任务管理应用程序，旨在帮助用户提高工作效率和专注度。通过结合番茄工作法和任务进度追踪，用户可以更好地管理时间和任务。

## 平台支持策略

- **T1 支持**: 主线功能发布，Android 平台。
- **T2 支持**: 保证可用性，Web/Windows 平台。
- **T3 支持**: 不做保证是否可用，MacOS/Linux/iOS 平台。

## 功能特性

- **专注计时器**: 使用可配置的专注计时器来管理您的专注时间
- **任务管理**: 创建、编辑和追踪任务进度，支持任务分类和预计时间设置
- **进度追踪**: 通过直观的滑动条跟踪任务进度（0-10级）
- **统计分析**: 查看专注记录和统计数据，了解您的专注模式和效率趋势
- **数据持久化**: 使用 shared_preferences 保存所有数据，确保应用重启后数据不丢失

## 快速开始

### 环境要求

- Flutter SDK 3.0.4 或更高版本
- Dart SDK 3.0.4 或更高版本
- 支持的 IDE（如 Android Studio、VS Code）

### 安装

```bash
git clone https://github.com/cup113/unison.git
cd unison
flutter pub get
```

### 运行应用

开发模式运行:
```
flutter run
```

构建发布版本:
```
# Android
flutter build apk

# Web
flutter build web

# Windows
flutter build windows
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口点
├── todo.dart                 # 任务数据模型
├── todo_manager.dart         # 任务管理逻辑
├── timer_manager.dart        # 计时器管理逻辑
├── todo_list_widget.dart     # 任务列表UI组件
├── active_todo_view.dart     # 活动任务视图
├── timer_view.dart           # 计时器视图
├── setup_view.dart           # 设置视图
└── statistics_page.dart      # 统计页面
```

## ROADMAP

### v0.0.3 联网功能准备

1. 重构本地数据存储
   - [x] 重构计时器
   - [ ] 重构待办事项
   - [ ] 重构专注存储

2. 重构界面
   - 优化现有UI组件
   - 实现响应式布局
   - 添加加载状态和错误处理

### v0.0.4 服务端功能基础

1. 添加服务端基础用户与好友功能
   - 用户注册/登录API
   - 好友关系管理
   - 基础权限控制

2. 添加登录界面与账号管理
   - 实现登录/注册界面
   - 集成服务端认证
   - 实现本地会话管理

3. 添加服务端实时信息通信
   - 实现WebSocket连接
   - 设计消息格式和处理机制
   - 添加消息推送功能

### v0.1.0 专注模式增强

1. 添加App时长监控
   - 实现使用时长统计
   - 添加后台数据同步
   - 优化电池使用

2. 添加通知功能
   - 实现本地通知
   - 添加推送通知
   - 设计通知管理界面

3. 添加锁屏界面
   - 实现专注模式锁屏
   - 添加快速操作按钮
   - 设计专注状态显示

## 开发

### 代码规范

项目遵循 Flutter 官方的 [Dart 编码规范](https://dart.dev/guides/language/effective-dart) 和 [Flutter 最佳实践](https://flutter.dev/docs/perf/best-practices)。

### 状态管理

项目使用 Flutter 内置的 [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) 和 [Provider](https://pub.dev/packages/provider) 模式进行状态管理。
