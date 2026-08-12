# 云笈藏码

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-blue?logo=harmonyos)
![API](https://img.shields.io/badge/API-6.1.0-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![Theme](https://img.shields.io/badge/Theme-Light%20%7C%20Dark-218BFE)
![License](https://img.shields.io/badge/License-GPL--3.0-blue)

> 云笈纳万卷，一码藏乾坤

**云笈藏码** — HarmonyOS NEXT 平台的第三方开源代码仓库浏览客户端。

> 本应用为第三方非官方客户端，非 GitHub 官方产品。所有数据均通过 GitHub 官方开放接口获取。

---

## ✨ 功能特性

### 🖥️ 界面

- 深色/浅色双主题（14 色值 ×2，状态栏 + WebView + 系统 ColorMode 联动）
- 4 Tab 导航 + 底部小白条沉浸 + 全屏沉浸（透明状态栏）
- 子页面沉浸毛玻璃标题栏（HdsNavDestination，内容滚动触发模糊）

### 📦 功能

- 仓库浏览 / 全局搜索（手动屏蔽词 + Linguist 语言颜色）
- 仓库详情页（Stats / Release / README / 开发者入口）
- 开发者资料页 + 贡献热力图（GraphQL API + 5 级色阶）
- 消息通知 + 议题 / PR 列表
- 我的工作项子页（议题 / PR / 仓库 / 组织 / 已加星标）
- 首页星标 / 收藏管理

### 🔒 架构与安全

- **GitHub Device Flow 登录** —— 仅需 `client_id`，客户端零密钥
- **Token 加密存储** —— HUKS 系统密钥库 AES-256 加密，密钥不可导出
- Repository 分层 API（HttpClient → Repo/User/Search/Auth）
- Release 代码混淆（属性 / 全局 / 文件名 / 导出 + remove-log）

## 🚀 快速开始

### 环境要求

- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) (5.0+)
- HarmonyOS SDK (API 6.1.0+)

### 运行

```bash
git clone git@github.com:WingedFin1251/YunjiCangma.git
# DevEco Studio → Open → Shift + F10
```

### 配置 Device Flow 登录

1. GitHub → Settings → Developer settings → OAuth Apps → New OAuth App
2. 勾选 **Enable Device Flow**
3. 将 Client ID 填入 `APIConstants.ets`

> 无需 Client Secret、无需 Callback URL —— 设备流仅需 `client_id`，客户端零密钥。
> 设备流登录需在应用内**登出后重新登录**，授权 `repo,user` 作用域。

## 🔐 安全设计

| 环节 | 方案 |
|------|------|
| 认证 | GitHub **Device Flow**（`/login/device/code` + 轮询 `access_token`），仅 `client_id`，无 `client_secret` |
| Token 存储 | **HUKS 系统密钥库** AES-256-CBC 加密，密钥驻留硬件不可导出，登出即销毁 |
| 数据本地化 | 数据仅从 GitHub 接口获取、本地缓存，无自有服务器 |
| 权限 | 仅申请 `INTERNET`，无任何敏感权限 |
| 备份 | Token 为密文，备份数据无密钥不可解 |

## 🛠 技术栈

- **语言**: ArkTS（TypeScript 严格子集）
- **架构**: Stage Model + ArkUI 声明式
- **服务层**: HttpClient → Repository 分层（关注点分离，Bearer 自动注入）
- **Markdown 渲染**: CJMarkdown（Apache-2.0）
- **主题**: ThemeColors 接口 + DarkTheme/LightTheme 静态类，preferences 持久化

## 📁 项目结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 入口：全屏沉浸 + Auth.init + loadToken + 主题恢复
├── pages/
│   ├── MainPage.ets                 # @Entry — Tabs(52dp, 小白条沉浸, 主题监听)
│   ├── LoginPage.ets                # @Entry — Device Flow 登录（验证码 + 轮询）
│   ├── tabs/
│   │   ├── HomeTab.ets              # 首页（我的项目 + 我的星标）
│   │   ├── InboxTab.ets             # 消息（筛选标签 + 通知列表/空状态）
│   │   ├── ExploreTab.ets           # 发现（热门仓库 + 活动流 → RepoDetailPage）
│   │   └── ProfileTab.ets           # 我的（头像 + 列表 + 登录 + 设置入口）
│   └── sub/
│       ├── SearchPage.ets           # 全局搜索（手动屏蔽词 + Linguist 颜色）
│       ├── WorkPage.ets             # 工作项子页（议题/PR/仓库/组织/已加星标）
│       ├── RepoDetailPage.ets       # 仓库详情（HEADER/Stats/Release/README/Info）
│       ├── DevProfilePage.ets       # 开发者资料（统计/仓库/贡献热力图）
│       ├── IssuesPage.ets           # Issue 列表
│       ├── SettingsPage.ets         # 设置（深色/屏蔽词/教程/用户协议/隐私/关于）
│       ├── TutorialPage.ets         # 使用教程
│       ├── UserAgreementPage.ets    # 用户协议
│       └── PrivacyPage.ets          # 隐私协议
├── services/
│   ├── HttpClient.ets               # HTTP 引擎（泛型 get/post，Bearer 自动注入）
│   ├── AuthService.ets              # Device Flow + HUKS 加密 Token + 主题存取
│   ├── RepoRepository.ets          # 仓库端点（Starred/Trending/Detail/Contents/Readme/Release）
│   ├── UserRepository.ets          # 用户端点（Profile/Followers/Following/Events/Orgs/GraphQL）
│   └── SearchRepository.ets        # 搜索/通知端点（Search/Notifications/Issues/PR）
├── models/{User,AuthModels}.ets     # User/Repository/GitHubNotification/SearchResult
└── common/
    ├── constants/{Theme,API}Constants.ets  # DarkTheme/LightTheme/ThemeColors + API 端点
    ├── utils/NavTitleBar.ets               # 子页面沉浸毛玻璃标题栏 helper
    └── components/  # RepoCard / ListItem / EmptyState / FilterTabBar / MarkdownView / TabBarBuilder
```

## 📱 页面概览

| Tab | 主要元素 | 数据源 |
|-----|----------|--------|
| 首页 | 标题栏（搜索/新增/更多）+ 我的项目（7项→子页面）+ 我的星标（RepoCard） | `GET /starred` + `GET /issues` + `GET /repos` + `GET /orgs` + `GET /search` |
| 消息 | 标题栏 + 筛选标签栏 + 通知列表/空状态 | `GET /notifications` |
| 发现 | 标题栏 + 发现入口 + 动态 + 热门仓库→WebView | `GET /search/repos` + `GET /received_events` |
| 我的 | 头像 + 统计 + 仓库/粉丝/关注列表 + ☰→设置 | `GET /user` + `GET /user/repos` + WebView |

## 🎨 主题系统

| 维度 | 深色 | 浅色 |
|------|------|------|
| 背景 | `#121212` | `#FFFFFF` |
| 表面 | `#1E1E1E` | `#F6F8FA` |
| 文本 | `#FFFFFF` / `#B3B3B3` / `#757575` | `#1F2328` / `#656D76` / `#959DA5` |
| 强调 | `#218BFE` | `#0969DA` |
| 状态栏 | 透明 + 白色图标 | 透明 + 深色图标 |
| WebView | `WebDarkMode.On` | `WebDarkMode.Off` |
| 持久化 | preferences `app_theme` | 同 |

## 📚 文档

| 文档 | 说明 |
|------|------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | 系统架构、组件树、数据流 |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | 开发指南、ArkTS 严格模式规则 |
| [API.md](docs/API.md) | OAuth 流程、REST 端点、数据模型 |
| [DESIGN.md](docs/DESIGN.md) | 色彩、排版、组件规范 |
| [ROADMAP.md](docs/ROADMAP.md) | 版本路线图 |

## 📄 许可证

[GNU General Public License v3.0](LICENSE)
