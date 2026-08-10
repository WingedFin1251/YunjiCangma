import { HttpClient } from './HttpClient';
import type { Repository, SearchResult } from '../models/User';

export class RepoRepository {
  static getStarredRepos(): Promise<Repository[]> { return HttpClient.get<Repository[]>('/user/starred?per_page=20'); }
  static getTopStarredRepos(): Promise<SearchResult> { return HttpClient.get<SearchResult>('/search/repositories?q=stars:%3E1&sort=stars&order=desc&per_page=20'); }
  static getTrendingRepos(): Promise<SearchResult> {
    const d: Date = new Date();
    d.setDate(d.getDate() - 30);
    const dateStr: string = d.getFullYear() + '-' + (d.getMonth() + 1 < 10 ? '0' : '') + (d.getMonth() + 1) + '-' + (d.getDate() < 10 ? '0' : '') + d.getDate();
    return HttpClient.get<SearchResult>('/search/repositories?q=pushed:%3E=' + dateStr + '&stars:%3E100&sort=stars&order=desc&per_page=10');
  }
  static getMyRepos(): Promise<Repository[]> { return HttpClient.get<Repository[]>('/user/repos?type=all&per_page=50&sort=updated'); }
  static getUserRepos(u: string): Promise<Repository[]> { return HttpClient.get<Repository[]>('/users/' + u + '/repos?per_page=30&sort=updated'); }
  static getRepoDetail(owner: string, repo: string): Promise<Object> { return HttpClient.get<Object>('/repos/' + owner + '/' + repo); }
  static getRepoContents(owner: string, repo: string, path: string): Promise<Object[]> {
    const p: string = path ? '/' + encodeURIComponent(path) : '';
    return HttpClient.get<Object[]>('/repos/' + owner + '/' + repo + '/contents' + p);
  }
  static getReadme(owner: string, repo: string): Promise<Object> {
    return HttpClient.get<Object>('/repos/' + owner + '/' + repo + '/readme');
  }
  static getLatestRelease(owner: string, repo: string): Promise<Object> {
    return HttpClient.get<Object>('/repos/' + owner + '/' + repo + '/releases/latest');
  }
}
