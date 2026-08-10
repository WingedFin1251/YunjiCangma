# MarkdownView 渲染优化设计

- **日期**：2026-08-10
- **范围**：`entry/src/main/ets/common/components/MarkdownView.ets`（单个组件重写）
- **背景**：云笈藏码 README/Release 用自写 Markdown 解析渲染器。当前缺表格/任务列表/图片/嵌套列表，且段落用 `Row` 放多个 `Text` —— **Row 不换行，长段落横向溢出**。

## 已确认范围

1. **补全缺失元素**：表格、任务列表（`- [x]`）、图片（`![alt](url)`）、嵌套列表、标题内联格式。
2. **性能优化**：`parseMd`/`parseInline` 解析结果缓存，主题切换不再重复解析。
3. **非目标**（用户未选）：代码块语言标注、更精致表格样式、GitHub 专属扩展、有序列表编号的"视觉打磨"以外的处理。

## 数据模型

### `MdLine` 类扩展（块级）

现有：`type/text/level`。新增字段：
- `indent: number` —— 列表嵌套缩进（前导空格数）
- `checked: boolean` —— 任务列表勾选态
- `rows: string[][]` —— 表格单元格（按行分组）

### 新增 `MdInline` 段（内联级）

`parseInline` 返回 `MdInline[]`，每段为 `text` 组 或 `img`：
- `text` 段：携带 `InlineSpan[]`（沿用现有 InlineSpan：text/bold/italic/code/strike/link），渲染为**一个自动换行的 `Text`（`Span` 子节点）**
- `img` 段：携带 `imgUrl` + `imgAlt`，渲染为一个 `Image` 组件

统一处理块级与行内图片：单独成行的 `![alt](url)` 自然解析为单一 img 段（全宽图片）；段落中混排的图片拆成独立 img 段（图片前后各一个 text 段）。

## 解析器增强（parseMd）

- **表格**：行以 `|` 开头（trim 后）且下一非空行为分隔符（`^:?-+:?\s*(\|...)*\|?$`）→ 连续 `|` 行收集为 `rows`，push `MdLine('table')`。分隔符行丢弃。
- **任务列表**：`^\s*[-*+]\s+\[([ xX])\]\s+(.+)` → `MdLine('task')`，`checked = (marker==='x'||'X')`，`text`=内容，`indent`=前导空格数。
- **嵌套列表**：ul/ol 正则捕获前导空格 → `indent`。渲染时按 `indent * 12` 左缩进。
- **有序列表编号**：捕获字面编号存 `level`；对**连续 ol 段**递增计数渲染（非 1 开头、全 `1.` 写法都正确），遇非 ol 行重置。

## 内联解析重构（parseInline → MdInline[]）

- 保持现有粗体 `**`/斜体 `*`/行内码 `` ` ``/粗体 `__`/斜体 `_`/删除线 `~~`/链接 `[t](u)` 的 span 逻辑（逐字符扫描 + 链接占位符）。
- 新增：先识别 `![alt](url)` → img 段；段落文本按图片切分为多个 text 段。
- 链接在 text 段中保持 span。

## 渲染器

- **段落/列表项/标题/引用 → `Text` + `Span`**：
  - 一个 `Text` 内含多个 `Span`，**自动换行**（修复 Row 溢出缺陷）
  - `Span` 属性：`fontSize/fontWeight/fontStyle/fontColor/decoration/backgroundColor`（行内码加底色）
  - 链接 `Span`：accent 色 + 下划线 + `.onClick(() => handleLink(url))`；非链接 span 用空 `onClick`（Span 的 onClick 不能条件省略）
  - 标题字号仍按 level（22/18/16）
- **图片**：`Image(imgUrl).width('100%').height(260).objectFit(ImageFit.Contain)` + `.onError` 回退为 alt 文本（无 alt 则显示「图片加载失败」）
- **表格**：外层圆角容器（背景 surfaceElevated + 细边框）→ 表头行粗体（accent 弱化背景）→ 数据行；单元格 `|` 切分、trim、`layoutWeight(1)` 等分 + padding，行间 Divider
- **任务列表**：`☐`/`☑` 符号（checked 用 accent 色）+ 内容
- **嵌套列表**：Row 左留 `indent * 12` 边距
- **告示块/引用**：保留现有样式，但内容走 `inlineText`（内联格式生效）

## 性能优化

- 模块级缓存：`const mdCache: Map<string, MdLine[]>`、`const inlineCache: Map<string, MdInline[]>`
- key = 输入内容字符串（parse 结果与主题无关，安全）
- 容量上限 ~100，超限按插入序删最旧
- 主题切换（StorageLink 触发 build）时 parse 命中缓存，不再重解析

## 文件改动

- 仅 `entry/src/main/ets/common/components/MarkdownView.ets`

## 验证

1. DevEco Studio Build 无 ArkTS 错误。
2. 真机/模拟器手测：
   - 含表格的 README（如 `github/gitignore`）表格正常渲染
   - 含任务列表 / 图片 / 嵌套列表 / `# **粗体标题**` 的 README 各元素正确
   - 长段落自动换行不溢出
   - 主题切换流畅（缓存生效），渲染无闪烁
