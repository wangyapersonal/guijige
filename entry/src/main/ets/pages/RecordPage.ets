import { LocationService } from '../services/LocationService';
import { RecordService } from '../services/RecordService';
import { router } from '@kit.ArkUI';
import { TrackPoint, RecordSegment } from '../models/RecordSegment';
import { TripService } from '../services/TripService';
import { Trip, TripStatus } from '../models/Trip';
import { AppColors } from '../common/constants/Colors';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

interface StatData {
  value: string;
  label: string;
  unit: string;
}

@Entry
@Component
struct RecordPage {
  @State isRecording: boolean = false;
  @State timerId: number = -1;
  @State duration: number = 0;
  @State distance: number = 0;
  @State speed: number = 0;
  @State trackPoints: TrackPoint[] = [];
  @State isPulsing: boolean = true;

  private locationService: LocationService = LocationService.getInstance();

  async aboutToAppear(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId;
      this.isRecording = true;
      this.locationService.startContinuousTracking();
      this.startTimer();
    } catch (error) {
      console.error('Failed to start recording:', error);
    }
  }

  aboutToDisappear() {
    this.stopTimer();
    if (this.isRecording) {
      this.locationService.stopContinuousTracking();
    }
  }

  private startTimer(): void {
    this.timerId = setInterval(() => {
      this.duration++;
      this.trackPoints = this.locationService.getTrackPoints();
      this.distance = this.calculateDistance(this.trackPoints);
      this.speed = this.calculateSpeed(this.distance, this.duration);
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private calculateSpeed(distance: number, duration: number): number {
    if (duration === 0) {
      return 0;
    }
    return (distance / (duration / 3600));
  }

  private calculateDistance(trackPoints: TrackPoint[]): number {
    let distance = 0;
    for (let i = 1; i < trackPoints.length; i++) {
      const prev = trackPoints[i - 1];
      const curr = trackPoints[i];
      distance += this.haversineDistance(prev.latitude, prev.longitude, curr.latitude, curr.longitude);
    }
    return distance;
  }

  private haversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371;
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  private formatDuration(seconds: number): string {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  @Builder
  StatCard(value: string, label: string, unit: string, iconColor: string) {
    Column({ space: 8 }) {
      Text(value)
        .fontSize(28)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .fontFamily('monospace')

      Text(label)
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.6)')
        .margin({ top: 4 })

      Text(unit)
        .fontSize(10)
        .fontColor('rgba(255, 255, 255, 0.4)')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255, 255, 255, 0.08)')
    .borderRadius(16)
    .backdropBlur(20)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#111827')

      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundImage('data:image/svg+xml,%3Csvg width="100" height="100" xmlns="http://www.w3.org/2000/svg"%3E%3Cdefs%3E%3Cpattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse"%3E%3Cpath d="M 30 0 L 0 0 0 30" fill="none" stroke="rgba(20, 184, 166, 0.08)" stroke-width="1"/%3E%3C/pattern%3E%3C/defs%3E%3Crect width="100%25" height="100%25" fill="url(%23grid)" /%3E%3C/svg%3E')

      Column() {
        Row() {
          Blank()

          Button() {
            Image($r('sys.media.ohos_ic_public_close'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .width(40)
          .height(40)
          .backgroundColor('rgba(255, 255, 255, 0.1)')
          .borderRadius(20)
          .backdropBlur(20)
          .onClick(() => {
            router.back();
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 48 })

        Column({ space: 16 }) {
          Text('实时记录中...')
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)

          Row({ space: 12 }) {
            this.StatCard(
              this.formatDuration(this.duration),
              '时长',
              '',
              AppColors.Primary
            )

            this.StatCard(
              this.distance.toFixed(2),
              '距离',
              'km',
              AppColors.Accent
            )

            this.StatCard(
              this.speed.toFixed(1),
              '配速',
              'KM/H',
              '#FCD34D'
            )
          }
          .width('100%')

          Row({ space: 8 }) {
            Column() {
            }
            .width(12)
            .height(12)
            .borderRadius(6)
            .backgroundColor('#10B981')

            Text('GPS 信号良好')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(12)
          .backgroundColor('rgba(16, 185, 129, 0.1)')
          .borderRadius(12)
        }
        .width('100%')
        .padding(24)
        .alignItems(HorizontalAlign.Start)

        Blank()

        Column({ space: 12 }) {
          Text('滑动或点击结束')
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.6)')

          Button() {
            Column() {
              Text('停止')
                .fontSize(20)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          .width('80%')
          .height(64)
          .backgroundColor('#EF4444')
          .borderRadius(32)
          .shadow({
            radius: 20,
            color: 'rgba(239, 68, 68, 0.4)',
            offsetY: 8
          })
          .onClick(async () => {
            await this.stopRecording();
          })
        }
        .width('100%')
        .padding(24)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  private async stopRecording(): Promise<void> {
    try {
      this.stopTimer();
      this.locationService.stopContinuousTracking();
      this.isRecording = false;

      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId;

      if (this.trackPoints.length > 0) {
        const segment: RecordSegment = {
          id: generateId(),
          tripId: tripId,
          startTime: this.trackPoints[0].timestamp,
          endTime: this.trackPoints[this.trackPoints.length - 1].timestamp,
          distance: this.distance,
          points: this.trackPoints,
          createdAt: Date.now()
        };

        await RecordService.getInstance().saveRecordSegment(segment);
      }

      router.back();
    } catch (error) {
      console.error('Failed to stop recording:', error);
    }
  }
}
