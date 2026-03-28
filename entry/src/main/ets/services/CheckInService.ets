/**
 * 打卡服务
 */

// @ts-nocheck
import { CheckInPoint, CreateCheckInParams, QueryCheckInParams } from '../models/CheckInPoint';
import { DatabaseService } from './DatabaseService';
import { LocationService } from './LocationService';
import { TimeUtils } from '../common/utils/TimeUtils';
import { CheckInType } from '../common/constants/Constants';
import { relationalStore } from '@kit.ArkData';

export class CheckInService {
  private static instance: CheckInService;
  private dbService: DatabaseService;
  private locationService: LocationService;
  
  static getInstance(): CheckInService {
    if (!CheckInService.instance) {
      CheckInService.instance = new CheckInService();
    }
    return CheckInService.instance;
  }
  
  constructor() {
    this.dbService = DatabaseService.getInstance();
    this.locationService = LocationService.getInstance();
  }
  
  /**
   * 自动打卡（APP启动时）
   */
  async autoCheckIn(tripId: string): Promise<CheckInPoint | null> {
    return this.checkIn({
      tripId,
      type: CheckInType.AUTO
    });
  }
  
  /**
   * 手动打卡
   */
  async manualCheckIn(
    tripId: string,
    placeName?: string,
    note?: string
  ): Promise<CheckInPoint | null> {
    return this.checkIn({
      tripId,
      type: CheckInType.MANUAL,
      placeName,
      note
    });
  }
  
  /**
   * 打卡（核心方法）
   */
  async checkIn(params: CreateCheckInParams): Promise<CheckInPoint | null> {
    try {
      // 获取当前位置
      const location = params.latitude && params.longitude
        ? { latitude: params.latitude, longitude: params.longitude }
        : await this.locationService.getCurrentLocation();
      
      if (!location) {
        console.error('CheckInService', 'no location');
        return null;
      }
      
      const point: CheckInPoint = {
        id: TimeUtils.generateId(),
        tripId: params.tripId,
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: params.altitude || location.altitude,
        accuracy: params.accuracy || location.accuracy,
        address: '',  // TODO: 逆地理编码
        placeName: params.placeName || undefined,
        note: params.note || undefined,
        timestamp: Date.now(),
        date: TimeUtils.formatDate(Date.now()),
        type: params.type,
        photoPath: params.photoPath,
        isAnomaly: false
      };
      
      // 保存到数据库
      const store = this.dbService.getStore();
      if (!store) {
        throw new Error('Database not initialized');
      }
      
      const valueBucket: relationalStore.ValuesBucket = {
        id: point.id,
        trip_id: point.tripId,
        latitude: point.latitude,
        longitude: point.longitude,
        altitude: point.altitude || null,
        accuracy: point.accuracy || null,
        address: point.address || '',
        place_name: point.placeName || '',
        note: point.note || '',
        timestamp: point.timestamp,
        date: point.date,
        type: point.type,
        photo_path: point.photoPath || '',
        thumbnail_path: point.thumbnailPath || '',
        is_anomaly: point.isAnomaly ? 1 : 0,
        anomaly_reason: point.anomalyReason || ''
      };
      
      await store.insert('check_in_points', valueBucket);
      
      // 更新行程统计
      await this.updateTripStats(params.tripId);
      
      console.info('CheckInService', 'checkIn success', point.id);
      return point;
    } catch (error) {
      console.error('CheckInService', 'checkIn error', error);
      return null;
    }
  }
  
  /**
   * 获取打卡点列表
   */
  async getCheckInPoints(params: QueryCheckInParams): Promise<CheckInPoint[]> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('check_in_points');
    predicates.equalTo('trip_id', params.tripId);
    
    if (params.date) {
      predicates.equalTo('date', params.date);
    }
    
    if (params.startTime) {
      predicates.greaterThanOrEqualTo('timestamp', params.startTime);
    }
    
    if (params.endTime) {
      predicates.lessThanOrEqualTo('timestamp', params.endTime);
    }
    
    if (params.type) {
      predicates.equalTo('type', params.type);
    }
    
    predicates.orderByAsc('timestamp');
    
    const resultSet = await store.query(predicates);
    const points: CheckInPoint[] = [];

    try {
      while (resultSet.goToNextRow()) {
        const point: CheckInPoint = {
          id: resultSet.getString(resultSet.getColumnIndex('id')),
          tripId: resultSet.getString(resultSet.getColumnIndex('trip_id')),
          latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
          longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
          altitude: resultSet.getDouble(resultSet.getColumnIndex('altitude')) || undefined,
          accuracy: resultSet.getDouble(resultSet.getColumnIndex('accuracy')) || undefined,
          address: resultSet.getString(resultSet.getColumnIndex('address')) || undefined,
          placeName: resultSet.getString(resultSet.getColumnIndex('place_name')) || undefined,
          note: resultSet.getString(resultSet.getColumnIndex('note')) || undefined,
          timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
          date: resultSet.getString(resultSet.getColumnIndex('date')),
          type: resultSet.getString(resultSet.getColumnIndex('type')) as CheckInType,
          photoPath: resultSet.getString(resultSet.getColumnIndex('photo_path')) || undefined,
          thumbnailPath: resultSet.getString(resultSet.getColumnIndex('thumbnail_path')) || undefined,
          isAnomaly: resultSet.getLong(resultSet.getColumnIndex('is_anomaly')) === 1,
          anomalyReason: resultSet.getString(resultSet.getColumnIndex('anomaly_reason')) || undefined
        };

        points.push(point);
      }

      return points;
    } catch (error) {
      console.error('CheckInService', 'getCheckInPoints error', error);
      return [];
    } finally {
      resultSet.close();
    }
  }
  
  /**
   * 删除打卡点
   */
  async deleteCheckIn(id: string): Promise<void> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('check_in_points');
    predicates.equalTo('id', id);
    
    await store.delete(predicates);
    console.info('CheckInService', 'delete', id);
  }
  
  /**
   * 更新行程统计
   */
  private async updateTripStats(tripId: string): Promise<void> {
    const store = this.dbService.getStore();
    if (!store) return;

    // 统计打卡点数
    const predicates = new relationalStore.RdbPredicates('check_in_points');
    predicates.equalTo('trip_id', tripId);
    const count = await store.query(predicates);

    let checkInCount = 0;
    try {
      while (count.goToNextRow()) {
        checkInCount++;
      }
    } finally {
      count.close();
    }

    if (checkInCount > 0) {
      // 更新行程表
      const valueBucket: relationalStore.ValuesBucket = {
        check_in_count: checkInCount,
        updated_at: Date.now()
      };

      const tripPredicates = new relationalStore.RdbPredicates('trips');
      tripPredicates.equalTo('id', tripId);
      await store.update(valueBucket, tripPredicates);
    }
  }
}
