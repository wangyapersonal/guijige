/**
 * 地理计算工具类
 */

// @ts-nocheck
export class GeoUtils {
  /**
   * 计算两点之间的距离（米）
   * Haversine公式
   */
  static calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number
  ): number {
    const R = 6371000; // 地球半径（米）
    
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    
    return R * c;
  }
  
  /**
   * 角度转弧度
   */
  private static toRad(deg: number): number {
    return deg * Math.PI / 180;
  }
  
  /**
   * 格式化距离显示
   */
  static formatDistance(meters: number): string {
    if (meters < 1000) {
      return `${Math.round(meters)}m`;
    } else {
      return `${(meters / 1000).toFixed(2)}km`;
    }
  }
  
  /**
   * 格式化时长显示
   */
  static formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    } else {
      return `${minutes}:${secs.toString().padStart(2, '0')}`;
    }
  }
  
  /**
   * 判断两个点是否在同一位置（考虑误差）
   */
  static isSameLocation(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
    threshold: number = 50
  ): boolean {
    return this.calculateDistance(lat1, lon1, lat2, lon2) < threshold;
  }
}
