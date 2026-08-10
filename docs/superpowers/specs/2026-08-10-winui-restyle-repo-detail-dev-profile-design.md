# WinUI/Fluent 改造：仓库详情页 + 开发者资料页

- **日期**：2026-08-10
- **范围**：`RepoDetailPage.ets`、`DevProfilePage.ets` 两个页面
- **参考**：`WinUIonWeb-master`（Microsoft WinUI 的 Vue/Web 复刻，仅借鉴视觉语言，不搬代码）

## 背景

云笈藏码当前仓库详情页与开发者资料页为"实色卡片堆叠"布局（GitHub 配色、圆角 16、无动效）。
目标：以 WinUI/Fluent 设计语言重绘这两个页面 —— 半透明亚克力卡片 + Mica 渐变背景 + 背景模糊 +
Fluent 动画 + WinUI 控件细节。

**已确认的三项关键决策：**

1. **改造深度 = 中等**：只做这两个页面；全 app 其它页面（Tabs、其余子页）的实色主题与配色保持不变。
2. **页面结构不变**：仓库详情页保持滚动单页；Issues 进原生列表页，PR/Security 仍跳 WebView。
3. **亚克力实现 = A 真亚克力**：页面背景铺 Mica 渐变层（含 accent 柔光斑），卡片半透明 rgba + `backdropBlur` + 细描边。

## 设计 Token（新增，只加不改）

`ThemeConstants.ets` 中 `DarkTheme` / `LightTheme` **新增静态字段**，不动 `ThemeColors` 接口与
已有 14 字段 → 全 app 其它页面的 `T()` 方法不受影响。accent 沿用现有 GitHub 蓝
（#218BFE / #0969DA），保证全 app 一致。

| Token | 深色 | 浅色 | 用途 |
|-------|------|------|------|
| `micaStart` | `#232323` | `#F3F3F3` | Mica 线性渐变起点 |
| `micaEnd` | `#16161A` | `#ECEEF1` | Mica 线性渐变终点 |
| `micaBlob` | `rgba(76,194,255,.10)` | `rgba(0,103,192,.07)` | accent 柔光斑（radialGradient）|
| `cardGlass` | `rgba(255,255,255,.05)` | `rgba(255,255,255,.70)` | 亚克力卡片底 |
| `cardGlassStrong` | `rgba(255,255,255,.09)` | `rgba(255,255,255,.85)` | 强调卡片 / 输入框 |
| `cardStroke` | `rgba(255,255,255,.08)` | `rgba(0,0,0,.06)` | 卡片描边 |
| `ctrlFill` | `rgba(255,255,255,.06)` | `rgba(255,255,255,.70)` | 控件填充 |
| `ctrlFillPressed` | `rgba(255,255,255,.03)` | `rgba(0,0,0,.06)` | 控件按压态 |

色值来源：WinUIonWeb `theme.css` 的 `--card-bg` / `--card-stroke` / `--ctrl-fill-*` /
`--app-bg` / `--accent-base`（浅色 #0067C0、深色 #4CC2FF 的柔和化处理）。

## 架构与文件改动

### 新增共享组件（`entry/src/main/ets/common/components/`）

| 组件 | 职责 | 关键 API |
|------|------|----------|
| `AcrylicCard.ets` | 亚克力卡片容器：半透明底 + `backdropBlur` + 细描边 + 圆角 + 按压反馈 | `@BuilderParam content`；`backdropBlur(20)`；`stateStyles` |
| `MicaLayer.ets` | Mica 背景层：`linearGradient` + 2 个 accent `radialGradient` 柔光斑 | 通过 `@Prop themeMode` 选深浅色 |
| `WinButton.ets` | WinUI 风格按钮：normal / hover / pressed 三态 | `stateStyles`；`@Prop label/icon/color` |
| `ExpandableSection.ets` | 可折叠区块：标题栏 + 展开/收起 Fluent 动画 | `@State expanded`；高度 + 透明度动画 |

### 修改文件

| 文件 | 改动 |
|------|------|
| `common/constants/ThemeConstants.ets` | 新增上表 8 个 token × 2 主题 |
| `pages/sub/RepoDetailPage.ets` | 整体重绘（见下文） |
| `pages/sub/DevProfilePage.ets` | 整体重绘（见下文） |
| `pages/tabs/ExploreTab.ets` | `repoDetail` / `devProfile` 两个 NavDestination 的 `.backgroundColor(纯色)` → `.linearGradient(Mica)`，标题栏与内容无缝衔接 |
| `pages/tabs/HomeTab.ets` | 同上（涉及该两页的 NavDestination 定义） |
| `pages/tabs/ProfileTab.ets` | 同上 |

> Tab 文件只改这两页 NavDestination 的宿主背景，属于这两个页面的最小必要改动；
> 其余页面（首页列表、消息等）的 NavDestination 不动。

## 动画体系

- 时长：100ms（按压）/ 167ms（反馈）/ 200ms（展开收起）
- 曲线：`Curve.FastOutSlowIn`（Fluent 缓动）
- 按压反馈：`stateStyles` 或 `scale(0.98)` + `.animation()`
- README / Release 展开收起：内容高度 + 透明度过渡（实测若高度动画不丝滑，退化为淡入 + 位移过渡）
- 卡片圆角：16 → 8（WinUI 圆角体系）

## 仓库详情页重绘规格

现有 7 个区块全部保留，行为不变，逐一重绘：

1. **HEADER**（AcrylicCard）
   - owner 小字（textSecondary）→ 仓库名大标题（28 bold）→ 描述 → topics 胶囊（沿用 accent 底）
   - 统计三栏：星标 / 复刻 / 议题，大数字 + 小标签，块间 WinUI 分隔
2. **操作区**（WinButton × 3：议题 / PR / 安全）
   - 行为不变：Issues → `onOpenIssues` 原生页；PR → WebView `/pulls`；安全 → WebView `/security`
   - WinUI 按钮态：细描边 + 图标 + 按压反馈
3. **仓库信息**（AcrylicCard）
   - 默认分支 / 语言圆点（`langColor`）/ 许可证 / 创建 / 最近更新，细分隔行
4. **最新 Release**（ExpandableSection）
   - tag（accent bold）+ 名称 + 日期 + 展开 body（MarkdownView），保留"查看完整 Release"
5. **开发者**（AcrylicCard 行）
   - PersonPicture（首字母兜底头像）+ owner 名 + "查看 ›"（accent）
6. **README**（AcrylicCard + ExpandableSection）
   - 展开后 MarkdownView，保留"在浏览器中查看"
7. **加载 / 空 / 错态**
   - 加载：WinUI ProgressRing 风格（`ProgressRing` 或自绘弧）
   - 空/错：InfoBar 式提示（图标 + 文案）

## 开发者资料页重绘规格

现有区块保留，逐一重绘：

1. **PROFILE HEADER**（AcrylicCard）
   - PersonPicture 头像：圆形 + 细描边圆环 + 无图时首字母兜底
   - 居中排版保留：姓名 → @login → bio → 统计三列（仓库/粉丝/关注）→ 公司/地点/链接
2. **贡献热力图**（AcrylicCard）
   - 保留现有 GraphQL 热力图逻辑与 GitHub 绿阶配色，图例改 WinUI 样式
3. **搜索 + 筛选**
   - 搜索框：AutoSuggestBox 风格（细描边、聚焦态高亮、清除按钮）
   - 筛选标签：Pivot 风格（选中态 accent 底、未选中透明、横向滚动）
4. **仓库列表**（AcrylicCard 容器）
   - 列表项：名称 / 描述 / 语言圆点 + 星标 / 复刻 / 更新日期，WinUI 分隔线

## 性能与风险

- `backdropBlur` 滚动开销：radius ≤ 20，两页卡片数量可控（10–15 张）；实现时若 API 26 模拟器
  表现不佳，用 `backgroundBlurStyle`（系统 BlurStyle）兜底，视觉以接近 WinUI 为准。
- Mica 渐变 + 光斑仅占两页，不影响其余页面。
- 标题栏与 Mica 衔接：改 NavDestination 背景为同一线性渐变；`padding({ top: 32 })` 安全区处理保留。
- ArkTS 严格模式：新组件全部用 `class`/`interface` 显式类型，无内联对象、无对象展开、
  `FontWeight.Light` → `FontWeight.Lighter`。

## 验证

1. `hvigorw assembleHap --mode module -p product=default -p buildMode=debug` 编译通过（ArkTS 严格模式无告警）
2. 真机/模拟器手动验证：
   - 深/浅主题切换：Mica 光斑、卡片玻璃感、文字对比度均正常
   - 仓库详情页 7 区块全部可见可点；Issues/PR/安全行为不变
   - 开发者资料页：头像兜底、搜索筛选、热力图、列表正常
   - 滚动流畅度：backdropBlur 无掉帧
