import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { PREFERENCES_NAME } from '../common/constants/Constants';

export class StorageService {
  private static instance: StorageService;
  private preferences: preferences.Preferences | null = null;

  private constructor() {
  }

  static getInstance(): StorageService {
    if (!StorageService.instance) {
      StorageService.instance = new StorageService();
    }
    return StorageService.instance;
  }

  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to get preferences. Code:${error.code},message:${error.message}`);
    }
  }

  async put(key: string, value: preferences.ValueType): Promise<void> {
    try {
      if (this.preferences) {
        await this.preferences.put(key, value);
      }
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to put data. Code:${error.code},message:${error.message}`);
    }
  }

  async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    try {
      if (this.preferences) {
        return await this.preferences.get(key, defaultValue);
      }
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to get value. Code:${error.code},message:${error.message}`);
    }
    return defaultValue;
  }

  async delete(key: string): Promise<void> {
    try {
      if (this.preferences) {
        await this.preferences.delete(key);
      }
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to delete. Code:${error.code},message:${error.message}`);
    }
  }
}
