import { router } from '@kit.ArkUI';
import { TripListPage } from './TripListPage';
import { ProfilePage } from './ProfilePage';

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
    ProfilePage()
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


