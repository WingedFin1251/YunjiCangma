# 系统架构

## 概述

本应用采用 **Tabs + Navigation** 复合架构，每个底部 Tab 拥有独立的 `Navigation` 导航栈，确保子页面跳转时底部导航栏始终可见。

**主题**: 深色/浅色双模式，通过 `DarkTheme`/`LightTheme` 静态类 + 组件内 `T()` 方法运行时切换，`@StorageLink(THEME_KEY)` 驱动全局联动。

## 分层架构

```
┌──────────────────────────────────────────────────────┐
│                UI Layer (pages/)                     │
│  MainPage → Tabs → TabContent × 4                    │
│    ├── HomeTab / Navigation (7 路线)                  │
│    ├── InboxTab / Navigation                         │
│    ├── ExploreTab / Navigation                       │
│    └── ProfileTab / Navigation (9 路线)               │
│  LoginPage (@Entry)                                  │
│  sub/ — SearchPage, WorkPage, RepoDetailPage,        │
│         DevProfilePage, IssuesPage, SettingsPage,    │
│         TutorialPage, PrivacyPage                    │
├──────────────────────────────────────────────────────┤
│         Service Layer (services/)                    │
│  AuthService         HttpClient                       │
│  RepoRepository      UserRepository                  │
│  SearchRepository                                    │
├──────────────────────────────────────────────────────┤
│          Model Layer (models/)                       │
│  User / Repository / RepoOwner                       │
│  GitHubNotification / SearchResult                   │
│  AuthState / DeviceFlowInfo / DevicePollStatus       │
├──────────────────────────────────────────────────────┤
│         Common Layer (common/)                       │
│  DarkTheme / LightTheme / ThemeColors                │
│  APIConstants / NavTitleBar                          │
│  RepoCard / ListItem / EmptyState                    │
│  FilterTabBar / TabBarBuilder / MarkdownView         │
└──────────────────────────────────────────────────────┘
```

## 组件树

```
EntryAbility (UIAbility)
  └─ loadContent('pages/MainPage')
       └─ MainPage.ets (@Entry)
            └─ Tabs(barPosition: End, barHeight: 52dp, animationDuration: 0)
                 ├─ TabContent[0]: HomeTab
                 │    └─ Navigation(homeStack) → 7 条路由
                 │         ├─ 标题栏 (搜索/新增/更多)
                 │         ├─ 我的项目 (7 项 WorkItem → WorkPage/IssuesPage)
                 │         ├─ 我的星标 (RepoCard → RepoDetailPage)
                 │         ├─ SearchPage → RepoDetailPage
                 │         ├─ DevProfilePage → RepoDetailPage/WebView
                 │         └─ WebView (GitHub 原始页面)
                 ├─ TabContent[1]: InboxTab
                 │    └─ Navigation(inboxStack)
                 │         ├─ 标题栏 (Inbox + 更多)
                 │         ├─ FilterTabBar (4 筛选标签)
                 │         └─ 通知列表 / LoadingProgress / EmptyState
                 ├─ TabContent[2]: ExploreTab
                 │    └─ Navigation(exploreStack)
                 │         ├─ 标题栏
                 │         ├─ 发现 (2 列入口)
                 │         ├─ 动态流 (ActivityItem)
                 │         ├─ 热门仓库 (RepoCard → RepoDetailPage)
                 │         ├─ DevProfilePage → RepoDetailPage/WebView
                 │         └─ WebView (GitHub 原始页面)
                 └─ TabContent[3]: ProfileTab
                      └─ Navigation(profileStack) → 9 条路由
                           ├─ 设置入口 (☰ → SettingsPage)
                           ├─ 登录态: 头像 + 用户名 + 状态框 + 统计 + Repos/Followers/Following
                           ├─ 未登录: 登录按钮 → LoginPage
                           ├─ repoList → RepoCard 列表 → RepoDetailPage
                           ├─ followers / following 列表 → DevProfilePage
                           ├─ IssuesPage / WebView
                           ├─ SettingsPage → TutorialPage / PrivacyPage
                           └─ 登出按钮

LoginPage.ets (@Entry, router.pushUrl 独立页面)
  └─ Device Flow：展示 user_code + Web (github.com/login/device)
       └─ AuthService.pollDeviceToken() 轮询 → 成功 → router.back()
```

## 数据流

### 启动初始化

```
EntryAbility.onCreate()
  → AppStorage: authToken='', isLoggedIn=false
  → AuthService.init(context)
  → AuthService.loadToken() (异步，preferences → AppStorage)
  → AuthService.loadTheme() (异步，preferences → AppStorage 'currentTheme')
  → setColorMode (同步系统主题到 NavDestination)
  → setWindowLayoutFullScreen(true) + 状态栏设置
  → windowStage.loadContent('pages/MainPage')
```

### OAuth 登录流

```
ProfileTab "Sign In" → router.pushUrl('pages/LoginPage')
  → AuthService.startDeviceFlow()
    → POST github.com/login/device/code { client_id }
  → 展示 user_code + Web 加载 github.com/login/device
  → 用户输入验证码并授权
  → AuthService.pollDeviceToken(device_code) 轮询
    → POST github.com/login/oauth/access_token (grant_type=device_code)
    → 成功 → saveToken(token) → preferences + AppStorage
  → router.back()
  → ProfileTab.onLoginChanged() → loadUserData()
    → UserRepository.getCurrentUser() → @State user
```

### API 数据流

```
Tab Component (UI)
  → XxxRepository.static method
    → HttpClient.get<T>(path)
      → buildHeaders() (AuthService.getToken() → Bearer header)
      → @ohos.net.http request
      → JSON parse → typed model
  → @State 更新
  → UI 重渲染
```

## 路由设计

### 页面路由注册 (`main_pages.json`)

```json
{
  "src": [
    "pages/MainPage",
    "pages/LoginPage"
  ]
}
```

- `MainPage` — 启动默认加载（Tabs 容器）
- `LoginPage` — 通过 `router.pushUrl({ url: 'pages/LoginPage' })` 跳转

### Tab 内部导航（NavPathStack）

每个 Tab 持有独立 `NavPathStack`，子页面通过 `@Builder pageMap(name, param)` 注册：

| Tab | NavPathStack | 路由名称 |
|-----|-------------|---------|
| HomeTab | `homeStack` | search, issues, repoWeb, devProfile, repoWebView + WorkPage(7 种) |
| InboxTab | `inboxStack` | (暂无子页面路由) |
| ExploreTab | `exploreStack` | repoDetail, devProfile, repoWeb |
| ProfileTab | `profileStack` | repoList, issues, repoDetail, devProfile, repoWeb, followers, following, settings, tutorial, privacy |

## 状态管理

| 状态类型 | 方案 | 作用域 |
|----------|------|--------|
| 认证 Token | `AppStorage` + `@StorageLink(AUTH_TOKEN_KEY)` | 全局 |
| 登录状态 | `AppStorage` + `@StorageLink(AUTH_LOGIN_KEY)` + `@Watch` | 全局 |
| 主题模式 | `AppStorage` + `@StorageLink(THEME_KEY)` + `@Watch(onThemeChange)` | 全局 |
| 搜索过滤 | `AppStorage` + `@StorageLink('userFilterEnabled')` | 全局 |
| Tab 选中 | `@State currentIndex` + `TabsController` | MainPage |
| 导航栈 | `NavPathStack` 实例 | 单个 Tab |
| 用户数据 | `@State user` | ProfileTab |
| 列表数据 | `@State items[]` + `async aboutToAppear` | 各组件 |

## 主题架构

深色/浅色双模式，`common/constants/ThemeConstants.ets` 定义：

- `ThemeColors` 接口 — 14 色值规范
- `DarkTheme` 类 — 14 个 `static readonly` 深色色值
- `LightTheme` 类 — 14 个 `static readonly` 浅色色值
- `THEME_KEY = 'currentTheme'` — AppStorage 键
- `langColor(lang)` — GitHub Linguist 语言颜色映射（30+ 语言）

每个组件通过 `@StorageLink(THEME_KEY)` + `T()` 方法获取当前主题色值。切换时 `MainPage.onThemeChange()` 同步更新状态栏颜色 + 窗口背景 + preferences 持久化。

## 目录结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets               # 应用入口: Auth.init + loadToken + loadTheme + 全屏
├── entrybackupability/
│   └── EntryBackupAbility.ets         # 备份扩展
├── pages/
│   ├── MainPage.ets                   # @Entry — Tabs 容器 + 主题切换监听
│   ├── LoginPage.ets                  # @Entry — OAuth Device Flow 登录
│   ├── tabs/
│   │   ├── HomeTab.ets                # 首页（7 项工作入口 + 星标列表）
│   │   ├── InboxTab.ets               # 收件箱（筛选 + 通知列表）
│   │   ├── ExploreTab.ets             # 探索（热门仓库 + 动态流）
│   │   └── ProfileTab.ets             # 个人资料（用户信息 + 资源列表）
│   └── sub/
│       ├── SearchPage.ets             # 全局搜索（手动屏蔽词 → RepoDetailPage）
│       ├── WorkPage.ets               # 工作项子页面（议题/PR/仓库/组织/星标）
│       ├── RepoDetailPage.ets         # 仓库详情（HEADER/Stats/Release/Info/README）
│       ├── DevProfilePage.ets         # 开发者资料（头像/统计/仓库/贡献热力图）
│       ├── IssuesPage.ets             # Issue 列表
│       ├── SettingsPage.ets           # 设置（深色切换/屏蔽词/教程/隐私/关于）
│       ├── TutorialPage.ets           # 使用教程
│       └── PrivacyPage.ets            # 隐私协议
├── services/
│   ├── HttpClient.ets                 # HTTP 引擎（泛型 get/post，自动 Bearer）
│   ├── AuthService.ets                # Device Flow + Token/Theme 持久化
│   ├── RepoRepository.ets            # 仓库相关端点
│   ├── UserRepository.ets            # 用户/动态/GraphQL 端点
│   └── SearchRepository.ets          # 搜索/通知/PR 端点
├── models/
│   ├── User.ets                       # User, Repository, RepoOwner, GitHubNotification, SearchResult
│   └── AuthModels.ets                 # AuthState, LoginPageParams, DeviceFlowInfo, DevicePollStatus, DevicePollResult
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets          # DarkTheme / LightTheme / ThemeColors / langColor()
    │   └── APIConstants.ets           # API 端点 + OAuth 配置 + AppStorage Key
    ├── utils/
    │   └── NavTitleBar.ets            # 子页面沉浸毛玻璃标题栏（HdsNavDestination）
    └── components/
        ├── RepoCard.ets               # 仓库卡片
        ├── ListItem.ets               # 列表功能项
        ├── EmptyState.ets             # 空状态
        ├── FilterTabBar.ets           # 筛选标签栏
        ├── TabBarBuilder.ets          # Tab 栏配置
        └── MarkdownView.ets          # Markdown 渲染
```
