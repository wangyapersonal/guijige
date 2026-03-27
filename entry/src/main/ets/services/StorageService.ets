/**
 * 存储服务 - 封装Preferences
 */

import preferences from '@ohos.data.preferences';
import common from '@kit.AbilityKit';

export class StorageService {
  private static instance: StorageService;
  private preferences: preferences.Preferences | null = null;
  private context: common.Context;
  
  private readonly STORE_NAME = 'guijige_store';
  
  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }
  
  private constructor() {
    this.context = getContext(this) as common.UIAbilityContext;
  }
  
  /**
   * 初始化
   */
  async init(): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(this.context, this.STORE_NAME);
      console.info('StorageService', 'initialized');
    } catch (error) {
      console.error('StorageService', 'init error', error);
      throw error;
    }
  }
  
  /**
   * 保存字符串
   */
  async putString(key: string, value: string): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }
  
  /**
   * 获取字符串
   */
  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.preferences) return defaultValue;
    return await this.preferences.get(key, defaultValue) as string;
  }
  
  /**
   * 保存数字
   */
  async putNumber(key: string, value: number): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }
  
  /**
   * 获取数字
   */
  async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    if (!this.preferences) return defaultValue;
    return await this.preferences.get(key, defaultValue) as number;
  }
  
  /**
   * 保存布尔值
   */
  async putBoolean(key: string, value: boolean): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.put(key, value);
    await this.preferences.flush();
  }
  
  /**
   * 获取布尔值
   */
  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.preferences) return defaultValue;
    return await this.preferences.get(key, defaultValue) as boolean;
  }
  
  /**
   * 保存对象（JSON序列化）
   */
  async putObject<T>(key: string, value: T): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.put(key, JSON.stringify(value));
    await this.preferences.flush();
  }
  
  /**
   * 获取对象
   */
  async getObject<T>(key: string, defaultValue: T): Promise<T> {
    if (!this.preferences) return defaultValue;
    const str = await this.preferences.get(key, '') as string;
    if (!str) return defaultValue;
    try {
      return JSON.parse(str) as T;
    } catch {
      return defaultValue;
    }
  }
  
  /**
   * 删除
   */
  async remove(key: string): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.delete(key);
    await this.preferences.flush();
  }
  
  /**
   * 清空所有
   */
  async clear(): Promise<void> {
    if (!this.preferences) return;
    await this.preferences.clear();
    await this.preferences.flush();
  }
}
