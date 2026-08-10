import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import {
  GITHUB_OAUTH_ACCESS_TOKEN_URL,
  GITHUB_OAUTH_DEVICE_CODE_URL,
  GITHUB_OAUTH_CLIENT_ID,
  AUTH_TOKEN_KEY,
  AUTH_LOGIN_KEY
} from '../common/constants/APIConstants';
import { DeviceFlowInfo, DevicePollResult, DevicePollStatus } from '../models/AuthModels';
import { http } from '@kit.NetworkKit';

const PREFERENCES_NAME: string = 'github_auth_prefs';

export class AuthService {
  private static appContext: common.UIAbilityContext | null = null;

  static init(context: common.UIAbilityContext): void {
    AuthService.appContext = context;
  }

  private static getContext(): common.UIAbilityContext {
    return AuthService.appContext!;
  }

  static async saveToken(token: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      await prefs.put('access_token', token);
      await prefs.flush();
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
    } catch (err) {
      console.error('Failed to save token:', JSON.stringify(err));
    }
  }

  static async loadToken(): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      const token: string = await prefs.get('access_token', '') as string;
      if (token) {
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
      } else {
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
      }
      return token;
    } catch (err) {
      console.error('Failed to load token:', JSON.stringify(err));
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
      return '';
    }
  }

  static getToken(): string {
    return AppStorage.get<string>(AUTH_TOKEN_KEY) || '';
  }

  static isLoggedIn(): boolean {
    return AppStorage.get<boolean>(AUTH_LOGIN_KEY) || false;
  }

  static async logout(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      await prefs.delete('access_token');
      await prefs.flush();
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
    } catch (err) {
      console.error('Failed to logout:', JSON.stringify(err));
    }
  }

  static async loadTheme(): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      return await prefs.get('app_theme', 'dark') as string;
    } catch (err) {
      return 'dark';
    }
  }

  static async saveTheme(theme: string): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      await prefs.put('app_theme', theme);
      await prefs.flush();
    } catch (err) {
      console.error('Failed to save theme:', JSON.stringify(err));
    }
  }

  static async loadGlowLevel(): Promise<number> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      return await prefs.get('glow_level', 1) as number;
    } catch (err) {
      return 1;
    }
  }

  static async saveGlowLevel(level: number): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      await prefs.put('glow_level', level);
      await prefs.flush();
    } catch (err) {
      console.error('Failed to save glow level:', JSON.stringify(err));
    }
  }

  /** 解析 GitHub 返回体：优先 JSON，兜底 form-urlencoded */
  private static parseBody(raw: string): Record<string, string> {
    const map: Record<string, string> = {};
    if (!raw) { return map; }
    if (raw.startsWith('{')) {
      try {
        const obj: Record<string, Object> = JSON.parse(raw) as Record<string, Object>;
        const keys: string[] = Object.keys(obj);
        for (let i = 0; i < keys.length; i++) {
          const k: string = keys[i];
          const v: Object | undefined = obj[k];
          map[k] = v === undefined ? '' : String(v);
        }
        return map;
      } catch (e) {
        // 落到 form 解析
      }
    }
    const pairs: string[] = raw.split('&');
    for (let i = 0; i < pairs.length; i++) {
      const p: string = pairs[i];
      const idx: number = p.indexOf('=');
      if (idx > 0) {
        map[decodeURIComponent(p.substring(0, idx))] = decodeURIComponent(p.substring(idx + 1));
      }
    }
    return map;
  }

  /** Device Flow 起始：POST /login/device/code，只需 client_id（无 secret） */
  static async startDeviceFlow(): Promise<DeviceFlowInfo> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        GITHUB_OAUTH_DEVICE_CODE_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          extraData: `client_id=${encodeURIComponent(GITHUB_OAUTH_CLIENT_ID)}`
        }
      );
      if (response.responseCode === 200) {
        const map: Record<string, string> = AuthService.parseBody(response.result as string);
        const info: DeviceFlowInfo = new DeviceFlowInfo();
        info.deviceCode = map['device_code'] || '';
        info.userCode = map['user_code'] || '';
        if (map['verification_uri']) { info.verificationUri = map['verification_uri']; }
        if (map['interval']) { info.interval = parseInt(map['interval']); }
        if (map['expires_in']) { info.expiresIn = parseInt(map['expires_in']); }
        if (!info.deviceCode || !info.userCode) {
          throw new Error(`GitHub device/code error: ${response.result as string}`);
        }
        return info;
      }
      throw new Error(`GitHub device/code failed: HTTP ${response.responseCode} ${response.result as string}`);
    } catch (e) {
      if (e instanceof Error) { throw e; }
      throw new Error(JSON.stringify(e));
    } finally {
      httpRequest.destroy();
    }
  }

  /** Device Flow 轮询：POST /login/oauth/access_token，grant_type=device_code */
  static async pollDeviceToken(deviceCode: string): Promise<DevicePollResult> {
    const result: DevicePollResult = new DevicePollResult();
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        GITHUB_OAUTH_ACCESS_TOKEN_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          extraData: `client_id=${encodeURIComponent(GITHUB_OAUTH_CLIENT_ID)}` +
            `&device_code=${encodeURIComponent(deviceCode)}` +
            `&grant_type=${encodeURIComponent('urn:ietf:params:oauth:grant-type:device_code')}`
        }
      );
      if (response.responseCode === 200) {
        const map: Record<string, string> = AuthService.parseBody(response.result as string);
        if (map['access_token']) {
          await AuthService.saveToken(map['access_token']);
          result.status = DevicePollStatus.SUCCESS;
          result.accessToken = map['access_token'];
          return result;
        }
        const err: string = map['error'] || '';
        if (err === 'authorization_pending') { result.status = DevicePollStatus.PENDING; }
        else if (err === 'slow_down') { result.status = DevicePollStatus.SLOW_DOWN; }
        else if (err === 'access_denied') { result.status = DevicePollStatus.DENIED; }
        else if (err === 'expired_token') { result.status = DevicePollStatus.EXPIRED; }
        else if (err === 'bad_verification_code') { result.status = DevicePollStatus.BAD_CODE; }
        else { result.status = DevicePollStatus.ERROR; result.detail = response.result as string; }
        return result;
      }
      result.status = DevicePollStatus.ERROR;
      result.detail = `HTTP ${response.responseCode} ${response.result as string}`;
      return result;
    } catch (e) {
      result.status = DevicePollStatus.ERROR;
      result.detail = e instanceof Error ? e.message : JSON.stringify(e);
      return result;
    } finally {
      httpRequest.destroy();
    }
  }
}
