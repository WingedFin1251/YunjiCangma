import { preferences } from '@kit.ArkData';
import {
  GITHUB_OAUTH_AUTHORIZE_URL,
  GITHUB_OAUTH_ACCESS_TOKEN_URL,
  GITHUB_OAUTH_CLIENT_ID,
  GITHUB_OAUTH_CLIENT_SECRET,
  GITHUB_OAUTH_SCOPES,
  GITHUB_OAUTH_REDIRECT_URI,
  AUTH_TOKEN_KEY,
  AUTH_LOGIN_KEY
} from '../common/constants/APIConstants';
import type { OAuthTokenResponse } from '../models/AuthModels';
import { http } from '@kit.NetworkKit';

const PREFERENCES_NAME: string = 'github_auth_prefs';

/**
 * 认证服务 — OAuth 流程、Token 存储、登录状态
 */
export class AuthService {

  static buildOAuthUrl(): string {
    const state: string = `${Date.now().toString(36)}${Math.floor(Math.random() * 1000000).toString(36)}`;
    const params: string = [
      `client_id=${encodeURIComponent(GITHUB_OAUTH_CLIENT_ID)}`,
      `redirect_uri=${encodeURIComponent(GITHUB_OAUTH_REDIRECT_URI)}`,
      `scope=${encodeURIComponent(GITHUB_OAUTH_SCOPES)}`,
      `state=${state}`
    ].join('&');
    return `${GITHUB_OAUTH_AUTHORIZE_URL}?${params}`;
  }

  static async exchangeCodeForToken(code: string): Promise<string> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        GITHUB_OAUTH_ACCESS_TOKEN_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          extraData: JSON.stringify({
            client_id: GITHUB_OAUTH_CLIENT_ID,
            client_secret: GITHUB_OAUTH_CLIENT_SECRET,
            code: code,
            redirect_uri: GITHUB_OAUTH_REDIRECT_URI
          })
        }
      );
      if (response.responseCode === 200) {
        const data: OAuthTokenResponse = JSON.parse(response.result as string) as OAuthTokenResponse;
        if (data.access_token) {
          await AuthService.saveToken(data.access_token);
          return data.access_token;
        }
      }
      throw new Error(`Token exchange failed: HTTP ${response.responseCode}`);
    } finally {
      httpRequest.destroy();
    }
  }

  static async saveToken(token: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), PREFERENCES_NAME);
      await prefs.put('access_token', token);
      await prefs.flush();
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
    } catch (err) {
      console.error('Failed to save token:', JSON.stringify(err));
    }
  }

  static async loadToken(): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(getContext(), PREFERENCES_NAME);
      const token: string = await prefs.get('access_token', '') as string;
      if (token) {
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
      } else {
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
      }
      return token;
    } catch (err) {
      console.error('Failed to load token:', JSON.stringify(err));
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
      return '';
    }
  }

  static getToken(): string {
    return AppStorage.get<string>(AUTH_TOKEN_KEY) || '';
  }

  static isLoggedIn(): boolean {
    return AppStorage.get<boolean>(AUTH_LOGIN_KEY) || false;
  }

  static async logout(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), PREFERENCES_NAME);
      await prefs.delete('access_token');
      await prefs.flush();
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
    } catch (err) {
      console.error('Failed to logout:', JSON.stringify(err));
    }
  }

  static isOAuthCallback(url: string): boolean {
    return url.includes('code=') &&
      (url.includes('github.com/?code=') || url.includes('github.com/login/oauth'));
  }

  static extractCodeFromUrl(url: string): string | null {
    const match: RegExpMatchArray | null = url.match(/[?&]code=([^&]+)/);
    return match ? match[1] : null;
  }
}
