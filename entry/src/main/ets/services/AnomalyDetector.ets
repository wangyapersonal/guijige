/**
 * 异常点检测服务
 * 检测和处理 GPS 漂移、异常速度、位置跳跃等
 */

import { Location } from '../common/types/CommonTypes';
import { RecordMode } from '../common/constants/Constants';

// 异常类型
export enum AnomalyType {
  GPS_DRIFT = 'gps_drift',           // GPS漂移
  SPEED_ANOMALY = 'speed_anomaly',   // 速度异常
  POSITION_JUMP = 'position_jump',   // 位置跳跃
  ACCURACY_LOW = 'accuracy_low',     // 精度过低
  TIMESTAMP_ERROR = 'timestamp_error' // 时间戳错误
}

// 异常检测结果
export interface AnomalyResult {
  isAnomaly: boolean;
  type?: AnomalyType;
  severity?: 'low' | 'medium' | 'high';
  description?: string;
  suggestedFix?: string;
}

// 检测配置
interface DetectionConfig {
  maxSpeedKmh: Map<RecordMode, number>;       // 各模式最大速度
  maxJumpDistance: number;                     // 最大跳跃距离（米）
  minAccuracy: number;                         // 最小精度要求
  driftThreshold: number;                      // 漂移检测阈值
}

const DEFAULT_CONFIG: DetectionConfig = {
  maxSpeedKmh: new Map([
    [RecordMode.DRIVING, 200],   // 自驾最大200km/h
    [RecordMode.CYCLING, 60],    // 骑行最大60km/h
    [RecordMode.WALKING, 15]     // 步行最大15km/h
  ]),
  maxJumpDistance: 500,          // 500米跳跃视为异常
  minAccuracy: 100,              // 精度低于100米视为低精度
  driftThreshold: 50             // 50米内视为漂移
};

export class AnomalyDetector {
  private static instance: AnomalyDetector;
  private config: DetectionConfig;
  private lastValidLocation: Location | null = null;
  private lastLocations: Location[] = [];  // 最近N个点用于漂移检测
  private readonly HISTORY_SIZE = 10;
  
  static getInstance(): AnomalyDetector {
    if (!AnomalyDetector.instance) {
      AnomalyDetector.instance = new AnomalyDetector();
    }
    return AnomalyDetector.instance;
  }
  
  constructor() {
    this.config = DEFAULT_CONFIG;
  }
  
  /**
   * 检测位置异常
   */
  detect(location: Location, mode: RecordMode): AnomalyResult {
    // 1. 精度检测
    if (location.accuracy > this.config.minAccuracy) {
      return {
        isAnomaly: true,
        type: AnomalyType.ACCURACY_LOW,
        severity: 'medium',
        description: `定位精度过低: ${location.accuracy.toFixed(1)}m`,
        suggestedFix: '建议在开阔区域重新定位'
      };
    }
    
    // 2. 时间戳检测
    if (this.lastValidLocation && location.timestamp < this.lastValidLocation.timestamp) {
      return {
        isAnomaly: true,
        type: AnomalyType.TIMESTAMP_ERROR,
        severity: 'high',
        description: '时间戳顺序错误',
        suggestedFix: '跳过该点'
      };
    }
    
    // 3. 速度检测（需要上一个有效点）
    if (this.lastValidLocation) {
      const speedResult = this.checkSpeed(location, mode);
      if (speedResult.isAnomaly) {
        return speedResult;
      }
    }
    
    // 4. 位置跳跃检测
    if (this.lastValidLocation) {
      const jumpResult = this.checkPositionJump(location);
      if (jumpResult.isAnomaly) {
        return jumpResult;
      }
    }
    
    // 5. GPS 漂移检测
    if (this.lastLocations.length >= 3) {
      const driftResult = this.checkDrift(location);
      if (driftResult.isAnomaly) {
        return driftResult;
      }
    }
    
    // 更新历史记录
    this.updateHistory(location);
    this.lastValidLocation = location;
    
    return { isAnomaly: false };
  }
  
  /**
   * 检测速度异常
   */
  private checkSpeed(location: Location, mode: RecordMode): AnomalyResult {
    if (!this.lastValidLocation) {
      return { isAnomaly: false };
    }
    
    // 计算平均速度
    const distance = this.calculateDistance(
      this.lastValidLocation.latitude, this.lastValidLocation.longitude,
      location.latitude, location.longitude
    );
    
    const timeDiff = (location.timestamp - this.lastValidLocation.timestamp) / 1000; // 秒
    
    if (timeDiff <= 0) {
      return { isAnomaly: false };
    }
    
    const speedMs = distance / timeDiff;
    const speedKmh = speedMs * 3.6;
    
    const maxSpeed = this.config.maxSpeedKmh.get(mode) || 200;
    
    if (speedKmh > maxSpeed) {
      return {
        isAnomaly: true,
        type: AnomalyType.SPEED_ANOMALY,
        severity: 'high',
        description: `速度异常: ${speedKmh.toFixed(1)}km/h (最大${maxSpeed}km/h)`,
        suggestedFix: '可能为GPS漂移，建议跳过'
      };
    }
    
    // 使用GPS报告的速度验证
    if (location.speed > 0) {
      const reportedSpeedKmh = location.speed * 3.6;
      const speedDiff = Math.abs(speedKmh - reportedSpeedKmh);
      
      if (speedDiff > 50) {
        return {
          isAnomaly: true,
          type: AnomalyType.SPEED_ANOMALY,
          severity: 'medium',
          description: `计算速度与GPS速度差异过大`,
          suggestedFix: '建议使用插值平滑'
        };
      }
    }
    
    return { isAnomaly: false };
  }
  
  /**
   * 检测位置跳跃
   */
  private checkPositionJump(location: Location): AnomalyResult {
    if (!this.lastValidLocation) {
      return { isAnomaly: false };
    }
    
    const distance = this.calculateDistance(
      this.lastValidLocation.latitude, this.lastValidLocation.longitude,
      location.latitude, location.longitude
    );
    
    if (distance > this.config.maxJumpDistance) {
      return {
        isAnomaly: true,
        type: AnomalyType.POSITION_JUMP,
        severity: 'high',
        description: `位置跳跃: ${distance.toFixed(0)}m`,
        suggestedFix: '跳过该点或使用插值'
      };
    }
    
    return { isAnomaly: false };
  }
  
  /**
   * 检测 GPS 漂移（静止时的小范围移动）
   */
  private checkDrift(location: Location): AnomalyResult {
    // 计算最近N个点的质心
    const centerLat = this.lastLocations.reduce((sum, l) => sum + l.latitude, 0) / this.lastLocations.length;
    const centerLng = this.lastLocations.reduce((sum, l) => sum + l.longitude, 0) / this.lastLocations.length;
    
    // 检查新点到质心的距离
    const distanceToCenter = this.calculateDistance(
      centerLat, centerLng,
      location.latitude, location.longitude
    );
    
    // 如果所有点都很近（小于漂移阈值），可能是静止漂移
    const allNearCenter = this.lastLocations.every(l => {
      const d = this.calculateDistance(centerLat, centerLng, l.latitude, l.longitude);
      return d < this.config.driftThreshold;
    });
    
    if (allNearCenter && distanceToCenter < this.config.driftThreshold) {
      // 检查速度，如果速度很低则认为是静止漂移
      if (location.speed < 1) { // 小于1m/s
        return {
          isAnomaly: true,
          type: AnomalyType.GPS_DRIFT,
          severity: 'low',
          description: '检测到静止漂移',
          suggestedFix: '合并为停留点'
        };
      }
    }
    
    return { isAnomaly: false };
  }
  
  /**
   * 计算两点间距离
   */
  private calculateDistance(
    lat1: number, lon1: number,
    lat2: number, lon2: number
  ): number {
    const R = 6371000;
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
   * 更新历史记录
   */
  private updateHistory(location: Location): void {
    this.lastLocations.push(location);
    if (this.lastLocations.length > this.HISTORY_SIZE) {
      this.lastLocations.shift();
    }
  }
  
  /**
   * 重置检测器状态
   */
  reset(): void {
    this.lastValidLocation = null;
    this.lastLocations = [];
  }
  
  /**
   * 批量检测和修正轨迹点
   */
  processTrackPoints(
    points: Location[],
    mode: RecordMode
  ): { validPoints: Location[]; anomalies: Array<{ point: Location; result: AnomalyResult }> } {
    this.reset();
    
    const validPoints: Location[] = [];
    const anomalies: Array<{ point: Location; result: AnomalyResult }> = [];
    
    for (const point of points) {
      const result = this.detect(point, mode);
      
      if (result.isAnomaly) {
        anomalies.push({ point, result });
        
        // 低严重度异常仍保留，但标记
        if (result.severity === 'low') {
          validPoints.push(point);
        }
      } else {
        validPoints.push(point);
      }
    }
    
    return { validPoints, anomalies };
  }
  
  /**
   * 插值平滑轨迹
   */
  smoothTrack(points: Location[]): Location[] {
    if (points.length < 3) {
      return points;
    }
    
    const smoothed: Location[] = [points[0]];
    
    for (let i = 1; i < points.length - 1; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const next = points[i + 1];
      
      // 简单的移动平均
      const smoothedPoint: Location = {
        latitude: (prev.latitude + curr.latitude + next.latitude) / 3,
        longitude: (prev.longitude + curr.longitude + next.longitude) / 3,
        altitude: curr.altitude,
        accuracy: curr.accuracy,
        speed: curr.speed,
        timestamp: curr.timestamp
      };
      
      smoothed.push(smoothedPoint);
    }
    
    smoothed.push(points[points.length - 1]);
    
    return smoothed;
  }
}
