/**
 * 照片信息模型
 */

export interface PhotoInfo {
  uri: string;
  fileName: string;
  latitude: number | null;
  longitude: number | null;
  timestamp: number;
  hasLocation: boolean;
  isInRange: boolean;
  isAnomaly: boolean;
  thumbnail?: string;
}

export interface DestinationBounds {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
}
