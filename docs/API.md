# API 集成

## GitHub REST API v3

本应用使用 GitHub REST API v3 获取数据。

- **Base URL**: `https://api.github.com`
- **版本**: v3
- **格式**: JSON
- **认证**: Bearer Token / Personal Access Token

## 认证

### 方式一：Personal Access Token（推荐）

```http
Authorization: Bearer ghp_xxxxxxxxxxxxxxxxxxxx
```

1. GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. 选择需要的权限（repo, user, notifications 等）
3. 生成 token，粘贴到应用登录页

### 方式二：OAuth App（规划中）

```
GET https://github.com/login/oauth/authorize?client_id=xxx&scope=repo,user
```

### 网络请求示例

```typescript
import { http } from '@kit.NetworkKit';

// 封装在 services/GitHubAPIService.ets 中
const httpRequest = http.createHttp();
const response = await httpRequest.request(
  'https://api.github.com/repos/octocat/Hello-World',
  {
    method: http.RequestMethod.GET,
    header: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28'
    }
  }
);
```

### 权限声明

在 `module.json5` 中添加：

```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

## 核心端点

### 仓库

| 端点 | 说明 |
|------|------|
| `GET /repos/{owner}/{repo}` | 获取仓库详情 |
| `GET /repos/{owner}/{repo}/contents/{path}` | 获取文件/目录内容 |
| `GET /repos/{owner}/{repo}/readme` | 获取 README |
| `GET /users/{username}/repos` | 获取用户仓库列表 |
| `GET /search/repositories?q=...` | 搜索仓库 |

### Issue

| 端点 | 说明 |
|------|------|
| `GET /repos/{owner}/{repo}/issues` | Issue 列表 |
| `GET /repos/{owner}/{repo}/issues/{number}` | Issue 详情 |
| `POST /repos/{owner}/{repo}/issues` | 创建 Issue |
| `GET /issues` | 当前用户相关 Issues |

### Pull Request

| 端点 | 说明 |
|------|------|
| `GET /repos/{owner}/{repo}/pulls` | PR 列表 |
| `GET /repos/{owner}/{repo}/pulls/{number}` | PR 详情 |
| `GET /repos/{owner}/{repo}/pulls/{number}/files` | PR 文件变更 |

### 用户

| 端点 | 说明 |
|------|------|
| `GET /users/{username}` | 用户信息 |
| `GET /user` | 当前认证用户 |
| `GET /users/{username}/followers` | 粉丝列表 |
| `GET /users/{username}/following` | 关注列表 |

### 通知

| 端点 | 说明 |
|------|------|
| `GET /notifications` | 通知列表 |
| `PATCH /notifications/threads/{id}` | 标记已读 |

### 动态

| 端点 | 说明 |
|------|------|
| `GET /users/{username}/events` | 用户公开动态 |
| `GET /users/{username}/received_events` | 用户收到的动态 |

### Star / Watch / Fork

| 端点 | 说明 |
|------|------|
| `PUT /user/starred/{owner}/{repo}` | Star 仓库 |
| `DELETE /user/starred/{owner}/{repo}` | Unstar 仓库 |
| `PUT /repos/{owner}/{repo}/subscription` | Watch 仓库 |
| `POST /repos/{owner}/{repo}/forks` | Fork 仓库 |

## 数据模型

### Repository

```typescript
// models/Repository.ets
export interface Repository {
  id: number;
  name: string;
  full_name: string;
  owner: User;
  description: string | null;
  stargazers_count: number;
  forks_count: number;
  open_issues_count: number;
  language: string | null;
  default_branch: string;
  updated_at: string;
  topics: string[];
  license: License | null;
}
```

### Issue

```typescript
// models/Issue.ets
export interface Issue {
  id: number;
  number: number;
  title: string;
  state: 'open' | 'closed';
  user: User;
  labels: Label[];
  comments: number;
  created_at: string;
  updated_at: string;
  body: string | null;
}
```

### User

```typescript
// models/User.ets
export interface User {
  id: number;
  login: string;
  avatar_url: string;
  html_url: string;
  name: string | null;
  bio: string | null;
  followers: number;
  following: number;
  public_repos: number;
}
```

## 错误处理

```typescript
// services/APIError.ets
export interface APIError {
  status: number;
  message: string;
  documentation_url?: string;
}

// 常见错误码
export enum HTTPStatus {
  OK = 200,
  NOT_MODIFIED = 304,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  RATE_LIMITED = 429,
  SERVER_ERROR = 500
}
```

### 频率限制

- 未认证：60 次/小时
- 已认证：5,000 次/小时
- 通过响应头 `X-RateLimit-Remaining` 跟踪剩余次数

## 分页

GitHub API 使用 Link Header 分页：

```typescript
// 解析 Link Header 获取上下页 URL
// Link: <https://api.github.com/repos?page=2>; rel="next"
```

## TODO

- [ ] `services/GitHubAPIService.ets` — API 客户端封装
- [ ] `services/AuthService.ets` — Token 管理
- [ ] `models/` — 数据模型定义
- [ ] Token 安全存储（使用 HarmonyOS 密钥库）
- [ ] 请求缓存策略（减少 API 调用）
