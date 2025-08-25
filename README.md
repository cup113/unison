# Unison

Unison 是一个专注力追踪和任务管理应用程序，旨在帮助用户提高工作效率和专注度。通过结合番茄工作法、任务进度追踪和社交功能，用户可以更好地管理时间、任务并与朋友一起学习。

## 核心特性

- **专注计时器**: 可配置的专注计时器，支持专注时间设置
- **任务管理**: 创建、编辑和追踪任务进度，支持任务分类和预计时间设置
- **社交功能**: 添加好友、查看好友动态和专注状态
- **进度追踪**: 通过直观的滑动条跟踪任务进度
- **数据同步**: 支持本地存储和云端同步，确保数据安全
- **多平台支持**: 支持 Android、Web、Windows

## 平台支持

- **Android**: T1，主要开发平台
- **Web**: T2，保证可构建
- **Windows**: T2，保证可构建
- **iOS/macOS**: 实验性支持，功能完整但可能有性能差异
- **Linux**: 实验性支持

## 🛠️ 技术栈

### 前端 (Flutter/Dart)

- **Flutter 3.0.4+**: 跨平台 UI 框架
- **Riverpod**: 状态管理
- **Hive**: 本地数据库存储
- **HTTP**: REST API 通信
- **Flutter Secure Storage**: 安全存储敏感数据

### 后端 (Node.js/TypeScript)

- **Express.js**: Web 框架
- **PocketBase**: 后端即服务数据库
- **Zod**: 数据验证
- **Winston**: 日志记录
- **ts-rest**: 类型安全的 API 契约

## 项目结构

```
unison/
├── lib/                          # Flutter 应用代码
│   ├── constants/                # 应用常量
│   ├── models/                   # 数据模型 (Todo, Focus, Friend, TimerState)
│   ├── services/                 # 业务服务层
│   │   ├── *_interface.dart      # 服务接口定义
│   │   └── *.dart               # 服务实现
│   ├── tabs/                     # 主页面标签
│   │   ├── focus_tab.dart        # 专注页面
│   │   ├── social_tab.dart       # 社交页面
│   │   ├── statistics_tab.dart   # 统计页面
│   │   └── account_tab.dart      # 账户页面
│   ├── widgets/                  # 可复用组件
│   ├── utils/                    # 工具类
│   ├── app_state_manager.dart    # 应用状态管理
│   ├── main.dart                 # 应用入口
│   ├── main_tabbed_page.dart     # 主页面框架
│   └── providers.dart            # Riverpod 提供者
├── server/                       # Node.js 后端服务
│   ├── src/
│   │   ├── routes/               # API 路由
│   │   ├── services/             # 后端服务
│   │   └── types/                # 类型定义
│   └── Dockerfile*               # Docker 配置
├── android/                      # Android 平台代码
├── ios/                          # iOS 平台代码
├── web/                          # Web 平台代码
├── windows/                      # Windows 平台代码
├── macos/                        # macOS 平台代码
└── linux/                        # Linux 平台代码
```

## ROADMAP / 路线图

### ✅ v0.0.3 重构本地数据存储 (2025.8.20)

- [x] 重构计时器
- [x] 重构待办事项
- [x] 重构专注存储

### ✅ v0.0.4 添加服务端基础用户与好友功能 (2025.8.22)

- [x] 用户注册/登录API
- [x] 好友关系管理

### ✅ v0.0.5 重构界面 (2025.8.23)

- [x] Multiple Tab 架构实现 (Focus, Social, Statistics)
- [x] 社交界面初步实现
- [x] 添加界面好友动态推送模拟

### ✅ v0.0.6 添加登录界面与账号管理 (2025.8.23)

- [x] 实现登录/注册界面
- [x] 实现本地状态管理
- [x] 实现异常处理

### ✅ v0.0.7 系统重构 (2025.8.25)

- [x] 修复 `ActiveTodoView` 同步
- [x] `lib/` 目录模块化修改
- [x] 状态管理重构
- [x] 长文件拆分
- [x] `README.md` 更新

### ✅ v0.1.0 添加好友功能 (2025.8.25)

- [x] 服务端好友管理实现
- [x] 客户端好友管理配套接入

### ✅ v0.1.1 细节体验优化

- [x] 进度改变优化
- [x] 添加休息计时
- [x] 密码确认、窗口优化

### 🚧 v0.1.2 客户端架构再优化

- [ ] 添加统一通信接口
- [ ] 完善类型系统
- [ ] 提取无状态组件

### 🔜 v0.2.0 添加App时长监控

- [ ] 实现使用时长统计
- [ ] 添加后台数据同步
- [ ] 优化电池使用

### 🔜 v0.2.1 添加服务端实时信息通信

- [ ] 实现 WebSocket 连接
- [ ] 设计消息格式和处理机制
- [ ] 添加消息推送功能

### 🔜 v0.2.2 添加服务端数据同步

- [ ] 添加 id 转换
- [ ] 实现服务端数据同步
- [ ] 实现客户端数据同步

### 🔜 v0.3.0 优化通知功能

- [ ] 实现本地通知
- [ ] 添加推送通知
- [ ] 设计通知管理界面

### 🔜 v0.3.1 设计锁屏界面

- [ ] 实现专注模式锁屏
- [ ] 添加快速操作按钮
- [ ] 设计专注状态显示

### 🔜 v0.3.2 细节优化

- [ ] 专注状态持久化
- [ ] 专注完成多进度统一编辑
- [ ] 优化好友添加逻辑

### 🔜 v0.3.3 响应式设计

- [ ] 电脑端、平板端适配

### 🔜 v0.4.0 基本服务端防护

- [ ] DDoS 防护
- [ ] 漏洞审查

### 🔜 v1.0.0 正式上线

- [ ] 客户端服务测试
- [ ] 客户端工具测试
- [ ] 客户端组件测试
- [ ] 客户端导航测试
- [ ] 服务端数据库测试
- [ ] 服务端环境切换测试
- [ ] 服务端接口测试
- [ ] 服务端同步测试

## 开发

### 代码规范

- 遵循 [Dart 编码规范](https://dart.dev/guides/language/effective-dart)
- 使用 [Flutter 最佳实践](https://flutter.dev/docs/perf/best-practices)
- 保持一致的命名约定和代码风格

### 状态管理

- 使用 **Riverpod** 进行状态管理
- 服务层实现接口分离模式
- 使用 ChangeNotifier 进行局部状态管理

### 构建命令

```bash
# Flutter 应用
flutter build apk          # Android
flutter build web         # Web
flutter build windows     # Windows

# 后端服务
cd server && pnpm build   # TypeScript 编译
cd server && pnpm start   # 生产环境启动
```

## 贡献

欢迎提交 Issue 和 Pull Request！目前是个人项目，但欢迎任何改进建议。
