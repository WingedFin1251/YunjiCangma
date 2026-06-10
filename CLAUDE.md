# CLAUDE.md

> Claude Code 项目上下文 — AI 辅助开发参考

## 项目概述

**Github** — HarmonyOS NEXT 平台上的 GitHub 移动客户端。

- **Bundle Name**: `com.github.web`
- **平台**: HarmonyOS NEXT (API 6.1.0 / 23)
- **语言**: ArkTS (TypeScript 严格子集)
- **架构**: Stage Model + ArkUI 声明式 UI
- **主题**: 全局深色模式（唯一主题，无浅色切换）
- **设计规范**: V1.0 — 色值/字号/间距严格按规范文档

## 技术栈

| 技术 | 用途 |
|------|------|
| ArkTS | 声明式 UI + 业务逻辑 |
| ArkUI | 组件框架（Tabs, Navigation, List, Scroll） |
| Stage Model | UIAbility + ExtensionAbility |
| GitHub REST API v3 | 数据源（api.github.com） |
| @ohos.net.http | HTTP 网络请求 |
| @ohos.data.preferences | Token 本地持久化 |
| Hvigor | 构建系统 |
| ohpm | 包管理 |

## 目录结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets          # 应用入口，初始化 AppStorage
├── pages/
│   ├── MainPage.ets              # @Entry — 4 Tab 底部导航
│   ├── LoginPage.ets             # @Entry — OAuth WebView 登录
│   └── tabs/
│       ├── HomeTab.ets           # 主页（我的工作 + 收藏夹）
│       ├── InboxTab.ets          # 收件箱（筛选 + 通知 / 空状态）
│       ├── ExploreTab.ets        # 探索（发现 + 活动）
│       └── ProfileTab.ets        # 个人资料（用户信息 + 资源列表）
├── services/
│   ├── AuthService.ets           # OAuth URL 构建、code→token、存储/加载/登出
│   └── GitHubAPIService.ets      # HTTP 封装（自动注入 Bearer Token）
├── models/
│   ├── User.ets                  # GitHub 用户数据模型
│   └── AuthModels.ets            # OAuthTokenResponse 等
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets     # DarkTheme 类 — 14 个静态 readonly 色值
    │   └── APIConstants.ets       # API 端点、OAuth 参数、APIHeaders 类
    └── components/
        ├── RepoCard.ets           # 仓库卡片（头像+描述+标签+星标）
        ├── ListItem.ets           # 列表功能项（图标+文字 52dp）
        ├── EmptyState.ets         # 空状态（居中图标+文案）
        ├── FilterTabBar.ets       # 筛选标签栏（横向滑动 40dp）
        └── TabBarBuilder.ets      # Tab 栏构建器
```

## 关键文件

| 文件 | 职责 |
|------|------|
| `AppScope/app.json5` | bundleName, versionCode, SDK |
| `entry/src/main/module.json5` | 模块声明、权限（ohos.permission.INTERNET） |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 启动加载 Token、设置 ColorMode |
| `entry/src/main/ets/pages/MainPage.ets` | @Entry — Tabs 容器，4 个中文 Tab |
| `entry/src/main/ets/pages/LoginPage.ets` | @Entry — OAuth WebView 页面 |
| `main_pages.json` | 路由注册：pages/MainPage, pages/LoginPage |
| `common/constants/ThemeConstants.ets` | 唯一色彩源 — DarkTheme 类 |
| `common/constants/APIConstants.ets` | API 配置、OAuth Client ID |
| `services/AuthService.ets` | Token CRUD + OAuth 流程 |

## 色彩系统

深色唯一主题，14 色值，定义在 `common/constants/ThemeConstants.ets`：

```typescript
// 所有组件引用方式：
import { DarkTheme } from '../../common/constants/ThemeConstants';
// 使用：DarkTheme.background, DarkTheme.accent, etc.
```

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | #121212 | 页面主背景 |
| `surface` | #1E1E1E | 卡片/标签栏 |
| `surfaceElevated` | #2A2A2A | 按钮/输入框 |
| `border` | #333333 | 分割线 |
| `textPrimary` | #FFFFFF | 一级文本 |
| `textSecondary` | #B3B3B3 | 二级文本 |
| `textTertiary` | #757575 | 三级文本 |
| `accent` | #218BFE | 品牌主色 |
| `issueGreen` | #2EA44F | 议题 |
| `starYellow` | #FFD33D | 星标 |
| `clickFeedback` | #383838 | 点击反馈 |

## ArkTS 严格模式编码规则

本项目的 `build-profile.json5` 启用了 `caseSensitiveCheck` 和 `useNormalizedOHMUrl`，编译器强制执行以下规则：

1. **无类型对象字面量** (`arkts-no-untyped-obj-literals`)
   - 常量用 `class static readonly` 替代裸 `export const {}`
   - 数据数组使用具名 `class` 实例，禁止内联 `{}`
   
2. **静态方法中禁用 `this`** (`arkts-no-standalone-this`)
   - `this.xxx()` → `ClassName.xxx()`
   - 模块级常量提取到类外部

3. **禁止对象展开** (`arkts-no-spread`)
   - `...(cond ? {} : {})` → 显式属性赋值

4. **数组元素类型可推断** — 数组声明必须带显式类型 `: ClassName[]`

5. **`FontWeight.Light`** — 不存在，使用 `FontWeight.Lighter`

## 开发规范

### 新增页面
1. 在 `pages/` 创建 `.ets` 文件
2. 如需独立页面入口 → 在 `main_pages.json` 注册
3. Tab 内子页面 → 通过各 Tab 的 `NavPathStack.pushPath()` 导航

### 新增组件
1. 在 `common/components/` 创建
2. 使用 `DarkTheme` 类引用色值，不硬编码
3. 遵循 V1.0 设计规范中的尺寸/字号/圆角

### 新增 API
1. 端点常量 → `APIConstants.ets`
2. 数据模型 → `models/` 中定义 interface
3. 服务方法 → `GitHubAPIService.ets` 中添加

### 构建命令
- `hvigorw assembleHap` — 构建 HAP
- `hvigorw test` — 本地单元测试
- `hvigorw ohosTest` — 设备集成测试
