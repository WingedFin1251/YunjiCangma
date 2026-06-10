# 设计系统

## 主题

本应用采用 **GitHub 品牌色彩系统**，支持深色和浅色两种主题，默认深色。

### 深色主题

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | `#0D1117` | 页面主背景 |
| `surface` | `#161B22` | 卡片/面板背景 |
| `border` | `#30363D` | 分割线/边框 |
| `textPrimary` | `#E6EDF3` | 主要文字 |
| `textSecondary` | `#8B949E` | 次要文字/辅助 |
| `accent` | `#58A6FF` | 链接/强调色 |
| `tabBarBackground` | `#161B22` | 底部导航栏背景 |
| `tabSelected` | `#FFFFFF` | Tab 选中态图标 |
| `tabUnselected` | `#8B949E` | Tab 未选中态图标 |

### 浅色主题

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | `#FFFFFF` | 页面主背景 |
| `surface` | `#F6F8FA` | 卡片/面板背景 |
| `border` | `#D0D7DE` | 分割线/边框 |
| `textPrimary` | `#1F2328` | 主要文字 |
| `textSecondary` | `#656D76` | 次要文字/辅助 |
| `accent` | `#0969DA` | 链接/强调色 |
| `tabBarBackground` | `#FFFFFF` | 底部导航栏背景 |
| `tabSelected` | `#1F2328` | Tab 选中态图标 |
| `tabUnselected` | `#656D76` | Tab 未选中态图标 |

## 排版

| Token | 值 | 用途 |
|-------|-----|------|
| `page_title_font_size` | `20fp` | 页面标题 |
| `body_font_size` | `16fp` | 正文 |
| `caption_font_size` | `12fp` | 辅助说明文字 |
| `tab_font_size` | `11fp` | Tab 栏文字 |
| `tab_icon_size` | `24fp` | Tab 栏图标 |

## 底部导航栏

### 规格

- **高度**: `56vp`
- **模式**: `BarMode.Fixed`（4 个 Tab 均分宽度）
- **图标**: Unicode 符号（开发阶段），未来替换为 SVG 图标
- **选中态**: 图标颜色变为主色（深色 `#FFFFFF`，浅色 `#1F2328`）
- **动画**: Tab 切换有 200ms 过渡动画

### Tab 图标

| Tab | 图标 | 说明 |
|-----|------|------|
| Home | ⌂ | 首页 Feed |
| Notifications | 🔔 | 通知列表 |
| Explore | ⌕ | 搜索/探索 |
| Profile | 👤 | 个人中心 |

> 正式版本将替换为 SVG 图标或 HarmonyOS SymbolGlyph 资源。

## 组件规范

### 仓库卡片（规划中）

```
┌──────────────────────────────┐
│ 📁 owner/repo        ⭐ 1.2k │
│ A brief description...       │
│ 🔵 TypeScript   🟡 MIT       │
└──────────────────────────────┘
```

- 背景: `surface` 色
- 圆角: `8vp`
- 边框: `1px solid border`
- 内边距: `16vp`

### Issue 列表项（规划中）

```
┌──────────────────────────────┐
│ 🔴 Open │ Issue title        │
│ #1234 · opened 2 days ago    │
│ by username  │  💬 5 comments│
└──────────────────────────────┘
```

### 搜索框

```
┌──────────────────────────────┐
│ 🔍 Search GitHub             │
└──────────────────────────────┘
```

- 高度: `40vp`
- 背景: `surface` 色
- 圆角: `8vp`
- 边框: `1px solid border`
- 左侧图标 + placeholder 文字

### 开关/Toggle

用于深色模式切换：
- 标签: "🌙 Dark Mode"
- `ToggleType.Switch`
- 背景行: `surface` 色，`10vp` 圆角，`1px` 边框

## 图标

### 系统图标（HarmonyOS SF Symbols）

| 用途 | Symbol | 条件 |
|------|--------|------|
| 首页 | `sys.symbol.house_fill` | 选中态 |
| 首页 | `sys.symbol.house` | 未选中态 |
| 通知 | `sys.symbol.bell_fill` | 选中态 |
| 通知 | `sys.symbol.bell` | 未选中态 |
| 搜索 | `sys.symbol.magnifyingglass` | 通用 |
| 个人 | `sys.symbol.person_fill` | 选中态 |
| 个人 | `sys.symbol.person` | 未选中态 |
| 返回 | `sys.symbol.chevron_left` | 导航栏 |

> 开发阶段使用 Unicode 文本替代，正式版切换到 SymbolGlyph。

## 间距系统

| 用途 | 值 |
|------|-----|
| 页面水平内边距 | `16vp` |
| 卡片间距 | `12vp` |
| 组件内部间距 | `8vp` / `12vp` / `16vp` |
| Tab 图标与文字间距 | `2vp` |
| 头像大小 | `80vp` |

## 交互

### Tab 切换

- 点击切换：即时响应
- 禁止滑动切换（`scrollable: false`）
- 200ms 过渡动画

### 子页面导航

- 使用 `Navigation.pushPath()` 推入
- 使用手势返回或返回按钮
- 底部 Tab 栏在子页面中保持可见

### 主题切换

- 位置：Profile Tab → Dark Mode Toggle
- 切换时全局 UI 立即更新
- 默认深色（`AppStorage.setOrCreate('currentTheme', 'dark')`）
