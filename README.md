# Github

![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-blue?logo=harmonyos)
![API](https://img.shields.io/badge/API-6.1.0-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![Theme](https://img.shields.io/badge/Theme-Dark%20Only-218BFE)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**HarmonyOS NEXT 平台上的 GitHub 客户端**，使用 ArkTS + Stage Model 构建。

支持 OAuth 登录、仓库浏览、Issue、PR、用户动态等 GitHub 核心功能，为 HarmonyOS 用户提供原生的 GitHub 移动体验。

## 已实现

- [x] 🎨 全局深色模式（GitHub 品牌色系，V1.0 规范）
- [x] 🏠 4 Tab 底部导航：主页 / 收件箱 / 探索 / 个人资料
- [x] 🔐 GitHub OAuth Web Flow 登录
- [x] 🧩 全局可复用组件（RepoCard / ListItem / EmptyState / FilterTabBar）
- [x] 📱 API 服务层（GitHub REST API v3 封装、Token 持久化）

## 进行中

- [ ] 🔄 各页面功能完善（通知列表、活动流动态数据等）

## 技术栈

| 技术 | 说明 |
|------|------|
| **HarmonyOS NEXT** | API 6.1.0 (23) |
| **ArkTS** | 声明式 UI + 业务逻辑 |
| **Stage Model** | 应用架构（UIAbility + ExtensionAbility） |
| **GitHub REST API** | v3 API，OAuth 认证 |
| **Hvigor** | 构建系统 |
| **ohpm** | 包管理器 |

## 快速开始

### 环境要求

- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) (5.0 或更高版本)
- HarmonyOS SDK (API 6.1.0+)
- ohpm (随 DevEco Studio 安装)

### 克隆项目

```bash
git clone https://github.com/YOUR_USERNAME/Github.git
cd Github
```

### 运行

1. 用 DevEco Studio 打开项目目录
2. 等待 ohpm 依赖同步完成
3. 连接设备或启动模拟器
4. 点击 **Run** 或按 `Shift + F10`

### 构建

```bash
# Debug 构建
hvigorw assembleHap --mode module -p product=default -p buildMode=debug

# Release 构建
hvigorw assembleHap --mode module -p product=default -p buildMode=release
```

## 项目结构

```
Github/
├── AppScope/                    # 应用级清单和图标资源
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/        # EntryAbility 入口
│   │   ├── pages/
│   │   │   ├── MainPage.ets     # @Entry — Tabs 容器
│   │   │   ├── LoginPage.ets    # @Entry — OAuth 登录页
│   │   │   └── tabs/
│   │   │       ├── HomeTab.ets      # 主页
│   │   │       ├── InboxTab.ets     # 收件箱
│   │   │       ├── ExploreTab.ets   # 探索
│   │   │       └── ProfileTab.ets   # 个人资料
│   │   ├── services/
│   │   │   ├── AuthService.ets      # OAuth / Token 管理
│   │   │   └── GitHubAPIService.ets # API 客户端
│   │   ├── models/
│   │   │   ├── User.ets             # 用户模型
│   │   │   └── AuthModels.ets       # 认证模型
│   │   └── common/
│   │       ├── constants/
│   │       │   ├── ThemeConstants.ets  # DarkTheme 色板
│   │       │   └── APIConstants.ets    # API 端点配置
│   │       └── components/
│   │           ├── RepoCard.ets        # 仓库卡片
│   │           ├── ListItem.ets        # 列表功能项
│   │           ├── EmptyState.ets      # 空状态
│   │           ├── FilterTabBar.ets    # 筛选标签栏
│   │           └── TabBarBuilder.ets   # Tab 栏构建
│   ├── module.json5             # 模块清单（含 INTERNET 权限）
│   └── resources/               # 字符串、颜色、尺寸资源
├── docs/                        # 详细文档
├── .github/                     # CI / PR 模板 / Issue 模板
├── build-profile.json5          # 构建产品配置
└── oh-package.json5             # OHPM 依赖
```

## 页面概览

| Tab | 页面 | 主要元素 |
|-----|------|----------|
| 主页 | HomeTab | 导航栏（搜索/新增/更多）+ 我的工作（7 项列表）+ 收藏夹（仓库卡片） |
| 收件箱 | InboxTab | 导航栏 + 筛选标签栏 + 通知列表 / 空状态 |
| 探索 | ExploreTab | 标题 + 发现入口（热门仓库/精选列表）+ 活动流 |
| 个人资料 | ProfileTab | 分享/设置 + 头像/用户名/状态框 + 资源列表 |

## 文档

| 文档 | 说明 |
|------|------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | 系统架构、组件树、数据流、路由设计 |
| [DEVELOPMENT.md](docs/DEVELOPMENT.md) | 开发指南、ArkTS 规范、调试技巧 |
| [API.md](docs/API.md) | GitHub REST API 集成、OAuth 流程、端点参考 |
| [DESIGN.md](docs/DESIGN.md) | 设计系统、色彩、排版、组件规范 |
| [ROADMAP.md](docs/ROADMAP.md) | 功能路线图、版本计划 |

## 测试

```bash
hvigorw test       # 本地单元测试
hvigorw ohosTest   # 设备集成测试
```

## 许可证

[MIT License](LICENSE)
