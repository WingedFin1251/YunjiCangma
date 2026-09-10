/**
 * GitHub API 速率限制跟踪服务
 * 参考 Komi Store 的 RateLimitInterceptor 设计
 * 从每次 HTTP 响应头中解析 X-RateLimit-* 信息
 */
import { RateLimitInfo, isRateLimitExhausted, formatTimeUntilReset } from '../models/RateLimitInfo';

/** 速率限制状态变化回调 */
type RateLimitCallback = (info: RateLimitInfo, exhausted: boolean) => void;

export class RateLimitService {
  private static _info: RateLimitInfo | null = null;
  private static _listeners: RateLimitCallback[] = [];

  /** 获取当前速率限制信息 */
  static getInfo(): RateLimitInfo | null {
    return RateLimitService._info;
  }

  /** 注册状态变化监听 */
  static onChange(callback: RateLimitCallback): void {
    RateLimitService._listeners.push(callback);
  }

  /** 移除监听 */
  static offChange(callback: RateLimitCallback): void {
    const idx: number = RateLimitService._listeners.indexOf(callback);
    if (idx >= 0) RateLimitService._listeners.splice(idx, 1);
  }

  /**
   * 从 HTTP 响应头解析速率限制信息
   * 调用时机：每次 HttpClient 请求完成后
   */
  static parseHeaders(headers: Record<string, string>): void {
    try {
      const limitStr: string | undefined = headers['X-RateLimit-Limit'];
      const remainingStr: string | undefined = headers['X-RateLimit-Remaining'];
      const resetStr: string | undefined = headers['X-RateLimit-Reset'];
      const resource: string = headers['X-RateLimit-Resource'] || 'core';

      if (!limitStr || !remainingStr || !resetStr) return;

      const limit: number = parseInt(limitStr);
      const remaining: number = parseInt(remainingStr);
      const reset: number = parseInt(resetStr);

      if (isNaN(limit) || isNaN(remaining) || isNaN(reset)) return;

      const info: RateLimitInfo = { limit, remaining, resetTimestamp: reset, resource };
      RateLimitService._info = info;

      // 通知监听者
      const exhausted: boolean = isRateLimitExhausted(info);
      for (let i = 0; i < RateLimitService._listeners.length; i++) {
        RateLimitService._listeners[i](info, exhausted);
      }
    } catch (e) {
      // 解析失败静默处理
    }
  }

  /** 检查是否已耗尽，返回用户可读的错误信息 */
  static checkAndGetError(): string | null {
    const info: RateLimitInfo | null = RateLimitService._info;
    if (!info || !isRateLimitExhausted(info)) return null;
    const remaining = info.remaining;
    const reset = formatTimeUntilReset(info);
    return 'API 请求配额已用完（剩余 ' + remaining + '/' + info.limit + '），' + reset;
  }
}
