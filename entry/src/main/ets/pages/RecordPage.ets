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
  @State startTime: number = 0;
  @State duration: number = 0;
  @State trackPoints: TrackPoint[] = [];
  @State locationService: LocationService = LocationService.getInstance();
  @State tripId: string = '';
  @State speed: number = 0;
  @State distance: number = 0;

  private startTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
    }
    this.timerId = setInterval(() => {
      if (this.isRecording) {
        this.duration = Math.floor((Date.now() - this.startTime) / 1000);
        this.speed = 4.0 + Math.random() * 2.5;
        this.distance = this.distance + (this.speed / 3600);
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
      return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    } else {
      return `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }
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

  private calculateTotalDistance(trackPoints: TrackPoint[]): number {
    let totalDistance = 0;
    for (let i = 1; i < trackPoints.length; i++) {
      totalDistance += this.getDistance(trackPoints[i - 1], trackPoints[i]);
    }
    return totalDistance;
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

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#111827')

    // 地图背景
    Column() {
      Image($r('app.media.bg_map'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .grayscale(true)
        .opacity(0.7)
        .mixBlendMode(MixBlendMode.SCREEN)
    }
    .width('100%')
    .height('100%')

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
          .animateTo(true, 1000)
        Circle()
          .width(32)
          .height(32)
          .fill('rgba(13, 148, 136, 0.4)')
          .animateTo(true, 1000)
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
          Image($r('sys.media.ohos_ic_public_activity'))
            .width(16)
            .height(16)
            .fillColor('#2DD4BF')
          Text('正在记录行程轨迹...')
            .fontSize(14)
            .fontColor('#2DD4BF')
            .fontWeight(500)
        }
        .animateTo(true, 1000)

        Blank()

        Row({ space: 4 }) {
          Image($r('sys.media.ohos_ic_public_location_on'))
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
          .fontWeight(FontWeight.Light)
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
}
