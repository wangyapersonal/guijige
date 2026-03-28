import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { CheckInPoint, CheckInType } from '../models/CheckInPoint';
import { CHECKIN_TABLE } from '../common/constants/Constants';
import { DatabaseService } from './DatabaseService';

export class CheckInService {
  private static instance: CheckInService;

  private constructor() {
  }

  static getInstance(): CheckInService {
    if (!CheckInService.instance) {
      CheckInService.instance = new CheckInService();
    }
    return CheckInService.instance;
  }

  async createCheckIn(checkIn: CheckInPoint): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'id': checkIn.id,
      'tripId': checkIn.tripId,
      'name': checkIn.name,
      'type': checkIn.type,
      'latitude': checkIn.latitude,
      'longitude': checkIn.longitude,
      'timestamp': checkIn.timestamp,
      'createdAt': checkIn.createdAt
    };
    try {
      await rdbStore?.insert(CHECKIN_TABLE, valueBucket);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async deleteCheckIn(id: string): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    try {
      await rdbStore?.delete(CHECKIN_TABLE, `id = ?`, [id]);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async getCheckInById(id: string): Promise<CheckInPoint | undefined> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(CHECKIN_TABLE);
    predicates.equalTo('id', id);
    try {
      const resultSet = await rdbStore?.query(predicates);
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return undefined;
      }
      resultSet.goToFirstRow();
      const checkIn = this.parseCheckIn(resultSet);
      resultSet.close();
      return checkIn;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return undefined;
  }

  async getCheckInsByTripId(tripId: string): Promise<CheckInPoint[]> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(CHECKIN_TABLE);
    predicates.equalTo('tripId', tripId);
    predicates.orderByAsc('timestamp');
    try {
      const resultSet = await rdbStore?.query(predicates);
      const checkIns: CheckInPoint[] = [];
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return checkIns;
      }
      while (resultSet.isAtLastRow === false) {
        resultSet.goToNextRow();
        checkIns.push(this.parseCheckIn(resultSet));
      }
      resultSet.close();
      return checkIns;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return [];
  }

  parseCheckIn(resultSet: relationalStore.ResultSet): CheckInPoint {
    const checkIn: CheckInPoint = {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      tripId: resultSet.getString(resultSet.getColumnIndex('tripId')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      type: resultSet.getString(resultSet.getColumnIndex('type')) as CheckInType,
      latitude: resultSet.getDouble(resultSet.getColumnIndex('latitude')),
      longitude: resultSet.getDouble(resultSet.getColumnIndex('longitude')),
      timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt'))
    };
    return checkIn;
  }
}
