import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GITHUB_API_BASE, APIHeaders } from '../common/constants/APIConstants';
import { RateLimitService } from '../common/utils/RateLimitService';
import type { RateLimitExhausted } from '../common/utils/RateLimitService';
import { TokenProvider } from '../common/utils/TokenProvider';
import { SessionEvents } from '../common/utils/SessionEvents';

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
  private static readonly REQUEST_TIMEOUT: number = 15000;

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
    const token: string = TokenProvider.getToken();
    const headers: Record<string, string> = {
      'Accept': APIHeaders.ACCEPT,
      'X-GitHub-Api-Version': APIHeaders.API_VERSION
    };
    if (token) { headers['Authorization'] = `Bearer ${token}`; }
    return headers;
  }

  /** 统一请求入口：鉴权 → 超时 → 每次响应解析限流头 → 资源释放；5 个公开方法共用 */
  private static async doRequest(method: http.RequestMethod, url: string, body?: string,
    extraHeaders?: Record<string, string>): Promise<http.HttpResponse> {
    const req = http.createHttp();
    try {
      const h: Record<string, string> = HttpClient.buildHeaders();
      h['Content-Type'] = 'application/json';
      if (extraHeaders) {
        const keys: string[] = Object.keys(extraHeaders);
        for (let i = 0; i < keys.length; i++) {
          const k: string = keys[i];
          h[k] = extraHeaders[k];
        }
      }
      const options: http.HttpRequestOptions = {
        method: method,
        header: h,
        extraData: body,
        connectTimeout: HttpClient.REQUEST_TIMEOUT,
        readTimeout: HttpClient.REQUEST_TIMEOUT
      };
      const res = await req.request(url, options);
      // 限流对全部动词生效，写操作后配额数据也保持最新
      RateLimitService.parseHeaders(res.header as Record<string, string>);
      return res;
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new HttpError(0);
    } finally { req.destroy(); }
  }

  /** 2xx 判定 + 401 未授权信号 + 403/429 配额耗尽映射；非 2xx 抛结构化错误 */
  private static ensureOk(res: http.HttpResponse): void {
    const code: number = res.responseCode;
    if (code >= 200 && code < 300) return;
    if (code === 401) {
      // token 失效：只发全局信号，登录态清理与跳转由 Shell 处理（避免传输层反向依赖业务服务）
      SessionEvents.notifyUnauthorized();
    }
    if (code === 403 || code === 429) {
      const exhausted: RateLimitExhausted | null = RateLimitService.getExhaustedInfo();
      if (exhausted !== null) { throw new RateLimitError(exhausted); }
    }
    throw new HttpError(code);
  }

  /** 解析 JSON 响应体；失败转中文兜底错误，不再让英文 SyntaxError 直透 */
  private static parseJson<T>(res: http.HttpResponse): T {
    const raw: string = res.result as string;
    try {
      return JSON.parse(raw) as T;
    } catch (e) {
      throw new Error('响应数据解析失败');
    }
  }

  static async get<T>(path: string): Promise<T> {
    const res = await HttpClient.doRequest(http.RequestMethod.GET, GITHUB_API_BASE + path);
    HttpClient.ensureOk(res);
    return HttpClient.parseJson<T>(res);
  }

  /** 完整 URL + 自定义头（供 OAuth 等非 api.github.com 场景使用） */
  static async postRaw<T>(url: string, body: string, extraHeaders?: Record<string, string>): Promise<T> {
    const res = await HttpClient.doRequest(http.RequestMethod.POST, url, body, extraHeaders);
    HttpClient.ensureOk(res);
    return HttpClient.parseJson<T>(res);
  }

  static async post<T>(path: string, body: Object): Promise<T> {
    const res = await HttpClient.doRequest(http.RequestMethod.POST, GITHUB_API_BASE + path, JSON.stringify(body));
    HttpClient.ensureOk(res);
    return HttpClient.parseJson<T>(res);
  }

  /** 编辑类接口官方推荐 PATCH（当前无调用需求，备用） */
  static async patch<T>(path: string, body: Object): Promise<T> {
    const res = await HttpClient.doRequest(http.RequestMethod.PATCH, GITHUB_API_BASE + path, JSON.stringify(body));
    HttpClient.ensureOk(res);
    return HttpClient.parseJson<T>(res);
  }

  static async put(path: string): Promise<void> {
    const res = await HttpClient.doRequest(http.RequestMethod.PUT, GITHUB_API_BASE + path);
    HttpClient.ensureOk(res);
  }

  static async delete(path: string): Promise<void> {
    const res = await HttpClient.doRequest(http.RequestMethod.DELETE, GITHUB_API_BASE + path);
    HttpClient.ensureOk(res);
  }
}