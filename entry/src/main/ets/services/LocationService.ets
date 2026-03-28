import { geoLocationManager } from '@kit.LocationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { TrackPoint } from '../models/RecordSegment';

export class LocationService {
  private static instance: LocationService;
  private boundHandleLocationChange: (location: geoLocationManager.Location) => void;
  private requestInfo: geoLocationManager.LocationRequest = {
    'priority': geoLocationManager.LocationRequestPriority.FIRST_FIX,
    'scenario': geoLocationManager.LocationRequestScenario.UNSET,
    'timeInterval': 1,
    'distanceInterval': 0,
    'maxAccuracy': 0
  };
  private trackPoints: TrackPoint[] = [];

  private constructor() {
    this.boundHandleLocationChange = this.handleLocationChange.bind(this);
  }

  static getInstance(): LocationService {
    if (!LocationService.instance) {
      LocationService.instance = new LocationService();
    }
    return LocationService.instance;
  }

  async startContinuousTracking(): Promise<void> {
    try {
      await geoLocationManager.on('locationChange', this.requestInfo, this.boundHandleLocationChange);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  async stopContinuousTracking(): Promise<void> {
    try {
      await geoLocationManager.off('locationChange', this.boundHandleLocationChange);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`errCode:${error.code},errMessage:${error.message}`);
    }
  }

  private handleLocationChange(location: geoLocationManager.Location): void {
    if (location) {
      this.trackPoints.push({
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: location.altitude,
        speed: location.speed,
        bearing: location.angle,
        accuracy: location.accuracy,
        timestamp: Date.now()
      });
    }
  }

  getTrackPoints(): TrackPoint[] {
    return this.trackPoints;
  }

  clearTrackPoints(): void {
    this.trackPoints = [];
  }
}
