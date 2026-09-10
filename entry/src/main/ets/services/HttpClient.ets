import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GITHUB_API_BASE, APIHeaders } from '../common/constants/APIConstants';
import { AuthService } from './AuthService';
import { RateLimitService } from '../common/utils/RateLimitService';
import type { RateLimitExhausted } from '../common/utils/RateLimitService';

/** 传输层 HTTP 错误：statusCode 即响应状态码（0 表示非 HTTP 网络异常兜底） */
export class HttpError extends Error {
  statusCode: number;

  constructor(statusCode: number) {
    super('HTTP ' + statusCode);
    this.statusCode = statusCode;
  }
}

/** 配额耗尽错误：携带结构化配额信息，中文文案由 formatError 统一生成 */
export class RateLimitError extends Error {
  remaining: number;
  limit: number;
  resetText: string;

  constructor(exhausted: RateLimitExhausted) {
    super('API 请求配额已用完');
    this.remaining = exhausted.remaining;
    this.limit = exhausted.limit;
    this.resetText = exhausted.resetText;
  }
}

export class HttpClient {
  /** 将异常格式化为用户可读的中文错误信息（读结构化字段，不再反解析 message 字符串） */
  static formatError(e: Object): string {
    if (e instanceof RateLimitError) {
      return 'API 请求配额已用完（剩余 ' + e.remaining + '/' + e.limit + '），' + e.resetText;
    }
    if (e instanceof HttpError) {
      const code: number = e.statusCode;
      if (code === 401) return '授权已失效，请重新登录';
      if (code === 403 || code === 429) return '请求过于频繁，请稍后重试';
      if (code === 404) return '仓库不存在或无权访问';
      if (code === 0) return '网络请求失败，请稍后重试';
      return `请求失败 (HTTP ${code})`;
    }
    if (e instanceof Error) {
      // 平台网络错误（BusinessError）：按 2300xxx 错误码分类，不再透传英文原文
      const be: BusinessError = e as BusinessError;
      const code: number = be.code;
      if (code === 2300028) return '网络请求超时，请检查网络';
      if (code === 2300006 || code === 2300007) return '网络连接失败，请检查网络';
      if (code === 2300094) return '网络认证失败，请重试';
      return '加载失败，请重试';
    }
    return '加载失败，请重试';
  }

  static buildHeaders(): Record<string, string> {
    const token: string = AuthService.getToken();
    const headers: Record<string, string> = {
      'Accept': APIHeaders.ACCEPT,
      'X-GitHub-Api-Version': APIHeaders.API_VERSION
    };
    if (token) { headers['Authorization'] = `Bearer ${token}`; }
    return headers;
  }

  static async get<T>(path: string): Promise<T> {
    const req = http.createHttp();
    try {
      const res = await req.request(`${GITHUB_API_BASE}${path}`, {
        method: http.RequestMethod.GET,
        header: HttpClient.buildHeaders(),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      // 解析速率限制 Header
      RateLimitService.parseHeaders(res.header as Record<string, string>);
      if (res.responseCode === 200) return JSON.parse(res.result as string) as T;
      // 403/429 + 配额耗尽 → 抛结构化限流错误
      if (res.responseCode === 403 || res.responseCode === 429) {
        const exhausted: RateLimitExhausted | null = RateLimitService.getExhaustedInfo();
        if (exhausted !== null) { throw new RateLimitError(exhausted); }
      }
      throw new HttpError(res.responseCode);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }

  static async postRaw<T>(url: string, body: string, extraHeaders?: Record<string, string>): Promise<T> {
    const req = http.createHttp();
    try {
      const h: Record<string, string> = HttpClient.buildHeaders();
      h['Content-Type'] = 'application/json';
      if (extraHeaders) { const keys: string[] = Object.keys(extraHeaders); for (let i = 0; i < keys.length; i++) { const k: string = keys[i]; h[k] = extraHeaders[k]; } }
      const res = await req.request(url, {
        method: http.RequestMethod.POST,
        header: h,
        extraData: body,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (res.responseCode === 200 || res.responseCode === 201) return JSON.parse(res.result as string) as T;
      throw new HttpError(res.responseCode);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }

  static async post<T>(path: string, body: Object): Promise<T> {
    const req = http.createHttp();
    try {
      const h: Record<string, string> = HttpClient.buildHeaders();
      h['Content-Type'] = 'application/json';
      const res = await req.request(`${GITHUB_API_BASE}${path}`, {
        method: http.RequestMethod.POST,
        header: h,
        extraData: JSON.stringify(body),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (res.responseCode === 200 || res.responseCode === 201) return JSON.parse(res.result as string) as T;
      throw new HttpError(res.responseCode);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }

  static async put(path: string): Promise<void> {
    const req = http.createHttp();
    try {
      const res = await req.request(`${GITHUB_API_BASE}${path}`, {
        method: http.RequestMethod.PUT,
        header: HttpClient.buildHeaders(),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (res.responseCode !== 204) {
        throw new HttpError(res.responseCode);
      }
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }

  static async delete(path: string): Promise<void> {
    const req = http.createHttp();
    try {
      const res = await req.request(`${GITHUB_API_BASE}${path}`, {
        method: http.RequestMethod.DELETE,
        header: HttpClient.buildHeaders(),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (res.responseCode !== 204) {
        throw new HttpError(res.responseCode);
      }
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }
}