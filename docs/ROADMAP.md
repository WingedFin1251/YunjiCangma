# 路线图

## 当前版本: v1.1.0（正式版）

- [x] 项目初始化 + 品牌「云笈藏码」
- [x] Repository 分层 API（HttpClient get/post/put/delete → Repo/User/Search/Auth Repository）
- [x] 深色/浅色双主题 + 状态栏透明沉浸 + WebView 联动 + 系统 ColorMode 同步
- [x] 15+ 个 REST 端点 + 1 个 GraphQL 端点（贡献热力图）
- [x] 🔍 全局搜索（固定搜索框 + 分页上一页/下一页 + 手动屏蔽词 + Linguist 语言颜色）
- [x] 📦 仓库详情页（亚克力卡片 HEADER/Stats/Release/README + WinButton 操作按钮）
- [x] 👤 开发者资料页（亚克力卡片 + 贡献热力图 + 仓库搜索/筛选）
- [x] 📊 GitHub 风格贡献热力图（GraphQL API + 5 级色阶）
- [x] 🔒 HUKS AES-256-CBC 加密存储 token + Release 代码混淆
- [x] ⚙️ 设置页（深色开关 + 沉浸光感三档 + 手动屏蔽词 + 教程/协议/关于）
- [x] 📁 页面分层（tabs/ 4 Tab + sub/ 14 子页 + NavPathStack 路由）
- [x] 🏠 HdsTabs 悬浮底栏（IMMERSIVE 材质 + 动态底部间距 + PiliPlus 规格）
- [x] 🧊 HdsNavDestination 子页面沉浸毛玻璃（IMMERSIVE_GRADIENT_BLUR + scrollEffectOpts + 主题色标题）
- [x] ✨ 沉浸光感三档联动（弱/均衡/强 → GENTLE/ADAPTIVE/EXQUISITE，底栏 + 标题栏）
- [x] 🎯 底栏隐藏（发现/消息页滚动隐藏 SCROLL_ANIMATION + 导航深度隐藏）
- [x] 🔐 GitHub OAuth Device Flow 登录（客户端零密钥，HUKS 加密 token）
- [x] 🔄 登录自动刷新 + 主题/光感持久化
- [x] 📝 MarkdownView 组件（README 渲染）
- [x] 🖼️ Octocat 应用图标

## v0.4.0 — 数据对接 ✅ 已完成

- [x] Home Tab — 收藏夹对接 `GET /user/starred` 真实 API
- [x] Inbox Tab — 通知列表对接 `GET /notifications` 真实 API
- [x] Explore Tab — 热门仓库 + 活动流
- [x] Profile Tab — 用户头像 + 仓库列表 + 粉丝/关注列表
- [x] API — `GET /user/repos` + `GET /followers` + `GET /following` + `GET /contents`
- [x] 登录防抖（isProcessing 守卫）+ Token 持久化

## v0.5.0 — 仓库浏览 ✅ 已完成

- [x] `pages/sub/RepoDetailPage.ets` — 仓库详情页（HEADER/Stats/Release/README/Info）
- [x] `common/components/MarkdownView.ets` — Markdown 渲染
- [ ] 代码文件浏览（WebView 跳转代替原生渲染）
- [ ] Star / Unstar API 操作

## v0.6.0 — Issue 与 PR ✅ 已完成

- [x] `pages/sub/IssuesPage.ets` — Issue 列表
- [x] `SearchRepository.getPullRequests()` — PR 列表
- [ ] Issue 详情页 + 筛选
- [ ] PR 详情页 + 文件变更

## v0.7.0 — 通知 ✅ 已完成

- [x] Inbox Tab — 真实通知 API 数据
- [x] 通知类型图标区分（Issue/PR/Discussion）
- [x] 未读指示器（蓝色圆点）
- [ ] 通知标记已读

## v0.8.0 — 搜索 ✅ 已完成

- [x] `pages/sub/SearchPage.ets` — 全局搜索
- [x] 手动屏蔽词过滤
- [x] Linguist 语言颜色标签
- [ ] 搜索类型切换（Repos / Users / Issues）

## v0.9.0 — 用户主页 ✅ 已完成

- [x] `pages/sub/DevProfilePage.ets` — 开发者资料页
- [x] 用户仓库列表（搜索 + 语言筛选）
- [x] 贡献热力图（GraphQL API + 5 级色阶 + 横向滚动）
- [ ] Follow / Unfollow

## v1.0.0 — 正式版（进行中）

- [x] 深色/浅色双主题 + SettingsPage 开关
- [x] Octocat 应用图标
- [x] 代码混淆（Release）
- [x] 隐私协议 + 使用教程
- [ ] SVG 图标替换 Unicode 占位
- [ ] 性能优化（LazyForEach、列表缓存）
- [ ] 单元测试覆盖
- [ ] 集成测试覆盖
- [ ] AppGallery 上架

## 长期规划

- [ ] 离线缓存
- [ ] 推送通知（HarmonyOS Push Kit）
- [ ] 平板/2in1 双栏布局
- [ ] Widget 桌面小组件
- [ ] Issue / PR 创建与评论
- [ ] Markdown 编辑器
- [ ] 代码 Diff 高亮
- [ ] Actions CI 状态查看
- [ ] Token 安全存储（HarmonyOS 密钥库）
