/**
 * GitHub 用户数据模型
 */

export interface User {
  /** 用户 ID */
  id: number;

  /** 用户名（login） */
  login: string;

  /** 显示名称 */
  name: string | null;

  /** 头像 URL */
  avatar_url: string;

  /** GitHub 主页 URL */
  html_url: string;

  /** 个人简介 */
  bio: string | null;

  /** 公司 */
  company: string | null;

  /** 博客/网站 */
  blog: string | null;

  /** 所在地 */
  location: string | null;

  /** 邮箱 */
  email: string | null;

  /** 公开仓库数 */
  public_repos: number;

  /** 粉丝数 */
  followers: number;

  /** 关注数 */
  following: number;

  /** 账号创建时间 */
  created_at: string;

  /** 最后更新时间 */
  updated_at: string;
}

/** 仓库所有者 */
export interface RepoOwner {
  login: string;
  avatar_url: string;
}

/** GitHub 仓库模型 */
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

/** 通知主题 */
export interface NotificationSubject {
  title: string;
  type: string;
  url: string;
}

/** 通知关联仓库 */
export interface NotificationRepo {
  full_name: string;
}

/** GitHub 通知模型 */
export interface GitHubNotification {
  id: string;
  subject: NotificationSubject;
  repository: NotificationRepo;
  reason: string;
  unread: boolean;
  updated_at: string;
}

/** 搜索仓库结果 */
export interface SearchResult {
  items: Repository[];
}

/** 匿名用户占位 */
export const ANONYMOUS_USER: Partial<User> = {
  login: '',
  name: 'Sign in to GitHub',
  avatar_url: '',
  bio: null
};
