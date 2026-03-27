/**
 * 记录服务
 */

import { RecordSegment, TrackPoint, StayPoint, CreateSegmentParams } from '../models/RecordSegment';
import { DatabaseService } from './DatabaseService';
import { LocationService } from './LocationService';
import { Location } from '../common/types/CommonTypes';
import { GeoUtils } from '../common/utils/GeoUtils';
import { TimeUtils } from '../common/utils/TimeUtils';
import { RecordMode } from '../common/constants/Constants';
import { relationalStore } from '@kit.ArkData';

export class RecordService {
  private static instance: RecordService;
  private dbService: DatabaseService;
  private locationService: LocationService;
  
  // 当前记录状态
  private currentSegment: RecordSegment | null = null;
  private lastTrackPoint: TrackPoint | null = null;
  private currentStayPoint: StayPoint | null = null;
  private isRecording: boolean = false;
  
  // 停留点合并阈值
  private readonly STAY_DISTANCE_THRESHOLD = 50; // 50米
  
  static getInstance(): RecordService {
    if (!RecordService.instance) {
      RecordService.instance = new RecordService();
    }
    return RecordService.instance;
  }
  
  constructor() {
    this.dbService = DatabaseService.getInstance();
    this.locationService = LocationService.getInstance();
  }
  
  /**
   * 开始记录
   */
  async startRecord(tripId: string, mode: RecordMode): Promise<RecordSegment | null> {
    if (this.isRecording) {
      return null;
    }
    
    try {
      // 创建记录段
      this.currentSegment = {
        id: TimeUtils.generateId(),
        tripId,
        startTime: Date.now(),
        endTime: null,
        mode,
        totalDistance: 0,
        duration: 0,
        trackPointCount: 0,
        stayPointCount: 0
      };
      
      // 保存到数据库
      await this.saveSegment();
      
      // 开始定位
      await this.locationService.startContinuousTracking((location) => {
        this.onLocationUpdate(location);
      });
      
      this.isRecording = true;
      console.info('RecordService', 'start record', this.currentSegment.id);
      
      return this.currentSegment;
    } catch (error) {
      console.error('RecordService', 'start record error', error);
      return null;
    }
  }
  
  /**
   * 暂停记录
   */
  pauseRecord() {
    if (!this.isRecording) return;
    
    this.locationService.stopContinuousTracking();
    
    // 保存当前停留点
    if (this.currentStayPoint) {
      this.saveStayPoint();
    }
    
    console.info('RecordService', 'paused');
  }
  
  /**
   * 恢复记录
   */
  async resumeRecord() {
    if (!this.currentSegment) return;
    
    // 创建新记录段
    this.currentSegment = {
      id: TimeUtils.generateId(),
      tripId: this.currentSegment.tripId,
      startTime: Date.now(),
      endTime: null,
      mode: this.currentSegment.mode,
      totalDistance: 0,
      duration: 0,
      trackPointCount: 0,
      stayPointCount: 0
    };
    
    await this.saveSegment();
    
    await this.locationService.startContinuousTracking((location) => {
      this.onLocationUpdate(location);
    });
    
    console.info('RecordService', 'resumed');
  }
  
  /**
   * 停止记录
   */
  async stopRecord() {
    if (!this.isRecording || !this.currentSegment) return;
    
    this.locationService.stopContinuousTracking();
    
    // 保存最后的停留点
    if (this.currentStayPoint) {
      await this.saveStayPoint();
    }
    
    // 更新记录段结束时间
    this.currentSegment.endTime = Date.now();
    this.currentSegment.duration = Math.floor(
      (this.currentSegment.endTime - this.currentSegment.startTime) / 1000
    );
    
    await this.updateSegment();
    
    // 更新行程统计
    await this.updateTripStats(this.currentSegment.tripId);
    
    this.isRecording = false;
    this.currentSegment = null;
    this.lastTrackPoint = null;
    this.currentStayPoint = null;
    
    console.info('RecordService', 'stopped');
  }
  
  /**
   * 位置更新处理
   */
  private async onLocationUpdate(location: Location) {
    if (!this.isRecording || !this.currentSegment) return;
    
    const trackPoint: TrackPoint = {
      id: TimeUtils.generateId(),
      segmentId: this.currentSegment.id,
      latitude: location.latitude,
      longitude: location.longitude,
      altitude: location.altitude,
      accuracy: location.accuracy,
      speed: location.speed,
      timestamp: Date.now()
    };
    
    // 自动合并检测
    if (this.lastTrackPoint) {
      const distance = GeoUtils.calculateDistance(
        trackPoint.latitude, trackPoint.longitude,
        this.lastTrackPoint.latitude, this.lastTrackPoint.longitude
      );
      
      if (distance < this.STAY_DISTANCE_THRESHOLD) {
        // 合并到当前停留点
        await this.mergeToStayPoint(trackPoint);
      } else {
        // 保存上一个停留点
        if (this.currentStayPoint) {
          await this.saveStayPoint();
        }
        
        // 保存轨迹点
        await this.saveTrackPoint(trackPoint);
        this.lastTrackPoint = trackPoint;
        
        // 更新距离
        this.currentSegment.totalDistance += distance;
      }
    } else {
      // 第一个点，直接保存
      await this.saveTrackPoint(trackPoint);
      this.lastTrackPoint = trackPoint;
    }
    
    // 更新记录段统计
    this.currentSegment.trackPointCount++;
    await this.updateSegment();
  }
  
  /**
   * 合并到停留点
   */
  private async mergeToStayPoint(point: TrackPoint) {
    if (!this.currentStayPoint) {
      // 创建新停留点
      this.currentStayPoint = {
        id: TimeUtils.generateId(),
        segmentId: this.currentSegment!.id,
        latitude: point.latitude,
        longitude: point.longitude,
        altitude: point.altitude,
        startTime: point.timestamp,
        endTime: point.timestamp,
        duration: 0,
        mergedPointCount: 1,
        address: undefined
      };
    } else {
      // 更新停留点
      this.currentStayPoint.endTime = point.timestamp;
      this.currentStayPoint.duration = 
        (this.currentStayPoint.endTime - this.currentStayPoint.startTime) / 1000;
      this.currentStayPoint.mergedPointCount++;
    }
  }
  
  /**
   * 保存停留点
   */
  private async saveStayPoint() {
    if (!this.currentStayPoint) return;
    
    const store = this.dbService.getStore();
    if (!store) return;
    
    const valueBucket: relationalStore.ValuesBucket = {
      id: this.currentStayPoint.id,
      segment_id: this.currentStayPoint.segmentId,
      latitude: this.currentStayPoint.latitude,
      longitude: this.currentStayPoint.longitude,
      altitude: this.currentStayPoint.altitude || null,
      start_time: this.currentStayPoint.startTime,
      end_time: this.currentStayPoint.endTime,
      duration: this.currentStayPoint.duration,
      merged_point_count: this.currentStayPoint.mergedPointCount,
      address: this.currentStayPoint.address || ''
    };
    
    await store.insert('stay_points', valueBucket);
    
    this.currentSegment!.stayPointCount++;
    this.currentStayPoint = null;
  }
  
  /**
   * 保存轨迹点
   */
  private async saveTrackPoint(point: TrackPoint) {
    const store = this.dbService.getStore();
    if (!store) return;
    
    const valueBucket: relationalStore.ValuesBucket = {
      id: point.id,
      segment_id: point.segmentId,
      latitude: point.latitude,
      longitude: point.longitude,
      altitude: point.altitude || null,
      accuracy: point.accuracy || null,
      speed: point.speed || null,
      timestamp: point.timestamp
    };
    
    await store.insert('track_points', valueBucket);
  }
  
  /**
   * 保存记录段
   */
  private async saveSegment() {
    if (!this.currentSegment) return;
    
    const store = this.dbService.getStore();
    if (!store) return;
    
    const valueBucket: relationalStore.ValuesBucket = {
      id: this.currentSegment.id,
      trip_id: this.currentSegment.tripId,
      start_time: this.currentSegment.startTime,
      end_time: null,
      mode: this.currentSegment.mode,
      total_distance: this.currentSegment.totalDistance,
      duration: this.currentSegment.duration,
      track_point_count: this.currentSegment.trackPointCount,
      stay_point_count: this.currentSegment.stayPointCount
    };
    
    await store.insert('record_segments', valueBucket);
  }
  
  /**
   * 更新记录段
   */
  private async updateSegment() {
    if (!this.currentSegment) return;
    
    const store = this.dbService.getStore();
    if (!store) return;
    
    const valueBucket: relationalStore.ValuesBucket = {
      total_distance: this.currentSegment.totalDistance,
      track_point_count: this.currentSegment.trackPointCount,
      stay_point_count: this.currentSegment.stayPointCount
    };
    
    const predicates = new relationalStore.RdbPredicates('record_segments');
    predicates.equalTo('id', this.currentSegment.id);
    
    await store.update(valueBucket, predicates);
  }
  
  /**
   * 更新行程统计
   */
  private async updateTripStats(tripId: string) {
    const store = this.dbService.getStore();
    if (!store) return;
    
    // 统计轨迹段数
    const result = await store.querySql(
      `SELECT COUNT(*) as count, SUM(total_distance) as distance FROM record_segments WHERE trip_id = '${tripId}'`
    );
    
    if (result.goToFirstRow()) {
      const segmentCount = result.getLong(result.getColumnIndex('count'));
      const totalDistance = result.getDouble(result.getColumnIndex('distance'));
      result.close();
      
      const valueBucket: relationalStore.ValuesBucket = {
        track_segment_count: segmentCount,
        total_distance: totalDistance,
        updated_at: Date.now()
      };
      
      const predicates = new relationalStore.RdbPredicates('trips');
      predicates.equalTo('id', tripId);
      await store.update(valueBucket, predicates);
    }
  }
  
  /**
   * 是否正在记录
   */
  isCurrentlyRecording(): boolean {
    return this.isRecording;
  }
  
  /**
   * 获取当前记录段
   */
  getCurrentSegment(): RecordSegment | null {
    return this.currentSegment;
  }
}
