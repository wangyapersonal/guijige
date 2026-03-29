import { router } from '@kit.ArkUI';
import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { APP_NAME } from '../common/constants/Constants';

@Entry
@Component
struct TripListPage {
  @State trips: Trip[] = [];

  async aboutToAppear(): Promise<void> {
    this.trips = await TripService.getInstance().getAllTrips();
  }

  build() {
    Column() {
      // 顶部 Header
      Column({ space: 12 }) {
        Row() {
          Image($r('app.media.icon'))
            .width(40)
            .height(40)

          Blank()

          Button() {
            Row({ space: 4 }) {
              Image($r('sys.media.ohos_ic_public_add'))
                .width(16)
                .height(16)
                .fillColor(Color.White)
              Text('新建')
                .fontSize(14)
                .fontColor(Color.White)
            }
          }
          .height(32)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#0D9488')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(13, 148, 136, 0.2)'
          })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CreateTripPage'
            })
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        Column({ space: 4 }) {
          Text('我的行程')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2937')
          Text('发现世界的精彩，记录每一个瞬间')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .padding({ top: 48, bottom: 24 })
      .backgroundColor(Color.White)
      .shadow({
        radius: 8,
        color: 'rgba(0,0,0,0.05)',
        offsetY: 2
      })

      // 行程列表
      if (this.trips.length === 0) {
        Column() {
          Text('暂无行程')
            .fontSize(18)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 24 }) {
          ForEach(this.trips, (item: Trip) => {
            ListItem() {
              Column() {
                // 封面图区域
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image($r('app.media.bg_launch'))
                    .width('100%')
                    .height(160)
                    .objectFit(ImageFit.Cover)
                    .borderRadius({ topLeft: 24, topRight: 24 })

                  // 渐变遮罩
                  Column() {
                    LinearGradient({
                      angle: 180,
                      colors: [['rgba(0,0,0,0.6)', 0.0], ['transparent', 1.0]]
                    })
                  }
                  .width('100%')
                  .height('100%')
                  .borderRadius({ topLeft: 24, topRight: 24 })

                  // 标题
                  Text(item.name)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .margin({ left: 16, right: 16, bottom: 16 })
                    .shadow({
                      radius: 4,
                      color: 'rgba(0,0,0,0.5)'
                    })
                }

                // 信息区域
                Column({ space: 12 }) {
                  Row({ space: 8 }) {
                    Image($r('sys.media.ohos_ic_public_location_on'))
                      .width(16)
                      .height(16)
                      .fillColor('#0D9488')
                    Text(item.destination || '未设置目的地')
                      .fontSize(14)
                      .fontColor('#4B5563')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 8 }) {
                    Image($r('sys.media.ohos_ic_public_calendar'))
                      .width(14)
                      .height(14)
                      .fillColor('#9CA3AF')
                    Text(`${new Date(item.startDate).toLocaleDateString()} - ${new Date(item.endDate ?? 0).toLocaleDateString()}`)
                      .fontSize(12)
                      .fontColor('#9CA3AF')
                  }
                  .alignItems(VerticalAlign.Center)
                }
                .padding(16)
              }
              .backgroundColor(Color.White)
              .borderRadius(24)
              .shadow({
                radius: 8,
                color: 'rgba(0,0,0,0.05)'
              })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/TripDetailPage',
                  params: {
                    tripId: item.id
                  }
                })
              })
            }
          }, (item: Trip) => item.id)
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 24 })
      }

      Blank()

      // 底部提示
      Text('没有更多行程了')
        .fontSize(14)
        .fontColor('#9CA3AF')
        .padding({ top: 32, bottom: 32 })
    }
    .width('100%')
    .backgroundColor('#F7F9FA')
  }
}
