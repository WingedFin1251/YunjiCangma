/**
 * GitHub 仓库相关数据模型（替代 Object 泛型，提供编译期字段校验）
 */
import type { RepoOwner } from './User';

/** 仓库许可证 */
export interface RepoLicense {
  spdx_id: string | null;
  name: string | null;
}

/** 仓库详情（GET /repos/{owner}/{repo}） */
export interface RepoDetail {
  id: number;
  name: string;
  full_name: string;
  owner: RepoOwner;
  description: string | null;
  stargazers_count: number;
  forks_count: number;
  open_issues_count: number;
  language: string | null;
  topics: string[];
  default_branch: string;
  license: RepoLicense | null;
  created_at: string;
  updated_at: string;
  html_url: string;
  fork: boolean;
}

/** README 响应（GET /repos/{owner}/{repo}/readme） */
export interface RepoReadme {
  name: string;
  path: string;
  content: string;
  encoding: string;
}

/** 目录内容项（GET /repos/{owner}/{repo}/contents/{path}） */
export interface RepoContentItem {
  name: string;
  path: string;
  type: string;
  size: number;
  html_url: string | null;
  download_url: string | null;
}

/** 最新 Release（GET /repos/{owner}/{repo}/releases/latest） */
export interface RepoRelease {
  tag_name: string;
  name: string | null;
  body: string | null;
  published_at: string;
  html_url: string;
}