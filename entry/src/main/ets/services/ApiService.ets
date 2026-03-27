/**
 * API服务 - 网络请求封装
 */

import http from '@ohos.net.http';
import { AuthService } from './AuthService';
import { ApiResponse } from '../common/types/CommonTypes';
import { API_CONFIG } from '../common/constants/Constants';

export class ApiService {
  private static instance: ApiService;
  private authService: AuthService;
  
  static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }
  
  constructor() {
    this.authService = AuthService.getInstance();
  }
  
  /**
   * GET请求
   */
  async get<T>(path: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
    return this.request<T>('GET', path, params);
  }
  
  /**
   * POST请求
   */
  async post<T>(path: string, body?: any): Promise<ApiResponse<T>> {
    return this.request<T>('POST', path, undefined, body);
  }
  
  /**
   * PUT请求
   */
  async put<T>(path: string, body?: any): Promise<ApiResponse<T>> {
    return this.request<T>('PUT', path, undefined, body);
  }
  
  /**
   * DELETE请求
   */
  async delete<T>(path: string): Promise<ApiResponse<T>> {
    return this.request<T>('DELETE', path);
  }
  
  /**
   * 通用请求方法
   */
  private async request<T>(
    method: http.RequestMethod,
    path: string,
    params?: Record<string, any>,
    body?: any
  ): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp();
    
    try {
      // 构建URL
      let url = `${API_CONFIG.BASE_URL}/${API_CONFIG.VERSION}${path}`;
      if (params) {
        const queryString = Object.entries(params)
          .map(([key, value]) => `${key}=${encodeURIComponent(String(value))}`)
          .join('&');
        url += `?${queryString}`;
      }
      
      // 构建请求头
      const headers: http.HttpHeader = {
        'Content-Type': 'application/json'
      };
      
      // 添加认证Token
      const token = this.authService.getAccessToken();
      if (token) {
        headers['Authorization'] = `Bearer ${token}`;
      }
      
      // 发送请求
      const response = await httpRequest.request(url, {
        method: method,
        header: headers,
        extraData: body ? JSON.stringify(body) : undefined,
        connectTimeout: API_CONFIG.TIMEOUT,
        readTimeout: API_CONFIG.TIMEOUT
      });
      
      // 处理响应
      if (response.responseCode === 200 || response.responseCode === 201) {
        const data = JSON.parse(response.result as string);
        return {
          code: data.code || 0,
          data: data.data,
          message: data.message
        };
      } else if (response.responseCode === 401) {
        // Token过期
        const refreshed = await this.authService.refreshAccessToken();
        if (refreshed) {
          // 重试请求
          return this.request<T>(method, path, params, body);
        }
        return {
          code: 401,
          message: '未授权，请重新登录'
        };
      } else {
        return {
          code: response.responseCode,
          message: `请求失败: ${response.responseCode}`
        };
      }
    } catch (error) {
      console.error('ApiService', 'request error', error);
      return {
        code: -1,
        message: `网络错误: ${error}`
      };
    } finally {
      httpRequest.destroy();
    }
  }
}
