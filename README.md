# Unison

Unison 是一个专注力追踪和任务管理应用程序，旨在帮助用户提高工作效率和专注度。通过结合番茄工作法和任务进度追踪，用户可以更好地管理时间和任务。

## 功能特性

- **专注计时器**: 使用可配置的专注计时器（5分钟、15分钟、25分钟、40分钟、60分钟、90分钟）来管理您的专注时间
- **任务管理**: 创建、编辑和追踪任务进度，支持任务分类和预计时间设置
- **进度追踪**: 通过直观的滑动条跟踪任务进度（0-10级）
- **统计分析**: 查看专注记录和统计数据，了解您的专注模式和效率趋势
- **数据持久化**: 使用 shared_preferences 保存所有数据，确保应用重启后数据不丢失
- **后台处理**: 智能处理应用在后台时的计时器状态，确保计时准确性

## 技术栈

- [Flutter](https://flutter.dev/) - Google 的 UI 工具包，用于构建跨平台应用
- [Dart](https://dart.dev/) - Flutter 的编程语言
- [shared_preferences](https://pub.dev/packages/shared_preferences) - 用于简单的数据持久化
- [intl](https://pub.dev/packages/intl) - 国际化和本地化功能

## 快速开始

### 环境要求

- Flutter SDK 3.0.4 或更高版本
- Dart SDK 3.0.4 或更高版本
- 支持的 IDE（如 Android Studio、VS Code）
- Android/iOS 模拟器或真机（用于测试）

### 安装

1. 克隆仓库:
   ```
   git clone <repository-url>
   ```

2. 进入项目目录:
   ```
   cd unison
   ```

3. 获取依赖:
   ```
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

# iOS
flutter build ios

# Web
flutter build web
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

## 核心组件

### 计时器管理 (TimerManager)

管理专注计时器的所有功能，包括:
- 多种预设时长（5/15/25/40/60/90分钟）
- 后台运行处理
- 暂停/继续功能
- 数据持久化

### 任务管理 (TodoManager)

处理任务的创建、更新和删除:
- 任务进度跟踪（0-10级）
- 任务分类
- 预计时间设置
- 活动任务管理

### 统计系统

记录和展示用户的专注历史:
- 专注时间统计
- 任务完成情况
- 使用模式分析

## 使用说明

1. **创建任务**: 在主界面添加新任务，设置标题、分类和预计时间
2. **设置专注时间**: 选择合适的专注时长开始计时
3. **专注工作**: 在计时期间专注完成任务
4. **更新进度**: 计时结束后更新任务进度
5. **查看统计**: 在统计页面查看历史专注记录和分析

## 开发

### 代码规范

项目遵循 Flutter 官方的 [Dart 编码规范](https://dart.dev/guides/language/effective-dart) 和 [Flutter 最佳实践](https://flutter.dev/docs/perf/best-practices)。

### 状态管理

项目使用 Flutter 内置的 [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) 和 [Provider](https://pub.dev/packages/provider) 模式进行状态管理。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 许可证

本项目基于 MIT 许可证开源 - 查看 [LICENSE](LICENSE) 文件了解详情。

