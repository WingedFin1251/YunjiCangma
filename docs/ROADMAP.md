# 路线图

## 当前版本: v0.5.0（深浅双主题 + WebView 联动 + 品牌落地）

- [x] 项目初始化 + GitHub 适配 + 品牌命名「云笈藏码」
- [x] 4 Tab 底部导航（首页 / 消息 / 发现 / 我的）
- [x] NavigationMode.Stack 平板修复 + 安全区适配
- [x] 深色/浅色双主题（ThemeColors 接口 + T() 方法 + preferences 持久化）
- [x] 状态栏自适应（透明沉浸 + statusBarContentColor 深浅切换）
- [x] WebView 深浅联动（WebDarkMode.On/Off + 背景色跟随）
- [x] 全局组件库（RepoCard / ListItem / EmptyState / FilterTabBar）
- [x] 统一几何图标 + 功能色值区分
- [x] `services/GitHubAPIService.ets`（11 端点）+ `AuthService.ets`（含主题存取）
- [x] `models/User.ets`（含 Repository/Notification/SearchResult）
- [x] OAuth WebView 登录（自定义 Scheme + onLoadIntercept + 防抖）
- [x] 登录/未登录双态 UI + @StorageLink + @Watch 自动刷新
- [x] 全屏沉浸 + 底部小白条延伸 + 浅色系统栏适配
- [x] 探索页热门仓库 → WebView；我的页仓库列表 → RepoCard → WebView

## v0.4.0 — 数据对接 ✅ 已完成

- [x] Home Tab — 收藏夹对接 `GET /user/starred` 真实 API
- [x] Inbox Tab — 通知列表对接 `GET /notifications` 真实 API
- [x] Explore Tab — 热门仓库 `GET /search/repositories` + 活动流 `GET /received_events`
- [x] Profile Tab — 用户头像 `Image` 组件加载 + @Watch 实时刷新
- [x] Profile Tab — 仓库列表（RepoCard）+ 点击 → WebView 详情 + 粉丝/关注列表
- [x] API — `GET /user/repos`(含私有) + `GET /followers` + `GET /following` + `GET /contents`
- [x] 登录防抖（isProcessing 守卫）+ Token 持久化（UIAbilityContext）

## v0.5.0 — 仓库浏览

- [ ] `pages/RepoDetailPage.ets` — 仓库详情页
- [ ] `pages/FileListPage.ets` — 文件树浏览
- [ ] `pages/CodeViewPage.ets` — 代码查看
- [ ] README 渲染（Markdown → ArkUI）
- [ ] Star / Unstar API 操作

## v0.6.0 — Issue 与 PR

- [ ] `pages/IssueListPage.ets` — Issue 列表
- [ ] `pages/IssueDetailPage.ets` — Issue 详情
- [ ] `pages/PRListPage.ets` — PR 列表
- [ ] `pages/PRDetailPage.ets` — PR 详情
- [ ] Issue 筛选（open/closed/author/label）

## v0.7.0 — 通知

- [ ] Inbox Tab — 真实通知 API 数据
- [ ] 通知标记已读
- [ ] 通知类型图标区分

## v0.8.0 — 搜索

- [ ] `pages/SearchPage.ets` — 全局搜索
- [ ] 搜索类型切换（Repos / Users / Issues）

## v0.9.0 — 用户主页

- [ ] `pages/UserProfilePage.ets` — 用户主页
- [ ] 用户仓库列表
- [ ] Follow / Unfollow

## v1.0.0 — 正式版

- [ ] SVG 图标替换 Unicode 占位
- [ ] 应用图标设计
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
