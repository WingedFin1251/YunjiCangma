# 云笈藏码

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-blue?logo=harmonyos)
![API](https://img.shields.io/badge/API-6.1.0-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![Theme](https://img.shields.io/badge/Theme-Light%20%7C%20Dark-218BFE)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

> 云笈纳万卷，一码藏乾坤

**云笈藏码** — HarmonyOS NEXT 平台的第三方开源代码仓库浏览客户端。

> 本应用为第三方非官方客户端，非 GitHub 官方产品。所有数据均通过 GitHub 官方开放接口获取。

## 已实现

- [x] 🎨 深色/浅色双主题（14 色值，状态栏 + WebView + 系统 ColorMode 联动）
- [x] 🏠 4 Tab 导航（标题栏固定不滚动 + 底部小白条沉浸）
- [x] 🔐 GitHub OAuth WebView 登录（自定义 Scheme + onLoadIntercept + 防抖）
- [x] 🖼️ 用户头像 + Octocat 应用图标
- [x] 🖥️ 全屏沉浸（透明状态栏 + 底部小白条 + 浅色适配）
- [x] 📡 Repository 分层 API（HttpClient → Repo/User/Search/Auth Repository）
- [x] 🔄 登录自动刷新 + 主题持久化（preferences 存取）
- [x] 🌐 仓库详情页 RepoDetailPage（HEADER + Stats + Release + README + 开发者入口）
- [x] 🔍 全局搜索（屏蔽词 + Linguist 颜色 → RepoDetailPage）
- [x] 👤 开发者资料页 DevProfilePage（头像/统计/仓库列表/搜索/筛选/贡献热力图）
- [x] 📊 贡献热力图（GraphQL API + 5 级色阶 + 横向滚动）
- [x] ⚙️ 设置页（深色开关 + 手动屏蔽词 + 使用教程 + 隐私协议 + 关于）
- [x] 📋 首页工作项子页面（议题/PR/仓库/组织/已加星标 → RepoDetailPage）
- [x] 📁 页面分层（tabs/ + sub/） + 🔒 代码混淆（Release）

## 快速开始

### 环境要求

- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) (5.0+)
- HarmonyOS SDK (API 6.1.0+)

### 运行

```bash
git clone https://github.com/WingedFin1251/Github.git
# DevEco Studio → Open → Shift + F10
```

### 配置 OAuth 登录

1. GitHub → Settings → Developer settings → OAuth Apps → New OAuth App
2. **Callback URL**: `githubclient://auth/callback`
3. 将 Client ID 填入 `APIConstants.ets`

## 项目结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 入口：全屏沉浸 + Auth.init + await loadToken + 主题恢复
├── pages/
│   ├── MainPage.ets                 # @Entry — Tabs(52dp, 小白条沉浸, 主题监听)
│   ├── LoginPage.ets                # @Entry — WebView OAuth(onLoadIntercept + 防抖)
│   └── tabs/
│       ├── HomeTab.ets              # 首页（我的项目 + 我的星标）
│       ├── InboxTab.ets             # 消息（筛选标签 + 通知列表/空状态）
│       ├── ExploreTab.ets           # 发现（热门仓库→WebView + 活动流）
│       └── ProfileTab.ets           # 我的（头像 + 列表 + 登录 + 主题开关）
├── services/
│   ├── AuthService.ets              # OAuth + Token CRUD + 主题存取
│   └── GitHubAPIService.ets         # HTTP 封装（Bearer 自动注入 + 11 端点）
├── models/{User,AuthModels}.ets
└── common/
    ├── constants/{Theme,API}Constants.ets  # DarkTheme/LightTheme/ThemeColors + API 端点
    └── components/  # RepoCard / ListItem / EmptyState / FilterTabBar / TabBarBuilder
```

## 页面概览

| Tab | 主要元素 | 数据源 |
|-----|----------|--------|
| 首页 | 标题栏（搜索/新增/更多）+ 我的项目（7项→子页面）+ 我的星标（RepoCard） | `GET /starred` + `GET /issues` + `GET /repos` + `GET /orgs` + `GET /search` |
| 消息 | 标题栏 + 筛选标签栏 + 通知列表/空状态 | `GET /notifications` |
| 发现 | 标题栏 + 发现入口 + 动态 + 热门仓库→WebView | `GET /search/repos` + `GET /received_events` |
| 我的 | 头像 + 统计 + 仓库/粉丝/关注列表 + ☰→设置 | `GET /user` + `GET /user/repos` + WebView |

## 主题系统

| 维度 | 深色 | 浅色 |
|------|------|------|
| 背景 | `#121212` | `#FFFFFF` |
| 表面 | `#1E1E1E` | `#F6F8FA` |
| 文本 | `#FFFFFF` / `#B3B3B3` / `#757575` | `#1F2328` / `#656D76` / `#959DA5` |
| 强调 | `#218BFE` | `#0969DA` |
| 状态栏 | 透明 + 白色图标 | 透明 + 深色图标 |
| WebView | `WebDarkMode.On` | `WebDarkMode.Off` |
| 持久化 | preferences `app_theme` | 同 |

## 文档

| 文档 | 说明 |
|------|------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | 系统架构、组件树、数据流 |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | 开发指南、ArkTS 严格模式规则 |
| [API.md](docs/API.md) | OAuth 流程、REST 端点、数据模型 |
| [DESIGN.md](docs/DESIGN.md) | 色彩、排版、组件规范 |
| [ROADMAP.md](docs/ROADMAP.md) | 版本路线图 |

## 许可证

[MIT License](LICENSE)
