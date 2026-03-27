/**
 * 认证服务
 */

import { UserInfo, LoginStatus, TokenInfo } from '../models/User';
import { StorageService } from './StorageService';
import { STORAGE_KEYS } from '../common/constants/Constants';

export class AuthService {
  private static instance: AuthService;
  private storageService: StorageService;
  private userInfo: UserInfo | null = null;
  
  // Token刷新阈值（提前5分钟）
  private readonly REFRESH_THRESHOLD = 5 * 60 * 1000;
  
  static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }
  
  constructor() {
    this.storageService = StorageService.getInstance();
  }
  
  /**
   * 初始化 - 恢复登录状态
   */
  async init(): Promise<void> {
    try {
      this.userInfo = await this.storageService.getObject<UserInfo | null>(
        STORAGE_KEYS.USER_INFO,
        null
      );
      console.info('AuthService', 'initialized', this.userInfo ? 'logged in' : 'not logged in');
    } catch (error) {
      console.error('AuthService', 'init error', error);
    }
  }
  
  /**
   * 华为账号登录
   * TODO: 集成HMS Core
   */
  async loginWithHuawei(): Promise<UserInfo | null> {
    try {
      // TODO: 调用华为登录SDK
      // 临时模拟登录
      const mockUser: UserInfo = {
        uid: 'mock_' + Date.now(),
        displayName: '测试用户',
        avatar: null,
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresIn: 7200,
        loggedInAt: Date.now()
      };
      
      this.userInfo = mockUser;
      await this.saveUserInfo(mockUser);
      
      console.info('AuthService', 'login success', mockUser.uid);
      return mockUser;
    } catch (error) {
      console.error('AuthService', 'login error', error);
      return null;
    }
  }
  
  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    try {
      this.userInfo = null;
      await this.storageService.remove(STORAGE_KEYS.USER_INFO);
      await this.storageService.remove(STORAGE_KEYS.ACCESS_TOKEN);
      await this.storageService.remove(STORAGE_KEYS.REFRESH_TOKEN);
      
      console.info('AuthService', 'logout success');
    } catch (error) {
      console.error('AuthService', 'logout error', error);
    }
  }
  
  /**
   * 获取当前用户
   */
  getCurrentUser(): UserInfo | null {
    return this.userInfo;
  }
  
  /**
   * 检查登录状态
   */
  getLoginStatus(): LoginStatus {
    if (!this.userInfo) {
      return LoginStatus.NOT_LOGGED_IN;
    }
    
    const expiresAt = this.userInfo.loggedInAt + this.userInfo.expiresIn * 1000;
    if (Date.now() >= expiresAt) {
      return LoginStatus.TOKEN_EXPIRED;
    }
    
    return LoginStatus.LOGGED_IN;
  }
  
  /**
   * 是否已登录
   */
  isLoggedIn(): boolean {
    return this.getLoginStatus() === LoginStatus.LOGGED_IN;
  }
  
  /**
   * 获取AccessToken
   */
  getAccessToken(): string | null {
    return this.userInfo?.accessToken || null;
  }
  
  /**
   * 刷新Token
   */
  async refreshAccessToken(): Promise<boolean> {
    if (!this.userInfo) return false;
    
    try {
      // TODO: 调用刷新Token API
      console.info('AuthService', 'refresh token');
      return true;
    } catch (error) {
      console.error('AuthService', 'refresh token error', error);
      return false;
    }
  }
  
  /**
   * 保存用户信息
   */
  private async saveUserInfo(user: UserInfo): Promise<void> {
    await this.storageService.putObject(STORAGE_KEYS.USER_INFO, user);
    await this.storageService.putString(STORAGE_KEYS.ACCESS_TOKEN, user.accessToken);
    await this.storageService.putString(STORAGE_KEYS.REFRESH_TOKEN, user.refreshToken);
  }
}
