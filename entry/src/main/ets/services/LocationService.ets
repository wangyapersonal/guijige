/**
 * 定位服务
 */

import geoLocationManager from '@ohos.geoLocationManager';
import { Location } from '../common/types/CommonTypes';

export class LocationService {
  private static instance: LocationService;
  private locationCallback: ((location: Location) => void) | null = null;
  private isTracking: boolean = false;
  private cachedLocation: Location | null = null;
  
  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }
  
  private constructor() {}
  
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
   * 开始持续定位
   */
  async startContinuousTracking(
    callback: (location: Location) => void
  ): Promise<boolean> {
    if (this.isTracking) {
      return true;
    }
    
    try {
      this.locationCallback = callback;
      
      const requestInfo: geoLocationManager.LocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        timeInterval: 60,  // 60秒
        distanceInterval: 0
      };
      
      geoLocationManager.on('locationChange', requestInfo, (location: geoLocationManager.Location) => {
        if (location && this.locationCallback) {
          this.cachedLocation = {
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: location.altitude,
            accuracy: location.accuracy,
            speed: location.speed,
            timestamp: Date.now()
          };
          this.locationCallback(this.cachedLocation);
        }
      });
      
      this.isTracking = true;
      console.info('LocationService', 'startContinuousTracking success');
      return true;
    } catch (error) {
      console.error('LocationService', 'startContinuousTracking error', error);
      return false;
    }
  }
  
  /**
   * 停止持续定位
   */
  stopContinuousTracking(): void {
    if (!this.isTracking || !this.locationCallback) {
      return;
    }
    
    try {
      geoLocationManager.off('locationChange', this.locationCallback);
      this.locationCallback = null;
      this.isTracking = false;
      console.info('LocationService', 'stopContinuousTracking success');
    } catch (error) {
      console.error('LocationService', 'stopContinuousTracking error', error);
    }
  }
  
  /**
   * 检查定位权限
   */
  async checkLocationPermission(): Promise<boolean> {
    // TODO: 实现权限检查
    return true;
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
}
