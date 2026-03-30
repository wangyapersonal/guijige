import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

interface Stat {
  value: number;
  label: string;
  color: string;
}

@Component
export struct HomePage {
  @State showMenu: boolean = false;
  @State currentMonth: string = '';
  @State stats: Stat[] = [
    { value: 12, label: '次行程', color: AppColors.Primary },
    { value: 8, label: '个城市', color: AppColors.Accent },
    { value: 156, label: '公里', color: '#6B7280' }
  ];

  private primaryAlpha10 = 'rgba(20, 184, 166, 0.1)';
  private primaryAlpha20 = 'rgba(20, 184, 166, 0.2)';

  aboutToAppear() {
    const now = new Date();
    this.currentMonth = `${now.getFullYear()}年${now.getMonth() + 1}月`;
  }

  @Builder
  StatsCard() {
    Column() {
      Text(`${this.currentMonth}统计`)
        .fontSize(14)
        .fontColor(AppColors.TextSecondary)
        .margin({ bottom: 16 })

      Row() {
        ForEach(this.stats, (stat: Stat) => {
          Column() {
            Text(stat.value.toString())
              .fontSize(24)
              .fontColor(stat.color)
              .fontWeight(FontWeight.Bold)

            Text(stat.label)
              .fontSize(12)
              .fontColor(AppColors.TextTertiary)
              .margin({ top: 4 })
          }
          .layoutWeight(1)
        }, (stat: Stat) => stat.label)
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(24)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetY: 2
    })
  }

  @Builder
  RecentTripCard(title: string, date: string, index: number) {
    Row() {
      // 图标
      Column() {
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .linearGradient({
        angle: 135,
        colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
      })

      // 信息
      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontColor(AppColors.TextPrimary)
          .fontWeight(500)

        Text(date)
          .fontSize(12)
          .fontColor(AppColors.TextSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 状态标签
      Column() {
      }
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(this.primaryAlpha10)
      .borderRadius(16)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetY: 2
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/TripDetailPage',
        params: { tripId: '1' }
      });
    })
  }

  @Builder
  FloatingMenu() {
    if (this.showMenu) {
      Stack() {
        // 遮罩层
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.2)')
        .onClick(() => {
          this.showMenu = false;
        })

        // 菜单
        Column({ space: 12 }) {
          // 持续记录
          Row() {
            Column() {
            }
            .width(40)
            .height(40)
            .borderRadius(20)
            .backgroundColor('#EF4444')

            Text('持续记录')
              .fontSize(16)
              .fontColor(AppColors.TextPrimary)
              .fontWeight(500)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.1)'
          })
          .onClick(() => {
            this.showMenu = false;
            router.pushUrl({
              url: 'pages/RecordPage'
            });
          })

          // 单次打卡
          Row() {
            Column() {
            }
            .width(40)
            .height(40)
            .borderRadius(20)
            .backgroundColor(AppColors.Accent)

            Text('单次打卡')
              .fontSize(16)
              .fontColor(AppColors.TextPrimary)
              .fontWeight(500)
              .margin({ left: 12 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.1)'
          })
          .onClick(() => {
            this.showMenu = false;
            router.pushUrl({
              url: 'pages/PunchRecordPage'
            });
          })
        }
        .width(200)
        .position({ x: '50%', y: '70%' })
        .translate({ x: '-50%', y: '-100%' })
      }
      .width('100%')
      .height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部 Header
        Column({ space: 12 }) {
          Text('轨迹哥')
            .fontSize(24)
            .fontColor(AppColors.TextPrimary)
            .fontWeight(FontWeight.Bold)

          Text('记录你的精彩旅程')
            .fontSize(14)
            .fontColor(AppColors.TextSecondary)
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 48, bottom: 24 })
        .alignItems(HorizontalAlign.Start)

        // 主内容区
        Scroll() {
          Column({ space: 16 }) {
            // 统计卡片
            this.StatsCard()

            // 最近行程
            Column({ space: 12 }) {
              Row() {
                Text('最近行程')
                  .fontSize(14)
                  .fontColor(AppColors.TextSecondary)

                Blank()

                Text('查看全部')
                  .fontSize(12)
                  .fontColor(AppColors.Primary)
                  .onClick(() => {
                    // 切换到行程Tab
                  })
              }
              .width('100%')

              ForEach(
                ['巴黎浪漫之旅', '东京美食探索', '圣托里尼蜜月'],
                (title: string, index: number) => {
                  this.RecentTripCard(title, '2026年3月', index);
                },
                (title: string) => title
              )
            }
            .width('100%')
          }
          .padding({ left: 24, right: 24, top: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [[this.primaryAlpha10, 0.0], ['transparent', 1.0]]
      })

      // 浮动菜单
      this.FloatingMenu()
    }
    .width('100%')
    .height('100%')
  }
}
