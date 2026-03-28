/**
 * 记录段数据模型
 */

import { RecordMode } from '../common/constants/Constants';

// 记录段（一次持续记录）
export interface RecordSegment {
  id: string;
  tripId: string;

  // 时间
  startTime: number;
  endTime?: number;

  // 模式
  mode: RecordMode;

  // 统计
  totalDistance: number;   // 距离（米）
  duration: number;        // 时长（秒）
  distance: number;        // 距离（米）- 兼容字段

  // 关联数据
  trackPointCount: number;
  stayPointCount: number;
  trackPoints: TrackPoint[]; // 轨迹点数组
}

// 轨迹点
export interface TrackPoint {
  id: string;
  segmentId: string;

  latitude: number;
  longitude: number;
  altitude?: number;
  accuracy?: number;
  speed?: number;

  timestamp: number;
}

// 停留点（自动合并）
export interface StayPoint {
  id: string;
  segmentId: string;

  latitude: number;
  longitude: number;
  altitude?: number;

  startTime: number;
  endTime: number;
  duration: number;        // 停留时长（秒）

  mergedPointCount: number; // 合并的点数
  address?: string;
}

// 创建记录段参数
export interface CreateSegmentParams {
  tripId: string;
  mode: RecordMode;
}
