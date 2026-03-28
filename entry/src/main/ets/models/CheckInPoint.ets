export enum CheckInType {
  MANUAL = 'manual',
  AUTO = 'auto'
}

export interface CheckInPoint {
  id: string;
  tripId: string;
  name: string;
  type: CheckInType;
  latitude: number;
  longitude: number;
  timestamp: number;
  createdAt: number;
}
