# CLAUDE.md

> Claude Code 项目上下文 — AI 辅助开发参考

## 项目概述

**云笈藏码** — HarmonyOS NEXT 平台上的第三方开源代码仓库浏览客户端。

- **Bundle**: `com.yunjicangma.app` | **API**: 6.1.0 (23)
- **语言**: ArkTS (TypeScript 严格子集)
- **架构**: Stage Model + ArkUI
- **主题**: 深色/浅色双模式（14 色值 ×2，ThemeColors 接口 + DarkTheme/LightTheme 静态类 + T() 方法，preferences 持久化 + 系统 ColorMode 联动）
- **OAuth**: GitHub Device Flow（仅 `client_id`，客户端零密钥）— 验证码展示 + 轮询换 token
- **状态栏**: 透明沉浸（#00FFFFFF）+ statusBarContentColor 深浅切换 + 运行时更新
- **搜索**: 手动屏蔽词过滤 + Linguist 语言颜色支持

## 关键架构决策

| 决策 | 方案 | 原因 |
|------|------|------|
| 主题 | `DarkTheme`/`LightTheme` 静态类 + 组件内 `T()` 方法返回 `ThemeColors` 对象 | ArkTS 禁止裸对象字面量 + 类不能作为对象传递 |
| 主题联动 | 每个组件 `@StorageLink(THEME_KEY)` + `this.T().xxx` | 所有组件即时响应切换 |
| 主题持久化 | `preferences` + `AuthService.loadTheme/saveTheme` | 重启保持 |
| 平板适配 | `Navigation.mode(Stack)` | 默认 Split 分栏导致内容区黑屏 |
| 全屏沉浸 | `setWindowLayoutFullScreen(true)` + `setColorMode` 同步 | 状态栏 + NavDestination 标题栏统一 |
| 小白条 | MainPage Column + bottom Row(20, surface) | 底栏色延伸至手势指示条 |
| 安全区 | Tab 主页面 `padding({ top: 32, bottom: 20 })`；HdsNavDestination 子页面标题栏 `avoidLayoutSafeArea` + 内容顶部 `Blank(100)` | 沉浸浮层标题栏避让状态栏，内容滚动滑入栏下 |
| OAuth 登录 | Device Flow（`POST /login/device/code` + 轮询 `access_token`） | 仅需 client_id，无需 client_secret 与回调 URL |
| 登录刷新 | `@StorageLink(AUTH_LOGIN_KEY)` + `@Watch('onLoginChanged')` | 登录完切回 Profile 即显示用户信息 |
| 数据数组 | 具名 `class` 实例 (`new WorkItem(...)`) | ArkTS 禁止内联对象和无法推断的类型 |
| API 类型 | 具名 `interface`（User, Repository, GitHubNotification 等） | ArkTS 禁止内联对象作为类型声明 |
| 服务分层 | `HttpClient`（HTTP 封装）→ `XxxRepository`（业务端点） | 关注点分离，Bearer Token 自动注入 |

## 服务层架构

```
HttpClient.ets          # HTTP 引擎 — buildHeaders() + get<T>() + post<T>() + postRaw<T>()
  ├── RepoRepository    # 仓库相关 — getStarredRepos, getTrendingRepos, getMyRepos, getUserRepos, getRepoDetail, getRepoContents, getReadme, getLatestRelease
  ├── UserRepository    # 用户相关 — getCurrentUser, getUser, getFollowers, getFollowing, getReceivedEvents, getOrgs, getContributions (GraphQL)
  ├── SearchRepository  # 搜索/通知 — searchRepos, getNotifications, getIssues, getPullRequests
  └── AuthService       # 认证 — startDeviceFlow, pollDeviceToken, Token/Theme 持久化
```

## API 端点（按 Repository 分布）

### RepoRepository
| 方法 | 端点 | 返回 |
|------|------|------|
| `getStarredRepos()` | `GET /user/starred?per_page=20` | `Repository[]` |
| `getTrendingRepos()` | `GET /search/repositories?q=stars:>1&sort=stars&order=desc&per_page=10` | `SearchResult` |
| `getMyRepos()` | `GET /user/repos?type=all&per_page=50&sort=updated` | `Repository[]` |
| `getUserRepos(u)` | `GET /users/{u}/repos?per_page=30&sort=updated` | `Repository[]` |
| `getRepoDetail(o,r)` | `GET /repos/{o}/{r}` | `Object` |
| `getRepoContents(o,r,p)` | `GET /repos/{o}/{r}/contents/{p}` | `Object[]` |
| `getReadme(o,r)` | `GET /repos/{o}/{r}/readme` | `Object` |
| `getLatestRelease(o,r)` | `GET /repos/{o}/{r}/releases/latest` | `Object` |

### UserRepository
| 方法 | 端点 | 返回 |
|------|------|------|
| `getCurrentUser()` | `GET /user` | `User` |
| `getUser(u)` | `GET /users/{u}` | `User` |
| `getFollowers(u)` | `GET /users/{u}/followers?per_page=30` | `Object[]` |
| `getFollowing(u)` | `GET /users/{u}/following?per_page=30` | `Object[]` |
| `getReceivedEvents(u)` | `GET /users/{u}/received_events?per_page=10` | `Object[]` |
| `getOrgs()` | `GET /user/orgs?per_page=30` | `Object[]` |
| `getContributions(u)` | `POST /graphql` (GraphQL) | `Object` |

### SearchRepository
| 方法 | 端点 | 返回 |
|------|------|------|
| `searchRepos(q)` | `GET /search/repositories?q=&per_page=20` | `Object` |
| `getNotifications()` | `GET /notifications?per_page=20` | `GitHubNotification[]` |
| `getIssues()` | `GET /issues?per_page=30&state=all` | `Object[]` |
| `getPullRequests(u)` | `GET /search/issues?q=is:pr+author:{u}&per_page=20` | `Object[]` |

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets       # 入口: AuthService.init + loadToken + loadTheme + 全屏沉浸 + ColorMode 同步
├── entrybackupability/EntryBackupAbility.ets  # 备份扩展
├── pages/
│   ├── MainPage.ets                    # @Entry — Tabs(4 tab, 52dp, 小白条沉浸, 主题监听)
│   ├── LoginPage.ets                   # @Entry — Device Flow 登录（验证码展示 + 轮询）
│   ├── tabs/
│   │   ├── HomeTab.ets                 # 首页（我的项目 7 项 → WorkPage/IssuesPage + 我的星标 RepoCard）
│   │   ├── InboxTab.ets                # 消息（FilterTabBar 4 筛选 + 通知列表/空状态）
│   │   ├── ExploreTab.ets              # 发现（热门仓库 + 动态流 → RepoDetailPage/DevProfilePage）
│   │   └── ProfileTab.ets              # 我的（头像 + 统计 + 列表 + 登录/登出）
│   └── sub/
│       ├── SearchPage.ets              # 全局搜索（手动屏蔽词 + Linguist 颜色 → RepoDetailPage）
│       ├── WorkPage.ets                # 我的工作子页（议题/PR/仓库/组织/已加星标列表）
│       ├── RepoDetailPage.ets          # 仓库详情（HEADER + Stats + Release + README + 开发者入口）
│       ├── DevProfilePage.ets          # 开发者资料（头像/统计/仓库搜索/筛选/贡献热力图）
│       ├── IssuesPage.ets              # Issue 列表
│       ├── SettingsPage.ets            # 设置（深色开关 + 手动屏蔽词 + 使用教程 + 隐私协议 + 关于）
│       ├── TutorialPage.ets            # 使用教程
│       └── PrivacyPage.ets             # 隐私协议
├── services/
│   ├── HttpClient.ets                  # HTTP 引擎（get/post 泛型，Bearer 自动注入）
│   ├── RepoRepository.ets             # 仓库端点
│   ├── UserRepository.ets             # 用户/动态/GraphQL 端点
│   ├── SearchRepository.ets           # 搜索/通知/PR 端点
│   └── AuthService.ets                # Device Flow + Token CRUD + 主题存取
├── models/
│   ├── User.ets                        # User, Repository, RepoOwner, GitHubNotification, SearchResult
│   └── AuthModels.ets                  # AuthState, LoginPageParams, DeviceFlowInfo, DevicePollStatus, DevicePollResult
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets          # DarkTheme / LightTheme / ThemeColors / THEME_KEY / langColor()
    │   └── APIConstants.ets            # API 端点 + OAuth 配置 + AppStorage Key
    ├── utils/
    │   └── NavTitleBar.ets             # 子页面沉浸毛玻璃标题栏（HdsNavDestination titleBar）
    └── components/
        ├── RepoCard.ets                # 仓库卡片（头像+描述+语言+星标）
        ├── ListItem.ets                # 列表功能项
        ├── EmptyState.ets              # 空状态
        ├── FilterTabBar.ets            # 筛选标签栏
        ├── TabBarBuilder.ets           # Tab 栏配置
        └── MarkdownView.ets           # Markdown 渲染（README 展示）
```

## 色彩系统

深色/浅色双主题，通过 `T()` 方法运行时切换：

```typescript
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
struct MyComponent {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';

  private T(): ThemeColors {
    const d = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      // ... 14 色值
    };
  }

  build() {
    Column()
      .backgroundColor(this.T().background)   // 深色 #121212 / 浅色 #FFFFFF
      // ...
  }
}
```

| Token | 深色 | 浅色 | 用途 |
|-------|------|------|------|
| `background` | `#121212` | `#FFFFFF` | 页面底层背景 |
| `surface` | `#1E1E1E` | `#F6F8FA` | 卡片、标签栏 |
| `surfaceElevated` | `#2A2A2A` | `#EAEEF2` | 按钮、输入框 |
| `border` | `#333333` | `#D0D7DE` | 分割线 |
| `textPrimary` | `#FFFFFF` | `#1F2328` | 标题、用户名 |
| `textSecondary` | `#B3B3B3` | `#656D76` | 描述、时间戳 |
| `textTertiary` | `#757575` | `#959DA5` | 次要备注 |
| `accent` | `#218BFE` | `#0969DA` | Tab 选中、品牌 |
| `issueGreen` | `#2EA44F` | `#1A7F37` | 议题图标 |
| `prBlue` | `#218BFE` | `#0969DA` | PR 图标 |
| `discussionPurple` | `#8957E5` | `#8250DF` | 讨论图标 |
| `orgOrange` | `#FF9529` | `#CF6A00` | 组织图标 |
| `starYellow` | `#FFD33D` | `#9A6700` | 星标图标 |
| `clickFeedback` | `#383838` | `#E0E4E8` | 点击反馈 |

## ArkTS 严格模式必遵规则

1. 常量 → `class static readonly`，禁止 `export const {}`
2. 静态方法 → `ClassName.method()`，禁止 `this`
3. 禁止对象展开 `...obj`
4. 数组 → 显式 `: ClassName[]`，元素用 `new ClassName()`
5. `FontWeight.Light` → `FontWeight.Lighter`

## 新增页面流程

1. 创建 `.ets` → 2. `main_pages.json` 注册（如独立页面）→ 3. Tab 内子页用 `NavPathStack.pushPath({ name: 'xxx' })`

## 构建

```bash
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
hvigorw test       # 本地单元测试
hvigorw ohosTest   # 设备集成测试
```
