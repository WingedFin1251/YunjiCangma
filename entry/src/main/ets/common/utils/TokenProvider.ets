/**
 * 令牌提供者 — 只依赖 AppStorage，不含任何业务逻辑
 * 传输层（HttpClient）通过它读取 token，从而不 import 业务服务 AuthService（services → common 方向）
 */
import { AUTH_TOKEN_KEY } from '../constants/APIConstants';

export class TokenProvider {
  static getToken(): string {
    return AppStorage.get<string>(AUTH_TOKEN_KEY) || '';
  }
}