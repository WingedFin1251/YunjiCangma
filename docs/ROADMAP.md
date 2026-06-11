# 路线图

## 当前版本: v0.4.0（OAuth 完整可用 + 全屏沉浸）

- [x] 项目初始化 + GitHub 适配
- [x] 4 Tab 底部导航（主页 / 收件箱 / 探索 / 个人资料）
- [x] 独立 Navigation 导航栈（NavigationMode.Stack 平板修复）
- [x] 全局深色模式（V1.0 规范，唯一主题，14 色值 DarkTheme 类）
- [x] 全局可复用组件库（RepoCard / ListItem / EmptyState / FilterTabBar）
- [x] 统一几何图标体系（◉⇄◈⊞⊡★，按功能色值区分）
- [x] `services/GitHubAPIService.ets` + `services/AuthService.ets`
- [x] `models/User.ets` + `models/AuthModels.ets`
- [x] `ohos.permission.INTERNET` 权限声明
- [x] `pages/LoginPage.ets` — WebView OAuth（onLoadIntercept + 自定义 Scheme）
- [x] Profile Tab 登录/未登录双态 UI
- [x] 登录状态管理（AppStorage + preferences）
- [x] OAuth 完整流程可用（Client ID 已配置，回调 Scheme 已注册）
- [x] 全屏沉浸（状态栏融合 + 底部小白条延伸）
- [x] 安全区适配（top 32 / bottom 64 padding）
- [x] 登录状态自动刷新（@StorageLink + @Watch）

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
