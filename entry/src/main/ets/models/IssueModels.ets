/**
 * GitHub 议题 / PR / 评论相关数据模型（替代 Object 泛型，提供编译期字段校验）
 */

/** 议题标签 */
export interface GitHubLabel {
  name: string;
  color: string;
}

/** 作者引用（登录名 + 头像） */
export interface AuthorRef {
  login: string;
  avatar_url: string;
}

/** PR 标记（字段存在即说明该条为 PR 而非普通 Issue） */
export interface PullRequestRef {
  url: string;
  html_url: string;
}

/** 议题 / PR 通用模型 */
export interface GitHubIssue {
  number: number;
  title: string;
  body: string | null;
  state: string;
  labels: GitHubLabel[];
  user: AuthorRef;
  comments: number;
  created_at: string;
  updated_at: string;
  html_url: string;
  /** 仓库议题列表接口会带此字段（api.github.com 前缀，展示时需裁剪） */
  repository_url?: string;
  pull_request?: PullRequestRef;
}

/** 议题评论 */
export interface IssueComment {
  id: number;
  body: string | null;
  user: AuthorRef;
  created_at: string;
  html_url: string;
}

/** 搜索议题/PR 结果（GET /search/issues） */
export interface SearchIssuesResult {
  total_count: number;
  items: GitHubIssue[];
}