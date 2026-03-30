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
      const tripId = params.tripId;

      const segment: RecordSegment = {
        id: generateId(),
        tripId: tripId || 'default',
        startTime: Date.now() - this.duration * 1000,
        endTime: Date.now(),
        trackPoints: this.trackPoints,
        totalDistance: this.distance,
        avgSpeed: this.speed,
      };

      await RecordService.getInstance().createRecordSegment(segment);

      router.back();
    } catch (error) {
    console.error('Failed to save record:', error);
    }
  }

  @Builder
  StatsCard() {
    Column({ space: 8 }) {
      Text('00:00:00')
        .fontSize(32)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
      
      Text('00.00 km')
        .fontSize(24)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
      
      Text('0.0 KM/H')
        .fontSize(24)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .backgroundColor('rgba(255, 255, 255, 0.9)')
    .borderRadius(16)
    .padding(16)
    .width('30%')
  }

  build() {
    Stack() {
      // 深色背景
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#111827')

      // 顶部信息
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_clock'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(this.formatDuration(this.duration))
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_location'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(`${this.distance.toFixed(2)} km`)
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_play'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(`${this.speed.toFixed(1)} KM/H`)
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
      .padding({ top: 100, left: 24, right: 24 })

      // 底部停止按钮
      Column() {
        Row({ space: 8 }) {
          Image($r('sys.media.ohos_ic_public_play'))
            .width(32)
            .height(32)
            .fillColor(Color.White)
        }
        
        Text('停止')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(100%')
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
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#111827')

    if (this.showStopDialog) {
      this.StopDialogBuilder()
    }
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
      .padding(24)
      .backgroundColor('rgba(0, 0, 0, 0.8)')
  }

  build() {
    Column() {
      // 顶部信息
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_clock'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(this.formatDuration(this.duration))
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_location'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(`${this.distance.toFixed(2)} km`)
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        Row({ space: 8 }) {
          Column() {
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#14B8A6')
          
          Image($r('sys.media.ohos_ic_public_play'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        
        Column({ space: 4 }) {
          Text(`${this.speed.toFixed(1)} KM/H')
            .fontSize(24)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

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
      }
      .width('100%')
      .padding({ top: 100, left: 24, right: 24 })

      // 底部停止按钮
      Column() {
        Row({ space: 8 }) {
          Image($r('sys.media.ohos_ic_public_play'))
            .width(32)
            .height(32)
            .fillColor(Color.White)
        }
        
        Text('停止')
          .fontSize(18)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .width(100%')
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
        .margin({ top: 16 })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#111827')

    if (this.showStopDialog) {
      this.StopDialogBuilder()
    }
  }
}
