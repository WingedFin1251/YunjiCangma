import { http } from '@kit.NetworkKit';
import { GITHUB_API_BASE, APIHeaders } from '../common/constants/APIConstants';
import { AuthService } from './AuthService';
import type { User } from '../models/User';

/**
 * GitHub API 客户端 — 自动注入认证 Token
 */
export class GitHubAPIService {

  private static buildHeaders(): Record<string, string> {
    const token: string = AuthService.getToken();
    const headers: Record<string, string> = {
      'Accept': APIHeaders.ACCEPT,
      'X-GitHub-Api-Version': APIHeaders.API_VERSION
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
  }

  private static async get<T>(path: string): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        `${GITHUB_API_BASE}${path}`,
        {
          method: http.RequestMethod.GET,
          header: GitHubAPIService.buildHeaders()
        }
      );
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as T;
      }
      throw new Error(`API request failed: HTTP ${response.responseCode} for ${path}`);
    } finally {
      httpRequest.destroy();
    }
  }

  private static async post<T>(path: string, body: Object): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const postHeaders: Record<string, string> = GitHubAPIService.buildHeaders();
      postHeaders['Content-Type'] = 'application/json';
      const response = await httpRequest.request(
        `${GITHUB_API_BASE}${path}`,
        {
          method: http.RequestMethod.POST,
          header: postHeaders,
          extraData: JSON.stringify(body)
        }
      );
      if (response.responseCode === 200 || response.responseCode === 201) {
        return JSON.parse(response.result as string) as T;
      }
      throw new Error(`API request failed: HTTP ${response.responseCode} for ${path}`);
    } finally {
      httpRequest.destroy();
    }
  }

  static async getCurrentUser(): Promise<User> {
    return GitHubAPIService.get<User>('/user');
  }

  static async getUser(username: string): Promise<User> {
    return GitHubAPIService.get<User>(`/users/${username}`);
  }

  static async validateToken(): Promise<boolean> {
    try {
      await GitHubAPIService.getCurrentUser();
      return true;
    } catch {
      return false;
    }
  }
}
