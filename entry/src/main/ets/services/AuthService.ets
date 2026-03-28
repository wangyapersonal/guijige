/**
 * 认证服务 - 集成华为账号登录
 * 使用 HarmonyOS NEXT @kit.AccountKit
 */
// @ts-nocheck
import { authentication } from '@kit.AccountKit';
import common from '@ohos.ability.common';
import { UserInfo, LoginStatus } from '../models/User';
import { StorageService } from './StorageService';
import { STORAGE_KEYS } from '../common/constants/Constants';

export class AuthService {
  private static instance: AuthService;
  private storageService: StorageService;
  private userInfo: UserInfo | null = null;
  
  // Token刷新阈值（提前5分钟）
  private readonly REFRESH_THRESHOLD = 5 * 60 * 1000;

  // 是否使用模拟登录（开发阶段）
  // ⚠️ 生产环境必须设置为 false
  private readonly USE_MOCK_LOGIN: boolean = false;
  
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
   */
  async loginWithHuawei(): Promise<UserInfo | null> {
    // 开发阶段使用模拟登录
    if (this.USE_MOCK_LOGIN) {
      console.warn('AuthService', 'Using mock login mode');
      return this.loginWithMock();
    }
    
    try {
      // 获取华为账号认证能力
      const authRequest: authentication.HuaweiIDProvider.AuthorizationCodeRequest = {
        accountAccessType: authentication.HuaweiIDProvider.AccountAccessType.ID,
        authorizationCode: [],
        state: 'guijige_' + Date.now(),
        scopeList: [
          authentication.HuaweiIDProvider.Permission.OPENID,
          authentication.HuaweiIDProvider.Permission.PROFILE
        ]
      };
      
      // 创建认证请求并登录
      const authManager = authentication.getAuthenticationManager();
      const result = await authManager.beginTransaction()
        .setHuaweiIDProvider(authRequest)
        .login();
      
      if (result && result.user) {
        const user: UserInfo = {
          uid: result.user.uid || result.user.unionId || '',
          displayName: result.user.displayName || '华为用户',
          avatar: result.user.avatarUri || null,
          accessToken: result.accessToken || '',
          refreshToken: result.refreshToken || '',
          expiresIn: result.expiresIn || 7200,
          loggedInAt: Date.now(),
          openId: result.user.openId,
          unionId: result.user.unionId
        };
        
        this.userInfo = user;
        await this.saveUserInfo(user);

        console.info('AuthService', 'Huawei login success');
        return user;
      }
      
      return null;
    } catch (error) {
      console.error('AuthService', 'Huawei login error', error);
      // 降级到模拟登录
      return this.loginWithMock();
    }
  }
  
  /**
   * 模拟登录（开发测试用）
   */
  private async loginWithMock(): Promise<UserInfo | null> {
    const mockUser: UserInfo = {
      uid: 'mock_user_' + Date.now(),
      displayName: '测试用户',
      avatar: null,
      accessToken: 'mock_token_' + Date.now(),
      refreshToken: 'mock_refresh_token',
      expiresIn: 7200,
      loggedInAt: Date.now()
    };
    
    this.userInfo = mockUser;
    await this.saveUserInfo(mockUser);
    
    console.info('AuthService', 'Mock login success');
    return mockUser;
  }
  
  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    try {
      // 尝试调用系统登出
      if (!this.USE_MOCK_LOGIN) {
        try {
          const authManager = authentication.getAuthenticationManager();
          await authManager.logout();
        } catch (e) {
          console.warn('AuthService', 'System logout failed', e);
        }
      }
      
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
    if (!this.userInfo) {
      return false;
    }
    
    try {
      if (this.USE_MOCK_LOGIN) {
        // 模拟刷新
        this.userInfo.accessToken = 'mock_refreshed_' + Date.now();
        this.userInfo.expiresIn = 7200;
        this.userInfo.loggedInAt = Date.now();
        await this.saveUserInfo(this.userInfo);
        return true;
      }
      
      const refreshToken = this.userInfo.refreshToken;
      if (!refreshToken) {
        return false;
      }
      
      const authManager = authentication.getAuthenticationManager();
      const result = await authManager.refreshToken(refreshToken);
      
      if (result) {
        this.userInfo.accessToken = result.accessToken;
        this.userInfo.expiresIn = result.expiresIn;
        this.userInfo.loggedInAt = Date.now();
        
        if (result.refreshToken) {
          this.userInfo.refreshToken = result.refreshToken;
        }
        
        await this.saveUserInfo(this.userInfo);
        console.info('AuthService', 'Token refreshed');
        return true;
      }
      return false;
    } catch (error) {
      console.error('AuthService', 'refresh token error', error);
      return false;
    }
  }
  
  /**
   * 检查并自动刷新Token
   */
  async ensureValidToken(): Promise<string | null> {
    if (!this.userInfo) {
      return null;
    }
    
    const expiresAt = this.userInfo.loggedInAt + this.userInfo.expiresIn * 1000;
    const shouldRefresh = Date.now() >= (expiresAt - this.REFRESH_THRESHOLD);
    
    if (shouldRefresh) {
      const refreshed = await this.refreshAccessToken();
      if (!refreshed) {
        await this.logout();
        return null;
      }
    }
    
    return this.userInfo.accessToken;
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
