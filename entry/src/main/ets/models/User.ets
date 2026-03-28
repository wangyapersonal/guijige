/**
 * 用户信息模型
 */

// 用户信息
export interface UserInfo {
  uid: string;                  // 用户ID
  displayName: string | null;   // 昵称
  avatar: string | null;        // 头像URL
  accessToken: string;          // 访问令牌
  refreshToken: string;         // 刷新令牌
  expiresIn: number;            // 过期时间（秒）
  loggedInAt: number;           // 登录时间
  openId?: string;              // 华为OpenID
  unionId?: string;             // 华为UnionID
}

// 登录状态
export enum LoginStatus {
  NOT_LOGGED_IN = 'not_logged_in',
  LOGGED_IN = 'logged_in',
  TOKEN_EXPIRED = 'token_expired'
}

// Token信息
export interface TokenInfo {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  expiresAt: number;  // 过期时间戳
}
