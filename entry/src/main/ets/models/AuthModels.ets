/**
 * 认证相关数据模型
 */

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

/** GitHub Device Flow 起始响应（POST /login/device/code） */
export class DeviceFlowInfo {
  /** 轮询用设备码 */
  deviceCode: string = '';
  /** 展示给用户输入的码 */
  userCode: string = '';
  /** 用户去输入的页面 */
  verificationUri: string = 'https://github.com/login/device';
  /** GitHub 建议的轮询间隔（秒） */
  interval: number = 5;
  /** 过期时间（秒） */
  expiresIn: number = 900;
}

/** 设备流轮询状态 */
export enum DevicePollStatus {
  SUCCESS = 0,
  PENDING = 1,
  SLOW_DOWN = 2,
  DENIED = 3,
  EXPIRED = 4,
  BAD_CODE = 5,
  ERROR = 6
}

/** 设备流轮询结果 */
export class DevicePollResult {
  status: DevicePollStatus = DevicePollStatus.PENDING;
  accessToken: string = '';
  detail: string = '';
}
