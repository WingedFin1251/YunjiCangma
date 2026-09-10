/**
 * 全局会话事件 — 传输层只发信号，不直接触碰登录态与导航
 * 订阅方：MainPage（Shell）负责 AuthService.logout() 并跳转登录页
 */
import { AUTH_UNAUTHORIZED_KEY } from '../constants/APIConstants';

export class SessionEvents {
  /** 发布 401 未授权信号（累加计数，连续 401 也能触发 @Watch） */
  static notifyUnauthorized(): void {
    const cur: number = AppStorage.get<number>(AUTH_UNAUTHORIZED_KEY) || 0;
    AppStorage.setOrCreate<number>(AUTH_UNAUTHORIZED_KEY, cur + 1);
  }
}