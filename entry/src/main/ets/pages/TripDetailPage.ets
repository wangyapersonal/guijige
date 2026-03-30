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
            color: 'rgba(20, 184, 166, 0.3)',
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
            .backgroundColor('#F59E0B')
            .borderRadius(12)
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
        Stack({ alignContent: Alignment.BottomStart }) {
          if (this.trip?.coverImage) {
            Image(this.trip.coverImage)
              .width('100%')
              .height(280)
              .objectFit(ImageFit.Cover)
          } else {
            Column() {
            }
            .width('100%')
            .height(280)
            .linearGradient({
              angle: 180,
              colors: [['rgba(20, 184, 166, 0.3)', 0.0], ['rgba(20, 184, 166, 0.7)', 1.0]]
            })
          }

          Column() {
          }
          .width('100%')
          .height(280)
          .linearGradient({
            angle: 180,
            colors: [['rgba(20, 184, 166, 0.3)', 0.0], ['rgba(20, 184, 166, 0.7)', 1.0]]
          })

          Row() {
            Button() {
              Image($r('sys.media.ohos_ic_public_arrow_left'))
                .width(24)
                .height(24)
                .fillColor(Color.White)
            }
            .width(40)
            .height(40)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(20)
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
                  .fontWeight(500)
              }
            }
            .height(40)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F59E0B')
            .borderRadius(24)
            .shadow({
              radius: 16,
              color: 'rgba(245, 158, 11, 0.4)',
              offsetY: 8
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 48 })
          .position({ x: 0, y: 0 })

          Column({ space: 8 }) {
            Text(this.trip?.name || '未命名行程')
              .fontSize(24)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)

            Row({ space: 16 }) {
              Row({ space: 4 }) {
                Image($r('sys.media.ohos_ic_public_location'))
                  .width(16)
                  .height(16)
                  .fillColor('rgba(255, 255, 255, 0.9)')
                Text(this.trip?.destination || '未设置目的地')
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
              }

              Row({ space: 4 }) {
                Image($r('sys.media.ohos_ic_public_clock'))
                  .width(16)
                  .height(16)
                  .fillColor('rgba(255, 255, 255, 0.9)')
                Text(`${new Date(this.trip?.startDate || Date.now()).toLocaleDateString()} - ${this.trip?.endDate ? new Date(this.trip.endDate).toLocaleDateString() : '进行中'}`)
                  .fontSize(14)
                  .fontColor('rgba(255, 255, 255, 0.9)')
              }
            }
          }
          .padding({ left: 24, right: 24, bottom: 24 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(280)

        Column() {
          Text('行程轨迹')
            .fontSize(14)
            .fontColor('#6B7280')
            .margin({ bottom: 16 })

          if (this.checkInPoints.length === 0) {
            Column() {
              Text('暂无打卡记录')
                .fontSize(16)
                .fontColor('#9CA3AF')
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            List({ space: 0 }) {
              ForEach(this.checkInPoints, (point: CheckInPoint, index: number) => {
                ListItem() {
                  this.TimelineItem(point, index, index === 0, index === this.checkInPoints.length - 1)
                }
              }, (point: CheckInPoint) => point.id)
            }
            .width('100%')
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 24, right: 24, top: 24, bottom: 100 })
        .backgroundColor('#F9FAFB')
      }
      .width('100%')
      .height('100%')

      Button() {
        Row({ space: 8 }) {
          Image($r('sys.media.ohos_ic_public_save'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
          Text('导出行程')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(500)
        }
      }
      .width('90%')
      .height(52)
      .backgroundColor('#14B8A6')
      .borderRadius(26)
      .shadow({
        radius: 16,
        color: 'rgba(20, 184, 166, 0.4)',
        offsetY: 8
      })
      .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
  }
}
