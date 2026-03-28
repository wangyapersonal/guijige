/**
 * 定位服务 - 支持后台持续定位
 */

import geoLocationManager from '@ohos.geoLocationManager';
import backgroundTaskManager from '@ohos.backgroundTaskManager';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { Location } from '../common/types/CommonTypes';
import { RecordMode } from '../common/constants/Constants';

// 定位模式配置
interface LocationConfig {
  priority: number;
  timeInterval: number;      // 秒
  distanceInterval: number;   // 米
}

// 不同运动模式的定位配置
const LOCATION_CONFIGS: Record<RecordMode, LocationConfig> = {
  [RecordMode.DRIVING]: {
    priority: geoLocationManager.LocationRequestPriority.ACCURACY,
    timeInterval: 10,      // 自驾每10秒
    distanceInterval: 50   // 或移动50米
  },
  [RecordMode.CYCLING]: {
    priority: geoLocationManager.LocationRequestPriority.ACCURACY,
    timeInterval: 5,       // 骑行每5秒
    distanceInterval: 20   // 或移动20米
  },
  [RecordMode.WALKING]: {
    priority: geoLocationManager.LocationRequestPriority.ACCURACY,
    timeInterval: 3,       // 步行每3秒
    distanceInterval: 10   // 或移动10米
  }
};

export class LocationService {
  private static instance: LocationService;
  private locationCallback: ((location: Location) => void) | null = null;
  private isTracking: boolean = false;
  private cachedLocation: Location | null = null;
  private backgroundTaskId: number = -1;
  private wantAgent: WantAgent | null = null;
  private currentMode: RecordMode = RecordMode.DRIVING;
  private context: common.UIAbilityContext | null = null;
  
  // 位置历史（用于计算距离）
  private locationHistory: Location[] = [];
  private totalDistance: number = 0;
  
  // 位置过滤阈值
  private readonly ACCURACY_THRESHOLD = 100;  // 精度低于100m的点丢弃
  private readonly SPEED_THRESHOLD = 200;     // 速度超过200km/h视为异常
  
  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }
  
  private constructor() {}
  
  /**
   * 初始化（需要 AbilityContext）
   */
  init(context: common.UIAbilityContext): void {
    this.context = context;
    console.info('LocationService', 'initialized');
  }
  
  /**
   * 获取当前位置（单次）
   */
  async getCurrentLocation(): Promise<Location | null> {
    // 返回缓存位置（5分钟内）
    if (this.cachedLocation && 
        Date.now() - this.cachedLocation.timestamp < 5 * 60 * 1000) {
      return this.cachedLocation;
    }
    
    try {
      const requestInfo: geoLocationManager.SingleLocationRequest = {
        locatingTimeoutMs: 15000,
        locatinigMaxAge: 60 * 1000
      };
      
      return new Promise((resolve) => {
        geoLocationManager.getCurrentLocation(requestInfo, (err, location) => {
          if (err || !location) {
            console.error('LocationService', 'getCurrentLocation failed', err);
            resolve(this.cachedLocation);
          } else {
            this.cachedLocation = {
              latitude: location.latitude,
              longitude: location.longitude,
              altitude: location.altitude,
              accuracy: location.accuracy,
              speed: location.speed,
              timestamp: Date.now()
            };
            resolve(this.cachedLocation);
          }
        });
      });
    } catch (error) {
      console.error('LocationService', 'getCurrentLocation error', error);
      return this.cachedLocation;
    }
  }
  
  /**
   * 开始持续定位（前台）
   */
  async startContinuousTracking(
    callback: (location: Location) => void,
    mode: RecordMode = RecordMode.DRIVING
  ): Promise<boolean> {
    if (this.isTracking) {
      // 如果已启动，仅更新回调
      this.locationCallback = callback;
      return true;
    }
    
    this.currentMode = mode;
    this.locationCallback = callback;
    
    const config = LOCATION_CONFIGS[mode];
    
    try {
      const requestInfo: geoLocationManager.LocationRequest = {
        priority: config.priority,
        timeInterval: config.timeInterval,
        distanceInterval: config.distanceInterval
      };
      
      geoLocationManager.on('locationChange', requestInfo, this.handleLocationChange.bind(this));
      
      this.isTracking = true;
      this.locationHistory = [];
      this.totalDistance = 0;
      
      console.info('LocationService', 'startContinuousTracking success', mode);
      return true;
    } catch (error) {
      console.error('LocationService', 'startContinuousTracking error', error);
      return false;
    }
  }
  
  /**
   * 开始后台定位（长时任务）
   */
  async startBackgroundTracking(
    callback: (location: Location) => void,
    mode: RecordMode = RecordMode.DRIVING
  ): Promise<boolean> {
    if (!this.context) {
      console.error('LocationService', 'Context not initialized');
      return false;
    }
    
    // 先启动普通定位
    const started = await this.startContinuousTracking(callback, mode);
    if (!started) {
      return false;
    }
    
    // 申请长时任务
    try {
      // 创建 WantAgent
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context.abilityInfo.bundleName,
            abilityName: this.context.abilityInfo.name
          }
        ],
        requestCode: 0,
        operationType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
      };
      
      this.wantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      
      // 申请后台长时任务
      this.backgroundTaskId = await backgroundTaskManager.requestEnableBackgroundTask(
        this.context,
        this.wantAgent
      );
      
      console.info('LocationService', 'Background task started', this.backgroundTaskId);
      return true;
      
    } catch (error) {
      console.error('LocationService', 'startBackgroundTracking error', error);
      // 降级到普通定位
      return true;
    }
  }
  
  /**
   * 停止持续定位
   */
  stopContinuousTracking(): void {
    if (!this.isTracking) {
      return;
    }
    
    try {
      geoLocationManager.off('locationChange', this.handleLocationChange);
    } catch (e) {
      console.warn('LocationService', 'Failed to unregister location listener');
    }
    
    // 停止后台任务
    if (this.backgroundTaskId >= 0 && this.context) {
      try {
        backgroundTaskManager.cancelBackgroundTask(this.context, this.backgroundTaskId);
        this.backgroundTaskId = -1;
        console.info('LocationService', 'Background task stopped');
      } catch (e) {
        console.warn('LocationService', 'Failed to cancel background task');
      }
    }
    
    this.locationCallback = null;
    this.isTracking = false;
    console.info('LocationService', 'stopContinuousTracking success');
  }
  
  /**
   * 处理位置变化
   */
  private handleLocationChange(location: geoLocationManager.Location): void {
    if (!location || !this.locationCallback) {
      return;
    }
    
    // 位置有效性检测
    if (!this.isValidLocation(location)) {
      console.warn('LocationService', 'Invalid location filtered');
      return;
    }
    
    const newLocation: Location = {
      latitude: location.latitude,
      longitude: location.longitude,
      altitude: location.altitude,
      accuracy: location.accuracy,
      speed: location.speed,
      timestamp: Date.now()
    };
    
    // 计算距离增量
    if (this.locationHistory.length > 0) {
      const lastLocation = this.locationHistory[this.locationHistory.length - 1];
      const distance = this.calculateDistance(
        lastLocation.latitude, lastLocation.longitude,
        newLocation.latitude, newLocation.longitude
      );
      
      // 异常点检测：距离跳跃过大（可能是GPS漂移）
      if (distance > 1000 && location.speed < 10) {
        console.warn('LocationService', 'Possible GPS drift detected, distance:', distance);
        // 可以选择跳过这个点
      }
      
      this.totalDistance += distance;
    }
    
    this.cachedLocation = newLocation;
    this.locationHistory.push(newLocation);
    
    // 限制历史记录大小
    if (this.locationHistory.length > 10000) {
      this.locationHistory = this.locationHistory.slice(-5000);
    }
    
    // 回调通知
    this.locationCallback(newLocation);
  }
  
  /**
   * 位置有效性检测
   */
  private isValidLocation(location: geoLocationManager.Location): boolean {
    // 检查精度
    if (location.accuracy > this.ACCURACY_THRESHOLD) {
      return false;
    }
    
    // 检查经纬度范围
    if (location.latitude < -90 || location.latitude > 90 ||
        location.longitude < -180 || location.longitude > 180) {
      return false;
    }
    
    // 检查速度异常（超过200km/h）
    if (location.speed > this.SPEED_THRESHOLD / 3.6) {
      return false;
    }
    
    return true;
  }
  
  /**
   * 计算两点间距离（Haversine公式）
   */
  private calculateDistance(
    lat1: number, lon1: number,
    lat2: number, lon2: number
  ): number {
    const R = 6371000; // 地球半径（米）
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return R * c;
  }
  
  private toRadians(degrees: number): number {
    return degrees * Math.PI / 180;
  }
  
  /**
   * 获取总距离
   */
  getTotalDistance(): number {
    return this.totalDistance;
  }
  
  /**
   * 获取位置历史
   */
  getLocationHistory(): Location[] {
    return [...this.locationHistory];
  }
  
  /**
   * 获取缓存位置
   */
  getCachedLocation(): Location | null {
    return this.cachedLocation;
  }
  
  /**
   * 是否正在追踪
   */
  isCurrentlyTracking(): boolean {
    return this.isTracking;
  }
  
  /**
   * 获取当前模式
   */
  getCurrentMode(): RecordMode {
    return this.currentMode;
  }
  
  /**
   * 动态更新定位频率
   */
  async updateTrackingMode(mode: RecordMode): Promise<void> {
    if (!this.isTracking) {
      return;
    }
    
    // 重启定位（使用新配置）
    const callback = this.locationCallback;
    this.stopContinuousTracking();
    await this.startContinuousTracking(callback!, mode);
  }
}
