# CLAUDE.md

> Claude Code 项目上下文件 — 帮助 AI 理解项目结构、技术栈和开发规范。

## 项目概述

**Github** 是 HarmonyOS NEXT 平台上的 GitHub 客户端应用。通过 GitHub REST API v3，为用户提供原生的仓库浏览、Issue 管理、PR 审查等功能。

- **Bundle Name**: `com.github.web`
- **平台**: HarmonyOS NEXT (API 6.1.0 / 23)
- **架构**: ArkTS + Stage Model

## 技术栈

| 技术 | 用途 |
|------|------|
| **HarmonyOS NEXT** | 运行平台 (API 6.1.0 / 23) |
| **ArkTS** | 声明式 UI + 业务逻辑 (TypeScript 超集) |
| **ArkUI** | 声明式 UI 框架 |
| **Stage Model** | 应用架构 (UIAbility + ExtensionAbility) |
| **GitHub REST API v3** | 数据来源 (github.com/api) |
| **Hvigor** | 构建系统 |
| **ohpm** | 包管理器 |
| **@ohos/hypium** | 测试框架 |

## API 集成

### GitHub REST API v3
- **Base URL**: `https://api.github.com`
- **认证**: Bearer Token / Personal Access Token — 通过 `Authorization: Bearer <token>` 请求头传递
- **核心端点**:
  - `GET /repos/{owner}/{repo}` — 仓库信息
  - `GET /repos/{owner}/{repo}/contents/{path}` — 文件/目录内容
  - `GET /repos/{owner}/{repo}/issues` — Issue 列表
  - `GET /repos/{owner}/{repo}/pulls` — PR 列表
  - `GET /users/{username}` — 用户信息
  - `GET /search/repositories` — 仓库搜索

### 网络请求
- 使用 `@ohos.net.http` 模块发起 HTTP 请求
- 需要声明网络权限: `ohos.permission.INTERNET`

## 目录结构

```
Github/
├── AppScope/              # 应用级清单和资源
│   ├── app.json5          # bundleName, version, SDK 版本
│   └── resources/         # 图标、全局字符串
├── entry/                 # 主模块 (module type: entry)
│   └── src/
│       ├── main/ets/
│       │   ├── entryability/    # UIAbility 入口
│       │   ├── entrybackupability/ # 备份扩展
│       │   ├── pages/           # UI 页面组件
│       │   ├── services/        # API 服务封装 (GitHub API)
│       │   ├── models/          # 数据模型/类型定义
│       │   └── common/          # 公共工具、常量
│       ├── main/resources/      # 字符串、颜色、媒体、profile
│       ├── test/                # 本地单元测试
│       ├── ohosTest/            # 设备集成测试
│       └── mock/                # Mock 数据
├── build-profile.json5    # 构建产品、签名配置
├── hvigor/                # Hvigor 构建配置
└── oh-package.json5       # 依赖管理
```

## 关键文件

| 文件 | 职责 |
|------|------|
| `AppScope/app.json5` | 应用 ID、版本、SDK 版本 |
| `entry/src/main/module.json5` | 模块能力声明（权限、abilities） |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 应用生命周期入口 |
| `entry/src/main/ets/pages/Index.ets` | 主页面 UI |
| `entry/src/main/resources/base/profile/main_pages.json` | 页面路由注册表 |
| `build-profile.json5` | 构建产品和模式配置 |
| `code-linter.json5` | 代码 Lint 规则 |

## 开发规范

### 文件命名
- UI 页面: `pages/XxxPage.ets` — PascalCase + Page 后缀
- Ability: `entryability/XxxAbility.ets` — PascalCase + Ability 后缀
- Service: `services/XxxService.ets` — PascalCase + Service 后缀
- Model: `models/Xxx.ets` — PascalCase
- 测试: `test/Xxx.test.ets` — 小写 .test.ets 后缀

### 代码规范
- 使用 ArkTS 语法（TypeScript 子集，部分特性受限）
- 声明式 UI 使用 `@Component` + `build()` 模式
- 网络请求统一通过 `services/` 层封装，页面不直接调用 HTTP API
- 数据模型在 `models/` 中定义，与 GitHub API 返回结构对应
- 颜色模式适配使用 `COLOR_MODE_NOT_SET`（跟随系统）
- 日志使用 `hilog`，domain 使用 `0x0000`

### 新增功能流程
1. 在 `models/` 定义数据模型（如需新数据结构）
2. 在 `services/` 封装 API 调用
3. 在 `pages/` 创建页面组件
4. 在 `main_pages.json` 注册路由
5. 在 `module.json5` 声明所需权限
6. 编写单元测试

### 构建命令
- `hvigorw assembleHap` — 构建 HAP 包
- `hvigorw test` — 本地单元测试
- `hvigorw ohosTest` — 设备集成测试

### Git 规范
- `.idea/` 已忽略（DevEco Studio 本地配置）
- `local.properties` 已忽略（本地 SDK 路径）
- `oh_modules/` 和 `**/build/` 已忽略（依赖和构建产物）
- 首次克隆后 DevEco Studio 会自动执行 `ohpm install`
