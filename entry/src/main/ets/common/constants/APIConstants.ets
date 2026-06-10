/**
 * GitHub API 常量配置
 */

/** GitHub REST API Base URL */
export const GITHUB_API_BASE: string = 'https://api.github.com';

/** GitHub OAuth 授权端点 */
export const GITHUB_OAUTH_AUTHORIZE_URL: string = 'https://github.com/login/oauth/authorize';

/** GitHub OAuth Token 交换端点 */
export const GITHUB_OAUTH_ACCESS_TOKEN_URL: string = 'https://github.com/login/oauth/access_token';

export const GITHUB_OAUTH_CLIENT_ID: string = 'YOUR_CLIENT_ID';
export const GITHUB_OAUTH_CLIENT_SECRET: string = 'YOUR_CLIENT_SECRET';

/** OAuth 授权范围 */
export const GITHUB_OAUTH_SCOPES: string = 'repo,user,notifications';

/** OAuth 回调 URL */
export const GITHUB_OAUTH_REDIRECT_URI: string = 'https://github.com/';

/** API 请求头 */
export class APIHeaders {
  static readonly ACCEPT: string = 'application/vnd.github+json';
  static readonly API_VERSION: string = '2022-11-28';
}

/** AppStorage 认证状态 Key */
export const AUTH_TOKEN_KEY: string = 'authToken';
export const AUTH_LOGIN_KEY: string = 'isLoggedIn';
