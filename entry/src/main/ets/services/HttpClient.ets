import { http } from '@kit.NetworkKit';
import { GITHUB_API_BASE, APIHeaders } from '../common/constants/APIConstants';
import { AuthService } from './AuthService';

export class HttpClient {
  /** 将异常格式化为用户可读的错误信息（从消息字符串解析 HTTP 状态码） */
  static formatError(e: Object): string {
    if (e instanceof Error) {
      const msg: string = e.message || '';
      const m: RegExpMatchArray | null = msg.match(/HTTP (\d+)/);
      if (m) {
        const code: number = parseInt(m[1]);
        if (code === 401) return '授权已失效，请重新登录';
        if (code === 403) return '请求过于频繁，请稍后重试';
        if (code === 404) return '仓库不存在或无权访问';
        return `请求失败 (HTTP ${code})`;
      }
      if (msg === 'NETWORK_ERROR') return '网络连接失败，请检查网络';
      return msg || '加载失败，请重试';
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
      if (res.responseCode === 200) return JSON.parse(res.result as string) as T;
      throw new Error(`HTTP ${res.responseCode}`);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error('NETWORK_ERROR');
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
      throw new Error(`HTTP ${res.responseCode}`);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error(JSON.stringify(e));
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
      throw new Error(`HTTP ${res.responseCode} for ${path}`);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error(JSON.stringify(e));
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
        throw new Error(`HTTP ${res.responseCode} for ${path}`);
      }
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error(JSON.stringify(e));
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
        throw new Error(`HTTP ${res.responseCode} for ${path}`);
      }
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error(JSON.stringify(e));
    } finally { req.destroy(); }
  }
}
