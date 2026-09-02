# CLAUDE.md

> Claude Code 项目上下文 — AI 辅助开发参考

## 项目概述

**云笈藏码** — HarmonyOS NEXT 平台上的第三方开源代码仓库浏览客户端。

- **Bundle**: `com.yunjicangma.app` | **API**: 6.1.0 (23)
- **语言**: ArkTS (TypeScript 严格子集)
- **架构**: Stage Model + ArkUI + HdsTabs/HdsNavDestination (UIDesignKit)
- **主题**: 深色/浅色双模式（14 色值 ×2，ThemeColors 接口 + DarkTheme/LightTheme 静态类 + T() 方法，preferences 持久化 + 系统 ColorMode 联动）
- **OAuth**: GitHub Device Flow（仅 `client_id`，客户端零密钥）— 验证码展示 + 轮询换 token
- **安全**: HUKS AES-256-CBC 加密存储 token
- **状态栏**: 透明沉浸（#00FFFFFF）+ statusBarContentColor 深浅切换 + 运行时更新
- **搜索**: 手动屏蔽词过滤 + 分页（上一页/下一页）+ Linguist 语言颜色
- **沉浸光感**: 三档（弱/均衡/强 → GENTLE/ADAPTIVE/EXQUISITE），底部 Tab 栏 + 子页面标题栏联动

## 关键架构决策

| 决策 | 方案 | 原因 |
|------|------|------|
| 主题 | `DarkTheme`/`LightTheme` 静态类 + 组件内 `T()` 方法返回 `ThemeColors` 对象 | ArkTS 禁止裸对象字面量 + 类不能作为对象传递 |
| 主题联动 | 每个组件 `@StorageLink(THEME_KEY)` + `this.T().xxx` | 所有组件即时响应切换 |
| 主题持久化 | `preferences` + `AuthService.loadTheme/saveTheme` | 重启保持 |
| 全屏沉浸 | `setWindowLayoutFullScreen(true)` + `setColorMode` 同步 | 状态栏 + NavDestination 标题栏统一 |
| 底部 Tab 栏 | `HdsTabs` 悬浮样式（IMMERSIVE 材质 + 动态底部间距） | 与 PiliPlus 一致的浮动药丸底栏 |
| Tab 栏隐藏 | `SCROLL_ANIMATION` 模式（发现/消息页滚动隐藏 + 导航深度隐藏） | 首页/我的页不随滚动隐藏 |
| 子页面标题栏 | `HdsNavDestination` + `buildTitleBar()`（IMMERSIVE_GRADIENT_BLUR + scrollEffectOpts） | 官方 HDS 沉浸毛玻璃方案 |
| 标题栏颜色 | `originalStyle` + `scrollEffectStyle` 设置 `mainTitleColor` / `backIconStyle` / `menuStyle` | 浅色模式标题/按钮文字正确显示 |
| 沉浸光感 | `AppStorage('glowLevel')` → `buildTitleBar` 读取 → `materialLevel` 映射 | 与底部 Tab 栏联动 |
| 安全区 | Tab 主页面 `padding({ top: 32, bottom: 20 })`；HdsNavDestination 子页面标题栏 `avoidLayoutSafeArea` + 内容顶部 `Blank(88)` | 沉浸浮层标题栏避让状态栏 |
| 滚动方向检测 | `onScrollFrameBegin` 回调 + `offsetRemain` 方向判断（发现/消息页） | 向下滚动隐藏底栏，向上滚动显示 |
| 导航深度检测 | `setInterval` 轮询 `getAllPathName().length`（300ms） | 进入子页面隐藏底栏，返回首页显示 |
| 底部间距 | 动态计算 `bottomAvoidAreaHeight`（`px2vp(h) + 1`，监听 `avoidAreaChange`） | 与 PiliPlus 一致的系统导航栏避让 |
| 搜索分页 | `SearchRepository.searchRepos(query, page)` + `total_count` 计算总页数 | GitHub API 原生分页支持 |
| OAuth 登录 | Device Flow（`POST /login/device/code` + 轮询 `access_token`） | 仅需 client_id，无需 client_secret 与回调 URL |
| Token 安全 | HUKS AES-256-CBC 加密存储，密钥驻留系统密钥库 | 不可导出密钥，登录态安全 |
| 数据数组 | 具名 `class` 实例 (`new WorkItem(...)`) | ArkTS 禁止内联对象和无法推断的类型 |
| API 类型 | 具名 `interface`（User, Repository, GitHubNotification 等） | ArkTS 禁止内联对象作为类型声明 |
| 服务分层 | `HttpClient`（HTTP 封装）→ `XxxRepository`（业务端点） | 关注点分离，Bearer Token 自动注入 |

## 服务层架构

```
HttpClient.ets          # HTTP 引擎 — buildHeaders() + get<T>() + post<T>() + postRaw<T>() + put() + delete()
  ├── RepoRepository    # 仓库相关 — getStarredRepos, getTrendingRepos, getTopStarredRepos, getMyRepos, getUserRepos, getRepoDetail, getReadme, getLatestRelease, starRepo, unstarRepo
  ├── UserRepository    # 用户相关 — getCurrentUser, getUser, getFollowers, getFollowing, getReceivedEvents, getOrgs, getContributions (GraphQL)
  ├── SearchRepository  # 搜索/通知 — searchRepos(query, page), getNotifications, getIssues, getPullRequests
  └── AuthService       # 认证 — startDeviceFlow, pollDeviceToken, Token/Theme/GlowLevel 持久化 + HUKS 加密
```

## API 端点（按 Repository 分布）

### RepoRepository
| 方法 | 端点 | 返回 |
|------|------|------|
| `getStarredRepos()` | `GET /user/starred?per_page=20` | `Repository[]` |
| `getStarredReposAll()` | `GET /user/starred?per_page=100` | `Repository[]` |
| `getTopStarredRepos()` | `GET /search/repositories?q=stars:>1&sort=stars&order=desc&per_page=20` | `SearchResult` |
| `getTrendingRepos()` | `GET /search/repositories?q=pushed:>=...&stars:>100&sort=stars&order=desc&per_page=10` | `SearchResult` |
| `getMyRepos()` | `GET /user/repos?type=all&per_page=50&sort=updated` | `Repository[]` |
| `getUserRepos(u)` | `GET /users/{u}/repos?per_page=30&sort=updated` | `Repository[]` |
| `getRepoDetail(o,r)` | `GET /repos/{o}/{r}` | `Object` |
| `getReadme(o,r)` | `GET /repos/{o}/{r}/readme` | `Object` |
| `getLatestRelease(o,r)` | `GET /repos/{o}/{r}/releases/latest` | `Object` |
| `starRepo(o,r)` | `PUT /user/starred/{o}/{r}` | `void` |
| `unstarRepo(o,r)` | `DELETE /user/starred/{o}/{r}` | `void` |

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
| `searchRepos(q, page)` | `GET /search/repositories?q={q}&per_page=20&page={page}` | `Object`（含 `total_count` + `items`） |
| `getNotifications()` | `GET /notifications?per_page=20` | `GitHubNotification[]` |
| `getIssues()` | `GET /issues?per_page=30&state=all` | `Object[]` |
| `getPullRequests(u)` | `GET /search/issues?q=is:pr+author:{u}&per_page=20` | `Object[]` |

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets       # 入口: AuthService.init + loadToken + loadTheme + 全屏沉浸 + ColorMode 同步
├── entrybackupability/EntryBackupAbility.ets  # 备份扩展
├── pages/
│   ├── MainPage.ets                    # @Entry — HdsTabs(4 tab, 悬浮底栏, 光感联动, 滚动/导航隐藏)
│   ├── LoginPage.ets                   # @Entry — Device Flow 登录（验证码展示 + 轮询）
│   ├── tabs/
│   │   ├── HomeTab.ets                 # 首页（我的项目 7 项 + 我的星标 RepoCard）
│   │   ├── InboxTab.ets                # 消息（FilterTabBar 4 筛选 + 通知列表 + 滚动隐藏底栏）
│   │   ├── ExploreTab.ets              # 发现（热门仓库 + 动态流 + 滚动隐藏底栏）
│   │   └── ProfileTab.ets              # 我的（头像 + 统计 + 列表 + 登录/登出 + 设置入口）
│   └── sub/
│       ├── SearchPage.ets              # 全局搜索（固定搜索框 + 分页 + 屏蔽词 → RepoDetailPage）
│       ├── WorkPage.ets                # 我的工作子页（议题/PR/仓库/组织/已加星标列表）
│       ├── RepoDetailPage.ets          # 仓库详情（亚克力卡片 HEADER + Stats + Release + README + 开发者入口）
│       ├── DevProfilePage.ets          # 开发者资料（亚克力卡片 头像/统计/贡献热力图/仓库搜索/筛选）
│       ├── IssuesPage.ets              # Issue 列表（筛选标签 + 分隔线）
│       ├── IssueDetailPage.ets         # Issue 详情（状态/标签/Markdown 正文 + 评论列表）
│       ├── NewIssuePage.ets            # 新建议题（填写表单 + POST 创建）
│       ├── StarredReposPage.ets        # 已加星标（全部星标仓库 + 取消星标即时移除）
│       ├── TopReposPage.ets            # 星标榜（按星标数排序的热门仓库）
│       ├── NotificationDetailPage.ets  # 通知详情（元信息 + 关联 Issue 内容 + 评论）
│       ├── SettingsPage.ets            # 设置（深色开关 + 沉浸光感三档 + 手动屏蔽词 + 教程/协议/关于）
│       ├── TutorialPage.ets            # 使用教程
│       ├── PrivacyPage.ets             # 隐私协议
│       └── UserAgreementPage.ets       # 用户协议
├── services/
│   ├── HttpClient.ets                  # HTTP 引擎（get/post 泛型，Bearer 自动注入）
│   ├── RepoRepository.ets             # 仓库端点
│   ├── UserRepository.ets             # 用户/动态/GraphQL 端点
│   ├── SearchRepository.ets           # 搜索/通知/PR 端点（支持分页）
│   └── AuthService.ets                # Device Flow + HUKS 加密 Token + 主题/光感存取
├── models/
│   ├── User.ets                        # User, Repository, RepoOwner, GitHubNotification, SearchResult
│   └── AuthModels.ets                  # AuthState, LoginPageParams, DeviceFlowInfo, DevicePollStatus, DevicePollResult
└── common/
    ├── constants/
    │   ├── ThemeConstants.ets          # DarkTheme / LightTheme / ThemeColors / THEME_KEY / langColor()
    │   └── APIConstants.ets            # API 端点 + OAuth 配置 + AppStorage Key
    ├── utils/
    │   └── NavTitleBar.ets             # 子页面沉浸毛玻璃标题栏（buildTitleBar: scrollEffectOpts + IMMERSIVE + 主题色标题）
    └── components/
        ├── AcrylicCard.ets             # 亚克力卡片（半透明 + backdropBlur + 细描边 + 圆角）
        ├── MicaLayer.ets               # Mica 背景层（渐变 + accent 柔光斑）
        ├── WinButton.ets               # WinUI 风格按钮（三态）
        ├── ExpandableSection.ets       # 可折叠区块（标题栏 + Fluent 展开/收起动画）
        ├── PersonPicture.ets           # 头像组件（URL 加载 + 首字母 fallback）
        ├── RepoCard.ets                # 仓库卡片（头像+描述+语言颜色+星标按钮）
        ├── MarkdownView.ets            # Markdown 渲染（标题/粗体/斜体/链接/代码/列表）
        ├── FilterTabBar.ets            # 筛选标签栏
        ├── EmptyState.ets              # 空状态
        ├── ListItem.ets                # 列表功能项
        └── TabBarBuilder.ets           # Tab 栏配置
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

## HDS 组件使用规范

### 底部 Tab 栏（HdsTabs）
- `barHeight(56)` + `barFloatingStyle` 动态底部间距（`px2vp(h) + 1`）
- `systemMaterialEffect: IMMERSIVE` + 光感三档联动 `glowLevel`
- `SCROLL_ANIMATION` 模式隐藏/显示（发现/消息页滚动触发）
- 首页/我的页仅在导航深度变化时隐藏

### 子页面标题栏（HdsNavDestination）
- `buildTitleBar()` 统一配置：`IMMERSIVE_GRADIENT_BLUR` + `scrollEffectOpts`
- `originalStyle` + `scrollEffectStyle` 设置标题/返回键/菜单颜色（主题联动）
- `avoidLayoutSafeArea: true`（标题栏内容避让状态栏）
- `bindToScrollable([scroller])` 绑定滚动组件

### 内容区滚动
- Scroll 顶部 `Blank().height(88)`（56vp 标题栏 + 32vp 状态栏）
- `onScrollFrameBegin` 检测滚动方向（发现/消息页底栏隐藏）
- `setInterval(300ms)` 轮询 `getAllPathName().length` 检测导航深度

## ArkTS 严格模式必遵规则

1. 常量 → `class static readonly`，禁止 `export const {}`
2. 静态方法 → `ClassName.method()`，禁止 `this`
3. 禁止对象展开 `...obj`
4. 数组 → 显式 `: ClassName[]`，元素用 `new ClassName()`
5. `FontWeight.Light` → `FontWeight.Lighter`
6. 禁止 `get` 属性语法（用普通方法代替）
7. ForEach builder 参数：未使用的 `index` 不声明
8. List 组件必须初始化 `width` 和 `height`
9. Promise 链必须加 `.catch()` 处理异常

## 新增页面流程

1. 创建 `.ets` → 2. `main_pages.json` 注册（如独立页面）→ 3. Tab 内子页用 `NavPathStack.pushPath({ name: 'xxx' })`
4. 子页面用 `HdsNavDestination` 包裹 + `buildTitleBar()` + `.bindToScrollable([scroller])`
5. 内容区 Scroll 顶部加 `Blank().height(88)`

## 构建

```bash
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
hvigorw test       # 本地单元测试
hvigorw ohosTest   # 设备集成测试
```
