# 设计系统

> 依据：GitHub 移动端 App 深色/浅色模式 UI 开发规范
> 适用终端：HarmonyOS NEXT 移动端
> 设计模式：**深色/浅色双模式**，通过 `AppStorage('currentTheme')` 运行时切换并持久化

## 色彩系统

14 色值 × 2（深色/浅色），纯实色填充。定义在 `common/constants/ThemeConstants.ets`：

- `DarkTheme` 类 — 深色模式色值
- `LightTheme` 类 — 浅色模式色值
- `ThemeColors` 接口 — 类型约束
- `T()` 方法 — 组件内运行时获取当前主题色值

### 深色主题色值

| Token | 色值 | RGB | 用途 |
|-------|------|-----|------|
| `background` | `#121212` | 18,18,18 | 页面底层背景 |
| `surface` | `#1E1E1E` | 30,30,30 | 卡片、标签栏、列表项 |
| `surfaceElevated` | `#2A2A2A` | 42,42,42 | 按钮常态、输入框背景 |
| `border` | `#333333` | 51,51,51 | 分割线、卡片边框 |
| `textPrimary` | `#FFFFFF` | 255,255,255 | 页面标题、用户名 |
| `textSecondary` | `#B3B3B3` | 179,179,179 | 描述文字、时间戳 |
| `textTertiary` | `#757575` | 117,117,117 | 次要备注、空状态辅助 |
| `accent` | `#218BFE` | 33,139,254 | Tab 选中、品牌高亮 |
| `issueGreen` | `#2EA44F` | 46,164,79 | 议题模块图标 |
| `prBlue` | `#218BFE` | 33,139,254 | 拉取请求图标 |
| `discussionPurple` | `#8957E5` | 137,87,229 | 讨论模块图标 |
| `orgOrange` | `#FF9529` | 255,149,41 | 组织模块图标 |
| `starYellow` | `#FFD33D` | 255,211,61 | 已加星标图标 |
| `clickFeedback` | `#383838` | 56,56,56 | 点击反馈底色 |

### 浅色主题色值

| Token | 色值 | RGB | 用途 |
|-------|------|-----|------|
| `background` | `#FFFFFF` | 255,255,255 | 页面底层背景 |
| `surface` | `#F6F8FA` | 246,248,250 | 卡片、标签栏、列表项 |
| `surfaceElevated` | `#EAEEF2` | 234,238,242 | 按钮常态、输入框背景 |
| `border` | `#D0D7DE` | 208,215,222 | 分割线、卡片边框 |
| `textPrimary` | `#1F2328` | 31,35,40 | 页面标题、用户名 |
| `textSecondary` | `#656D76` | 101,109,118 | 描述文字、时间戳 |
| `textTertiary` | `#959DA5` | 149,157,165 | 次要备注、空状态辅助 |
| `accent` | `#0969DA` | 9,105,218 | Tab 选中、品牌高亮 |
| `issueGreen` | `#1A7F37` | 26,127,55 | 议题模块图标 |
| `prBlue` | `#0969DA` | 9,105,218 | 拉取请求图标 |
| `discussionPurple` | `#8250DF` | 130,80,223 | 讨论模块图标 |
| `orgOrange` | `#CF6A00` | 207,106,0 | 组织模块图标 |
| `starYellow` | `#9A6700` | 154,103,0 | 已加星标图标 |
| `clickFeedback` | `#E0E4E8` | 224,228,232 | 点击反馈底色 |

### 组件内主题使用

```typescript
@Component
struct MyComponent {
  @StorageLink('currentTheme') themeMode: string = 'dark';

  private T(): ThemeColors {
    const d = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      // ... 14 色值
    };
  }

  build() {
    Column()
      .backgroundColor(this.T().background)
    Text('Hello')
      .fontColor(this.T().textPrimary)
  }
}
```

## 字体系统

行高 = 字号 × 1.4。字体：系统无衬线。

| 层级 | 字号(sp) | 字重 | 用途 |
|------|----------|------|------|
| 超大标题 | 26 | Bold | 页面一级标题（主页、Inbox、探索） |
| 模块标题 | 20 | Medium | 「我的工作」「收藏夹」「活动」 |
| 内容主文本 | 16 | Regular | 功能名称、仓库名称 |
| 内容辅助 | 14 | Regular | 仓库简介、标签文字 |
| 极小辅助 | 12 | Lighter | 时间戳、统计数字 |

文本溢出：单行末尾省略号 `...`；多行描述最多 2 行省略。

## 栅格、间距与圆角

基于 8dp 基础栅格。

| 用途 | 值 |
|------|-----|
| 页面左右安全边距 | 16dp |
| 页面顶部安全区 | 32dp |
| 页面底部安全区 | 20dp |
| 模块上下间距 | 24dp |
| 模块内元素间距 | 16dp |
| 图标与文字间距 | 12dp |
| 列表项内上下边距 | 14dp |
| 卡片内四周边距 | 16dp |
| 常规卡片/标签圆角 | 8dp |
| 大按钮圆角 | 6dp |
| 头像圆形裁切 | 半径 = 尺寸 1/2 |
| 分割线 | 1dp |

## 图标规范

- 样式：全局线性图标（开发阶段使用 Unicode 占位）
- 常规图标：24dp × 24dp
- Tab 栏图标：20fp，文字 10fp
- 未选中：textSecondary；选中：accent

## 底部导航栏

| 属性 | 值 |
|------|-----|
| 高度 | 52dp |
| 模式 | BarPosition.End（固定底部） |
| 入口顺序 | 主页(☷) → 收件箱(✉) → 探索(◎) → 个人资料(◉) |
| 图标 | 20fp，文字 10fp Lighter |
| 选中色 | accent |
| 未选中色 | textSecondary |
| 切换动画 | 无（`animationDuration: 0`） |

## 全局可复用组件

### 仓库卡片 `RepoCard.ets`

```
┌──────────────────────────────────┐
│ [A]  owner / repo                │
│     描述文字（最多 2 行）...      │
│ ⬤ TypeScript  ⭐ 1.2k    [☆]   │
└──────────────────────────────────┘
```

- 背景: `surface`，圆角: 8dp
- 头像: 32dp 圆形，背景 `surfaceElevated`
- 星标按钮: 选中色 `starYellow`

### 列表功能项 `ListItem.ets`

```
┌──────────────────────────────────┐
│ 🟢  议题                        ›│
└──────────────────────────────────┘
```

- 高度: 52dp，整行可点击
- 图标: 24dp，文字: 16sp Regular

### 空状态 `EmptyState.ets`

```
        [📭 120dp]
    都赶上了！（20sp Medium）
  休息一下，写一些代码...（14sp Regular）
```

- 居中排布，无操作按钮

### 筛选标签栏 `FilterTabBar.ets`

```
[收件箱▼] [重点] [未读] [仓库▼]
```

- 高度: 40dp，背景: `surface`，圆角: 8dp
- 选中: `textPrimary` 文字 + `surfaceElevated` 背景
- 未选中: `textSecondary` 文字

### Markdown 渲染 `MarkdownView.ets`

- README 等 Markdown 内容的 ArkUI 渲染组件

### 头像

- 尺寸: 32dp / 40dp / 48dp 三档
- 样式: 纯圆形裁切，无边框
- 首字母大写显示（用户名首字符）

## 各页面布局

| 页面 | 布局结构 |
|------|----------|
| 主页 | 导航栏(26sp Bold 标题 + 搜索/新增/更多) → 我的项目(7 项 WorkItem) → 我的星标(RepoCard 列表) |
| 收件箱 | 导航栏(Inbox + 更多) → FilterTabBar(4 标签) → 通知列表/EmptyState |
| 探索 | 标题(26sp Bold) → 发现(2 列: 热门仓库/精选列表) → 动态(ActivityItem) → 热门仓库(RepoCard) |
| 个人资料 | 设置入口(☰) → 头像(48dp) + 用户名(24sp Bold) + 状态框 → 统计 → 资源列表(仓库/粉丝/关注) |
| 仓库详情 | HEADER(头像/描述/统计) → Release → README → Info(语言/许可证/分支) |
| 开发者资料 | 头像 + 统计 + 仓库搜索/筛选 → 贡献热力图(GraphQL 5 级色阶) |
| 设置 | 深色模式开关 + 手动屏蔽词管理 + 使用教程 + 隐私协议 + 关于 |

## 交互规则

1. **点击反馈**：所有可点击区域按下时背景 → `clickFeedback`，100ms
2. **Tab 切换**：即时生效，无过渡动画
3. **纵向滚动**：原生惯性滑动、回弹
4. **下拉刷新**：不启用
5. **文字溢出**：单行 → 末尾省略号；多行 → 最多 2 行省略
6. **状态同步**：登录/主题切换即时刷新 UI（via `@Watch` + `@StorageLink`）
7. **WebView 暗色**：随主题切换 `WebDarkMode.On` / `WebDarkMode.Off`
