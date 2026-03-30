import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

@Component
export struct ProfilePage {
  @State userName: string = '旅行达人';
  @State totalTrips: number = 12;
  @State totalCities: number = 28;
  @State totalDistance: number = 1560;

  private primaryAlpha10 = 'rgba(20, 184, 166, 0.1)';
  private accentAlpha10 = 'rgba(245, 158, 11, 0.1)';

  @Builder
  MenuItem(icon: Resource, title: string, subtitle: string, showArrow: boolean = true) {
    Row({ space: 16 }) {
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(AppColors.Primary)
      }
      .width(48)
      .height(48)
      .borderRadius(16)
      .backgroundColor(this.primaryAlpha10)

      Column({ space: 4 }) {
        Text(title)
          .fontSize(16)
          .fontColor('#1F2937')
          .fontWeight(500)

        if (subtitle) {
          Text(subtitle)
            .fontSize(12)
            .fontColor('#9CA3AF')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (showArrow) {
        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(20)
          .height(20)
          .fillColor('#D1D5DB')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.02)',
      offsetY: 2
    })
    .onClick(() => {
      // 点击事件
    })
  }

  build() {
    Column() {
      // 顶部 Header
      Row() {
        Text('我的')
          .fontSize(24)
          .fontColor(AppColors.TextPrimary)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button() {
          Image($r('sys.media.ohos_ic_public_more'))
            .width(24)
            .height(24)
            .fillColor('#6B7280')
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          // 打开设置页面
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 48, bottom: 24 })

      Scroll() {
        Column({ space: 24 }) {
          // 用户信息卡片
          Row({ space: 16 }) {
            // 头像
            Stack() {
              Column() {
              }
              .width(80)
              .height(80)
              .borderRadius(40)
              .linearGradient({
                angle: 135,
                colors: [[AppColors.Primary, 0.0], ['#0D9488', 1.0]]
              })

              Text(this.userName.charAt(0))
                .fontSize(32)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width(80)
            .height(80)

            Column({ space: 8 }) {
              Text(this.userName)
                .fontSize(20)
                .fontColor('#1F2937')
                .fontWeight(FontWeight.Bold)

              Text('记录世界，发现美好')
                .fontSize(14)
                .fontColor('#6B7280')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(24)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.04)',
            offsetY: 2
          })

          // 统计数据
          Row({ space: 12 }) {
            Column() {
              Text(this.totalTrips.toString())
                .fontSize(24)
                .fontColor(AppColors.Primary)
                .fontWeight(FontWeight.Bold)

              Text('次行程')
                .fontSize(12)
                .fontColor('#9CA3AF')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)

            Column() {
              Text(this.totalCities.toString())
                .fontSize(24)
                .fontColor(AppColors.Accent)
                .fontWeight(FontWeight.Bold)

              Text('个城市')
                .fontSize(12)
                .fontColor('#9CA3AF')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)

            Column() {
              Text(this.totalDistance.toString())
                .fontSize(24)
                .fontColor('#6B7280')
                .fontWeight(FontWeight.Bold)

              Text('公里')
                .fontSize(12)
                .fontColor('#9CA3AF')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(16)
          }
          .width('100%')

          // 功能菜单
          Column({ space: 12 }) {
            Text('功能')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)
              .width('100%')

            this.MenuItem(
              $r('sys.media.ohos_ic_public_add'),
              '我的收藏',
              '收藏的行程和打卡点'
            )

            this.MenuItem(
              $r('sys.media.ohos_ic_public_arrow_down'),
              '数据导出',
              '导出 GPX、KML 文件'
            )

            this.MenuItem(
              $r('sys.media.ohos_ic_public_camera'),
              '相册管理',
              '管理行程照片'
            )

            this.MenuItem(
              $r('sys.media.ohos_ic_public_edit'),
              '意见反馈',
              '帮助我们做得更好'
            )

            this.MenuItem(
              $r('sys.media.ohos_ic_public_arrow_right'),
              '关于我们',
              '版本 1.0.0',
              false
            )
          }
          .width('100%')
        }
        .padding({ left: 24, right: 24, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.Background)
  }
}
