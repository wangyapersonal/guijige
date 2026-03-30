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
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  private async saveRecord(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId;
      if (this.trackPoints.length === 0) {
        return;
      }
      const segment: RecordSegment = {
        id: generateId(),
        tripId: tripId,
        startTime: this.trackPoints[0].timestamp,
        endTime: this.trackPoints[this.trackPoints.length - 1].timestamp,
        distance: this.distance,
        trackPoints: this.trackPoints,
        createdAt: Date.now()
      };
      await RecordService.getInstance().createRecord(segment);
    } catch (error) {
      console.error('Failed to save record:', error);
    }
  }

  private async updateTripStatus(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId;
      const trip = await TripService.getInstance().getTripById(tripId);
      if (trip) {
        trip.status = TripStatus.COMPLETED;
        await TripService.getInstance().updateTrip(trip);
      }
    } catch (error) {
      console.error('Failed to update trip status:', error);
    }
  }

  @Builder
  StatCard(icon: Resource, value: string, label: string, color: string) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(color)

      Text(value)
        .fontSize(24)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 })

      Text(label)
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.6)')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(16)
    .backdropBlur(20)
  }

  build() {
    Stack() {
      // 深色背景 + 网格
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#111827')

      // 网格背景（模拟地图）
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundImage('data:image/svg+xml,%3Csvg width="100" height="100" xmlns="http://www.w3.org/2000/svg"%3E%3Cdefs%3E%3Cpattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse"%3E%3Cpath d="M 30 0 L 0 0 0 30" fill="none" stroke="rgba(20, 184, 166, 0.1)" stroke-width="1"/%3E%3C/pattern%3E%3C/defs%3E%3Crect width="100%25" height="100%25" fill="url(%23grid)" /%3E%3C/svg%3E')

      Column() {
        // 关闭按钮
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

        // 实时记录状态
        Column({ space: 12 }) {
          Text('实时记录中...')
            .fontSize(28)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)

          // 统计卡片
          Row({ space: 12 }) {
            this.StatCard(
              $r('sys.media.ohos_ic_public_clock'),
              this.formatDuration(this.duration),
              '时长',
              AppColors.Primary
            )

            this.StatCard(
              $r('sys.media.ohos_ic_public_navigation'),
              this.distance.toFixed(2),
              '公里',
              AppColors.Accent
            )

            this.StatCard(
              $r('sys.media.ohos_ic_public_flash'),
              this.speed.toFixed(1),
              'km/h',
              '#FCD34D'
            )
          }
          .width('100%')

          // GPS 状态
          Row({ space: 8 }) {
            Column() {
            }
            .width(12)
            .height(12)
            .borderRadius(6)
            .backgroundColor('#EF4444')

            Text('GPS 定位中')
              .fontSize(14)
              .fontColor(Color.White)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(16)
          .backgroundColor('rgba(255, 255, 255, 0.05)')
          .borderRadius(16)
          .backdropBlur(10)
        }
        .width('100%')
        .padding(24)

        Blank()

        // 结束记录按钮
        Column() {
          Stack() {
            // 脉冲动画效果
            if (this.isPulsing) {
              Column() {
              }
              .width(160)
              .height(160)
              .borderRadius(80)
              .backgroundColor('rgba(239, 68, 68, 0.3)')

              Column() {
              }
              .width(140)
              .height(140)
              .borderRadius(70)
              .backgroundColor('rgba(239, 68, 68, 0.5)')
              .margin({ top: 10, left: 10 })
            }

            Button() {
              Text('结束记录')
                .fontSize(20)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width(128)
            .height(128)
            .borderRadius(64)
            .linearGradient({
              angle: 135,
              colors: [['#EF4444', 0.0], ['#DC2626', 1.0]]
            })
            .shadow({
              radius: 40,
              color: 'rgba(239, 68, 68, 0.5)',
              offsetY: 0
            })
            .onClick(() => {
              this.isPulsing = false;
              this.isRecording = false;
              this.locationService.stopContinuousTracking();
              this.trackPoints = this.locationService.getTrackPoints();
              this.stopTimer();
              this.saveRecord();
              this.updateTripStatus();
              router.back();
            })
          }
          .width(160)
          .height(160)
        }
        .width('100%')
        .padding({ bottom: 48 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
