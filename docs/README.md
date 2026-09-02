# 文档索引

> GitHub HarmonyOS 客户端项目文档

## 文档列表

| 文档 | 说明 |
|------|------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | 系统架构 — 组件树、数据流、模块分层、路由设计、主题架构 |
| [DEVELOPMENT.md](DEVELOPMENT.md) | 开发指南 — 环境搭建、编码规范、工作流、调试技巧 |
| [API.md](API.md) | API 集成 — GitHub REST API v3 + GraphQL 封装、认证、端点参考 |
| [DESIGN.md](DESIGN.md) | 设计系统 — 深色/浅色双主题色彩、UI 组件规范、交互模式 |
| [ROADMAP.md](ROADMAP.md) | 路线图 — 功能规划、版本历史 |

## 快速导航

- **新手入门** → [DEVELOPMENT.md](DEVELOPMENT.md)
- **了解架构** → [ARCHITECTURE.md](ARCHITECTURE.md)
- **接入 API** → [API.md](API.md)
- **UI 设计参考** → [DESIGN.md](DESIGN.md)
- **功能规划** → [ROADMAP.md](ROADMAP.md)

## 项目速览

- **平台**: HarmonyOS NEXT (API 6.1.0)
- **语言**: ArkTS（TypeScript 严格子集）
- **架构**: Stage Model + ArkUI + HdsTabs/HdsNavDestination (UIDesignKit)
- **数据源**: GitHub REST API v3 + GraphQL + OAuth Device Flow + HUKS 加密
- **设计**: 深色/浅色双主题（14 色值 ×2，HDS 亚克力卡片 + 沉浸毛玻璃 + 光感三档）
- **服务层**: HttpClient（get/post/put/delete）→ RepoRepository / UserRepository / SearchRepository(分页) / AuthService
- **底部导航**: 主页 / 收件箱 / 探索 / 个人资料（4 Tab，独立 NavPathStack）
- **子页面**: SearchPage / WorkPage / RepoDetailPage / DevProfilePage / IssuesPage / SettingsPage / TutorialPage / PrivacyPage
