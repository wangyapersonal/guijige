import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { CheckInService } from '../services/CheckInService';
import { CheckInPoint } from '../models/CheckInPoint';
import { RecordService } from '../services/RecordService';
import { RecordSegment } from '../models/RecordSegment';
import { TimeUtils } from '../common/utils/TimeUtils';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct TripDetailPage {
  @State trip: Trip | undefined = undefined;
  @State checkInPoints: CheckInPoint[] = [];
  @State recordSegments: RecordSegment[] = [];

  async aboutToAppear(): Promise<void> {
    const params = router.getParams() as Record<string, string>;
    const tripId = params.tripId;
    this.trip = await TripService.getInstance().getTripById(tripId);
    this.checkInPoints = await CheckInService.getInstance().getCheckInsByTripId(tripId);
    this.recordSegments = await RecordService.getInstance().getRecordsByTripId(tripId);
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
        Text('行程详情')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          Column() {
            if (this.checkInPoints.length === 0) {
              Column() {
                Text('暂无打卡记录')
                  .fontSize(18)
                  .fontColor('#99182431')
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            } else {
              List({ space: 12 }) {
                ForEach(this.checkInPoints, (item: CheckInPoint) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                        Text(TimeUtils.formatDateTime(item.timestamp))
                          .fontSize(14)
                          .fontColor('#99182431')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .margin({
                      left: 16,
                      right: 16,
                      top: 12
                    })
                  }
                }, (item: CheckInPoint) => item.id)
              }
              .width('100%')
              .padding({ top: 12 })
            }
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
        .tabBar('打卡点')

        TabContent() {
          Column() {
            if (this.recordSegments.length === 0) {
              Column() {
                Text('暂无轨迹记录')
                  .fontSize(18)
                  .fontColor('#99182431')
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            } else {
              List({ space: 12 }) {
                ForEach(this.recordSegments, (item: RecordSegment) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(`${TimeUtils.formatDuration((item.endTime ?? 0) - item.startTime)}`)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                        Text(`${TimeUtils.formatDateTime(item.startTime)} - ${TimeUtils.formatDateTime(item.endTime ?? 0)}`)
                          .fontSize(14)
                          .fontColor('#99182431')
                          .margin({ top: 4 })
                        Text(`${TimeUtils.formatDistance(item.distance)}`)
                          .fontSize(14)
                          .fontColor('#99182431')
                          .margin({ top: 4 })
                      }
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .margin({
                      left: 16,
                      right: 16,
                      top: 12
                    })
                  }
                }, (item: RecordSegment) => item.id)
              }
              .width('100%')
              .padding({ top: 12 })
            }
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
        .tabBar('轨迹')
      }
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .barHeight(48)
      .animationDuration(300)
      .animationDuration(400)

      Button('开始记录')
        .width('60%')
        .height(40)
        .fontSize(16)
        .fontWeight(500)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/RecordPage',
            params: {
              tripId: this.trip?.id
            }
          })
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
