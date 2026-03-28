
/**
 * 应用常量定义
 */
// 类型定义
export interface LocationConfig {
  INTERVAL: number;
  STAY_DISTANCE: number;
  STAY_MIN_DURATION: number;
  MAX_CACHE_POINTS: number;
}

export interface ApiConfig {
  BASE_URL: string;
  VERSION: string;
  TIMEOUT: number;
}

export interface StorageKeys {
  USER_INFO: string;
  ACCESS_TOKEN: string;
  REFRESH_TOKEN: string;
  CURRENT_TRIP: string;
  LAST_LOCATION: string;
}

// 应用信息
export const APP_NAME = '轨迹哥';
export const APP_VERSION = '1.0.0';

// 定位相关
export const LOCATION_CONFIG: LocationConfig = {
  // 定位间隔（毫秒）
  INTERVAL: 60 * 1000, // 1分钟
  // 停留点判定距离（米）
  STAY_DISTANCE: 50,
  // 停留点最小时长（秒）
  STAY_MIN_DURATION: 60,
  // 最大缓存位置数
  MAX_CACHE_POINTS: 100
};

// 打卡类型
export enum CheckInType {
  AUTO = 'auto',        // 自动打卡
  MANUAL = 'manual',    // 手动打卡
  PHOTO_IMPORT = 'photo' // 照片导入
}

// 行程状态
export enum TripStatus {
  NOT_STARTED = 'not_started',
  ONGOING = 'ongoing',
  COMPLETED = 'completed'
}

// 记录模式
export enum RecordMode {
  DRIVING = 'driving',  // 自驾
  CYCLING = 'cycling',  // 骑行
  WALKING = 'walking'   // 步行
}
// API配置
export const API_CONFIG: ApiConfig = {
  BASE_URL: 'https://api.traveltracker.com',
  VERSION: 'v1',
  TIMEOUT: 30000
};
// 存储Key
export const STORAGE_KEYS: StorageKeys = {
  USER_INFO: 'user_info',
  ACCESS_TOKEN: 'access_token',
  REFRESH_TOKEN: 'refresh_token',
  CURRENT_TRIP: 'current_trip',
  LAST_LOCATION: 'last_location'
};
