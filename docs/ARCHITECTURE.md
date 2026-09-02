# 系统架构

## 概述

本应用采用 **HdsTabs + Navigation** 复合架构。底部使用 `HdsTabs` 悬浮底栏（IMMERSIVE 材质），每个 Tab 拥有独立的 `Navigation` 导航栈，子页面使用 `HdsNavDestination` 实现沉浸毛玻璃标题栏。

**主题**: 深色/浅色双模式，通过 `DarkTheme`/`LightTheme` 静态类 + 组件内 `T()` 方法运行时切换，`@StorageLink(THEME_KEY)` 驱动全局联动。

**HDS 组件**: `HdsTabs`（底部悬浮导航栏）+ `HdsNavDestination`（子页面沉浸标题栏）+ `AcrylicCard`/`MicaLayer`/`WinButton`/`ExpandableSection`（亚克力卡片等 UI 组件）

## 分层架构

```
┌──────────────────────────────────────────────────────────┐
│                    UI Layer (pages/)                     │
│  MainPage → HdsTabs(悬浮底栏, IMMERSIVE材质, 光感联动)    │
│    ├── HomeTab / Navigation (7 路线)                      │
│    ├── InboxTab / Navigation (滚动隐藏底栏)               │
│    ├── ExploreTab / Navigation (HDS毛玻璃标题栏+滚动隐藏)  │
│    └── ProfileTab / Navigation (10+ 路线)                 │
│  LoginPage (@Entry, Device Flow)                          │
│  sub/ — HdsNavDestination 包裹的子页面:                    │
│    SearchPage, RepoDetailPage(亚克力卡片),                │
│    DevProfilePage(贡献热力图), IssuesPage,                │
│    IssueDetailPage, SettingsPage(光感三档), TutorialPage   │
├──────────────────────────────────────────────────────────┤
│            Service Layer (services/)                     │
│  AuthService(HUKS加密)    HttpClient(put/delete)         │
│  RepoRepository           UserRepository                 │
│  SearchRepository(分页)                                   │
├──────────────────────────────────────────────────────────┤
│            Model Layer (models/)                         │
│  User / Repository / GitHubNotification / SearchResult   │
│  AuthState / DeviceFlowInfo / DevicePollStatus            │
├──────────────────────────────────────────────────────────┤
│            Common Layer (common/)                        │
│  ThemeConstants / APIConstants / NavTitleBar              │
│  AcrylicCard / MicaLayer / WinButton / ExpandableSection  │
│  PersonPicture / RepoCard / MarkdownView                 │
│  FilterTabBar / EmptyState / ListItem / TabBarBuilder    │
└──────────────────────────────────────────────────────────┘
```

## 组件树

```
EntryAbility (UIAbility)
  └─ loadContent('pages/MainPage')
       └─ MainPage.ets (@Entry)
            └─ HdsTabs(barHeight: 56, floatingStyle, IMMERSIVE材质, 光感联动)
                 ├─ TabContent[0]: HomeTab
                 │    └─ Navigation(homeStack) → 7 条路由
                 │         ├─ 固定标题栏 (搜索/新增/刷新)
                 │         ├─ 我的项目 (7 项 WorkItem)
                 │         ├─ 我的星标 (RepoCard → HdsNavDestination)
                 │         └─ HdsNavDestination 子页面 (buildTitleBar + bindToScrollable)
                 ├─ TabContent[1]: InboxTab
                 │    └─ Navigation(inboxStack)
                 │         ├─ FilterTabBar (4 筛选标签)
                 │         ├─ 通知列表 (滚动隐藏底栏)
                 │         └─ NotificationDetailPage (关联Issue+评论)
                 ├─ TabContent[2]: ExploreTab
                 │    └─ Navigation(exploreStack)
                 │         ├─ HDS毛玻璃标题栏 (IMMERSIVE_GRADIENT_BLUR)
                 │         ├─ 发现入口 + 动态流 + 热门仓库
                 │         ├─ 滚动隐藏底栏 (onScrollFrameBegin)
                 │         └─ HdsNavDestination 子页面
                 └─ TabContent[3]: ProfileTab
                      └─ Navigation(profileStack) → 10+ 路由
                           ├─ 用户头像/统计 + 登录/登出
                           ├─ HdsNavDestination 子页面 (repoList, followers, etc.)
                           └─ 设置 → 光感三档 + 屏蔽词 + 教程/协议

LoginPage.ets (@Entry)
  └─ Device Flow：user_code + Web + AuthService.pollDeviceToken()
```

## 数据流

### 启动初始化

```
EntryAbility.onCreate()
  → AuthService.init(context)
  → AppStorage: authToken='', isLoggedIn=false, userFilterEnabled=true
EntryAbility.onWindowStageCreate()
  → loadToken (HUKS 解密 → AppStorage)
  → loadTheme (preferences → AppStorage 'currentTheme')
  → loadGlowLevel (preferences → AppStorage 'glowLevel')
  → setWindowLayoutFullScreen(true) + 状态栏设置
  → setColorMode (同步系统主题)
  → loadContent('pages/MainPage')
```

### 主题切换流

```
MainPage @StorageLink('currentTheme') + @Watch('onThemeChange')
  → appCtx.setColorMode()
  → w.setWindowSystemBarProperties({ statusBarContentColor })
  → w.setWindowBackgroundColor()
  → AuthService.saveTheme() (preferences 持久化)
  → 所有子组件 @StorageLink(THEME_KEY) 自动响应
```

### 底栏隐藏/显示流

```
发现/消息页: onScrollFrameBegin → offsetRemain > 0 → scrollHidden=true
  → onNavChanged(true) → MainPage.applyHideAnimation(SCROLL_ANIMATION)
首页/我的页: setInterval(300ms) 轮询 getAllPathName().length
  → depth 0→1: onNavChanged(true) → 隐藏
  → depth 1→0: onNavChanged(false) → 显示
```

### HdsNavDestination 标题栏流

```
buildTitleBar(title) → 读取 AppStorage('currentTheme', 'glowLevel')
  → 设置 mainTitleColor/backIconStyle/menuColor (主题联动)
  → 设置 scrollEffectOpts (IMMERSIVE_GRADIENT_BLUR)
  → 设置 systemMaterialEffect (IMMERSIVE + 光感档位)
  → 设置 originalStyle + scrollEffectStyle (滚动前后样式)
  → HdsNavDestination.titleBar(options)
  → .bindToScrollable([scroller])
```

## 滚动方向检测（发现/消息页）

```
Scroll(this.scroller).onScrollFrameBegin((offsetRemain) => {
  if (offsetRemain > 0 && navDepth === 0) → 隐藏底栏
  if (offsetRemain < 0 && scrollHidden)  → 显示底栏
})
```

- 仅发现页和消息页启用滚动隐藏
- 首页和我的页不随滚动隐藏（仅导航深度变化时隐藏）

## 路由设计

### 页面路由注册 (`main_pages.json`)

```json
{ "src": ["pages/MainPage", "pages/LoginPage"] }
```

### Tab 内部导航（NavPathStack）

每个 Tab 持有独立 `NavPathStack`，子页面通过 `@Builder pageMap(name, param)` 注册，用 `HdsNavDestination` 包裹 + `buildTitleBar()` + `.bindToScrollable([scroller])`：

| Tab | NavPathStack | 主要路由 |
|-----|-------------|---------|
| HomeTab | `homeStack` | search, starredPage, newIssue, issues, issueDetail, repoWeb, devProfile, repoWebView + WorkPage(7 种) |
| InboxTab | `inboxStack` | notifDetail, repoWebView |
| ExploreTab | `exploreStack` | repoDetail, issues, issueDetail, devProfile, repoWeb, topRepos |
| ProfileTab | `profileStack` | repoList, issues, issueDetail, repoDetail, devProfile, repoWeb, followers, following, settings, tutorial, userAgreement, privacy |

## 状态管理

| 状态类型 | 方案 | 作用域 |
|----------|------|--------|
| 认证 Token | `AppStorage` + HUKS 加密存储 | 全局 |
| 登录状态 | `AppStorage` + `@StorageLink(AUTH_LOGIN_KEY)` + `@Watch` | 全局 |
| 主题模式 | `AppStorage` + `@StorageLink(THEME_KEY)` + `@Watch(onThemeChange)` | 全局 |
| 沉浸光感 | `AppStorage('glowLevel')` → `buildTitleBar` 读取 → materialLevel | 全局 |
| 搜索过滤 | `AppStorage('userFilterEnabled')` | 全局 |
| Tab 选中 | `@State currentIndex` + `HdsTabsController` | MainPage |
| 底栏隐藏 | `@State scrollHidden` + `@State navDepth` | 各 Tab |
| 导航栈 | `NavPathStack` 实例 | 单个 Tab |

## HDS 组件集成

### 底部 Tab 栏

```
HdsTabs
  ├─ barHeight(56)
  ├─ barFloatingStyle: { barBottomMargin: dynamic, IMMERSIVE 材质 }
  ├─ scrollable(false)
  ├─ onChange → currentIndex
  └─ tabsController.applyHideAnimation/ShowAnimation(SCROLL_ANIMATION)
```

### 子页面标题栏

```
HdsNavDestination
  ├─ .titleBar(buildTitleBar('标题'))
  │     ├─ originalStyle: { titleStyle, backIconStyle, menuStyle }
  │     ├─ scrollEffectStyle: { 同上 }
  │     ├─ scrollEffectOpts: { IMMERSIVE_GRADIENT_BLUR, enableScrollEffect }
  │     ├─ blurStrategy: ENABLE
  │     └─ systemMaterialEffect: { IMMERSIVE, materialLevel(光感) }
  ├─ .bindToScrollable([scroller])
  └─ 内容: Scroll(this.scroller) + Blank(88) + 内容
```

### 滚动方向检测

```
Scroll(this.scroller).onScrollFrameBegin((offsetRemain) => {
  offsetRemain > 0 → 向下滚动 → 隐藏底栏
  offsetRemain < 0 → 向上滚动 → 显示底栏
})
```

- 仅发现页和消息页启用滚动隐藏
- 首页和我的页仅在导航深度变化时隐藏/显示

## 目录结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets               # 入口: HUKS + loadToken/loadTheme/loadGlowLevel + 全屏
├── entrybackupability/
│   └── EntryBackupAbility.ets         # 备份扩展
├── pages/
│   ├── MainPage.ets                   # @Entry — HdsTabs + 光感联动 + 底栏隐藏
│   ├── LoginPage.ets                  # @Entry — Device Flow 登录
│   ├── tabs/
│   │   ├── HomeTab.ets               # 首页 (我的项目 + 星标)
│   │   ├── InboxTab.ets             # 消息 (筛选 + 通知 + 滚动隐藏底栏)
│   │   ├── ExploreTab.ets          # 发现 (HDS毛玻璃标题 + 滚动隐藏底栏)
│   │   └── ProfileTab.ets          # 我的 (头像/统计 + 登录/登出 + 10+ 路由)
│   └── sub/
│       ├── SearchPage.ets          # 搜索 (固定搜索框 + 分页 + 屏蔽词)
│       ├── WorkPage.ets            # 工作项 (议题/PR/仓库/组织/星标)
│       ├── RepoDetailPage.ets     # 仓库详情 (亚克力卡片 + Release + README)
│       ├── DevProfilePage.ets     # 开发者资料 (贡献热力图 + 仓库筛选)
│       ├── IssuesPage.ets         # Issue 列表
│       ├── IssueDetailPage.ets    # Issue 详情 (Markdown + 评论)
│       ├── NewIssuePage.ets       # 新建议题
│       ├── StarredReposPage.ets   # 已加星标
│       ├── TopReposPage.ets       # 星标榜
│       ├── NotificationDetailPage.ets # 通知详情
│       ├── SettingsPage.ets       # 设置 (光感三档 + 屏蔽词 + 教程/协议)
│       ├── TutorialPage.ets       # 使用教程
│       ├── PrivacyPage.ets        # 隐私协议
│       └── UserAgreementPage.ets  # 用户协议
├── services/
│   ├── HttpClient.ets              # HTTP 引擎 (get/post/put/delete)
│   ├── RepoRepository.ets         # 仓库端点
│   ├── UserRepository.ets         # 用户/GraphQL 端点
│   ├── SearchRepository.ets       # 搜索/通知 (支持分页)
│   └── AuthService.ets            # Device Flow + HUKS 加密 + 主题/光感
├── models/
│   ├── User.ets                    # User, Repository, SearchResult 等
│   └── AuthModels.ets             # DeviceFlowInfo, DevicePollStatus 等
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets      # DarkTheme / LightTheme / ThemeColors
    │   └── APIConstants.ets        # API 端点 + OAuth 配置
    ├── utils/
    │   └── NavTitleBar.ets         # buildTitleBar: HDS 沉浸毛玻璃标题栏
    └── components/
        ├── AcrylicCard.ets         # 亚克力卡片
        ├── MicaLayer.ets           # Mica 背景层
        ├── WinButton.ets           # WinUI 风格按钮
        ├── ExpandableSection.ets   # 可折叠区块
        ├── PersonPicture.ets       # 头像组件
        ├── RepoCard.ets            # 仓库卡片
        ├── MarkdownView.ets        # Markdown 渲染
        ├── FilterTabBar.ets        # 筛选标签栏
        ├── EmptyState.ets          # 空状态
        ├── ListItem.ets            # 列表功能项
        └── TabBarBuilder.ets       # Tab 栏配置
```
