/**
 * GitHub API 速率限制信息
 * 参考 Komi Store 的 RateLimitInfo 设计
 */
export interface RateLimitInfo {
  /** 总配额 */
  limit: number;
  /** 剩余次数 */
  remaining: number;
  /** 重置时间戳（秒） */
  resetTimestamp: number;
  /** 资源类型（core / search / graphql） */
  resource: string;
}

/** 是否已耗尽配额 */
export function isRateLimitExhausted(info: RateLimitInfo): boolean {
  return info.remaining === 0;
}

/** 距重置还有多少秒 */
export function timeUntilReset(info: RateLimitInfo): number {
  const now: number = Math.floor(Date.now() / 1000);
  return Math.max(0, info.resetTimestamp - now);
}

/** 格式化为可读文本（如 "5分30秒后重置"） */
export function formatTimeUntilReset(info: RateLimitInfo): string {
  const sec: number = timeUntilReset(info);
  if (sec <= 0) return '已重置';
  const min: number = Math.floor(sec / 60);
  const s: number = sec % 60;
  if (min > 0) return min + '分' + (s > 0 ? s + '秒' : '') + '后重置';
  return sec + '秒后重置';
}
