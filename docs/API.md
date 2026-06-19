# API 集成

## GitHub REST API v3

本应用使用 GitHub REST API v3（部分 GraphQL）获取数据。

- **Base URL**: `https://api.github.com`
- **版本**: `X-GitHub-Api-Version: 2022-11-28`
- **Accept**: `application/vnd.github+json`
- **认证**: Bearer Token（OAuth Web Flow）

## 服务层架构

HTTP 请求由 `services/HttpClient.ets` 统一封装，按业务域拆分为 4 个 Repository 类：

```
HttpClient.ets          # HTTP 引擎 — buildHeaders() + get<T>() + post<T>()
  ├── RepoRepository    # 仓库相关
  ├── UserRepository    # 用户/动态/GraphQL
  ├── SearchRepository  # 搜索/通知/PR
  └── AuthService       # OAuth 认证
```

### HttpClient 核心

```typescript
// services/HttpClient.ets
export class HttpClient {
  static buildHeaders(): Record<string, string> {
    // 自动注入 Bearer Token（若已登录）
    // Accept + X-GitHub-Api-Version
  }
  static async get<T>(path: string): Promise<T>    // GET 请求
  static async post<T>(path: string, body: Object): Promise<T>  // POST JSON
  static async postRaw<T>(url: string, body: string, headers?): Promise<T>
}
```

## 认证

### OAuth Web Flow（已实现）

应用通过 WebView 加载 GitHub OAuth 授权页面，用户授权后拦截回调 URL 提取 authorization code，再用 code 交换 access token。

```
AuthService.buildOAuthUrl()
  → WebView 加载 github.com/login/oauth/authorize
  → 用户授权 → 回调 URL 含 ?code=xxx
  → AuthService.isOAuthCallback(url) 检测
  → AuthService.extractCodeFromUrl(url)
  → AuthService.exchangeCodeForToken(code)
    → POST github.com/login/oauth/access_token
    → AuthService.saveToken(token) → preferences + AppStorage
```

**配置**: 在 `common/constants/APIConstants.ets` 中设置 `GITHUB_OAUTH_CLIENT_ID` 和 `GITHUB_OAUTH_CLIENT_SECRET`。

### Token 管理

`services/AuthService.ets` 提供完整的 Token 生命周期：
- `saveToken(token)` → preferences 持久化 + AppStorage 全局状态
- `loadToken()` → 启动时从 preferences 恢复
- `getToken()` → 读取当前 token（AppStorage）
- `isLoggedIn()` → 检查登录状态
- `logout()` → 清除 token + AppStorage 状态
- `loadTheme()` / `saveTheme()` → 主题持久化

### 权限声明

在 `module.json5` 中添加：

```json
{
  "module": {
    "requestPermissions": [
      { "name": "ohos.permission.INTERNET" }
    ]
  }
}
```

## 核心端点

### RepoRepository（`services/RepoRepository.ets`）

| 方法 | 端点 | 说明 |
|------|------|------|
| `getStarredRepos()` | `GET /user/starred?per_page=20` | 已加星标仓库 |
| `getTrendingRepos()` | `GET /search/repositories?q=stars:>1&sort=stars&order=desc&per_page=10` | 热门仓库 |
| `getMyRepos()` | `GET /user/repos?type=all&per_page=50&sort=updated` | 我的仓库 |
| `getUserRepos(u)` | `GET /users/{u}/repos?per_page=30&sort=updated` | 用户仓库 |
| `getRepoDetail(o,r)` | `GET /repos/{o}/{r}` | 仓库详情 |
| `getRepoContents(o,r,p)` | `GET /repos/{o}/{r}/contents/{p}` | 文件/目录内容 |
| `getReadme(o,r)` | `GET /repos/{o}/{r}/readme` | README |
| `getLatestRelease(o,r)` | `GET /repos/{o}/{r}/releases/latest` | 最新 Release |

### UserRepository（`services/UserRepository.ets`）

| 方法 | 端点 | 说明 |
|------|------|------|
| `getCurrentUser()` | `GET /user` | 当前认证用户 |
| `getUser(u)` | `GET /users/{u}` | 用户信息 |
| `getFollowers(u)` | `GET /users/{u}/followers?per_page=30` | 粉丝列表 |
| `getFollowing(u)` | `GET /users/{u}/following?per_page=30` | 关注列表 |
| `getReceivedEvents(u)` | `GET /users/{u}/received_events?per_page=10` | 用户收到的动态 |
| `getOrgs()` | `GET /user/orgs?per_page=30` | 组织列表 |
| `getContributions(u)` | `POST /graphql` | 贡献热力图（GraphQL） |

### SearchRepository（`services/SearchRepository.ets`）

| 方法 | 端点 | 说明 |
|------|------|------|
| `searchRepos(q)` | `GET /search/repositories?q=&per_page=20` | 搜索仓库 |
| `getNotifications()` | `GET /notifications?per_page=20` | 通知列表 |
| `getIssues()` | `GET /issues?per_page=30&state=all` | 当前用户 Issues |
| `getPullRequests(u)` | `GET /search/issues?q=is:pr+author:{u}&per_page=20` | 用户 PR |

## 数据模型

所有模型定义在 `models/User.ets` 和 `models/AuthModels.ets` 中。

### User

```typescript
// models/User.ets
export interface User {
  id: number;
  login: string;
  name: string | null;
  avatar_url: string;
  html_url: string;
  bio: string | null;
  company: string | null;
  blog: string | null;
  location: string | null;
  email: string | null;
  public_repos: number;
  followers: number;
  following: number;
  created_at: string;
  updated_at: string;
}
```

### Repository

```typescript
// models/User.ets
export interface RepoOwner {
  login: string;
  avatar_url: string;
}

export interface Repository {
  id: number;
  name: string;
  full_name: string;
  owner: RepoOwner;
  description: string | null;
  stargazers_count: number;
  language: string | null;
  topics: string[];
  html_url: string;
  fork: boolean;
}
```

### GitHubNotification

```typescript
// models/User.ets
export interface NotificationSubject {
  title: string;
  type: string;    // "Issue" | "PullRequest" | "Discussion"
  url: string;
}

export interface NotificationRepo {
  full_name: string;
}

export interface GitHubNotification {
  id: string;
  subject: NotificationSubject;
  repository: NotificationRepo;
  reason: string;
  unread: boolean;
  updated_at: string;
}
```

### SearchResult

```typescript
// models/User.ets
export interface SearchResult {
  items: Repository[];
}
```

### OAuthTokenResponse

```typescript
// models/AuthModels.ets
export interface OAuthTokenResponse {
  access_token: string;
  token_type: string;
  scope: string;
}
```

## 错误处理

HTTP 层错误在 `HttpClient` 中统一处理：非 200/201 响应码抛出 `Error('HTTP {code} for {path}')`。Repository 层由调用方 try/catch 捕获，设置空数组/空状态。常见错误码：

| 状态码 | 含义 |
|--------|------|
| 200 | 成功 |
| 304 | 未修改（缓存） |
| 401 | 未认证（Token 失效 → 自动登出） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 429 | 频率限制 |

## 频率限制

- 未认证：60 次/小时
- 已认证：5,000 次/小时
- 通过响应头 `X-RateLimit-Remaining` 跟踪剩余次数

## TODO

- [x] `services/HttpClient.ets` — HTTP 引擎封装
- [x] `services/AuthService.ets` — Token 管理
- [x] `services/RepoRepository.ets` — 仓库端点
- [x] `services/UserRepository.ets` — 用户/GraphQL 端点
- [x] `services/SearchRepository.ets` — 搜索/通知端点
- [x] `models/User.ets` — 数据模型（User/Repository/Notification/SearchResult）
- [x] `models/AuthModels.ets` — 认证模型
- [ ] Token 安全存储（使用 HarmonyOS 密钥库）
- [ ] 请求缓存策略（减少 API 调用）
- [ ] 分页数据加载
