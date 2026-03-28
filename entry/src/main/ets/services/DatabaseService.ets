/**
 * 数据库服务
 */
// @ts-nocheck
import { relationalStore } from '@kit.ArkData';
import common from '@ohos.ability.common';

export class DatabaseService {
  private static instance: DatabaseService;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.Context;
  
  // 数据库配置
  private readonly DB_NAME = 'guijige.db';
  private readonly DB_VERSION = 1;
  
  static getInstance(): DatabaseService {
    if (!DatabaseService.instance) {
      DatabaseService.instance = new DatabaseService();
    }
    return DatabaseService.instance;
  }
  private constructor() {
    // 获取context
    this.context = getContext(this) as common.Context;
  }
  
  /**
   * 初始化数据库
   */
  async init(): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    
    try {
      this.rdbStore = await relationalStore.getRdbStore(this.context, config);
      await this.createTables();
      console.info('DatabaseService', 'Database initialized');
    } catch (error) {
      console.error('DatabaseService', 'Failed to init database', error);
      throw new Error('Database initialization failed');
    }
  }
  
  /**
   * 创建表
   */
  private async createTables(): Promise<void> {
    if (!this.rdbStore) return;
    
    // 行程表
    const createTripsTable = `
      CREATE TABLE IF NOT EXISTS trips (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        destinations TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        status TEXT NOT NULL DEFAULT 'ongoing',
        total_distance REAL DEFAULT 0,
        track_segment_count INTEGER DEFAULT 0,
        check_in_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    `;
    
    // 打卡点表
    const createCheckInTable = `
      CREATE TABLE IF NOT EXISTS check_in_points (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        accuracy REAL,
        address TEXT,
        place_name TEXT,
        note TEXT,
        timestamp INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        photo_path TEXT,
        thumbnail_path TEXT,
        is_anomaly INTEGER DEFAULT 0,
        anomaly_reason TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
      )
    `;
    
    // 记录段表
    const createSegmentsTable = `
      CREATE TABLE IF NOT EXISTS record_segments (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        mode TEXT NOT NULL,
        total_distance REAL DEFAULT 0,
        duration INTEGER DEFAULT 0,
        track_point_count INTEGER DEFAULT 0,
        stay_point_count INTEGER DEFAULT 0,
        FOREIGN KEY (trip_id) REFERENCES trips(id) ON DELETE CASCADE
      )
    `;
    
    // 轨迹点表
    const createTrackPointsTable = `
      CREATE TABLE IF NOT EXISTS track_points (
        id TEXT PRIMARY KEY,
        segment_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        accuracy REAL,
        speed REAL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (segment_id) REFERENCES record_segments(id) ON DELETE CASCADE
      )
    `;
    
    // 停留点表
    const createStayPointsTable = `
      CREATE TABLE IF NOT EXISTS stay_points (
        id TEXT PRIMARY KEY,
        segment_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        merged_point_count INTEGER DEFAULT 1,
        address TEXT,
        FOREIGN KEY (segment_id) REFERENCES record_segments(id) ON DELETE CASCADE
      )
    `;
    
    await this.rdbStore.executeSql(createTripsTable);
    await this.rdbStore.executeSql(createCheckInTable);
    await this.rdbStore.executeSql(createSegmentsTable);
    await this.rdbStore.executeSql(createTrackPointsTable);
    await this.rdbStore.executeSql(createStayPointsTable);

    // 创建索引
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_checkin_trip ON check_in_points(trip_id)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_checkin_date ON check_in_points(date)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_checkin_timestamp ON check_in_points(timestamp)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_segments_trip ON record_segments(trip_id)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_track_segment ON track_points(segment_id)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_stay_segment ON stay_points(segment_id)'
    );
    await this.rdbStore.executeSql(
      'CREATE INDEX IF NOT EXISTS idx_trips_status ON trips(status)'
    );

    console.info('DatabaseService', 'Tables created');
  }
  
  /**
   * 获取RdbStore
   */
  getStore(): relationalStore.RdbStore | null {
    return this.rdbStore;
  }
}
