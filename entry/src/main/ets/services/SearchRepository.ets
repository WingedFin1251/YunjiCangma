import { HttpClient } from './HttpClient';
import type { GitHubNotification } from '../models/User';

export class SearchRepository {
  static searchRepos(query: string, page: number = 1): Promise<Object> { return HttpClient.get<Object>('/search/repositories?q=' + encodeURIComponent(query) + '&per_page=20&page=' + page.toString()); }
  static getNotifications(): Promise<GitHubNotification[]> { return HttpClient.get<GitHubNotification[]>('/notifications?all=true&per_page=50'); }
  static getIssues(): Promise<Object[]> { return HttpClient.get<Object[]>('/issues?per_page=30&state=all'); }
  static getPullRequests(username: string): Promise<Object[]> { return HttpClient.get<Object[]>('/search/issues?q=is:pr+author:' + username + '&per_page=20'); }
}
