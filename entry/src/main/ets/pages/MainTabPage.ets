import { router } from '@kit.ArkUI';
import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { TripType } from '../models/Trip';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
export struct MainTabPage {
  @State currentIndex: number = 0

  @Builder
  TabBuilder(index: number) {
    Column() {
      if (this.currentIndex === index) {
        Text(this.messageList[index].selectedIcon)
          .fontSize(24)
          .fontColor('#0D9488')
      } else {
        Text(this.messageList[index].unselectedIcon)
          .fontSize(24)
          .fontColor('#9CA3AF')
      }
      Text(this.messageList[index].title)
        .fontSize(10)
        .lineHeight(14)
        .fontWeight(500)
        .margin({ top: 4 })
    }
  }

  @State messageList: Array<Record<string, string>> = [
    {
      'title': '行程',
      'unselectedIcon': '\uE6CF',
      'selectedIcon': '\uE6D0',
    },
    {
      'title': '发现',
      'unselectedIcon': '\uE6CC',
      'selectedIcon': '\uE6CD',
    },
    {
      'title': '我的',
      'unselectedIcon': '\uE6C9',
      'selectedIcon': '\uE6CA',
    },
  ]

  @Builder
  tripListBuilder() {
    TripListPage()
  }

  @Builder
  discoveryBuilder() {
    Column() {
      Text('发现')
        .fontSize(20)
        .fontColor('#1F2937')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  profileBuilder() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontColor('#1F2937')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        this.tripListBuilder()
      }
      .tabBar(this.TabBuilder(0))

      TabContent() {
        this.discoveryBuilder()
      }
      .tabBar(this.TabBuilder(1))

      TabContent() {
        this.profileBuilder()
      }
      .tabBar(this.TabBuilder(2))
    }
    .onChange((index: number) => {
      this.currentIndex = index
    })
    .width(340)
    .height(56)
    .margin({ left: 24, right: 24, bottom: 16 })
    .backgroundColor(Color.White)
    .barMode(BarMode.Fixed)
    .barOverlap(false)
    .scrollable(false)
    .animationDuration(300)
    .animationCurve(Curve.EaseInOut)
    .divider({
      strokeWidth: 0.5,
      color: '#F1F3F5',
      startMargin: 0,
      endMargin: 0
    })
  }
}

@Component
export struct TripListPage {
  @State trips: Trip[] = [];

  async aboutToAppear(): Promise<void> {
    this.trips = await TripService.getInstance().getAllTrips();

    // 如果没有数据，添加测试数据
    if (this.trips.length === 0) {
      const mockTrips: Trip[] = [
        {
          id: generateId(),
          name: '巴黎浪漫之旅',
          type: TripType.LEISURE,
          startDate: Date.now() - 86400000 * 5,
          endDate: Date.now() - 86400000 * 2,
          destination: '巴黎',
          notes: '埃菲尔铁塔、卢浮宫、塞纳河游船',
          status: 'completed',
          createdAt: Date.now() - 86400000 * 6
        },
        {
          id: generateId(),
          name: '东京美食探索',
          type: TripType.FOOD,
          startDate: Date.now() - 86400000 * 10,
          endDate: Date.now() - 86400000 * 7,
          destination: '东京',
          notes: '寿司、拉面、居酒屋',
          status: 'completed',
          createdAt: Date.now() - 86400000 * 11
        },
        {
          id: generateId(),
          name: '瑞士雪山徒步',
          type: TripType.ADVENTURE,
          startDate: Date.now() + 86400000 * 7,
          endDate: Date.now() + 86400000 * 14,
          destination: '瑞士',
          notes: '少女峰、马特洪峰',
          status: 'planned',
          createdAt: Date.now() - 86400000 * 1
        }
      ];

      for (const trip of mockTrips) {
        await TripService.getInstance().createTrip(trip);
      }

      this.trips = await TripService.getInstance().getAllTrips();
    }
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
                  Column() {
                  }
                  .width('100%')
                  .height(160)
                  .borderRadius({ topLeft: 24, topRight: 24 })
                  .linearGradient({
                    angle: 135,
                    colors: [['#0D9488', 0.0], ['#14B8A6', 0.5], ['#10B981', 1.0]]
                  })
                }
                .height(160)
                .borderRadius({ topLeft: 24, topRight: 24 })

                // 信息区域
                Column({ space: 12 }) {
                  Row({ space: 8 }) {
                    Image($r('sys.media.ohos_ic_public_location'))
                      .width(16)
                      .height(16)
                      .fillColor('#0D9488')
                    Text(item.destination || '未设置目的地')
                      .fontSize(14)
                      .fontColor('#4B5563')
                  }
                  .alignItems(VerticalAlign.Center)

                  Row({ space: 8 }) {
                    Image($r('sys.media.ohos_ic_public_clock'))
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
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(24)
              .shadow({
                radius: 8,
                color: 'rgba(0,0,0,0.04)',
                offsetY: 2
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
        .padding({ left: 24, right: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F9FA')
  }
}
