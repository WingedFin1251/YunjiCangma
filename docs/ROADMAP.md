# 路线图

## 当前版本: v0.3.0（深色模式 UI + 登录框架）

- [x] 项目初始化 + GitHub 适配
- [x] 4 Tab 底部导航架构（主页 / 收件箱 / 探索 / 个人资料）
- [x] 独立 Navigation 导航栈（每个 Tab 独立路由）
- [x] 全局深色模式（V1.0 规范，唯一主题，14 色值）
- [x] 全局可复用组件库（RepoCard / ListItem / EmptyState / FilterTabBar）
- [x] 基础资源体系（颜色、字体、字符串、尺寸）
- [x] `services/GitHubAPIService.ets` — HTTP 客户端（GET/POST + Bearer 自动注入）
- [x] `services/AuthService.ets` — OAuth URL 构建、code→token、preferences 持久化
- [x] `models/User.ets` + `models/AuthModels.ets` — 数据模型
- [x] `ohos.permission.INTERNET` 权限声明
- [x] `pages/LoginPage.ets` — OAuth WebView 登录页
- [x] Profile Tab 登录/未登录双态 UI
- [x] 登录状态管理（AppStorage + preferences）

## v0.4.0 — 各页面功能完善

- [ ] Home Tab — 动态数据（我的工作计数、收藏夹 API 数据）
- [ ] Inbox Tab — 通知列表（真实 API 数据）、筛选联动
- [ ] Explore Tab — 热门仓库 API、活动流动态数据
- [ ] Profile Tab — 热门仓库横滑、用户信息实时刷新
- [ ] Markdown 渲染（README 显示）
- [ ] 图片加载（用户头像、仓库图）

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
