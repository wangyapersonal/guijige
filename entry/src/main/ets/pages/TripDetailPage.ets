import { router } from '@kit.ArkUI';
import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { CheckInPoint } from '../models/CheckInPoint';
import { RecordSegment } from '../models/RecordSegment';
import { CheckInService } from '../services/CheckInService';
import { RecordService } from '../services/RecordService';
import { AppColors } from '../common/constants/Colors';

@Entry
@Component
struct TripDetailPage {
  @State trip: Trip | undefined = undefined;
  @State checkInPoints: CheckInPoint[] = [];
  @State recordSegments: RecordSegment[] = [];

  private primaryAlpha30 = 'rgba(20, 184, 166, 0.3)';
  private primaryAlpha70 = 'rgba(20, 184, 166, 0.7)';

  async aboutToAppear(): Promise<void> {
    try {
      const params = router.getParams() as Record<string, string>;
      const tripId = params.tripId;
      this.trip = await TripService.getInstance().getTripById(tripId);
      this.checkInPoints = await CheckInService.getInstance().getCheckInsByTripId(tripId);
      this.recordSegments = await RecordService.getInstance().getRecordsByTripId(tripId);
    } catch (error) {
      console.error('Failed to load trip detail:', error);
    }
  }

  @Builder
  TimelineItem(point: CheckInPoint, index: number, isFirst: boolean, isLast: boolean) {
    Row() {
      // 时间轴线条
      Column() {
        if (!isFirst) {
          Column() {
          }
          .width(2)
          .height(16)
          .linearGradient({
            angle: 0,
            colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryLight, 1.0]]
          })
        }

        // 圆点
        Stack() {
          Column() {
          }
          .width(32)
          .height(32)
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.Primary, 0.0], ['#0D9488', 1.0]]
          })
          .shadow({
            radius: 8,
            color: this.primaryAlpha30,
            offsetY: 2
          })

          if (index === 0) {
            Image($r('sys.media.ohos_ic_public_location'))
              .width(16)
              .height(16)
              .fillColor(Color.White)
          } else {
            Column() {
            }
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(Color.White)
          }
        }
        .width(32)
        .height(32)

        if (!isLast) {
          Column() {
          }
          .width(2)
          .layoutWeight(1)
          .linearGradient({
            angle: 0,
            colors: [[AppColors.Primary, 0.0], ['rgba(20, 184, 166, 0.1)', 1.0]]
          })
        }
      }
      .width(32)
      .padding({ top: isFirst ? 0 : 16, bottom: isLast ? 0 : 16 })

      // 内容卡片
      Column({ space: 8 }) {
        Row({ space: 12 }) {
          Text(new Date(point.timestamp).toLocaleTimeString())
            .fontSize(12)
            .fontColor('#9CA3AF')

          if (index === 0) {
            Row() {
              Text('Day 1')
                .fontSize(10)
                .fontColor(Color.White)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(AppColors.Accent)
            .borderRadius(8)
          }
        }

        Text(point.name || '未知位置')
          .fontSize(16)
          .fontColor('#1F2937')
          .fontWeight(500)
      }
      .layoutWeight(1)
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .margin({ left: 16, bottom: 16 })
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.04)',
        offsetY: 2
      })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 地图背景区域
        Stack({ alignContent: Alignment.BottomStart }) {
          // 地图背景（使用渐变色占位符）
          Column() {
          }
          .width('100%')
          .height(280)
          .linearGradient({
            angle: 180,
            colors: [[this.primaryAlpha30, 0.0], [this.primaryAlpha70, 1.0]]
          })

          // 返回按钮和分享按钮
          Row() {
            Button() {
              Column() {
              }
              .width(40)
              .height(40)
              .borderRadius(20)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .backdropBlur(20)
            }
            .width(40)
            .height(40)
            .backgroundColor('transparent')
            .onClick(() => {
              router.back();
            })

            Blank()

            Button() {
              Row({ space: 8 }) {
                Image($r('sys.media.ohos_ic_public_share'))
                  .width(16)
                  .height(16)
                  .fillColor(Color.White)

                Text('一键分享')
                  .fontSize(14)
                  .fontColor(Color.White)
              }
            }
            .height(36)
            .padding({ left: 16, right: 16 })
            .backgroundColor(AppColors.Accent)
            .borderRadius(18)
            .shadow({
              radius: 12,
              color: 'rgba(245, 158, 11, 0.3)',
              offsetY: 4
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 48 })

          // 标题信息
          Column({ space: 12 }) {
            Text(this.trip?.name || '行程详情')
              .fontSize(28)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            Row({ space: 16 }) {
              Row({ space: 8 }) {
                Image($r('sys.media.ohos_ic_public_location'))
                  .width(16)
                  .height(16)
                  .fillColor(Color.White)

                Text(this.trip?.destination || '未设置')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
              }

              Row({ space: 8 }) {
                Image($r('sys.media.ohos_ic_public_clock'))
                  .width(16)
                  .height(16)
                  .fillColor(Color.White)

                Text(`${new Date(this.trip?.startDate || 0).toLocaleDateString()} - ${this.trip?.endDate ? new Date(this.trip.endDate).toLocaleDateString() : '进行中'}`)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
              }
            }
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 24 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(280)

        // 时间轴内容
        Scroll() {
          Column({ space: 0 }) {
            Text('行程轨迹')
              .fontSize(18)
              .fontColor('#1F2937')
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })

            if (this.checkInPoints.length === 0) {
              Column() {
                Text('暂无轨迹记录')
                  .fontSize(14)
                  .fontColor('#9CA3AF')
              }
              .width('100%')
              .padding(32)
            } else {
              Column({ space: 0 }) {
                ForEach(this.checkInPoints, (point: CheckInPoint, index: number) => {
                  this.TimelineItem(
                    point,
                    index,
                    index === 0,
                    index === this.checkInPoints.length - 1
                  );
                }, (point: CheckInPoint) => point.id);
              }
              .width('100%')
            }
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 24, bottom: 120 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F7F9FA')
      }
      .width('100%')
      .height('100%')

      // 底部导出按钮
      Column() {
        Button() {
          Row({ space: 8 }) {
            Image($r('sys.media.ohos_ic_public_arrow_down'))
              .width(20)
              .height(20)
              .fillColor(Color.White)

            Text('一键导出行程长图')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(500)
          }
        }
        .width('100%')
        .height(52)
        .borderRadius(26)
        .linearGradient({
          angle: 135,
          colors: [[AppColors.Accent, 0.0], ['#F97316', 1.0]]
        })
        .shadow({
          radius: 20,
          color: 'rgba(245, 158, 11, 0.3)',
          offsetY: 8
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .backdropBlur(20)
    }
    .width('100%')
    .height('100%')
  }
}
