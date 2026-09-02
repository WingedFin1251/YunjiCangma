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

## 底部导航栏（HdsTabs 悬浮底栏）

| 属性 | 值 |
|------|-----|
| 高度 | 56vp（`barHeight(56)`） |
| 模式 | `BarPosition.End` + `barFloatingStyle`（浮动药丸，与 PiliPlus 一致） |
| 底部间距 | 动态 `px2vp(系统导航栏高度) + 1` |
| 材质 | `IMMERSIVE` + 光感三档联动 `glowLevel` |
| 入口顺序 | 首页 → 消息 → 发现 → 我的 |
| 图标 | 22vp，文字 10.5fp |
| 选中色 | accent |
| 未选中色 | textSecondary |
| 隐藏行为 | 发现/消息页向下滚动隐藏（`SCROLL_ANIMATION`）；首页/我的页仅导航深度变化时隐藏 |

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

### 头像 `PersonPicture.ets`

- 尺寸: 20vp / 40vp / 84vp 三档
- 样式: 圆形裁切，URL 加载 + 首字母 fallback

### 亚克力卡片 `AcrylicCard.ets`

- 半透明背景 + `backdropBlur` + 细描边 + 圆角
- 用于仓库详情 HEADER、开发者资料等

### Mica 背景层 `MicaLayer.ets`

- 线性渐变 + accent 柔光斑（radialGradient）
- 用于仓库详情、开发者资料的 Stack 底层

### WinUI 风格按钮 `WinButton.ets`

- normal/hover/pressed 三态
- 用于仓库详情的操作按钮（议题/PR/安全）

### 可折叠区块 `ExpandableSection.ets`

- 标题栏 + Fluent 展开/收起动画
- 用于 README、Release 等可折叠内容

## 各页面布局

| 页面 | 布局结构 |
|------|----------|
| 首页 | 固定标题栏(26sp + 搜索/新增/刷新) → 我的项目(7 项 WorkItem) → 我的星标(RepoCard 列表) |
| 消息 | 固定标题栏 → FilterTabBar(4 标签) → 通知列表/EmptyState → 滚动隐藏底栏 |
| 发现 | HDS 标题栏(IMMERSIVE 毛玻璃) → 发现入口(2 列) → 动态流 → 热门仓库(RepoCard) → 滚动隐藏底栏 |
| 我的 | 设置入口(☰) → 头像 + 用户名 + 统计 → 资源列表(仓库/粉丝/关注) |
| 搜索 | HDS 标题栏 → 固定搜索框 + 屏蔽词 → 分页结果列表(上一页/下一页) |
| 仓库详情 | HDS 标题栏(Mica 渐变) → 亚克力卡片 HEADER → 操作按钮 → 仓库信息 → Release(可折叠) → 开发者入口 → README(可折叠) |
| 开发者资料 | HDS 标题栏(Mica 渐变) → 亚克力卡片 头像/统计 → 贡献热力图 → 仓库搜索/筛选 |
| 议题详情 | HDS 标题栏 → 状态/标签 → Markdown 正文 → 评论列表 |
| 设置 | HDS 标题栏 → 深色开关 + 沉浸光感三档 + 手动屏蔽词 + 教程/协议/关于 |

## 交互规则

1. **点击反馈**：所有可点击区域按下时背景 → `clickFeedback`，100ms
2. **Tab 切换**：即时生效，无过渡动画
3. **纵向滚动**：原生惯性滑动、回弹
4. **下拉刷新**：不启用
5. **文字溢出**：单行 → 末尾省略号；多行 → 最多 2 行省略
6. **状态同步**：登录/主题切换即时刷新 UI（via `@Watch` + `@StorageLink`）
7. **WebView 暗色**：随主题切换 `WebDarkMode.On` / `WebDarkMode.Off`
