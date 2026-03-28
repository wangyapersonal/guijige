/**
 * 时间工具类
 */

// @ts-nocheck
export class TimeUtils {
  /**
   * 格式化日期 YYYY-MM-DD
   */
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
  
  /**
   * 格式化时间 HH:mm:ss
   */
  static formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const seconds = date.getSeconds().toString().padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }
  
  /**
   * 格式化日期时间
   */
  static formatDateTime(timestamp: number): string {
    return `${this.formatDate(timestamp)} ${this.formatTime(timestamp)}`;
  }
  
  /**
   * 获取今天的日期字符串
   */
  static getToday(): string {
    return this.formatDate(Date.now());
  }
  
  /**
   * 判断是否是同一天
   */
  static isSameDay(timestamp1: number, timestamp2: number): boolean {
    return this.formatDate(timestamp1) === this.formatDate(timestamp2);
  }
  
  /**
   * 计算两个时间戳之间的天数
   */
  static getDaysBetween(start: number, end: number): number {
    const oneDay = 24 * 60 * 60 * 1000;
    return Math.ceil((end - start) / oneDay);
  }
  
  /**
   * 生成UUID
   */
  static generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substring(2);
  }
}
