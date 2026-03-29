import { router } from '@kit.ArkUI';
import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { CheckInPoint } from '../models/CheckInPoint';
import { RecordSegment } from '../models/RecordSegment';
import { CheckInService } from '../services/CheckInService';
import { RecordService } from '../services/RecordService';

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
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        // 内容区域
        Scroll() {
          Column({ space: 32 }) {
            // 行程标题区域
            Column({ space: 8 }) {
              Row({ space: 8 }) {
                Text('实时轨迹')
                  .fontSize(12)
                  .fontColor(Color.White)
                  .fontWeight(500)
                Image($r('sys.media.ohos_ic_public_location'))
                  .width(12)
                  .height(12)
                  .fillColor(Color.White)
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .backgroundColor('rgba(13, 148, 136, 0.8)')
              .backdropBlur(10)

              Text(this.trip?.name || '行程详情')
                .fontSize(30)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Row({ space: 8 }) {
                Image($r('sys.media.ohos_ic_public_location'))
                  .width(14)
                  .height(14)
                  .fillColor('rgba(255,255,255,0.8)')
                Text(this.trip?.destination || '未设置目的地')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.8)')
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding({ left: 24, top: 32, right: 24 })

            // 行程记录
            Column({ space: 16 }) {
              Row() {
                Text('行程记录')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1F2937')
                Blank()
                Text(`共 ${this.checkInPoints.length} 个足迹`)
                  .fontSize(12)
                  .fontColor('#0D9488')
                  .fontWeight(500)
              }
              .width('100%')

              // 时间线
              Column() {
                ForEach(this.checkInPoints, (item: CheckInPoint, index: number) => {
                  Row() {
                    // 左侧圆点
                    Stack() {
                      Circle()
                        .width(32)
                        .height(32)
                        .fill('#F0FDFA')
                        .border({ width: 4, color: Color.White })
                        .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)' })

                      if (index === 0) {
                        Image($r('sys.media.ohos_ic_public_flight'))
                          .width(14)
                          .height(14)
                          .fillColor('#0D9488')
                      } else {
                        Image($r('sys.media.ohos_ic_public_location'))
                          .width(14)
                          .height(14)
                          .fillColor('#0D9488')
                      }
                    }
                    .width(32)
                    .height(32)

                    // 右侧卡片
                    Column({ space: 8 }) {
                      Row() {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#1F2937')
                        Blank()
                        Row({ space: 4 }) {
                          Image($r('sys.media.ohos_ic_public_clock'))
                            .width(12)
                            .height(12)
                            .fillColor('#9CA3AF')
                          Text(new Date(item.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }))
                            .fontSize(12)
                            .fontColor('#9CA3AF')
                        }
                      }
                      .width('100%')

                      Text('记录一些旅行心得或重要事项...')
                        .fontSize(14)
                        .fontColor('#6B7280')
                        .lineHeight(20)

                      // Day 标签
                      Text(`DAY ${index + 1}`)
                        .fontSize(10)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#0D9488')
                        .letterSpacing(2)
                    }
                    .padding(16)
                    .alignItems(HorizontalAlign.Start)
                    .borderRadius(16)
                    .backgroundColor(Color.White)
                    .border({ width: 1, color: '#F9FAFB' })
                    .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)' })
                  }
                  .alignItems(VerticalAlign.Top)
                  .width('100%')
                }, (item: CheckInPoint) => item.id)
              }
              .width('100%')
              .padding({ left: 16 })
              .border({ width: { left: 2 }, color: '#CCFBF1' })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(24)

            // 一键导出卡片
            Column({ space: 12 }) {
              Column({ space: 8 }) {
                Button() {
                  Image($r('sys.media.ohos_ic_public_share'))
                    .width(32)
                    .height(32)
                    .fillColor(Color.White)
                }
                .type(ButtonType.Normal)
                .width(64)
                .height(64)
                .backgroundColor('rgba(255,255,255,0.2)')
                .borderRadius(32)
                .backdropBlur(10)
              }
              .backgroundColor('#0D9488')
              .borderRadius(32)

              Text('一键导出行程长图')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .letterSpacing(2)
              Text('生成精美排版，将这段美好旅程分享给朋友')
                .fontSize(14)
                .fontColor('#CCFBF1')
                .fontWeight(500)

              // 添加位置打卡按钮
              Button() {
                Row({ space: 8 }) {
                  Image($r('sys.media.ohos_ic_public_location'))
                    .width(20)
                    .height(20)
                    .fillColor(Color.White)
                  Text('位置打卡')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                }
              }
              .type(ButtonType.Normal)
              .width('100%')
              .height(48)
              .backgroundColor('#F97316')
              .borderRadius(24)
              .margin({ top: 8 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/PunchRecordPage',
                  params: {
                    tripId: this.trip?.id
                  }
                })
              })
            }
            .alignItems(HorizontalAlign.Center)
            .width('100%')
            .padding(32)
            .borderRadius(32)
            .shadow({ radius: 30, color: 'rgba(13, 148, 136, 0.25)' })
            .linearGradient({
              angle: 135,
              colors: [['#0D9488', 0.0], ['#14B8A6', 0.5], ['#10B981', 1.0]]
            })
          }
          .width('100%')
          .padding({ bottom: 32 })
        }
        .width('100%')
      }
      .width('100%')
      .backgroundColor('#F7F9FA')

      // 顶部覆盖层
      Column({ space: 16 }) {
        // 返回按钮
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
        }
        .type(ButtonType.Normal)
        .width(40)
        .height(40)
        .backgroundColor('rgba(0,0,0,0.2)')
        .borderRadius(20)
        .backdropBlur(10)

        // 一键分享按钮
        Button() {
          Row({ space: 6 }) {
            Image($r('sys.media.ohos_ic_public_star'))
              .width(16)
              .height(16)
              .fillColor('#FEF3C7')
            Text('一键分享')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
        }
        .type(ButtonType.Normal)
        .backgroundColor('#0D9488')
        .borderRadius(20)
        .height(40)
        .padding({ left: 16, right: 16 })
        .shadow({ radius: 16, color: 'rgba(13, 148, 136, 0.3)' })
        .linearGradient({
          angle: 90,
          colors: [['#0D9488', 0.0], ['#10B981', 1.0]]
        })
      }
      .width('100%')
      .padding(24)
      .padding({ top: 48 })
      .backgroundColor(Color.Transparent)
      .backdropBlur(0)

      // 地图背景
      Column() {
      }
      .width('100%')
      .height(256)
      .backgroundColor('#E5E7EB')
      .borderRadius({ bottomLeft: 40, bottomRight: 40 })
      .linearGradient({
        angle: 180,
        colors: [['rgba(13, 148, 136, 0.8)', 0.0], ['transparent', 1.0]]
      })
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.15)' })
    }
    .width('100%')
    .height('100%')
  }
}
