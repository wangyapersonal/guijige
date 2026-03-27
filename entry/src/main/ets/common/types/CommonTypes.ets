/**
 * 通用类型定义
 */

// 位置信息
export interface Location {
  latitude: number;
  longitude: number;
  altitude?: number;
  accuracy?: number;
  speed?: number;
  timestamp: number;
}

// 地址信息
export interface Address {
  country: string;
  province: string;
  city: string;
  district: string;
  street?: string;
  fullAddress: string;
}

// 响应结构
export interface ApiResponse<T> {
  code: number;
  data?: T;
  message?: string;
}

// 分页参数
export interface PageParams {
  page: number;
  pageSize: number;
}

// 分页响应
export interface PageResponse<T> {
  list: T[];
  total: number;
  page: number;
  pageSize: number;
}
