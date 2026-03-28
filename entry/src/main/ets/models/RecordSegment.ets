export interface TrackPoint {
  latitude: number;
  longitude: number;
  altitude?: number;
  speed?: number;
  bearing?: number;
  accuracy?: number;
  timestamp: number;
}

export interface RecordSegment {
  id: string;
  tripId: string;
  startTime: number;
  endTime?: number;
  distance: number;
  trackPoints: TrackPoint[];
  createdAt: number;
}
