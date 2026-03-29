import { LocationService } from '../services/LocationService';
import { RecordService } from '../services/RecordService';
import { router } from '@kit.ArkUI';
import { TrackPoint, RecordSegment } from '../models/RecordSegment';
import { TripService } from '../services/TripService';
import { Trip, TripStatus } from '../models/Trip';

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
  private locationService: LocationService = LocationService.getInstance();

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, string>;
    const tripId = params.tripId;
    this.isRecording = true;
    this.locationService.startContinuousTracking();
    this.startTimer();
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
    const R = 6371; // 地球半径，单位千米
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
  }

  private async updateTripStatus(): Promise<void> {
    const params = router.getParams() as Record<string, string>;
    const tripId = params.tripId;
    const trip = await TripService.getInstance().getTripById(tripId);
    if (trip) {
      trip.status = TripStatus.COMPLETED;
      await TripService.getInstance().updateTrip(trip);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Blank()

        // 底部控制区域
        Column({ space: 24 }) {
          Text('Slide or Click to end')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.6)')
            .letterSpacing(2)
            .fontWeight(600)

          Button() {
            Image($r('sys.media.ohos_ic_public_pause'))
              .width(36)
              .height(36)
              .fillColor('#EF4444')
          }
          .type(ButtonType.Normal)
          .backgroundColor('rgba(239, 68, 68, 0.2)')
          .borderRadius(48)
          .width(96)
          .height(96)
          .border({ width: 2, color: '#EF4444' })
          .shadow({ radius: 30, color: 'rgba(239, 68, 68, 0.2)' })
          .shadow({ radius: 40, color: 'rgba(239, 68, 68, 0.6)' })
          .onClick(() => {
            this.isRecording = false;
            this.locationService.stopContinuousTracking();
            this.trackPoints = this.locationService.getTrackPoints();
            this.stopTimer();
            this.saveRecord();
            this.updateTripStatus();
            router.back();
          })

          Text('结束记录')
            .fontSize(14)
            .fontColor('#FCA5A5')
            .fontWeight(500)
        }
        .padding({ top: 32, bottom: 48 })
        .alignItems(HorizontalAlign.Center)
        .linearGradient({
          angle: 180,
          colors: [['rgba(17, 24, 39, 1)', 0.0], ['rgba(17, 24, 39, 0)', 1.0]]
        })
      }
      .width('100%')

      // 地图背景
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#1F2937')

      // 模拟轨迹线
      Column() {
        Polyline()
          .width(300)
          .height(300)
          .points([[50,400], [150,350], [120,250], [250,150], [300,180], [280,280]])
          .strokeWidth(5)
          .stroke(Color.Red)
          .fill(Color.Transparent)
          .strokeDashArray([0])
          .strokeLineCap(LineCapStyle.Round)
          .strokeLineJoin(LineJoinStyle.Round)
          .shadow({ radius: 6, color: 'rgba(13, 148, 136, 0.6)' })
      }
      .width('100%')
      .height('100%')

      // 脉冲定位点
      Column() {
        Stack() {
          Circle()
            .width(48)
            .height(48)
            .fill('rgba(13, 148, 136, 0.3)')
          Circle()
            .width(32)
            .height(32)
            .fill('rgba(13, 148, 136, 0.4)')
          Circle()
            .width(16)
            .height(16)
            .fill('#5EEAD4')
            .border({ width: 2, color: Color.White })
            .shadow({ radius: 10, color: 'rgba(13, 148, 136, 1)' })
          Circle()
            .width(6)
            .height(6)
            .fill(Color.White)
        }
        .margin({ top: 280, left: 280 })
      }
      .width('100%')
      .height('100%')

      // 顶部玻璃态状态栏
      Column({ space: 24 }) {
        Row() {
          Row({ space: 8 }) {
            Image($r('sys.media.ohos_ic_public_favor'))
              .width(16)
              .height(16)
              .fillColor('#2DD4BF')
            Text('正在记录行程轨迹...')
              .fontSize(14)
              .fontColor('#2DD4BF')
              .fontWeight(500)
          }

          Blank()

          Row({ space: 4 }) {
            Image($r('sys.media.ohos_ic_public_location'))
              .width(12)
              .height(12)
              .fillColor('#14B8A6')
            Text('GPS 信号良好')
              .fontSize(12)
              .fontColor('#9CA3AF')
          }
        }
        .width('100%')

        Column({ space: 8 }) {
          Text(this.formatDuration(this.duration))
            .fontSize(48)
            .fontFamily('monospace')
            .fontColor(Color.White)
            .fontWeight(FontWeight.Lighter)
            .letterSpacing(4)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.5)' })

          Text('持续时间')
            .fontSize(14)
            .fontColor('#9CA3AF')
        }

        Row({ space: 16 }) {
          Column({ space: 4 }) {
            Text(this.distance.toFixed(2))
              .fontSize(24)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Text('公里 (KM)')
              .fontSize(12)
              .fontColor('#9CA3AF')
          }
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(16)
          .padding(16)
          .border({ width: 1, color: 'rgba(255,255,255,0.05)' })

          Column({ space: 4 }) {
            Text(this.speed.toFixed(1))
              .fontSize(24)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Text('配速 (KM/H)')
              .fontSize(12)
              .fontColor('#9CA3AF')
          }
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgba(255,255,255,0.05)')
          .borderRadius(16)
          .padding(16)
          .border({ width: 1, color: 'rgba(255,255,255,0.05)' })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .padding({ top: 48 })
      .borderRadius(24)
      .backgroundColor('rgba(0,0,0,0.4)')
      .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
      .backdropBlur(24)
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.5)' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#111827')
  }
}
