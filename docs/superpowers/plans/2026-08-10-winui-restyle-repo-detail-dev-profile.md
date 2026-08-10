# WinUI/Fluent 改造（仓库详情页 + 开发者资料页）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用 WinUI/Fluent 设计语言重绘 `RepoDetailPage.ets` 与 `DevProfilePage.ets`（亚克力卡片 + Mica 渐变背景 + 背景模糊 + Fluent 动画），保持页面结构与行为不变。

**Architecture:** 在 `ThemeConstants.ets` 只增不改地加入 WinUI token；新增 5 个共享组件（MicaLayer / AcrylicCard / WinButton / ExpandableSection / PersonPicture）；3 个 Tab 的 NavDestination 背景改为 Mica 渐变；两个子页整体重绘。改造严格限定在这两个页面及其宿主。

**Tech Stack:** ArkTS（TypeScript 严格子集）、ArkUI 声明式范式、API 23。参考 `docs/superpowers/specs/2026-08-10-winui-restyle-repo-detail-dev-profile-design.md`。

## Global Constraints

- **ArkTS 严格模式**：无对象展开 `...obj`；常量用 `class static readonly`；数组显式 `: Xxx[]`；类型显式；`FontWeight.Light` → `FontWeight.Lighter`。禁止内联对象作为类型声明（用 interface/class）。
- **ThemeColors 接口不动**：只向 `DarkTheme`/`LightTheme` **新增静态字段**；不改 `ThemeColors` 接口、不改 `darkColors()/lightColors()`，以免破坏全 app 其它页面的 `T()`。
- **UI accent 保持 GitHub 蓝**（`#218BFE` 深 / `#0969DA` 浅），沿用现有 `T().accent`；`micaBlob` 用 WinUI 蓝（`#4CC2FF` 深 / `#0067C0` 浅）。
- **行为不变**：Issues → 原生 `IssuesPage`；PR/Security → WebView；报告问题 → WebView。不新增 API 端点。
- **backdropBlur radius ≤ 20**；若真机性能差，改用 `backgroundBlurStyle(BlurStyle.Regular)` 兜底。
- **卡片圆角 8**（WinUI），非 16。
- **构建命令**（CLAUDE.md）：
  ```bash
  hvigorw assembleHap --mode module -p product=default -p buildMode=debug
  ```
  > 若 `hvigorw` 不在 PATH：在 DevEco Studio 里打开项目 → Build → Build Hap(s)/App(s)，观察 Build 窗口无 ArkTS 错误即可。两种方式等效。

---

## File Structure Map

**新增文件（`entry/src/main/ets/common/components/`）：**

| 文件 | 职责 |
|------|------|
| `MicaLayer.ets` | 页面背景光斑层（2 个 accent radialGradient 柔光斑） |
| `AcrylicCard.ets` | 亚克力卡片容器：半透明底 + `backdropBlur(20)` + 细描边 + 圆角 + 内边距 |
| `WinButton.ets` | WinUI 按钮：图标+文字、细描边、按压反馈（`stateStyles`） |
| `ExpandableSection.ets` | 折叠区块：标题栏 + 旋转箭头 + 展开内容淡入过渡 |
| `PersonPicture.ets` | 圆形头像：图片加载失败/无图时首字母兜底 + 名字散列色 |

**修改文件：**

| 文件 | 改动 |
|------|------|
| `common/constants/ThemeConstants.ets` | 新增 8 个 token × 2 主题（Task 1） |
| `pages/tabs/ExploreTab.ets` | 2 个 NavDestination 背景 → Mica 渐变（Task 7） |
| `pages/tabs/HomeTab.ets` | 同上（Task 7） |
| `pages/tabs/ProfileTab.ets` | 同上（Task 7） |
| `pages/sub/RepoDetailPage.ets` | 整体重绘（Task 8） |
| `pages/sub/DevProfilePage.ets` | 整体重绘（Task 9） |

---

### Task 1: 新增 WinUI 设计 Token

**Files:**
- Modify: `entry/src/main/ets/common/constants/ThemeConstants.ets`

**Interfaces:**
- Produces: `DarkTheme.micaStart/micaEnd/micaBlob/cardGlass/cardGlassStrong/cardStroke/ctrlFill/ctrlFillPressed`（string）
- Produces: `LightTheme.micaStart/micaEnd/micaBlob/cardGlass/cardGlassStrong/cardStroke/ctrlFill/ctrlFillPressed`（string）
- 后续所有组件与页面直接引用这些静态字段。

- [ ] **Step 1: 在 `DarkTheme` 类的 `clickFeedback` 字段后追加**

找到 `ThemeConstants.ets` 中 `DarkTheme` 类（约 18–33 行），在 `static readonly clickFeedback` 后追加：

```typescript
  static readonly micaStart: string = '#232323';
  static readonly micaEnd: string = '#16161A';
  static readonly micaBlob: string = 'rgba(76,194,255,0.10)';
  static readonly cardGlass: string = 'rgba(255,255,255,0.05)';
  static readonly cardGlassStrong: string = 'rgba(255,255,255,0.09)';
  static readonly cardStroke: string = 'rgba(255,255,255,0.08)';
  static readonly ctrlFill: string = 'rgba(255,255,255,0.06)';
  static readonly ctrlFillPressed: string = 'rgba(255,255,255,0.03)';
```

- [ ] **Step 2: 在 `LightTheme` 类的 `clickFeedback` 字段后追加**

找到 `LightTheme` 类（约 36–51 行），同样追加：

```typescript
  static readonly micaStart: string = '#F3F3F3';
  static readonly micaEnd: string = '#ECEEF1';
  static readonly micaBlob: string = 'rgba(0,103,192,0.07)';
  static readonly cardGlass: string = 'rgba(255,255,255,0.70)';
  static readonly cardGlassStrong: string = 'rgba(255,255,255,0.85)';
  static readonly cardStroke: string = 'rgba(0,0,0,0.06)';
  static readonly ctrlFill: string = 'rgba(255,255,255,0.70)';
  static readonly ctrlFillPressed: string = 'rgba(0,0,0,0.06)';
```

**不要**修改 `ThemeColors` 接口、`darkColors()/lightColors()` 或 `langColor()`。

- [ ] **Step 3: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`，无 ArkTS 错误。若 `hvigorw` 不可用，改用 DevEco Studio IDE Build，确认 Build 窗口无错误。

- [ ] **Step 4: 提交**

```bash
git add entry/src/main/ets/common/constants/ThemeConstants.ets
git commit -m "feat(theme): 新增 WinUI 亚克力/Mica 设计 token"
```

---

### Task 2: MicaLayer 背景层组件

**Files:**
- Create: `entry/src/main/ets/common/components/MicaLayer.ets`

**Interfaces:**
- Consumes: `DarkTheme.micaBlob` / `LightTheme.micaBlob`（Task 1）、`THEME_KEY`
- Produces: `MicaLayer`（无参数组件，尺寸 100%×100%，放在页面根部 Stack 最底层；其上为 Scroll，卡片 backdropBlur 会模糊它）

- [ ] **Step 1: 创建组件文件**

```typescript
import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI Mica 背景层 — 两个 accent 柔光斑（radialGradient）。
 * 放在页面根部 Stack 最底层；上层卡片的 backdropBlur 会模糊它形成亚克力质感。
 */
@Component
export struct MicaLayer {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';

  private blob(): string {
    return this.themeMode === 'dark' ? DarkTheme.micaBlob : LightTheme.micaBlob;
  }

  private blobGradient(): Array<[ResourceColor, number]> {
    return [[this.blob(), 0], ['rgba(0,0,0,0)', 1]];
  }

  build() {
    Stack() {
      Column()
        .width('100%').height('100%')
        .radialGradient({
          center: ['82%', '12%'],
          radius: '60%',
          colors: this.blobGradient()
        })
      Column()
        .width('100%').height('100%')
        .radialGradient({
          center: ['12%', '94%'],
          radius: '65%',
          colors: this.blobGradient()
        })
    }
    .width('100%').height('100%')
  }
}
```

> `ResourceColor` 为 ArkUI 全局类型，无需 import。若 ArkTS 编译器对 `Array<[ResourceColor, number]>` 字面量报类型推断错误，把 colors 改为 `colors: [[this.blob(), 0] as [ResourceColor, number], ['rgba(0,0,0,0)', 1] as [ResourceColor, number]]`。

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/common/components/MicaLayer.ets
git commit -m "feat(components): 新增 MicaLayer 背景层"
```

---

### Task 3: AcrylicCard 亚克力卡片组件

**Files:**
- Create: `entry/src/main/ets/common/components/AcrylicCard.ets`

**Interfaces:**
- Consumes: `DarkTheme.cardGlass/cardStroke`、`LightTheme.cardGlass/cardStroke`、`THEME_KEY`
- Produces: `AcrylicCard({ radius?: number, paddingV?: number, paddingH?: number })`，尾部 `{ ... }` 为 `@BuilderParam content` 内容槽（在父组件作用域内执行，可用父组件的 `this`）

- [ ] **Step 1: 创建组件文件**

```typescript
import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI 亚克力卡片 — 半透明底 + backdropBlur + 细描边 + 圆角。
 * 用法：AcrylicCard() { ...内容... }，内容在父组件作用域内渲染。
 */
@Component
export struct AcrylicCard {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop radius: number = 8;
  @Prop paddingV: number = 18;
  @Prop paddingH: number = 16;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(this.radius)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.cardGlass : LightTheme.cardGlass)
    .backdropBlur(20)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
    .padding({ left: this.paddingH, right: this.paddingH, top: this.paddingV, bottom: this.paddingV })
  }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/common/components/AcrylicCard.ets
git commit -m "feat(components): 新增 AcrylicCard 亚克力卡片"
```

---

### Task 4: WinButton 组件

**Files:**
- Create: `entry/src/main/ets/common/components/WinButton.ets`

**Interfaces:**
- Consumes: `DarkTheme.ctrlFill/ctrlFillPressed/cardStroke`、`LightTheme.ctrlFill/ctrlFillPressed/cardStroke`、`THEME_KEY`
- Produces: `WinButton({ label: string, icon?: string, tint?: string, onAction?: () => void })`；调用处可追加通用属性（如 `.layoutWeight(1)`）作用于根节点

- [ ] **Step 1: 创建组件文件**

```typescript
import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI 风格按钮 — 图标 + 文字 + 细描边 + 按压反馈。
 * 在 Row 中并列时，调用处加 .layoutWeight(1) 均分宽度。
 */
@Component
export struct WinButton {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop label: string = '';
  @Prop icon: string = '';
  @Prop tint: string = '#218BFE';
  onAction?: () => void;

  @Styles
  pressedStyle() {
    .scale({ x: 0.97, y: 0.97 })
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFillPressed : LightTheme.ctrlFillPressed)
  }

  build() {
    Row({ space: 6 }) {
      if (this.icon !== '') {
        Text(this.icon).fontSize(15).fontColor(this.tint)
      }
      Text(this.label).fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.tint)
    }
    .height(40).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
    .borderRadius(8)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
    .stateStyles({ pressed: this.pressedStyle })
    .onClick(() => { if (this.onAction) this.onAction(); })
  }
}
```

> 若 `@Styles` 引用 `this` 编译报错，改用 `@Builder pressedStyle()`（`@Builder` 也支持引用 `this`）。

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/common/components/WinButton.ets
git commit -m "feat(components): 新增 WinButton WinUI 按钮"
```

---

### Task 5: ExpandableSection 折叠区块组件

**Files:**
- Create: `entry/src/main/ets/common/components/ExpandableSection.ets`

**Interfaces:**
- Consumes: `DarkTheme.textPrimary/textTertiary/accent/cardGlass/cardStroke`、`LightTheme.*`、`THEME_KEY`
- Produces: `ExpandableSection({ title: string, icon?: string, accentText?: string, initialExpanded?: boolean })`，尾部 `{ ... }` 为展开内容槽
- 依赖：Task 3 无；独立可编译

- [ ] **Step 1: 创建组件文件**

```typescript
import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI Expander 折叠区块 — 标题栏（旋转箭头 + 可选 accent 副文本）+ 展开内容淡入过渡。
 */
@Component
export struct ExpandableSection {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop title: string = '';
  @Prop icon: string = '';
  @Prop accentText: string = '';
  @Prop initialExpanded: boolean = false;
  @State expanded: boolean = false;
  @BuilderParam content: () => void;

  aboutToAppear(): void {
    this.expanded = this.initialExpanded;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        if (this.icon !== '') {
          Text(this.icon).fontSize(16)
        }
        Text(this.title).fontSize(17).fontWeight(FontWeight.Medium)
          .fontColor(this.themeMode === 'dark' ? DarkTheme.textPrimary : LightTheme.textPrimary)
          .layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.accentText !== '') {
          Text(this.accentText).fontSize(13).fontWeight(FontWeight.Medium)
            .fontColor(this.themeMode === 'dark' ? DarkTheme.accent : LightTheme.accent)
            .maxLines(1)
        }
        Text('▾').fontSize(14)
          .fontColor(this.themeMode === 'dark' ? DarkTheme.textTertiary : LightTheme.textTertiary)
          .rotate({ angle: this.expanded ? 180 : 0 })
          .animation({ duration: 200, curve: Curve.FastOutSlowIn })
      }
      .width('100%').height(48).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
      .onClick(() => { this.expanded = !this.expanded; })

      if (this.expanded) {
        Column() {
          this.content()
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 18 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.FastOutSlowIn }))
      }
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.cardGlass : LightTheme.cardGlass)
    .backdropBlur(20)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
  }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/common/components/ExpandableSection.ets
git commit -m "feat(components): 新增 ExpandableSection 折叠区块"
```

---

### Task 6: PersonPicture 头像组件

**Files:**
- Create: `entry/src/main/ets/common/components/PersonPicture.ets`

**Interfaces:**
- Consumes: `DarkTheme.cardStroke` / `LightTheme.cardStroke`、`THEME_KEY`
- Produces: `PersonPicture({ url?: string, name?: string, size?: number })`（圆形头像 + 描边；无图/加载失败时首字母 + 名字散列色兜底）

- [ ] **Step 1: 创建组件文件**

```typescript
import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI PersonPicture — 圆形头像 + 细描边；无图/加载失败时首字母兜底 + 名字散列色。
 */
@Component
export struct PersonPicture {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop url: string = '';
  @Prop name: string = '';
  @Prop size: number = 80;
  @State failed: boolean = false;

  private initials(): string {
    const nm: string = this.name || '';
    return nm.length > 0 ? nm.charAt(0).toUpperCase() : '?';
  }

  private avatarColor(): string {
    const palette: string[] = ['#218BFE', '#2EA44F', '#8957E5', '#FF9529', '#C42B1C', '#00B4AB'];
    const nm: string = this.name || '?';
    let h: number = 0;
    for (let i = 0; i < nm.length; i++) {
      h = (h * 31 + nm.charCodeAt(i)) % 997;
    }
    return palette[h % palette.length];
  }

  build() {
    Stack() {
      if (this.url !== '' && !this.failed) {
        Image(this.url)
          .width(this.size).height(this.size).borderRadius(this.size / 2).objectFit(ImageFit.Cover)
          .onError(() => { this.failed = true; })
      } else {
        Text(this.initials())
          .fontSize(this.size * 0.36).fontWeight(FontWeight.Medium).fontColor(Color.White)
          .width(this.size).height(this.size).borderRadius(this.size / 2).textAlign(TextAlign.Center)
          .backgroundColor(this.avatarColor())
      }
    }
    .width(this.size).height(this.size)
    .borderRadius(this.size / 2)
    .border({ width: 1.5, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
  }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/common/components/PersonPicture.ets
git commit -m "feat(components): 新增 PersonPicture 头像"
```

---

### Task 7: 3 个 Tab 的 NavDestination 背景换 Mica 渐变

**Files:**
- Modify: `entry/src/main/ets/pages/tabs/ExploreTab.ets:28`（加 helper）、`:81`、`:84`（改背景）
- Modify: `entry/src/main/ets/pages/tabs/HomeTab.ets:28`（加 helper，`T()` 定义行附近）、`:102`、`:105`
- Modify: `entry/src/main/ets/pages/tabs/ProfileTab.ets:28`（加 helper）、`:114`、`:117`

**Interfaces:**
- Consumes: `DarkTheme.micaStart/micaEnd`、`LightTheme.micaStart/micaEnd`（Task 1）
- Produces: 三个 Tab 的 `repoDetail` / `devProfile` 两个 NavDestination 背景为 Mica 渐变；其余 NavDestination 不动

- [ ] **Step 1: ExploreTab 加 helper + 改 2 处背景**

在 `ExploreTab` 的 `private T(): ThemeColors { ... }` 之后（约 28 行）追加私有方法：

```typescript
  private mica(): Array<[ResourceColor, number]> {
    const d: boolean = this.themeMode === 'dark';
    return [[d ? DarkTheme.micaStart : LightTheme.micaStart, 0], [d ? DarkTheme.micaEnd : LightTheme.micaEnd, 1]];
  }
```

把 `repoDetail` NavDestination 的背景（第 81 行）从：
```typescript
        .title('仓库详情').backgroundColor(this.T().background).padding({ top: 32 })
```
改为：
```typescript
        .title('仓库详情').linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).padding({ top: 32 })
```

把 `devProfile` NavDestination 的背景（第 84 行）从：
```typescript
        .title('开发者').backgroundColor(this.T().background).padding({ top: 32 })
```
改为：
```typescript
        .title('开发者').linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).padding({ top: 32 })
```

- [ ] **Step 2: HomeTab 加 helper + 改 2 处背景**

同样在 `T()` 后追加 `mica()` helper（内容同上）。把第 102 行 `repoDetail` 与第 105 行 `devProfile` 的 `.backgroundColor(this.T().background)` 改为 `.linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom })`（整行 `.title(...)` 其它部分不变）。

- [ ] **Step 3: ProfileTab 加 helper + 改 2 处背景**

同样在 `T()` 后追加 `mica()` helper。把第 114 行 `repoDetail` 与第 117 行 `devProfile` 的 `.backgroundColor(this.T().background)` 改为 `.linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom })`。

> `ResourceColor`、`GradientDirection` 均为 ArkUI 全局类型/枚举，无需 import。三个文件均已 import `DarkTheme`/`LightTheme`。

- [ ] **Step 4: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。

- [ ] **Step 5: 提交**

```bash
git add entry/src/main/ets/pages/tabs/ExploreTab.ets entry/src/main/ets/pages/tabs/HomeTab.ets entry/src/main/ets/pages/tabs/ProfileTab.ets
git commit -m "feat(tabs): 仓库详情/开发者 NavDestination 换 Mica 渐变背景"
```

---

### Task 8: 重绘 RepoDetailPage

**Files:**
- Rewrite: `entry/src/main/ets/pages/sub/RepoDetailPage.ets`

**Interfaces:**
- Consumes: 全部新组件（MicaLayer / AcrylicCard / WinButton / ExpandableSection / PersonPicture）、`DarkTheme.ctrlFill`、`LightTheme.ctrlFill`、`langColor`、`RepoRepository`
- Produces: 完整 WinUI 风格仓库详情页；对外 Props/回调签名与原来完全一致（`owner` / `repoName` / `onOpenWebView` / `onOpenDev` / `onOpenIssues` / `onOpenRepo`），Tab 调用处无需改

- [ ] **Step 1: 用以下完整内容替换 RepoDetailPage.ets**

```typescript
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors, langColor } from '../../common/constants/ThemeConstants';
import { MarkdownView } from '../../common/components/MarkdownView';
import { RepoRepository } from '../../services/RepoRepository';
import { AcrylicCard } from '../../common/components/AcrylicCard';
import { MicaLayer } from '../../common/components/MicaLayer';
import { WinButton } from '../../common/components/WinButton';
import { ExpandableSection } from '../../common/components/ExpandableSection';
import { PersonPicture } from '../../common/components/PersonPicture';

const B64CHARS: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
function b64decode(b64: string): string {
  let s: string = b64.replace(/[^A-Za-z0-9+/=]/g, '');
  let out: string = ''; let i: number = 0;
  while (i < s.length) {
    const a: number = B64CHARS.indexOf(s.charAt(i++));
    const b: number = B64CHARS.indexOf(s.charAt(i++));
    const c: number = B64CHARS.indexOf(s.charAt(i++));
    const d: number = B64CHARS.indexOf(s.charAt(i++));
    const n: number = (a << 18) | (b << 12) | ((c & 63) << 6) | (d & 63);
    out += String.fromCharCode((n >> 16) & 255);
    if (c !== 64) out += String.fromCharCode((n >> 8) & 255);
    if (d !== 64) out += String.fromCharCode(n & 255);
  }
  try { return decodeURIComponent(escape(out)); } catch (e) { return out; }
}
function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}
function stripMd(md: string): string {
  return md
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/\*\*(.+?)\*\*/g, '$1')
    .replace(/__(.+?)__/g, '$1')
    .replace(/\*(.+?)\*/g, '$1')
    .replace(/_(.+?)_/g, '$1')
    .replace(/`{1,3}[^`]*`{1,3}/g, '')
    .replace(/\[(.+?)\]\(.+?\)/g, '$1')
    .replace(/!\[.*?\]\(.+?\)/g, '')
    .replace(/^[-*+]\s+/gm, '• ')
    .replace(/^\d+\.\s+/gm, '')
    .replace(/^>\s+/gm, '')
    .replace(/---+/g, '')
    .replace(/^\|.*\|$/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

@Component
export struct RepoDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State repo: Object | null = null;
  private readmeText: string = '';
  @State readmeLoaded: boolean = false;
  @State readmeLoading: boolean = false;
  @State latestRelease: Object | null = null;
  @State loading: boolean = true;
  @Prop @Watch('loadRepo') owner: string = '';
  @Prop @Watch('loadRepo') repoName: string = '';
  onOpenWebView?: (url: string) => void;
  onOpenDev?: (username: string) => void;
  onOpenIssues?: (owner: string, repo: string) => void;
  onOpenRepo?: (owner: string, repo: string) => void;
  private T(): ThemeColors {
    const d: boolean = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated,
      border: d ? DarkTheme.border : LightTheme.border,
      textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary,
      textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary,
      textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary,
      accent: d ? DarkTheme.accent : LightTheme.accent,
      issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen,
      prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue,
      discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple,
      orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange,
      starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow,
      clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback
    };
  }

  aboutToAppear(): void { if (this.owner && this.repoName) this.loadRepo(); }

  async loadRepo(): Promise<void> {
    if (!this.owner || !this.repoName) { this.loading = false; return; }
    this.loading = true;
    try { this.repo = await RepoRepository.getRepoDetail(this.owner, this.repoName); }
    catch (e) { this.repo = null; }
    finally { this.loading = false; }
    if (this.repo) { this.loadReadme(); this.loadRelease(); }
  }

  async loadRelease(): Promise<void> {
    try { this.latestRelease = await RepoRepository.getLatestRelease(this.owner, this.repoName); }
    catch (e) { this.latestRelease = null; }
  }

  async loadReadme(): Promise<void> {
    this.readmeLoading = true;
    try {
      const data: Object = await RepoRepository.getReadme(this.owner, this.repoName);
      const raw: string = (data as Record<string, Object>).content as string || '';
      setTimeout(() => {
        try { this.readmeText = b64decode(raw); } catch (e) { this.readmeText = raw; }
        this.readmeLoaded = true;
      }, 50);
    } catch (e) { this.readmeText = ''; this.readmeLoaded = true; }
    finally { this.readmeLoading = false; }
  }

  private rr(): Record<string, Object> { return (this.repo as Record<string, Object>); }
  private ownerRec(): Record<string, string> { return (this.rr().owner as Record<string, string>); }
  private ownerLogin(): string { return this.ownerRec() ? (this.ownerRec().login || this.owner) : this.owner; }
  private ownerAvatar(): string { return this.ownerRec() ? (this.ownerRec().avatar_url || '') : ''; }
  private num(k: string): number { return (this.rr()[k] as number) || 0; }
  private str(k: string): string { return (this.rr()[k] as string) || ''; }
  private topics(): string[] { return (this.rr().topics as string[]) || []; }
  private licenseName(): string {
    const lic: Record<string, string> = (this.rr().license as Record<string, string>);
    if (lic) { return lic.spdx_id || lic.name || ''; }
    return '';
  }
  private releaseTag(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).tag_name as string) || '') : ''; }
  private releaseName(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).name as string) || '') : ''; }
  private releaseDate(): string { return this.latestRelease ? ((((this.latestRelease as Record<string, Object>).published_at as string) || '').substring(0, 10)) : ''; }
  private releaseBody(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).body as string) || '') : ''; }
  private openWeb(url: string): void { if (this.onOpenWebView) this.onOpenWebView(url); }

  build() {
    Stack() {
      MicaLayer()
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress().width(40).height(40).color(this.T().accent)
          Text('正在加载仓库…').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else if (!this.repo) {
        Column({ space: 12 }) {
          Text('☁').fontSize(48).fontColor(this.T().textTertiary)
          Text('无法加载仓库信息').fontSize(16).fontColor(this.T().textSecondary)
          Text('请检查网络后重试').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // ===== 1. HEADER =====
            AcrylicCard() {
              Column({ space: 10 }) {
                Row({ space: 6 }) {
                  PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), size: 20 })
                  Text(this.ownerLogin()).fontSize(13).fontColor(this.T().textSecondary)
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.width('100%').alignItems(VerticalAlign.Center)
                Text(this.str('name') || this.repoName).fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).width('100%')
                if (this.str('description') !== '') {
                  Text(this.str('description')).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20).width('100%')
                }
                if (this.topics().length > 0) {
                  Row({ space: 6 }) {
                    ForEach(this.topics().slice(0, 8), (t: string, idx: number) => {
                      Text(t).fontSize(12).fontColor(this.T().accent)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
                        .borderRadius(8)
                    }, (t: string, idx: number) => idx.toString())
                  }.width('100%')
                }
                Row({ space: 10 }) {
                  this.statCard('星标', fmt(this.num('stargazers_count')))
                  this.statCard('复刻', fmt(this.num('forks_count')))
                  this.statCard('议题', fmt(this.num('open_issues_count')))
                }.width('100%').margin({ top: 6 })
              }.width('100%')
            }

            // ===== 2. 操作区（议题/PR/安全） =====
            Row({ space: 8 }) {
              WinButton({
                label: '议题', icon: '◉', tint: this.T().issueGreen,
                onAction: () => { if (this.onOpenIssues) this.onOpenIssues(this.owner, this.repoName); }
              }).layoutWeight(1)
              WinButton({
                label: 'PR', icon: '⇄', tint: this.T().prBlue,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/pulls'); }
              }).layoutWeight(1)
              WinButton({
                label: '安全', icon: '🛡', tint: this.T().discussionPurple,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/security'); }
              }).layoutWeight(1)
            }.width('100%')

            // ===== 3. 仓库信息 =====
            AcrylicCard() {
              Column() {
                this.sectionTitle('📋 仓库信息')
                this.infoRow('默认分支', this.str('default_branch'))
                if (this.str('language') !== '') {
                  Divider().color(this.T().border).width('100%')
                  Row() {
                    Text('语言').fontSize(14).fontColor(this.T().textSecondary).width(88)
                    Row({ space: 6 }) {
                      Circle().width(8).height(8).fill(langColor(this.str('language')))
                      Text(this.str('language')).fontSize(15).fontColor(this.T().textPrimary)
                    }
                  }.width('100%').padding({ top: 14, bottom: 14 })
                }
                if (this.licenseName() !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('许可证', this.licenseName())
                }
                if (this.str('created_at') !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('创建', this.str('created_at').substring(0, 10))
                }
                if (this.str('updated_at') !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('最近更新', this.str('updated_at').substring(0, 10))
                }
              }.width('100%')
            }

            // ===== 4. 最新 Release =====
            if (this.latestRelease) {
              ExpandableSection({ title: '最新版本', icon: '🚀', accentText: this.releaseTag(), initialExpanded: true }) {
                Column({ space: 8 }) {
                  if (this.releaseName() !== '') {
                    Text(this.releaseName()).fontSize(14).fontColor(this.T().textSecondary).width('100%')
                  }
                  if (this.releaseDate() !== '') {
                    Text(this.releaseDate()).fontSize(12).fontColor(this.T().textTertiary).width('100%')
                  }
                  if (this.releaseBody() !== '') {
                    MarkdownView({ content: this.releaseBody(), fontSize: 13, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView }).margin({ top: 8 })
                  }
                  Text('查看完整 Release ›').fontSize(14).fontColor(this.T().accent).margin({ top: 8 })
                    .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/releases/tag/' + this.releaseTag()); })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            }

            // ===== 5. 开发者 =====
            AcrylicCard() {
              Row({ space: 12 }) {
                PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), size: 40 })
                Column({ space: 2 }) {
                  Text(this.ownerLogin()).fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                  Text('开发者').fontSize(12).fontColor(this.T().textTertiary)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Row() {
                  Text('查看 ›').fontSize(13).fontColor(this.T().accent)
                }.padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF').borderRadius(8)
                  .onClick(() => { if (this.onOpenDev) this.onOpenDev(this.ownerLogin()); })
              }.width('100%').alignItems(VerticalAlign.Center)
            }

            // ===== 6. 报告问题 =====
            AcrylicCard() {
              Row() {
                Text('🐛 报告问题').fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
                Text('›').fontSize(20).fontColor(this.T().textSecondary)
              }.width('100%').alignItems(VerticalAlign.Center)
              .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/issues/new'); })
            }

            // ===== 7. README =====
            if (this.readmeLoading) {
              AcrylicCard() {
                Column({ space: 8 }) {
                  this.sectionTitle('📄 README')
                  LoadingProgress().width(20).height(20).color(this.T().accent).margin({ bottom: 8 })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            } else if (this.readmeLoaded && this.readmeText !== '') {
              ExpandableSection({ title: 'README', icon: '📄', initialExpanded: false }) {
                Column({ space: 8 }) {
                  MarkdownView({ content: this.readmeText, fontSize: 14, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView })
                  Text('在浏览器中查看 ›').fontSize(14).fontColor(this.T().accent)
                    .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '#readme'); })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            }
          }
          Blank().height(80)
        }.scrollBar(BarState.Off).width('100%').height('100%')
      }
    }.width('100%').height('100%')
  }

  @Builder
  statCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(label).fontSize(12).fontWeight(FontWeight.Medium).fontColor(this.T().textTertiary)
    }.layoutWeight(1).padding({ top: 12, bottom: 12 }).alignItems(HorizontalAlign.Center)
      .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill).borderRadius(8)
  }

  @Builder
  sectionTitle(title: string) {
    Row() {
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
      Blank()
    }.width('100%').padding({ top: 2, bottom: 12 })
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.T().textSecondary).width(88)
      Text(value).fontSize(15).fontColor(this.T().textPrimary).layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }.width('100%').padding({ top: 14, bottom: 14 })
  }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`，无 ArkTS 错误。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/pages/sub/RepoDetailPage.ets
git commit -m "feat(repodetail): WinUI 风格重绘仓库详情页"
```

---

### Task 9: 重绘 DevProfilePage

**Files:**
- Rewrite: `entry/src/main/ets/pages/sub/DevProfilePage.ets`

**Interfaces:**
- Consumes: 全部新组件（MicaLayer / AcrylicCard / WinButton / PersonPicture）、`DarkTheme.ctrlFill`、`LightTheme.ctrlFill`、`UserRepository`、`RepoRepository`
- Produces: 完整 WinUI 风格开发者资料页；对外 Props/回调签名与原来完全一致（`username` / `onOpenRepo` / `onOpenWebView`）

- [ ] **Step 1: 用以下完整内容替换 DevProfilePage.ets**

```typescript
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { UserRepository } from '../../services/UserRepository';
import { RepoRepository } from '../../services/RepoRepository';
import { AcrylicCard } from '../../common/components/AcrylicCard';
import { MicaLayer } from '../../common/components/MicaLayer';
import { WinButton } from '../../common/components/WinButton';
import { PersonPicture } from '../../common/components/PersonPicture';
import type { User } from '../../models/User';

function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}

@Component
export struct DevProfilePage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State profile: User | null = null;
  @State allRepos: Object[] = [];
  @State filteredRepos: Object[] = [];
  @State filterType: number = 0;
  @State searchQuery: string = '';
  @State totalContributions: number = 0;
  @State contribWeeks: Object[] = [];
  @State contribLoading: boolean = true;
  @State loading: boolean = true;
  @Prop @Watch('load') username: string = '';
  onOpenRepo?: (owner: string, repo: string) => void;
  onOpenWebView?: (url: string) => void;
  private filterLabels: string[] = ['全部', '原创', '复刻'];
  private T(): ThemeColors {
    const d: boolean = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated,
      border: d ? DarkTheme.border : LightTheme.border,
      textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary,
      textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary,
      textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary,
      accent: d ? DarkTheme.accent : LightTheme.accent,
      issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen,
      prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue,
      discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple,
      orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange,
      starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow,
      clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback
    };
  }

  aboutToAppear(): void { if (this.username) this.load(); }

  async loadContributions(): Promise<void> {
    try {
      const data: Object = await UserRepository.getContributions(this.username);
      const d: Record<string, Object> = data as Record<string, Object>;
      const userObj: Record<string, Object> = d.data ? (d.data as Record<string, Object>).user as Record<string, Object> : ({} as Record<string, Object>);
      const coll: Record<string, Object> = userObj ? (userObj.contributionsCollection as Record<string, Object>) : ({} as Record<string, Object>);
      const cal: Record<string, Object> = coll ? (coll.contributionCalendar as Record<string, Object>) : ({} as Record<string, Object>);
      this.totalContributions = (cal.totalContributions as number) || 0;
      this.contribWeeks = (cal.weeks as Object[]) || [];
    } catch (e) { this.totalContributions = 0; this.contribWeeks = []; }
    finally { this.contribLoading = false; }
  }

  async load(): Promise<void> {
    this.loading = true;
    try {
      this.profile = await UserRepository.getUser(this.username);
      const items: Object[] = await RepoRepository.getUserRepos(this.username);
      this.allRepos = items.slice(0, 30);
      this.applyFilter();
      this.loadContributions();
    } catch (e) { this.profile = null; this.allRepos = []; }
    finally { this.loading = false; }
  }

  applyFilter(): void {
    let result: Object[] = this.allRepos;
    if (this.filterType === 1) result = result.filter((r: Object) => !((r as Record<string, Object>).fork as boolean));
    else if (this.filterType === 2) result = result.filter((r: Object) => (r as Record<string, Object>).fork as boolean);
    if (this.searchQuery.trim()) {
      const q: string = this.searchQuery.toLowerCase();
      result = result.filter((r: Object) => ((r as Record<string, Object>).name as string || '').toLowerCase().includes(q) || ((r as Record<string, Object>).description as string || '').toLowerCase().includes(q));
    }
    this.filteredRepos = result;
  }

  build() {
    Stack() {
      MicaLayer()
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress().width(32).height(32).color(this.T().accent)
          Text('正在加载…').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else if (!this.profile) {
        Column({ space: 12 }) {
          Text('☁').fontSize(48).fontColor(this.T().textTertiary)
          Text('无法加载用户信息').fontSize(14).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // ===== 1. PROFILE HEADER =====
            AcrylicCard({ paddingV: 24 }) {
              Column() {
                PersonPicture({ url: this.profile.avatar_url, name: this.profile.login, size: 84 })
                Text(this.profile.name || this.profile.login)
                  .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).margin({ top: 12 })
                Text('@' + this.profile.login).fontSize(14).fontColor(this.T().textSecondary).margin({ top: 2 })
                if (this.profile.bio) {
                  Text(this.profile.bio).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20)
                    .textAlign(TextAlign.Center).width('100%').margin({ top: 10 })
                }
                Row() {
                  this.statCol('仓库', this.profile.public_repos)
                  Text('│').fontSize(18).fontColor(this.T().border).margin({ left: 20, right: 20 })
                  this.statCol('粉丝', this.profile.followers)
                  Text('│').fontSize(18).fontColor(this.T().border).margin({ left: 20, right: 20 })
                  this.statCol('关注', this.profile.following)
                }.margin({ top: 16 })
                if (this.profile.company) Text('🏢 ' + (this.profile.company || '')).fontSize(13).fontColor(this.T().textTertiary).margin({ top: 12 })
                if (this.profile.location) Text('📍 ' + (this.profile.location || '')).fontSize(13).fontColor(this.T().textTertiary).margin({ top: 4 })
                if (this.profile.blog) Text('🔗 ' + (this.profile.blog || '')).fontSize(13).fontColor(this.T().accent).margin({ top: 4 })
                WinButton({ label: '分享', icon: '📤', tint: this.T().accent, onAction: () => { if (this.onOpenWebView) this.onOpenWebView('https://github.com/' + this.username); } })
                  .margin({ top: 14 })
              }.alignItems(HorizontalAlign.Center)
            }

            // ===== 2. 贡献热力图 =====
            if (this.contribLoading) {
              AcrylicCard({ paddingV: 14 }) {
                Column({ space: 8 }) {
                  this.sectionTitle('📊 贡献')
                  LoadingProgress().width(20).height(20).color(this.T().accent)
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            } else if (this.contribWeeks.length > 0) {
              AcrylicCard({ paddingV: 14 }) {
                Column() {
                  Row() {
                    Text('📊 贡献').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                    Blank()
                    Text(this.totalContributions + ' 次').fontSize(14).fontColor(this.T().textSecondary)
                  }.width('100%').padding({ top: 2, bottom: 8 })
                  Scroll() {
                    Column({ space: 2 }) {
                      ForEach([0, 1, 2, 3, 4, 5, 6], (row: number, ri: number) => {
                        Row({ space: 2 }) {
                          ForEach(this.contribWeeks.slice(Math.max(0, this.contribWeeks.length - 53)), (week: Object, wi: number) => {
                            if (row < (((week as Record<string, Object>).contributionDays as Object[]) || []).length) {
                              Text('').width(10).height(10)
                                .backgroundColor(this.heatColor((((((week as Record<string, Object>).contributionDays as Object[]) || [])[row] as Record<string, Object>).contributionCount as number) || 0))
                                .borderRadius(2)
                            } else { Text('').width(10).height(10) }
                          }, (week: Object, wi: number) => 'w' + wi)
                        }
                      }, (row: number, ri: number) => 'r' + ri)
                    }
                  }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(82)
                  Row({ space: 4 }) {
                    Text('较少').fontSize(10).fontColor(this.T().textTertiary)
                    Text('■').fontSize(10).fontColor('#1B3419'); Text('■').fontSize(10).fontColor('#0E4429')
                    Text('■').fontSize(10).fontColor('#006D32'); Text('■').fontSize(10).fontColor('#26A641')
                    Text('■').fontSize(10).fontColor('#39D353')
                    Text('较多').fontSize(10).fontColor(this.T().textTertiary)
                  }.width('100%').padding({ top: 4 }).justifyContent(FlexAlign.End)
                }.width('100%')
              }
            }

            // ===== 3. 仓库区（搜索 + 筛选 + 列表） =====
            AcrylicCard({ paddingV: 14 }) {
              Column() {
                Row() {
                  TextInput({ placeholder: '搜索仓库...', text: this.searchQuery })
                    .placeholderColor(this.T().textTertiary).fontSize(14).fontColor(this.T().textPrimary)
                    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill)
                    .borderRadius(8).height(38).layoutWeight(1).padding({ left: 12 })
                    .onChange((v: string) => { this.searchQuery = v; this.applyFilter(); })
                  if (this.searchQuery) {
                    Text('✕').fontSize(16).fontColor(this.T().textTertiary).width(36).height(38).textAlign(TextAlign.Center).lineHeight(38)
                      .onClick(() => { this.searchQuery = ''; this.applyFilter(); })
                  }
                }.width('100%').alignItems(VerticalAlign.Center)

                Scroll() {
                  Row({ space: 8 }) {
                    ForEach(this.filterLabels, (t: string, idx: number) => {
                      Text(t).fontSize(13).fontWeight(FontWeight.Medium)
                        .fontColor(this.filterType === idx ? Color.White : this.T().textSecondary)
                        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                        .backgroundColor(this.filterType === idx ? this.T().accent : (this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill))
                        .borderRadius(8)
                        .onClick(() => { this.filterType = idx; this.applyFilter(); })
                    }, (t: string, idx: number) => idx.toString())
                  }
                }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(40).margin({ top: 8 })

                Text('显示 ' + this.filteredRepos.length + ' 个仓库').fontSize(12).fontColor(this.T().textTertiary)
                  .width('100%').padding({ top: 4, bottom: 8 })

                Column() {
                  ForEach(this.filteredRepos, (item: Object, idx: number) => {
                    Row() {
                      Column() {
                        Text(((item as Record<string, Object>).name as string) || '')
                          .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                        if ((item as Record<string, Object>).description) {
                          Text(((item as Record<string, Object>).description as string) || '')
                            .fontSize(13).fontColor(this.T().textSecondary).maxLines(2).lineHeight(18)
                            .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
                        }
                        Row() {
                          if ((item as Record<string, Object>).language) {
                            Text(((item as Record<string, Object>).language as string) || '')
                              .fontSize(12).fontColor(this.T().textTertiary)
                          }
                          Text(' ★ ' + fmt((item as Record<string, Object>).stargazers_count as number || 0))
                            .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          Text(' ⑂ ' + fmt((item as Record<string, Object>).forks_count as number || 0))
                            .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          if ((item as Record<string, Object>).updated_at) {
                            Text(' · ' + (((item as Record<string, Object>).updated_at as string) || '').substring(0, 10))
                              .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          }
                        }.margin({ top: 6 })
                      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                      Text('›').fontSize(20).fontColor(this.T().textSecondary)
                    }
                    .width('100%').padding({ top: 12, bottom: 12 }).alignItems(VerticalAlign.Center)
                    .onClick(() => {
                      const it = item as Record<string, Object>;
                      const rOwner: string = (it.owner as Record<string, string>).login || this.username;
                      const rName: string = (it.name as string) || '';
                      if (this.onOpenRepo) this.onOpenRepo(rOwner, rName);
                    })
                    if (idx < this.filteredRepos.length - 1) {
                      Divider().color(this.T().border).width('100%')
                    }
                  }, (item: Object, idx: number) => idx.toString())
                }.width('100%')
              }.width('100%')
            }
          }
          Blank().height(80)
        }.scrollBar(BarState.Off).width('100%').height('100%')
      }
    }.width('100%').height('100%')
  }

  private heatColor(count: number): string {
    if (count === 0) return this.T().surfaceElevated;
    if (count <= 2) return '#0E4429'; if (count <= 5) return '#006D32';
    if (count <= 8) return '#26A641'; return '#39D353';
  }

  @Builder
  sectionTitle(title: string) {
    Row() {
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
      Blank()
    }.width('100%').padding({ top: 2, bottom: 4 })
  }

  @Builder
  statCol(label: string, value: number) {
    Column() {
      Text(value.toString()).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(label).fontSize(12).fontColor(this.T().textTertiary)
    }
  }
}
```

- [ ] **Step 2: 编译验证**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`，无 ArkTS 错误。

- [ ] **Step 3: 提交**

```bash
git add entry/src/main/ets/pages/sub/DevProfilePage.ets
git commit -m "feat(devprofile): WinUI 风格重绘开发者资料页"
```

---

### Task 10: 最终构建 + 手工验证

**Files:**
- 无代码改动；只做验证与巡检。

**Interfaces:**
- 全部 Task 1–9 产出。

- [ ] **Step 1: 全量构建**

```bash
cd D:/DevelopFiles/DevEcoStudioProjects/Github
hvigorw assembleHap --mode module -p product=default -p buildMode=debug
```

预期：`BUILD SUCCESSFUL`。若失败，读取错误定位到具体文件修复后重跑。

- [ ] **Step 2: 提交未提交的变更**

```bash
git status
git add -A
git commit -m "chore: WinUI 改造收尾"
```

> 仅当 `git status` 显示有未提交变更时执行；若无变更则跳过。

- [ ] **Step 3: 真机/模拟器手工验证清单**

按清单逐项检查（在 DevEco Studio 运行到设备后）：

1. 深色/浅色主题切换：两个页面的 Mica 光斑、卡片玻璃感、文字对比度均正常；切换无卡死。
2. 仓库详情页：HEADER（owner+头像+仓库名+描述+topics+统计）→ 议题/PR/安全按钮 → 仓库信息 → 最新版本（默认展开，箭头可折叠）→ 开发者 → 报告问题 → README（折叠展开）全部可见可点。
3. 行为回归：点「议题」进原生列表；「PR」「安全」「查看完整 Release」「在浏览器中查看」「报告问题」均跳 WebView。
4. 开发者资料页：头像（含无图首字母兜底）→ 统计 → 分享按钮 → 贡献热力图 → 搜索框过滤 → 筛选标签 → 仓库列表（点进仓库详情）。
5. 滚动流畅度：两页滚动无明显掉帧；backdropBlur 生效（卡片背后可见模糊的光斑）。
6. 若卡片无玻璃感（纯色/黑块）：把相关组件的 `.backdropBlur(20)` 换为 `.backgroundBlurStyle(BlurStyle.Regular)` 再测。

---

## Self-Review 记录

- **Spec 覆盖**：spec 的 token 表（Task 1）、4+1 组件（Task 2–6）、3 Tab 宿主背景（Task 7）、仓库详情 8 区块（Task 8，含补上的"报告问题"）、开发者资料 4 区块（Task 9）、验证（Task 10）全部有对应任务。
- **占位符扫描**：无 TBD/TODO；每步含完整代码。
- **类型一致性**：组件 Props（`radius/paddingV/paddingH/title/icon/accentText/initialExpanded/url/name/size/label/tint/onAction`）在任务间一致；页面对外签名与改动前一致，Tab 调用处无需改。
