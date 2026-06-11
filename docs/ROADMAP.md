# 路线图

## 当前版本: v0.6.0（设置页 + 工作项子页面 + 标题栏统一）

- [x] 项目初始化 + GitHub 适配 + 品牌「云笈藏码」
- [x] 4 Tab（首页/消息/发现/我的）+ 标题栏固定不滚动 + Scroll 顶部对齐
- [x] NavigationMode.Stack 平板修复 + 顶部 24dp + 底部 20dp + layoutWeight 移除
- [x] 深色/浅色双主题（ThemeColors + T() + preferences 持久化）
- [x] 状态栏透明沉浸 + statusBarContentColor 深浅切换 + 系统 ColorMode 同步
- [x] WebView 深浅联动（WebDarkMode.On/Off + 背景自适应）
- [x] 11 个 API 端点（Star/通知/热门/活动/仓库/粉丝/关注/议题/PR/组织）
- [x] 首页工作项子页面（议题/PR/仓库/组织/已加星标，未登录→提示）
- [x] 设置页（深色模式 + 使用教程 + 隐私协议 + 关于）
- [x] OAuth WebView 登录 + 防抖 + @Watch 自动刷新

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
