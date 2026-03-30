import { LocationService } from '../services/LocationService';
import { RecordService } from '../services/RecordService';
import { router } from '@kit.ArkUI';
import { TrackPoint, RecordSegment } from '../models/RecordSegment';
import { AppColors } from '../common/constants/Colors';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

interface StatsCardData {
  icon: string;
  value: string;
  label: string;
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
  @State showStopDialog: boolean = false;

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

  private calculateDistance(points: TrackPoint[]): number {
    let total = 0;
    for (let i = 1; i < points.length; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      const dx = curr.longitude - prev.longitude;
      const dy = curr.latitude - prev.latitude;
      total += Math.sqrt(dx * dx + dy * dy) * 111;
    }
    return Math.round(total * 100) / 100;
  }

  private calculateSpeed(distance: number, duration: number): number {
    if (duration === 0) {
      return 0;
    }
    const hours = duration / 3600;
    return Math.round(distance / hours);
  }

  private formatDuration(seconds: number): string {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  private async saveRecord(): Promise<void> {
    this.stopTimer();
    this.locationService.stopContinuousTracking();
    this.isRecording = false;

    try {
      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId || 'default';

      const segment: RecordSegment = {
        id: generateId(),
        tripId: tripId,
        startTime: Date.now() - this.duration * 1000,
        endTime: Date.now(),
        distance: this.distance,
        trackPoints: this.trackPoints,
        createdAt: Date.now()
      };

      await RecordService.getInstance().createRecord(segment);
      router.back();
    } catch (error) {
      console.error('Failed to save record:', error);
    }
  }

  @Builder
  StatsCard(icon: string, value: string, label: string) {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Column() {
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor('#14B8A6')

        Image($r(icon))
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }

      Text(value)
        .fontSize(24)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.6)')
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StopDialogBuilder() {
    Column({ space: 16 }) {
      Text('确认结束记录?')
        .fontSize(20)
        .fontColor('#1F2937')
        .fontWeight(FontWeight.Bold)

      Row({ space: 16 }) {
        Button() {
          Text('取消')
            .fontSize(16)
            .fontColor('#6B7280')
        }
        .width(80)
        .onClick(() => {
          this.showStopDialog = false
        })

        Blank()

        Button() {
          Text('确认')
            .fontSize(16)
            .fontColor(Color.White)
        }
        .width(120)
        .backgroundColor('#EF4444')
        .onClick(() => {
          this.saveRecord();
          this.showStopDialog = false
        })
      }
      .width('100%')
    }
    .width('80%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 深色背景
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#111827')

      // 顶部信息
      Column({ space: 12 }) {
        this.StatsCard('sys.media.ohos_ic_public_clock', this.formatDuration(this.duration), '时长')

        this.StatsCard('sys.media.ohos_ic_public_location', `${this.distance.toFixed(2)} km`, '距离')

        this.StatsCard('sys.media.ohos_ic_public_play', `${this.speed.toFixed(1)} KM/H`, '配速')

        // GPS 状态
        Row({ space: 8 }) {
          Column() {
          }
          .width(32)
          .height(32)
          .borderRadius(16)
          .backgroundColor('#10B981')

          Image($r('sys.media.ohos_ic_public_location'))
            .width(16)
            .height(16)
            .fillColor(Color.White)
        }

        Text('GPS 信号良好')
          .fontSize(12)
          .fontColor('#10B981')
      }
      .width('100%')
      .padding({ top: 100, left: 24, right: 24 })
      .alignItems(HorizontalAlign.Start)

      // 底部停止按钮
      Column({ space: 8 }) {
        Button() {
          Row({ space: 8 }) {
            Image($r('sys.media.ohos_ic_public_play'))
              .width(32)
              .height(32)
              .fillColor(Color.White)

            Text('停止')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
        }
        .width('90%')
        .height(64)
        .borderRadius(32)
        .backgroundColor('#EF4444')
        .shadow({ radius: 20, color: 'rgba(239, 68, 68, 0.4)' })
        .onClick(() => {
          this.showStopDialog = true
        })

        Text('滑动或点击结束')
          .fontSize(14)
          .fontColor('rgba(255, 255, 255, 0.6)')
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.showStopDialog, this.StopDialogBuilder(), {
      height: 200,
      showClose: false,
      onDisappear: () => {
        this.showStopDialog = false
      }
    })
  }
}
