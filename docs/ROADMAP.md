# 路线图

## 当前版本: 0.1.0（主界面框架）

- [x] 项目初始化 + GitHub 适配
- [x] 4 Tab 底部导航架构（Home / Notifications / Explore / Profile）
- [x] 独立 Navigation 导航栈（每个 Tab 独立路由）
- [x] GitHub 深色/浅色主题系统
- [x] 手动主题切换（Profile Tab → Toggle）
- [x] 基础资源体系（颜色、字体、字符串）

## v0.2.0 — API 基础设施

- [ ] `services/HttpClient.ets` — 网络请求封装（基于 `@ohos.net.http`）
- [ ] `services/AuthService.ets` — Token 管理（安全存储）
- [ ] `services/GitHubAPIService.ets` — REST API 客户端
- [ ] `models/` — Repository, User, Issue, PR 数据模型
- [ ] 请求频率限制处理（Rate Limit）
- [ ] 网络错误统一处理
- [ ] 声明 `ohos.permission.INTERNET` 权限

## v0.3.0 — 登录与认证

- [ ] `pages/LoginPage.ets` — Personal Access Token 输入页
- [ ] Token 持久化存储
- [ ] 登录状态管理
- [ ] 401 错误自动跳转登录页
- [ ] Profile Tab 展示用户信息（头像、用户名、bio）

## v0.4.0 — 首页 Feed

- [ ] Home Tab — 用户动态流
- [ ] `components/FeedItem.ets` — 动态卡片组件
- [ ] 支持展示事件类型：WatchEvent, StarEvent, ForkEvent, PushEvent 等
- [ ] 下拉刷新
- [ ] 无限滚动（分页加载）

## v0.5.0 — 仓库浏览

- [ ] `pages/RepoDetailPage.ets` — 仓库详情页
- [ ] `pages/FileListPage.ets` — 文件树浏览
- [ ] `pages/CodeViewPage.ets` — 代码查看（语法高亮）
- [ ] `components/RepoCard.ets` — 仓库卡片组件
- [ ] README 渲染（Markdown → ArkUI）
- [ ] Star / Unstar 操作

## v0.6.0 — Issue 与 PR

- [ ] `pages/IssueListPage.ets` — Issue 列表
- [ ] `pages/IssueDetailPage.ets` — Issue 详情
- [ ] `pages/PRListPage.ets` — PR 列表
- [ ] `pages/PRDetailPage.ets` — PR 详情 + Diff 查看
- [ ] Issue 筛选（open/closed/author/label）
- [ ] 评论展示

## v0.7.0 — 通知

- [ ] Notifications Tab — 通知列表
- [ ] 通知标记已读
- [ ] 通知类型图标区分（Issue, PR, Release 等）
- [ ] 点击通知跳转到对应详情页

## v0.8.0 — 探索与搜索

- [ ] Explore Tab — 热门仓库列表
- [ ] `pages/SearchPage.ets` — 全局搜索
- [ ] 搜索类型切换（Repos / Users / Issues）
- [ ] 搜索历史

## v0.9.0 — 用户主页

- [ ] `pages/UserProfilePage.ets` — 用户主页
- [ ] 用户仓库列表
- [ ] Follow / Unfollow
- [ ] Profile Tab 完善（自己的仓库、Star 列表）

## v1.0.0 — 正式版

- [ ] 多语言支持（中文 / English）
- [ ] SVG 图标替换 Unicode 占位
- [ ] 应用图标设计
- [ ] 性能优化（LazyForEach、列表缓存）
- [ ] 单元测试覆盖
- [ ] 集成测试覆盖
- [ ] AppGallery 上架

## 长期规划

- [ ] OAuth Web Flow 登录
- [ ] 离线缓存（IndexedDB / RDB）
- [ ] 推送通知（HarmonyOS Push Kit）
- [ ] 平板/2in1 双栏布局
- [ ] Widget 桌面小组件
- [ ] Watch 手表端适配
- [ ] Issue / PR 创建与评论
- [ ] Markdown 编辑器
- [ ] 代码 Diff 高亮
- [ ] Actions CI 状态查看
