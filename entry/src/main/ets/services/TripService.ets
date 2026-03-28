import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Trip, TripStatus, TripType } from '../models/Trip';
import { TRIP_TABLE } from '../common/constants/Constants';
import { DatabaseService } from './DatabaseService';

export class TripService {
  private static instance: TripService;

  private constructor() {
  }

  static getInstance(): TripService {
    if (!TripService.instance) {
      TripService.instance = new TripService();
    }
    return TripService.instance;
  }

  async createTrip(trip: Trip): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'id': trip.id,
      'name': trip.name,
      'type': trip.type,
      'destination': trip.destination,
      'startDate': trip.startDate,
      'endDate': trip.endDate,
      'notes': trip.notes,
      'status': trip.status,
      'createdAt': trip.createdAt,
      'updatedAt': trip.updatedAt
    };
    try {
      await rdbStore?.insert(TRIP_TABLE, valueBucket);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async updateTrip(trip: Trip): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': trip.name,
      'type': trip.type,
      'destination': trip.destination,
      'startDate': trip.startDate,
      'endDate': trip.endDate,
      'notes': trip.notes,
      'status': trip.status,
      'updatedAt': trip.updatedAt
    };
    try {
      await rdbStore?.update(valueBucket, TRIP_TABLE, `id = ?`, [trip.id]);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async deleteTrip(id: string): Promise<void> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    try {
      await rdbStore?.delete(TRIP_TABLE, `id = ?`, [id]);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async getTripById(id: string): Promise<Trip | undefined> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TRIP_TABLE);
    predicates.equalTo('id', id);
    try {
      const resultSet = await rdbStore?.query(predicates);
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return undefined;
      }
      resultSet.goToFirstRow();
      const trip = this.parseTrip(resultSet);
      resultSet.close();
      return trip;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return undefined;
  }

  async getAllTrips(): Promise<Trip[]> {
    const rdbStore = DatabaseService.getInstance().getRdbStore();
    const predicates = new relationalStore.RdbPredicates(TRIP_TABLE);
    predicates.orderByDesc('startDate');
    try {
      const resultSet = await rdbStore?.query(predicates);
      const trips: Trip[] = [];
      if (resultSet === undefined || resultSet.rowCount === 0) {
        resultSet?.close();
        return trips;
      }
      while (resultSet.isAtLastRow === false) {
        resultSet.goToNextRow();
        trips.push(this.parseTrip(resultSet));
      }
      resultSet.close();
      return trips;
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
    return [];
  }

  parseTrip(resultSet: relationalStore.ResultSet): Trip {
    const trip: Trip = {
      id: resultSet.getString(resultSet.getColumnIndex('id')),
      name: resultSet.getString(resultSet.getColumnIndex('name')),
      type: resultSet.getString(resultSet.getColumnIndex('type')) as TripType,
      destination: resultSet.getString(resultSet.getColumnIndex('destination')),
      startDate: resultSet.getLong(resultSet.getColumnIndex('startDate')),
      endDate: resultSet.getLong(resultSet.getColumnIndex('endDate')),
      notes: resultSet.getString(resultSet.getColumnIndex('notes')),
      status: resultSet.getString(resultSet.getColumnIndex('status')) as TripStatus,
      createdAt: resultSet.getLong(resultSet.getColumnIndex('createdAt')),
      updatedAt: resultSet.getLong(resultSet.getColumnIndex('updatedAt'))
    };
    return trip;
  }
}
