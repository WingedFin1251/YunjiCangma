# CLAUDE.md

> Claude Code 项目上下文 — AI 辅助开发参考

## 项目概述

**Github** — HarmonyOS NEXT 平台上的 GitHub 移动客户端。

- **Bundle**: `com.github.web` | **API**: 6.1.0 (23)
- **语言**: ArkTS (TypeScript 严格子集)
- **架构**: Stage Model + ArkUI
- **主题**: 全局深色唯一（V1.0 规范，14 色值 DarkTheme 类）
- **OAuth**: GitHub OAuth App → 自定义 Scheme `githubclient://auth/callback` → WebView `onLoadIntercept` 拦截

## 关键架构决策

| 决策 | 方案 | 原因 |
|------|------|------|
| 主题 | `DarkTheme` 静态类 (14 `static readonly`) | ArkTS 禁止裸对象字面量 |
| 平板适配 | `Navigation.mode(Stack)` | 默认 Split 分栏导致内容区黑屏 |
| 全屏沉浸 | `setWindowLayoutFullScreen(true)` | 状态栏与内容融合 |
| 小白条 | MainPage Column + bottom Row(20, surface) | 底栏色延伸至手势指示条 |
| 安全区 | 所有 Tab `padding({ top: 32, bottom: 64 })` | 避开状态栏 + Tab 栏 |
| OAuth 回调 | `onLoadIntercept` + 自定义 Scheme | WebView 内拦截，不跳系统浏览器 |
| 数据数组 | 具名 `class` 实例 (`new WorkItem(...)`) | ArkTS 禁止内联对象和无法推断类型的数组 |

## 目录结构

```
entry/src/main/ets/
├── entryability/EntryAbility.ets    # 启动: Auth init + 全屏配置
├── pages/
│   ├── MainPage.ets                 # @Entry — Tabs(4 tab, 52dp, 小白条沉浸)
│   ├── LoginPage.ets                # @Entry — WebView OAuth(onLoadIntercept)
│   └── tabs/{Home,Inbox,Explore,Profile}Tab.ets
├── services/{Auth,GitHubAPI}Service.ets
├── models/{User,AuthModels}.ets
└── common/
    ├── constants/{Theme,API}Constants.ets
    └── components/{RepoCard,ListItem,EmptyState,FilterTabBar,TabBarBuilder}.ets
```

## 色彩系统

所有组件统一引用 `DarkTheme` 类：

```typescript
import { DarkTheme } from '../../common/constants/ThemeConstants';
// DarkTheme.background (#121212), DarkTheme.surface (#1E1E1E)
// DarkTheme.accent (#218BFE), DarkTheme.textPrimary (#FFFFFF)
// DarkTheme.issueGreen (#2EA44F), DarkTheme.starYellow (#FFD33D)
// DarkTheme.clickFeedback (#383838)
```

## ArkTS 严格模式必遵规则

1. 常量 → `class static readonly`，禁止 `export const {}`
2. 静态方法 → `ClassName.method()`，禁止 `this`
3. 禁止对象展开 `...obj`
4. 数组 → 显式 `: ClassName[]`，元素用 `new ClassName()`
5. `FontWeight.Light` → `FontWeight.Lighter`

## 新增页面流程

1. 创建 `.ets` → 2. `main_pages.json` 注册（如独立页面）→ 3. Tab 内子页用 `NavPathStack.pushPath()`

## 构建

```bash
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
hvigorw test       # 本地单元测试
hvigorw ohosTest   # 设备集成测试
```
