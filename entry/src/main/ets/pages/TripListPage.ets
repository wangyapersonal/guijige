import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { APP_NAME } from '../common/constants/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct TripListPage {
  @State trips: Trip[] = [];

  async aboutToAppear(): Promise<void> {
    this.trips = await TripService.getInstance().getAllTrips();
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text(APP_NAME)
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding(20)

        Divider()
          .height(1)
          .width('100%')
          .color(Color.Grey)

        Button('新建行程')
          .width('60%')
          .height(40)
          .fontSize(16)
          .fontWeight(500)
          .backgroundColor('#0A59F7')
          .margin({ top: 12, bottom: 12 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CreateTripPage'
            })
          })

        if (this.trips.length === 0) {
          Column() {
            Text('暂无行程')
              .fontSize(18)
              .fontColor('#99182431')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.trips, (item: Trip) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(`${new Date(item.startDate).toLocaleDateString()} - ${new Date(item.endDate ?? 0).toLocaleDateString()}`)
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
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/TripDetailPage',
                  params: {
                    tripId: item.id
                  }
                })
              })
            }, (item: Trip) => item.id)
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
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
