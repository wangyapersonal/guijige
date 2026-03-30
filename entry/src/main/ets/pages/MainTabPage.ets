import { router } from '@kit.ArkUI';
import { TripListPage } from './TripListPage';
import { HomePage } from './HomePage';
import { ProfilePage } from './ProfilePage';

@Entry
@Component
export struct MainTabPage {
  @State currentIndex: number = 0
  @State showActionSheet: boolean = false

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
    HomePage()
  }

  @Builder
  profileBuilder() {
    ProfilePage()
  }

  build() {
    Column() {
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
      .width('100%')
      .layoutWeight(1)
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
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F9FA')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
    .bindSheet(this.showActionSheet, this.ActionSheetBuilder(), {
      height: 280,
      showClose: false,
      onDisappear: () => {
        this.showActionSheet = false
      }
    })
  }

  @Builder
  ActionSheetBuilder() {
    Column({ space: 0 }) {
      Column({ space: 16 }) {
        Text('开始记录')
          .fontSize(18)
          .fontColor('#1F2937')
          .fontWeight(FontWeight.Bold)

        Column({ space: 8 }) {
          this.ActionSheetItem('sys.media.ohos_ic_public_play', '持续记录', '记录完整轨迹', () => {
            router.pushUrl({
              url: 'pages/RecordPage',
              params: {
                tripId: 'default'
              }
            })
          })

          this.ActionSheetItem('sys.media.ohos_ic_public_map', '单次打卡', '记录当前位置', () => {
            router.pushUrl({
              url: 'pages/PunchRecordPage'
            })
          })
        }
      }
      .width('100%')
      .padding(24)
      .alignItems(HorizontalAlign.Start)

      Button() {
        Text('取消')
          .fontSize(16)
          .fontColor('#6B7280')
      }
      .width('100%')
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.showActionSheet = false
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  ActionSheetItem(icon: string, title: string, subtitle: string, action: () => void) {
    Row({ space: 16 }) {
      Column() {
        Image($r(icon))
          .width(24)
          .height(24)
          .fillColor('#14B8A6')
      }
      .width(48)
      .height(48)
      .borderRadius(16)
      .backgroundColor('rgba(20, 184, 166, 0.1)')

      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontColor('#1F2937')
          .fontWeight(500)

        Text(subtitle)
          .fontSize(12)
          .fontColor('#9CA3AF')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#D1D5DB')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F9FAFB')
    .borderRadius(16)
    .onClick(() => {
      action()
      this.showActionSheet = false
    })
  }
}


