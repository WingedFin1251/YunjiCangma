# 云笈藏码

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-blue?logo=harmonyos)
![API](https://img.shields.io/badge/API-6.1.0-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![Theme](https://img.shields.io/badge/Theme-Dark%20Only-218BFE)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

> 云笈纳万卷，一码藏乾坤

**云笈藏码** — HarmonyOS NEXT 平台的第三方开源代码仓库浏览客户端。

> 本应用为第三方非官方客户端，非 GitHub 官方产品。所有数据均通过 GitHub 官方开放接口获取。

## 已实现

- [x] 🎨 全局深色模式（V1.0 规范，14 色值）
- [x] 🏠 4 Tab 导航：首页 / 消息 / 发现 / 我的
- [x] 🔐 GitHub OAuth WebView 登录（自定义 Scheme + onLoadIntercept）
- [x] 🖼️ 用户头像 + GitHub Octocat 应用图标
- [x] 🖥️ 全屏沉浸（状态栏融合 + 底部小白条延伸）
- [x] 📡 真实 API：已 Star 仓库 / 通知 / 热门仓库 / 活动流 / 个人仓库 / 粉丝 / 关注
- [x] 🔄 登录自动刷新（@StorageLink + @Watch）+ 防抖守卫
- [x] 🌐 仓库详情 WebView 浏览（强制深色模式）
- [x] 🧩 组件库：RepoCard / ListItem / EmptyState / FilterTabBar

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
3. 将 Client ID 填入 `entry/src/main/ets/common/constants/APIConstants.ets`

## 项目结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 入口：全屏 + Auth 初始化
├── pages/
│   ├── MainPage.ets                 # @Entry — Tabs 容器（52dp bar + 小白条沉浸）
│   ├── LoginPage.ets                # @Entry — WebView OAuth（onLoadIntercept 拦截回调）
│   └── tabs/
│       ├── HomeTab.ets              # 主页（我的工作 + 收藏夹）
│       ├── InboxTab.ets             # 收件箱（筛选 + 空状态）
│       ├── ExploreTab.ets           # 探索（发现 + 活动流）
│       └── ProfileTab.ets           # 个人资料（登录态双 UI）
├── services/
│   ├── AuthService.ets              # OAuth URL → code→token → 存取
│   └── GitHubAPIService.ets         # HTTP 封装（GET/POST + Bearer）
├── models/                          # User, AuthModels
└── common/
    ├── constants/                   # DarkTheme (14 色), APIConstants
    └── components/                  # RepoCard, ListItem, EmptyState, FilterTabBar
```

## 页面概览

| Tab | 主要元素 | 数据源 |
|-----|----------|--------|
| 首页 | 我的项目（7 项）+ 我的星标（仓库卡片） | `GET /user/starred` |
| 消息 | 筛选标签栏 + 通知列表 / 空状态 | `GET /notifications` |
| 发现 | 发现入口（2 列）+ 动态 + 热门仓库卡片 | `GET /search/repositories` + `GET /received_events` |
| 我的 | 头像 + 用户名/统计 + 仓库/粉丝/关注列表 + 登录/登出 | `GET /user` + `GET /user/repos` + WebView |

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
