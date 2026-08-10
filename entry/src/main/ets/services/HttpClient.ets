import { http } from '@kit.NetworkKit';
import { GITHUB_API_BASE, APIHeaders } from '../common/constants/APIConstants';
import { AuthService } from './AuthService';

export class HttpClient {
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
        header: HttpClient.buildHeaders()
      });
      if (res.responseCode === 200) return JSON.parse(res.result as string) as T;
      throw new Error(`HTTP ${res.responseCode} for ${path}`);
    } catch (e) { throw e; } finally { req.destroy(); }
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
        extraData: body
      });
      if (res.responseCode === 200 || res.responseCode === 201) return JSON.parse(res.result as string) as T;
      throw new Error(`HTTP ${res.responseCode}`);
    } catch (e) { throw e; } finally { req.destroy(); }
  }

  static async post<T>(path: string, body: Object): Promise<T> {
    const req = http.createHttp();
    try {
      const h: Record<string, string> = HttpClient.buildHeaders();
      h['Content-Type'] = 'application/json';
      const res = await req.request(`${GITHUB_API_BASE}${path}`, {
        method: http.RequestMethod.POST,
        header: h,
        extraData: JSON.stringify(body)
      });
      if (res.responseCode === 200 || res.responseCode === 201) return JSON.parse(res.result as string) as T;
      throw new Error(`HTTP ${res.responseCode} for ${path}`);
    } catch (e) { throw e; } finally { req.destroy(); }
  }
}
