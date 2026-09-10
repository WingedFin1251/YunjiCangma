import { HttpClient } from './HttpClient';
import type { GitHubNotification, SearchResult } from '../models/User';
import type { GitHubIssue, SearchIssuesResult } from '../models/IssueModels';

export class SearchRepository {
  static searchRepos(query: string, page: number = 1): Promise<SearchResult> { return HttpClient.get<SearchResult>('/search/repositories?q=' + encodeURIComponent(query) + '&per_page=20&page=' + page.toString()); }
  static getNotifications(): Promise<GitHubNotification[]> { return HttpClient.get<GitHubNotification[]>('/notifications?all=true&per_page=50'); }
  static getIssues(): Promise<GitHubIssue[]> { return HttpClient.get<GitHubIssue[]>('/issues?per_page=30&state=all'); }
  static getPullRequests(username: string): Promise<SearchIssuesResult> { return HttpClient.get<SearchIssuesResult>('/search/issues?q=is:pr+author:' + username + '&per_page=20'); }
}
