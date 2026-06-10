/**
 * 认证相关数据模型
 */

/** OAuth Token 交换响应 */
export interface OAuthTokenResponse {
  /** Access Token */
  access_token: string;

  /** Token 类型（bearer） */
  token_type: string;

  /** 授权范围 */
  scope: string;
}

/** 认证状态 */
export interface AuthState {
  /** 是否已登录 */
  isLoggedIn: boolean;

  /** Access Token */
  token: string;

  /** 当前用户基本信息（login + avatar） */
  userLogin: string;

  userAvatar: string;

  userName: string;

  userBio: string;
}

/** 登录页参数 */
export interface LoginPageParams {
  /** 登录来源（profile / feed / etc.） */
  from: string;
}
