# Github

<!-- Project shields -->
![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT-blue?logo=harmonyos)
![API](https://img.shields.io/badge/API-6.1.0-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**HarmonyOS NEXT 平台上的 GitHub 客户端**，使用 ArkTS + Stage Model 构建。

支持浏览仓库、Issue、Pull Request、用户动态等 GitHub 核心功能，为 HarmonyOS 用户提供原生的 GitHub 移动体验。

> 项目当前处于初始开发阶段，功能正在逐步完善中。

## 功能规划

- [ ] 🔐 OAuth 登录 / Personal Access Token 认证
- [ ] 📁 仓库浏览（文件树、代码查看、README 渲染）
- [ ] 🐛 Issue 管理（列表、筛选、创建、评论）
- [ ] 🔀 Pull Request 浏览与审查
- [ ] 👤 用户主页与动态
- [ ] ⭐ Star / Watch / Fork 操作
- [ ] 🔍 仓库、用户、代码搜索
- [ ] 🌙 深色模式适配
- [ ] 🌐 多语言支持

## 技术栈

| 技术 | 说明 |
|------|------|
| **HarmonyOS NEXT** | API 6.1.0 (23) |
| **ArkTS** | 声明式 UI 开发语言 |
| **Stage Model** | 应用架构模型 |
| **GitHub REST API** | v3 API，JSON 交互 |
| **Hvigor** | 构建系统 |
| **ohpm** | 包管理器 |

## 快速开始

### 环境要求

- [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) (5.0 或更高版本)
- HarmonyOS SDK (API 6.1.0+)
- ohpm (随 DevEco Studio 安装)
- GitHub 账号（用于 API 调用）

### 克隆项目

```bash
git clone https://github.com/YOUR_USERNAME/Github.git
cd Github
```

### 运行

1. 用 DevEco Studio 打开项目目录
2. 等待依赖同步完成（ohpm install 会自动执行）
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
├── AppScope/             # 应用级配置和资源
│   ├── app.json5         # 应用清单 (bundle: com.github.web)
│   └── resources/        # 应用图标等资源
├── entry/                # 主模块
│   └── src/
│       ├── main/
│       │   ├── ets/      # ArkTS 源代码
│       │   │   ├── entryability/   # Ability 入口
│       │   │   ├── pages/          # UI 页面
│       │   │   ├── services/       # API 服务层 (GitHub API)
│       │   │   ├── models/         # 数据模型
│       │   │   └── common/         # 公共工具
│       │   ├── module.json5       # 模块清单
│       │   └── resources/         # 模块资源
│       ├── mock/          # Mock 数据
│       ├── ohosTest/      # 设备集成测试
│       └── test/          # 本地单元测试
├── hvigor/                # Hvigor 构建配置
├── build-profile.json5    # 构建产品配置
└── oh-package.json5       # OHPM 包配置
```

## 核心模块

- **EntryAbility** — 应用主入口，管理应用生命周期
- **Index 页面** — 主页面/首页
- **services/** — GitHub API 封装层（REST v3）
- **models/** — 数据模型定义（Repo, Issue, User 等）
- **BackupExtensionAbility** — 数据备份与恢复支持

## 运行测试

```bash
# 本地单元测试
hvigorw test

# 设备集成测试
hvigorw ohosTest
```

## 贡献

欢迎提交 Issue 和 Pull Request！请参阅 [PR 模板](.github/PULL_REQUEST_TEMPLATE.md)。

## 许可证

[MIT License](LICENSE)
