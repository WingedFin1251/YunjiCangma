# 系统架构

## 概述

本应用采用 **Tabs + Navigation** 复合架构，每个底部 Tab 拥有独立的 `Navigation` 导航栈，确保子页面跳转时底部导航栏始终可见。

**主题**: 全局深色模式（唯一主题），通过 `DarkTheme` 类提供 14 个静态色值。无浅色切换。

## 分层架构

```
┌─────────────────────────────────────────┐
│           UI Layer (pages/)              │
│  MainPage → Tabs → TabContent × 4       │
│    ├── HomeTab / Navigation             │
│    ├── InboxTab / Navigation            │
│    ├── ExploreTab / Navigation          │
│    └── ProfileTab / Navigation          │
│  LoginPage (@Entry)                     │
├─────────────────────────────────────────┤
│        Service Layer (services/)         │
│  AuthService          GitHubAPIService   │
├─────────────────────────────────────────┤
│         Model Layer (models/)            │
│  User                 AuthModels         │
├─────────────────────────────────────────┤
│        Common Layer (common/)            │
│  DarkTheme   APIHeaders                  │
│  RepoCard    ListItem    EmptyState      │
│  FilterTabBar  TabBarBuilder            │
└─────────────────────────────────────────┘
```

## 组件树

```
EntryAbility (UIAbility)
  └─ loadContent('pages/MainPage')
       └─ MainPage.ets (@Entry)
            └─ Tabs(barPosition: End, barHeight: 52dp, animationDuration: 0)
                 ├─ TabContent[0]: HomeTab
                 │    └─ Navigation(homeStack)
                 │         ├─ 顶部导航栏 (esc+add+more)
                 │         ├─ 我的工作 (7 项 WorkItem 列表)
                 │         └─ 收藏夹 (FavoriteRepo 卡片)
                 ├─ TabContent[1]: InboxTab
                 │    └─ Navigation(inboxStack)
                 │         ├─ 顶部导航栏 (Inbox title + more)
                 │         ├─ 筛选标签栏 (FilterTabBar)
                 │         └─ EmptyState / 通知列表
                 ├─ TabContent[2]: ExploreTab
                 │    └─ Navigation(exploreStack)
                 │         ├─ 标题
                 │         ├─ 发现 (2 列 discoverItem)
                 │         └─ 活动 (ActivityItem 流 + RepoCard)
                 └─ TabContent[3]: ProfileTab
                      └─ Navigation(profileStack)
                           ├─ 顶部图标 (share + settings)
                           ├─ 个人信息 (头像 + 用户名 + 状态框)
                           ├─ 深色模式（固定，无 Toggle）
                           └─ 资源列表 (仓库/组织/已加星标)

LoginPage.ets (@Entry, router.pushUrl 独立页面)
  └─ Web (GitHub OAuth authorize page)
       └─ URL 拦截 → AuthService.exchangeCodeForToken() → router.back()
```

## 数据流

### 启动初始化

```
EntryAbility.onCreate()
  → AppStorage: authToken='', isLoggedIn=false
  → AuthService.loadToken() (异步，preferences → AppStorage)
  → windowStage.loadContent('pages/MainPage')
```

### OAuth 登录流

```
ProfileTab "Sign In" → router.pushUrl('pages/LoginPage')
  → Web 加载 github.com/login/oauth/authorize
  → 用户授权 → 回调 URL 含 ?code=xxx
  → AuthService.extractCodeFromUrl(url)
  → AuthService.exchangeCodeForToken(code)
    → POST github.com/login/oauth/access_token
    → saveToken(token) → preferences + AppStorage
  → router.back()
  → ProfileTab.aboutToAppear() → loadUserData()
    → GitHubAPIService.getCurrentUser() → @State user
```

### API 数据流

```
Tab Component (UI)
  → GitHubAPIService.static method
    → buildHeaders() (AuthService.getToken() → Bearer header)
    → @ohos.net.http request
    → JSON parse → typed model
  → @State / @Prop 更新
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

- `MainPage` — 启动默认加载
- `LoginPage` — 通过 `router.pushUrl({ url: 'pages/LoginPage' })` 跳转

### Tab 内部导航（规划）

每个 Tab 持有独立 `NavPathStack`，子页面通过 `.navDestination(@Builder pageMap)` 注册。

## 状态管理

| 状态类型 | 方案 | 作用域 |
|----------|------|--------|
| 认证 | `AppStorage` + `@StorageLink` | 全局 (authToken, isLoggedIn) |
| 用户数据 | `@State user` | ProfileTab |
| Tab 选中 | `@State currentIndex` | MainPage |
| 导航栈 | `NavPathStack` 实例 | 单个 Tab |
| 色彩 | `DarkTheme` 静态类 | 全局引用 |

## 色彩架构

深色唯一主题，由 `common/constants/ThemeConstants.ets` 中的 `DarkTheme` 类定义（14 个 `static readonly` 属性）。所有组件直接 `import { DarkTheme }` 引用，无需 prop 传递。

```typescript
// 唯一引用方式
import { DarkTheme } from '../../common/constants/ThemeConstants';
Column().backgroundColor(DarkTheme.background)
Text().fontColor(DarkTheme.textPrimary)
```

## 目录结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets            # 应用入口
├── pages/
│   ├── MainPage.ets                # @Entry — Tabs 容器
│   ├── LoginPage.ets               # @Entry — OAuth 登录
│   └── tabs/
│       ├── HomeTab.ets             # 主页
│       ├── InboxTab.ets            # 收件箱
│       ├── ExploreTab.ets          # 探索
│       └── ProfileTab.ets          # 个人资料
├── services/
│   ├── AuthService.ets             # OAuth + Token CRUD
│   └── GitHubAPIService.ets        # API 客户端
├── models/
│   ├── User.ets                    # 用户模型
│   └── AuthModels.ets              # OAuthTokenResponse
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets       # DarkTheme 色板
    │   └── APIConstants.ets        # API 配置
    └── components/
        ├── RepoCard.ets            # 仓库卡片
        ├── ListItem.ets            # 列表功能项
        ├── EmptyState.ets          # 空状态
        ├── FilterTabBar.ets        # 筛选标签栏
        └── TabBarBuilder.ets       # Tab 栏配置
```
