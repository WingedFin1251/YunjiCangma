# 系统架构

## 概述

本应用采用 **Tabs + Navigation** 复合架构，每个底部 Tab 拥有独立的 `Navigation` 导航栈，确保子页面跳转时底部导航栏始终可见。

## 分层架构

```
┌─────────────────────────────────────────┐
│              UI Layer (pages/)           │
│  MainPage → Tabs → TabContent × 4       │
│    ├── HomeTab / Navigation             │
│    ├── NotificationsTab / Navigation    │
│    ├── ExploreTab / Navigation          │
│    └── ProfileTab / Navigation          │
├─────────────────────────────────────────┤
│          Service Layer (services/)       │
│  GitHubAPIService   AuthService          │
│  RepoService        UserService          │
├─────────────────────────────────────────┤
│           Model Layer (models/)          │
│  Repository   Issue   PullRequest        │
│  User         Notification              │
├─────────────────────────────────────────┤
│          Common Layer (common/)          │
│  ThemeConstants   Components   Utils     │
│  HttpClient       Logger                 │
└─────────────────────────────────────────┘
```

## 组件树

```
EntryAbility (UIAbility)
  └─ MainPage.ets (@Entry, @Component)
       ├─ @StorageLink('currentTheme') → 主题状态
       └─ Tabs(barPosition: BarPosition.End, barMode: BarMode.Fixed)
            ├─ TabContent[0]
            │    └─ HomeTab (@Component)
            │         └─ Navigation(homeStack)
            │              ├─ Column (首页 Feed 内容)
            │              └─ .navDestination(homePageMap)
            │                   └─ 未来: RepoDetail, IssueList 等
            ├─ TabContent[1]
            │    └─ NotificationsTab (@Component)
            │         └─ Navigation(notifStack)
            ├─ TabContent[2]
            │    └─ ExploreTab (@Component)
            │         └─ Navigation(exploreStack)
            └─ TabContent[3]
                 └─ ProfileTab (@Component)
                      ├─ 头像 + 用户名
                      ├─ Toggle (深色模式开关)
                      └─ Navigation(profileStack)
```

## 数据流

### 主题切换流

```
ProfileTab.Toggle.onChange(isOn)
  → AppStorage.setOrCreate('currentTheme', isOn ? 'dark' : 'light')
  → MainPage.@StorageLink 检测变化 → 组件重渲染
  → 4 个 Tab.@Prop theme 同步更新 → 各 Tab 重渲染
  → 全局颜色切换完成
```

### API 数据流（规划）

```
Tab Component (UI)
  → Service Layer (GitHubAPIService)
    → HttpClient (@ohos.net.http)
      → GitHub REST API v3 (api.github.com)
        → JSON Response
      → Model Parser (models/)
    → @State data
  → List / ForEach 渲染
```

## 路由设计

### 页面路由注册

所有 `@Entry` 页面在 `main_pages.json` 中注册：

```json
{
  "src": [
    "pages/MainPage"
  ]
}
```

### Tab 内部导航

每个 Tab 使用独立 `NavPathStack`，通过 `.navDestination()` 注册子页面：

```typescript
// 示例：在 HomeTab 内导航到仓库详情
this.homeStack.pushPath({ name: 'repoDetail', param: { owner: 'octocat', repo: 'Hello-World' } })
```

### 路由架构优势

| 特性 | 说明 |
|------|------|
| Tab 持久化 | 子页面导航不遮挡底部导航栏 |
| 独立栈 | 各 Tab 导航状态互不影响 |
| 返回手势 | `NavPathStack.pop()` 回到上一页 |
| 懒加载 | 子页面仅在导航到时创建 |

## 状态管理

| 状态类型 | 方案 | 作用域 |
|----------|------|--------|
| 主题 | `AppStorage` + `@StorageLink`/`@Prop` | 全局 |
| Tab 选中 | `@State currentIndex` | MainPage |
| 页面数据 | `@State` / `@ObjectLink` | Tab 内部 |
| 导航栈 | `NavPathStack` 实例 | 单个 Tab |

## 目录结构

```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets         # 应用入口，初始化 AppStorage
├── entrybackupability/
│   └── EntryBackupAbility.ets   # 备份扩展
├── pages/
│   ├── MainPage.ets             # @Entry — 主页面 Tabs 容器
│   └── tabs/
│       ├── HomeTab.ets          # 首页
│       ├── NotificationsTab.ets # 通知
│       ├── ExploreTab.ets       # 探索/搜索
│       └── ProfileTab.ets       # 个人中心
├── services/                    # API 服务层（规划中）
├── models/                      # 数据模型（规划中）
└── common/
    ├── constants/
    │   └── ThemeConstants.ets   # 色彩常量
    └── components/
        └── TabBarBuilder.ets    # Tab 栏配置
```
