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

- [x] 🎨 深色/浅色双主题（14 色值，手动切换，状态栏 + WebView 联动适配）
- [x] 🏠 4 Tab 导航：首页 / 消息 / 发现 / 我的
- [x] 🔐 GitHub OAuth WebView 登录（自定义 Scheme + onLoadIntercept + 防抖）
- [x] 🖼️ 用户头像 + Octocat 应用图标
- [x] 🖥️ 全屏沉浸（透明状态栏 + 底部小白条延伸 + 浅色适配）
- [x] 📡 真实 API：已 Star / 通知 / 热门仓库 / 活动流 / 个人仓库 / 粉丝 / 关注
- [x] 🔄 登录自动刷新 + 主题持久化（preferences 存取）
- [x] 🌐 仓库详情 WebView 浏览（深浅自适应）
- [x] 🗜️ 平板 Navigation.Stack 模式 + 安全区适配
- [x] 🧩 组件库：RepoCard / ListItem / EmptyState / FilterTabBar / TabBarBuilder

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
| 首页 | 我的项目（7 项）+ 我的星标（登录联动刷新） | `GET /user/starred` |
| 消息 | 筛选标签栏 + 通知列表/空状态（类型图标） | `GET /notifications` |
| 发现 | 热门仓库卡片（点击→WebView）+ 活动流 | `GET /search/repos` + `GET /received_events` |
| 我的 | 头像 + 统计 + 仓库/粉丝/关注列表 + 登录/主题开关 | `GET /user` + `GET /user/repos` + WebView |

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
