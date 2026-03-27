/**
 * 行程数据模型
 */

import { TripStatus } from '../common/constants/Constants';

// 行程
export interface Trip {
  id: string;
  name: string;
  description?: string;
  destinations: string[];  // 目的地列表
  
  startTime: number;       // 开始时间戳
  endTime?: number;        // 结束时间戳
  status: TripStatus;      // 状态
  
  // 统计
  totalDistance: number;   // 总距离（米）
  trackSegmentCount: number; // 轨迹段数
  checkInCount: number;    // 打卡点数
  
  createdAt: number;
  updatedAt: number;
}

// 创建行程参数
export interface CreateTripParams {
  name: string;
  destinations: string[];
  startTime: number;
  endTime?: number;
  description?: string;
}

// 行程统计
export interface TripStats {
  totalDistance: number;
  totalDuration: number;
  checkInCount: number;
  trackSegmentCount: number;
  photoCount: number;
}
