import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import {
  GITHUB_OAUTH_ACCESS_TOKEN_URL,
  GITHUB_OAUTH_DEVICE_CODE_URL,
  GITHUB_OAUTH_CLIENT_ID,
  GITHUB_OAUTH_SCOPES,
  AUTH_TOKEN_KEY,
  AUTH_LOGIN_KEY
} from '../common/constants/APIConstants';
import { DeviceFlowInfo, DevicePollResult, DevicePollStatus } from '../models/AuthModels';
import { http } from '@kit.NetworkKit';
import { huks } from '@kit.UniversalKeystoreKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { util } from '@kit.ArkTS';

const PREFERENCES_NAME: string = 'github_auth_prefs';

export class AuthService {
  private static appContext: common.UIAbilityContext | null = null;

  static init(context: common.UIAbilityContext): void {
    AuthService.appContext = context;
  }

  private static getContext(): common.UIAbilityContext {
    return AuthService.appContext!;
  }

  /** HUKS 密钥别名 + 加密后 token 的偏好键 */
  private static readonly TOKEN_KEY_ALIAS: string = 'yunjicangma_token_key_v2';
  private static readonly ENC_TOKEN_PREF: string = 'access_token_enc';

  /** AES-256-GCM 密钥生成参数（密钥驻留系统密钥库，不可导出） */
  private static keyGenOptions(): huks.HuksOptions {
    const props: huks.HuksParam[] = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT | huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7 }
    ];
    const opts: huks.HuksOptions = { properties: props };
    return opts;
  }

  /** AES-CBC 会话属性（算法/密钥长度/目的/模式/填充/随机 IV） */
  private static cbcParams(purpose: number, iv: Uint8Array): huks.HuksParam[] {
    const props: huks.HuksParam[] = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: huks.HuksKeySize.HUKS_AES_KEY_SIZE_256 },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: purpose },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_CBC },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_PKCS7 },
      { tag: huks.HuksTag.HUKS_TAG_IV, value: iv }
    ];
    return props;
  }

  private static async ensureTokenKey(): Promise<void> {
    let exists: boolean = false;
    try {
      exists = await huks.isKeyItemExist(AuthService.TOKEN_KEY_ALIAS, AuthService.keyGenOptions());
    } catch (e) {
      // HUKS 怪癖：密钥不存在时 isKeyItemExist 抛 ITEM_NOT_EXIST(12000011) 而非返回 false
      const msg: string = JSON.stringify(e);
      if (msg.indexOf('12000011') === -1) { throw new Error('HUKS isKeyItemExist: ' + msg); }
    }
    if (!exists) {
      try {
        await huks.generateKeyItem(AuthService.TOKEN_KEY_ALIAS, AuthService.keyGenOptions());
      } catch (e) {
        // 并发/重试时密钥已存在 → KEY_ALREADY_EXIST(12000017)，忽略
        const msg: string = JSON.stringify(e);
        if (msg.indexOf('12000017') === -1) { throw new Error('HUKS generateKeyItem: ' + msg); }
      }
    }
  }

  /** 用 HUKS AES-CBC 加密 token，返回 {iv, ct} 的 JSON（base64） */
  private static async encryptTokenValue(plaintext: string): Promise<string> {
    await AuthService.ensureTokenKey();
    let nonceBlob: cryptoFramework.DataBlob;
    try { nonceBlob = cryptoFramework.createRandom().generateRandomSync(16); }
    catch (e) { throw new Error('Random generation failed: ' + JSON.stringify(e)); }
    const plainBytes: Uint8Array = new Uint8Array(plaintext.length);
    for (let i = 0; i < plaintext.length; i++) { plainBytes[i] = plaintext.charCodeAt(i); }
    // 数据经 options.inData 传入（不是函数第三参），小数据一次性 init → finish
    const props: huks.HuksParam[] = AuthService.cbcParams(huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT, nonceBlob.data);
    // 官方流程：同一 options（含 inData）传给 initSession 与 finishSession
    const options: huks.HuksOptions = { properties: props, inData: plainBytes };
    let handle: huks.HuksSessionHandle;
    try {
      handle = await huks.initSession(AuthService.TOKEN_KEY_ALIAS, options);
    } catch (e) {
      throw new Error('HUKS encrypt initSession: ' + JSON.stringify(e));
    }
    let finish: huks.HuksReturnResult;
    try {
      finish = await huks.finishSession(handle.handle, options);
    } catch (e) {
      throw new Error('HUKS encrypt finishSession: ' + JSON.stringify(e));
    }
    const ctOut: Uint8Array | undefined = finish.outData;
    if (ctOut === undefined) { throw new Error('HUKS encrypt failed: missing output'); }
    const base64 = new util.Base64Helper();
    const blob: Record<string, string> = {
      'iv': base64.encodeToStringSync(nonceBlob.data),
      'ct': base64.encodeToStringSync(ctOut)
    };
    return JSON.stringify(blob);
  }

  /** 解密 HUKS 密文 blob 还原 token */
  private static async decryptTokenValue(blob: string): Promise<string> {
    const obj: Record<string, string> = JSON.parse(blob) as Record<string, string>;
    const base64 = new util.Base64Helper();
    const iv: Uint8Array = base64.decodeSync(obj['iv']);
    const ct: Uint8Array = base64.decodeSync(obj['ct']);
    const props: huks.HuksParam[] = AuthService.cbcParams(huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT, iv);
    const options: huks.HuksOptions = { properties: props, inData: ct };
    let handle: huks.HuksSessionHandle;
    try {
      handle = await huks.initSession(AuthService.TOKEN_KEY_ALIAS, options);
    } catch (e) {
      throw new Error('HUKS decrypt initSession: ' + JSON.stringify(e));
    }
    let finish: huks.HuksReturnResult;
    try {
      finish = await huks.finishSession(handle.handle, options);
    } catch (e) {
      throw new Error('HUKS decrypt finishSession: ' + JSON.stringify(e));
    }
    const out: Uint8Array | undefined = finish.outData;
    if (out === undefined) { throw new Error('HUKS decrypt failed: missing output'); }
    const bytes: Uint8Array = out;
    let s: string = '';
    for (let i = 0; i < bytes.length; i++) { s += String.fromCharCode(bytes[i]); }
    return s;
  }

  static async saveToken(token: string): Promise<void> {
    try {
      const enc: string = await AuthService.encryptTokenValue(token);
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      await prefs.put(AuthService.ENC_TOKEN_PREF, enc);
      await prefs.delete('access_token'); // 清理旧明文
      await prefs.flush();
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
    } catch (err) {
      // 加密失败则不落盘明文（fail-closed），让调用方感知登录失败
      throw err instanceof Error ? err : new Error(JSON.stringify(err));
    }
  }

  static async loadToken(): Promise<string> {
    try {
      const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
      const enc: string = await prefs.get(AuthService.ENC_TOKEN_PREF, '') as string;
      if (enc) {
        const token: string = await AuthService.decryptTokenValue(enc);
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, token);
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
        return token;
      }
      // 旧版明文 token 迁移到加密存储
      const legacy: string = await prefs.get('access_token', '') as string;
      if (legacy) {
        await AuthService.saveToken(legacy);
        AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, legacy);
        AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, true);
        return legacy;
      }
      AppStorage.setOrCreate<string>(AUTH_TOKEN_KEY, '');
      AppStorage.setOrCreate<boolean>(AUTH_LOGIN_KEY, false);
      return '';
    } catch (err) {
      console.error('Failed to load token:', JSON.stringify(err));
      // 清理损坏/过期密文（如旧 GCM 时代残留），避免每次启动反复失败
      try {
        const prefs = await preferences.getPreferences(AuthService.getContext(), PREFERENCES_NAME);
        await prefs.delete(AuthService.ENC_TOKEN_PREF);
        await prefs.flush();
      } catch (e) { }
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
      await prefs.delete(AuthService.ENC_TOKEN_PREF);
      await prefs.delete('access_token');
      await prefs.flush();
      // 一并删除 HUKS 密钥，旧密文永久不可解
      try { await huks.deleteKeyItem(AuthService.TOKEN_KEY_ALIAS, AuthService.keyGenOptions()); } catch (e) { }
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
          extraData: `client_id=${encodeURIComponent(GITHUB_OAUTH_CLIENT_ID)}` +
            `&scope=${encodeURIComponent(GITHUB_OAUTH_SCOPES)}`
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
