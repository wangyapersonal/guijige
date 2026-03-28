import { relationalStore } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { DB_NAME, DB_VERSION, TRIP_TABLE, CHECKIN_TABLE, RECORD_TABLE, TRACK_TABLE } from '../common/constants/Constants';

export class DatabaseService {
  private static instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: Context;

  private constructor(context: Context) {
    this.context = context;
  }

  static getInstance(context: Context): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService(context);
    }
    return DatabaseService.instance;
  }

  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    this.rdbStore = await relationalStore.getRdbStore(this.context, config);
    await this.createTables();
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }

    await this.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TRIP_TABLE} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        destination TEXT,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        notes TEXT,
        status TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    `);

    await this.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS ${CHECKIN_TABLE} (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (tripId) REFERENCES ${TRIP_TABLE}(id) ON DELETE CASCADE
      )
    `);

    await this.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS ${RECORD_TABLE} (
        id TEXT PRIMARY KEY,
        tripId TEXT NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER,
        distance REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (tripId) REFERENCES ${TRIP_TABLE}(id) ON DELETE CASCADE
      )
    `);

    await this.rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TRACK_TABLE} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        segmentId TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        speed REAL,
        bearing REAL,
        accuracy REAL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (segmentId) REFERENCES ${RECORD_TABLE}(id) ON DELETE CASCADE
      )
    `);
  }

  getRdbStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }
}