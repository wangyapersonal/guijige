export enum TripStatus {
  PLANNING = 'planning',
  ACTIVE = 'active',
  COMPLETED = 'completed'
}

export enum TripType {
  DRIVING = 'driving',
  CYCLING = 'cycling',
  WALKING = 'walking',
  OTHER = 'other'
}

export interface Trip {
  id: string;
  name: string;
  type: TripType;
  destination?: string;
  startDate: number;
  endDate?: number;
  notes?: string;
  status: TripStatus;
  createdAt: number;
  updatedAt: number;
}
