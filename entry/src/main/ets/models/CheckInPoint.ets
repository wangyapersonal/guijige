/**
 * 打卡点数据模型
 */

import { CheckInType } from '../common/constants/Constants';

// 打卡点
export interface CheckInPoint {
  id: string;
  tripId: string;
  
  // 位置
  latitude: number;
  longitude: number;
  altitude?: number;
  accuracy?: number;
  
  // 地址
  address?: string;
  placeName?: string;
  note?: string;
  
  // 时间
  timestamp: number;
  date: string;  // YYYY-MM-DD
  
  // 类型
  type: CheckInType;
  
  // 照片（照片导入类型）
  photoPath?: string;
  thumbnailPath?: string;
  
  // 异常标记
  isAnomaly: boolean;
  anomalyReason?: string;
}

// 创建打卡点参数
export interface CreateCheckInParams {
  tripId: string;
  latitude: number;
  longitude: number;
  altitude?: number;
  accuracy?: number;
  type: CheckInType;
  placeName?: string;
  note?: string;
  photoPath?: string;
}

// 打卡点查询参数
export interface QueryCheckInParams {
  tripId: string;
  date?: string;
  startTime?: number;
  endTime?: number;
  type?: CheckInType;
}
