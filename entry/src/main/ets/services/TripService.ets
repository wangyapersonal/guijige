/**
 * 行程服务
 */

import { Trip, CreateTripParams, TripStats } from '../models/Trip';
import { TimeUtils } from '../common/utils/TimeUtils';
import { DatabaseService } from './DatabaseService';
import { relationalStore } from '@kit.ArkData';
import { TripStatus } from '../common/constants/Constants';

export class TripService {
  private static instance: TripService;
  private dbService: DatabaseService;
  
  static getInstance(): TripService {
    if (!TripService.instance) {
      TripService.instance = new TripService();
    }
    return TripService.instance;
  }
  
  constructor() {
    this.dbService = DatabaseService.getInstance();
  }
  
  /**
   * 创建行程
   */
  async createTrip(params: CreateTripParams): Promise<Trip> {
    const trip: Trip = {
      id: TimeUtils.generateId(),
      name: params.name,
      description: params.description,
      destinations: params.destinations,
      startTime: params.startTime,
      endTime: params.endTime,
      status: TripStatus.NOT_STARTED,
      totalDistance: 0,
      trackSegmentCount: 0,
      checkInCount: 0,
      createdAt: Date.now(),
      updatedAt: Date.now()
    };
    
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const valueBucket: relationalStore.ValuesBucket = {
      id: trip.id,
      name: trip.name,
      description: trip.description || '',
      destinations: JSON.stringify(trip.destinations),
      start_time: trip.startTime,
      end_time: trip.endTime || null,
      status: trip.status,
      total_distance: trip.totalDistance,
      track_segment_count: trip.trackSegmentCount,
      check_in_count: trip.checkInCount,
      created_at: trip.createdAt,
      updated_at: trip.updatedAt
    };
    
    await store.insert('trips', valueBucket);
    console.info('TripService', 'Trip created', trip.id);
    
    return trip;
  }
  
  /**
   * 获取行程
   */
  async getTrip(id: string): Promise<Trip | null> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('trips');
    predicates.equalTo('id', id);
    
    const resultSet = await store.query(predicates);
    
    if (resultSet.goToFirstRow()) {
      const trip: Trip = {
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        description: resultSet.getString(resultSet.getColumnIndex('description')) || undefined,
        destinations: JSON.parse(resultSet.getString(resultSet.getColumnIndex('destinations'))),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')) || undefined,
        status: resultSet.getString(resultSet.getColumnIndex('status')) as TripStatus,
        totalDistance: resultSet.getDouble(resultSet.getColumnIndex('total_distance')),
        trackSegmentCount: resultSet.getLong(resultSet.getColumnIndex('track_segment_count')),
        checkInCount: resultSet.getLong(resultSet.getColumnIndex('check_in_count')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      };
      
      resultSet.close();
      return trip;
    }
    
    resultSet.close();
    return null;
  }
  
  /**
   * 获取所有行程
   */
  async getAllTrips(): Promise<Trip[]> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('trips');
    predicates.orderByDesc('created_at');
    
    const resultSet = await store.query(predicates);
    const trips: Trip[] = [];
    
    while (resultSet.goToNextRow()) {
      const trip: Trip = {
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        description: resultSet.getString(resultSet.getColumnIndex('description')) || undefined,
        destinations: JSON.parse(resultSet.getString(resultSet.getColumnIndex('destinations'))),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')) || undefined,
        status: resultSet.getString(resultSet.getColumnIndex('status')) as TripStatus,
        totalDistance: resultSet.getDouble(resultSet.getColumnIndex('total_distance')),
        trackSegmentCount: resultSet.getLong(resultSet.getColumnIndex('track_segment_count')),
        checkInCount: resultSet.getLong(resultSet.getColumnIndex('check_in_count')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      };
      
      trips.push(trip);
    }
    
    resultSet.close();
    return trips;
  }
  
  /**
   * 更新行程状态
   */
  async updateTripStatus(id: string, status: TripStatus): Promise<void> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const valueBucket: relationalStore.ValuesBucket = {
      status: status,
      updated_at: Date.now()
    };
    
    const predicates = new relationalStore.RdbPredicates('trips');
    predicates.equalTo('id', id);
    
    await store.update(valueBucket, predicates);
    console.info('TripService', 'Trip status updated', id, status);
  }
  
  /**
   * 删除行程
   */
  async deleteTrip(id: string): Promise<void> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('trips');
    predicates.equalTo('id', id);
    
    await store.delete(predicates);
    console.info('TripService', 'Trip deleted', id);
  }
  
  /**
   * 获取进行中的行程
   */
  async getOngoingTrip(): Promise<Trip | null> {
    const store = this.dbService.getStore();
    if (!store) {
      throw new Error('Database not initialized');
    }
    
    const predicates = new relationalStore.RdbPredicates('trips');
    predicates.equalTo('status', TripStatus.ONGOING);
    
    const resultSet = await store.query(predicates);
    
    if (resultSet.goToFirstRow()) {
      const trip: Trip = {
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        description: resultSet.getString(resultSet.getColumnIndex('description')) || undefined,
        destinations: JSON.parse(resultSet.getString(resultSet.getColumnIndex('destinations'))),
        startTime: resultSet.getLong(resultSet.getColumnIndex('start_time')),
        endTime: resultSet.getLong(resultSet.getColumnIndex('end_time')) || undefined,
        status: resultSet.getString(resultSet.getColumnIndex('status')) as TripStatus,
        totalDistance: resultSet.getDouble(resultSet.getColumnIndex('total_distance')),
        trackSegmentCount: resultSet.getLong(resultSet.getColumnIndex('track_segment_count')),
        checkInCount: resultSet.getLong(resultSet.getColumnIndex('check_in_count')),
        createdAt: resultSet.getLong(resultSet.getColumnIndex('created_at')),
        updatedAt: resultSet.getLong(resultSet.getColumnIndex('updated_at'))
      };
      
      resultSet.close();
      return trip;
    }
    
    resultSet.close();
    return null;
  }
}
