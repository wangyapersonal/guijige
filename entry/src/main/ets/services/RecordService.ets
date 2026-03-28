import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RecordSegment, TrackPoint } from '../models/RecordSegment';
import { RECORD_TABLE, TRACK_TABLE } from '../common/constants/Constants';
import { DatabaseService } from './DatabaseService';

export class RecordService {
  private static instance: RecordService;

  private constructor() {
  }

  static getInstance(): RecordService {
    if (!RecordService.instance) {
      RecordService.instance = new RecordService();
    }
    return RecordService.instance;
  }

  async createRecord(record: RecordSegment): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'id': record.id,
      'tripId': record.tripId,
      'startTime': record.startTime,
      'endTime': record.endTime,
      'distance': record.distance,
      'createdAt': record.createdAt
    };
    try {
      await rdbStore?.insert(RECORD_TABLE, valueBucket);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async updateRecord(record: RecordSegment): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'endTime': record.endTime,
      'distance': record.distance
    };
    try {
      await rdbStore?.update(valueBucket, RECORD_TABLE, `id = ?`, [record.id]);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async addTrackPoints(trackPoints: TrackPoint[], segmentId: string): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBuckets: relationalStore.ValuesBucket[] = [];
    trackPoints.forEach((trackPoint) => {
      valueBuckets.push({
        'segmentId': segmentId,
        'latitude': trackPoint.latitude,
        'longitude': trackPoint.longitude,
        'altitude': trackPoint.altitude,
        'speed': trackPoint.speed,
        'bearing': trackPoint.bearing,
        'accuracy': trackPoint.accuracy,
        'timestamp': trackPoint.timestamp
      });
    });
    try {
      await rdbStore?.batchInsert(TRACK_TABLE, valueBuckets);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async getRecordsByTripId(tripId: string): Promise<RecordSegment[]> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(RECORD_TABLE);
    predicates.equalTo('tripId', tripId);
    predicates.orderByAsc('startTime');
    try {
      const resultSet = await rdbStore?.query(predicates);
      const records: RecordSegment[] = [];
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return records;
      }
      while (resultSet.isAtLastRow === false) {
        resultSet.goToNextRow();
        records.push(this.parseRecord(resultSet));
      }
      resultSet.close();
      return records;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return [];
  }

  async getTrackPointsBySegmentId(segmentId: string): Promise<TrackPoint[]> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TRACK_TABLE);
    predicates.equalTo('segmentId', segmentId);
    predicates.orderByAsc('timestamp');
    try {
      const resultSet = await rdbStore?.query(predicates);
      const trackPoints: TrackPoint[] = [];
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return trackPoints;
      }
      while (resultSet.isAtLastRow === false) {
        resultSet.goToNextRow();
        trackPoints.push(this.parseTrackPoint(resultSet));
      }
      resultSet.close();
      return trackPoints;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return [];
  }

  parseRecord(resultSet: relationalStore.ResultSet): RecordSegment {
    const record: RecordSegment = {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      tripId: resultSet.getString(resultSet.getColumnIndex('tripId')),
      startTime: resultSet.getLong(resultSet.getColumnIndex('startTime')),
      endTime: resultSet.getLong(resultSet.getColumnIndex('endTime')),
      distance: resultSet.getDouble(resultSet.getColumnIndex('distance')),
      trackPoints: [],
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
    };
    return record;
  }

  parseTrackPoint(resultSet: relationalStore.ResultSet): TrackPoint {
    const trackPoint: TrackPoint = {
      latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
      longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
      altitude: resultSet.getDouble(resultSet.getColumnIndex('altitude')),
      speed: resultSet.getDouble(resultSet.getColumnIndex('speed')),
      bearing: resultSet.getDouble(resultSet.getColumnIndex('bearing')),
      accuracy: resultSet.getDouble(resultSet.getColumnIndex('accuracy')),
      timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp'))
    };
    return trackPoint;
  }
}
