# CLAUDE.md

> Claude Code 项目上下文 — AI 辅助开发参考

## 项目概述

**云笈藏码** — HarmonyOS NEXT 平台上的第三方开源代码仓库浏览客户端。

- **Bundle**: `com.github.web` | **API**: 6.1.0 (23)
- **语言**: ArkTS (TypeScript 严格子集)
- **架构**: Stage Model + ArkUI
- **主题**: 深色/浅色双模式（14 色值，ThemeColors 接口 + T() 方法，preferences 持久化）
- **OAuth**: GitHub OAuth App → 自定义 Scheme `githubclient://auth/callback` → WebView `onLoadIntercept` 拦截
- **状态栏**: 透明沉浸（#00FFFFFF）+ statusBarContentColor 深浅切换 + 运行时更新

## 关键架构决策

| 决策 | 方案 | 原因 |
|------|------|------|
| 主题 | `DarkTheme`/`LightTheme` 静态类 + 组件内 `T()` 方法返回 `ThemeColors` 对象 | ArkTS 禁止裸对象字面量 + 类不能作为对象传递 |
| 主题联动 | 每个组件 `@StorageLink(THEME_KEY)` + `this.T().xxx` | 所有组件即时响应切换 |
| 主题持久化 | `preferences` + `AuthService.loadTheme/saveTheme` | 重启保持 |
| 平板适配 | `Navigation.mode(Stack)` | 默认 Split 分栏导致内容区黑屏 |
| 全屏沉浸 | `setWindowLayoutFullScreen(true)` | 状态栏与内容融合 |
| 小白条 | MainPage Column + bottom Row(20, surface) | 底栏色延伸至手势指示条 |
| 安全区 | 所有 Tab `padding({ top: 24, bottom: 20 })` | 避开状态栏 + Tab 栏 |
| OAuth 回调 | `onLoadIntercept` + 自定义 Scheme | WebView 内拦截，不跳系统浏览器 |
| 登录刷新 | `@StorageLink` + `@Watch('onLoginChanged')` | 登录完切回 Profile 即显示用户信息 |
| 数据数组 | 具名 `class` 实例 (`new WorkItem(...)`) | ArkTS 禁止内联对象和无法推断的类型 |
| API 类型 | 具名 `interface`（RepoOwner, SearchResult 等） | ArkTS 禁止内联对象作为类型声明 |

## API 端点

| 方法 | 端点 | 返回 |
|------|------|------|
| `getCurrentUser()` | `GET /user` | `User` |
| `getUser(username)` | `GET /users/{u}` | `User` |
| `getStarredRepos()` | `GET /user/starred` | `Repository[]` |
| `getMyRepos()` | `GET /user/repos?type=all` | `Repository[]` |
| `getUserRepos(u)` | `GET /users/{u}/repos` | `Repository[]` |
| `getNotifications()` | `GET /notifications` | `GitHubNotification[]` |
| `getTrendingRepos()` | `GET /search/repositories?sort=stars` | `SearchResult` |
| `getReceivedEvents(u)` | `GET /users/{u}/received_events` | `Object[]` |
| `getUserFollowers(u)` | `GET /users/{u}/followers` | `Object[]` |
| `getUserFollowing(u)` | `GET /users/{u}/following` | `Object[]` |
| `getRepoContents(o,r,p)` | `GET /repos/{o}/{r}/contents/{p}` | `Object[]` |
| `getIssues()` | `GET /issues` | `Object[]` |
| `getOrgs()` | `GET /user/orgs` | `Object[]` |
| `searchRepos(q)` | `GET /search/repositories?q=` | `Object` |

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 启动: Auth.init(context) + await loadToken + 全屏
├── pages/
│   ├── MainPage.ets                 # @Entry — Tabs(4 tab, 52dp, 小白条沉浸)
│   ├── LoginPage.ets                # @Entry — WebView OAuth(onLoadIntercept + 防抖)
│   └── tabs/{Home,Inbox,Explore,Profile}Tab.ets  # 首页/消息/发现/我的
├── services/{Auth,GitHubAPI}Service.ets
│   AuthService: UIAbilityContext 替代废弃的 getContext()
├── models/{User(含Repository/Notification),AuthModels}.ets
└── common/
    ├── constants/{Theme,API}Constants.ets
    └── components/{RepoCard,ListItem,EmptyState,FilterTabBar,TabBarBuilder}.ets
```

## 色彩系统

所有组件统一引用 `DarkTheme` 类：

```typescript
import { DarkTheme } from '../../common/constants/ThemeConstants';
// DarkTheme.background (#121212), DarkTheme.surface (#1E1E1E)
// DarkTheme.accent (#218BFE), DarkTheme.textPrimary (#FFFFFF)
// DarkTheme.issueGreen (#2EA44F), DarkTheme.starYellow (#FFD33D)
// DarkTheme.clickFeedback (#383838)
```

## ArkTS 严格模式必遵规则

1. 常量 → `class static readonly`，禁止 `export const {}`
2. 静态方法 → `ClassName.method()`，禁止 `this`
3. 禁止对象展开 `...obj`
4. 数组 → 显式 `: ClassName[]`，元素用 `new ClassName()`
5. `FontWeight.Light` → `FontWeight.Lighter`

## 新增页面流程

1. 创建 `.ets` → 2. `main_pages.json` 注册（如独立页面）→ 3. Tab 内子页用 `NavPathStack.pushPath()`

## 构建

```bash
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
hvigorw test       # 本地单元测试
hvigorw ohosTest   # 设备集成测试
```
