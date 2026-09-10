import { HttpClient } from './HttpClient';
import type { GitHubIssue, IssueComment } from '../models/IssueModels';

/** Issue 相关端点 */
export class IssueRepository {
  /** 获取单个 Issue 详情 */
  static getIssue(owner: string, repo: string, number: number): Promise<GitHubIssue> {
    return HttpClient.get<GitHubIssue>('/repos/' + owner + '/' + repo + '/issues/' + number.toString());
  }

  /** 获取 Issue 评论列表 */
  static getIssueComments(owner: string, repo: string, number: number): Promise<IssueComment[]> {
    return HttpClient.get<IssueComment[]>('/repos/' + owner + '/' + repo + '/issues/' + number.toString() + '/comments?per_page=50');
  }

  /** 获取仓库 Issue 列表（支持状态筛选） */
  static getRepoIssues(owner: string, repo: string, state: string = 'all'): Promise<GitHubIssue[]> {
    return HttpClient.get<GitHubIssue[]>('/repos/' + owner + '/' + repo + '/issues?state=' + state + '&per_page=30');
  }
}