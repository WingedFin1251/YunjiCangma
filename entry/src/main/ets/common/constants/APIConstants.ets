/**
 * GitHub API 常量配置
 */

/** GitHub REST API Base URL */
export const GITHUB_API_BASE: string = 'https://api.github.com';

/** GitHub OAuth Token 交换端点 */
export const GITHUB_OAUTH_ACCESS_TOKEN_URL: string = 'https://github.com/login/oauth/access_token';

/** GitHub Device Flow 起始端点（只需 client_id，无 secret） */
export const GITHUB_OAUTH_DEVICE_CODE_URL: string = 'https://github.com/login/device/code';

export const GITHUB_OAUTH_CLIENT_ID: string = 'Ov23ling48xkbpVRtB13';

/** API 请求头 */
export class APIHeaders {
  static readonly ACCEPT: string = 'application/vnd.github+json';
  static readonly API_VERSION: string = '2022-11-28';
}

/** AppStorage 认证状态 Key */
export const AUTH_TOKEN_KEY: string = 'authToken';
export const AUTH_LOGIN_KEY: string = 'isLoggedIn';
