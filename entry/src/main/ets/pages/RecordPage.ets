import { LocationService } from '../services/LocationService';
import { RecordService } from '../services/RecordService';
import { router } from '@kit.ArkUI';
import { TrackPoint, RecordSegment } from '../models/RecordSegment';
import { BusinessError } from '@kit.BasicServicesKit';
import { TripService } from '../services/TripService';
import { Trip, TripStatus } from '../models/Trip';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct RecordPage {
  @State isRecording: boolean = false;
  @State isPaused: boolean = false;
  @State timerId: number = -1;
  @State startTime: number = 0;
  @State duration: number = 0;
  @State trackPoints: TrackPoint[] = [];
  @State locationService: LocationService = LocationService.getInstance();
  @State tripId: string = '';

  private startTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(() => {
      if (this.isRecording && !this.isPaused) {
        this.duration = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000);
  }

  private stopTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) {
      return `${hours}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    } else {
      return `${minutes}:${String(secs).padStart(2, '0')}`;
    }
  }

  private getDistance(point1: TrackPoint, point2: TrackPoint): number {
    const R = 6371e3;
    const φ1 = point1.latitude * Math.PI / 180;
    const φ2 = point2.latitude * Math.PI / 180;
    const Δφ = (point2.latitude - point1.latitude) * Math.PI / 180;
    const Δλ = (point2.longitude - point1.longitude) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) *
      Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  private calculateTotalDistance(trackPoints: TrackPoint[]): number {
    let totalDistance = 0;
    for (let i = 1; i < trackPoints.length; i++) {
      totalDistance += this.getDistance(trackPoints[i - 1], trackPoints[i]);
    }
    return totalDistance;
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    this.tripId = params.tripId;
    this.startTimer();
  }

  aboutToDisappear(): void {
    if (this.isRecording) {
      this.locationService.stopContinuousTracking();
    }
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private async saveRecord(): Promise<void> {
    if (this.trackPoints.length === 0) {
      return;
    }

    const record: RecordSegment = {
      id: generateId(),
      tripId: this.tripId,
      startTime: this.trackPoints[0].timestamp,
      endTime: this.trackPoints[this.trackPoints.length - 1].timestamp,
      distance: this.calculateTotalDistance(this.trackPoints),
      trackPoints: this.trackPoints,
      createdAt: Date.now()
    };

    await RecordService.getInstance().createRecord(record);
    await RecordService.getInstance().addTrackPoints(this.trackPoints, record.id);
  }

  private async updateTripStatus(): Promise<void> {
    const trip = await TripService.getInstance().getTripById(this.tripId);
    if (trip) {
      trip.status = TripStatus.ACTIVE;
      trip.updatedAt = Date.now();
      await TripService.getInstance().updateTrip(trip);
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back()
          })
        Text('记录轨迹')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Column() {
        Text(this.formatDuration(this.duration))
          .fontSize(64)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 12 })
        Text(this.calculateTotalDistance(this.trackPoints).toFixed(2) + 'km')
          .fontSize(18)
          .fontColor('#99182431')
          .margin({ top: 8 })

        Button(this.isRecording ? (this.isPaused ? '继续' : '暂停') : '开始记录')
          .width('60%')
          .height(40)
          .fontSize(16)
          .fontWeight(500)
          .margin({ top: 24 })
          .onClick(() => {
            if (!this.isRecording) {
              this.isRecording = true;
              this.isPaused = false;
              this.startTime = Date.now();
              this.locationService.startContinuousTracking();
            } else {
              if (this.isPaused) {
                this.isPaused = false;
                this.locationService.startContinuousTracking();
              } else {
                this.isPaused = true;
                this.locationService.stopContinuousTracking();
              }
            }
          })

        Button('停止记录')
          .width('60%')
          .height(40)
          .fontSize(16)
          .fontWeight(500)
          .backgroundColor(Color.Red)
          .margin({ top: 12 })
          .onClick(() => {
            this.isRecording = false;
            this.isPaused = false;
            this.locationService.stopContinuousTracking();
            this.trackPoints = this.locationService.getTrackPoints();
            this.stopTimer();
            this.saveRecord();
            this.updateTripStatus();
            router.back();
          })
      }
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
      .borderRadius({
        topLeft: 24,
        topRight: 24
      })
      .padding({
        top: 12,
        bottom: 12
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({
      bottom: 24
    })
  }
}
