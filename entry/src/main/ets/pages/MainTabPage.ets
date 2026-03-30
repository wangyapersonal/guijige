import { router } from '@kit.ArkUI';
import { TripListPage } from './TripListPage';
import { HomePage } from './HomePage';

interface TabItem {
  title: string;
  unselectedIcon: string;
  selectedIcon: string;
}

@Entry
@Component
export struct MainTabPage {
  @State currentIndex: number = 0
  @State showActionSheet: boolean = false

  private messageList: TabItem[] = [
    { title: '行程', unselectedIcon: '📋', selectedIcon: '📋' },
    { title: '我的', unselectedIcon: '👤', selectedIcon: '👤' }
  ]

  @Builder
  FABButton() {
    Button() {
      Column() {
        Image($r('sys.media.ohos_ic_public_play'))
          .width(28)
          .height(28)
          .fillColor(Color.White)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width(64)
    .height(64)
    .borderRadius(32)
    .linearGradient({
      angle: 135,
      colors: [['#14B8A6', 0.0], ['#0D9488', 1.0]]
    })
    .shadow({
      radius: 16,
      color: 'rgba(20, 184, 166, 0.4)',
      offsetY: 8
    })
    .onClick(() => {
      this.showActionSheet = true
    })
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
            });
          })

          this.ActionSheetItem('sys.media.ohos_ic_public_map', '单次打卡', '记录当前位置', () => {
            router.pushUrl({
              url: 'pages/PunchRecordPage'
            });
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

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          TripListPage()
        }
        .tabBar(this.TabBuilder(0))

        TabContent() {
          HomePage()
        }
        .tabBar(this.TabBuilder(1))
      }
      .width('100%')
      .height('100%')
      .barBackgroundColor(Color.White)
      .onChange((index: number) => {
        this.currentIndex = index
      })

      this.FABButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9FAFB')
  }
}
