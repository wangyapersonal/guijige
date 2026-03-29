import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/TripListPage'
      });
    }, 2000);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图片
      Image($r('app.media.bg_launch'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 渐变遮罩
      Column() {
        LinearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.2)', 0.0], ['rgba(0,0,0,0.6)', 1.0]]
        })
      }
      .width('100%')
      .height('100%')

      // 玻璃态卡片
      Column({ space: 24 }) {
        // Logo
        Image($r('app.media.icon'))
          .width(80)
          .height(80)

        // 标语
        Text('记录世界的每一个角落')
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.9)')
          .fontWeight(500)

        // 开启旅程按钮
        Button() {
          Row({ space: 8 }) {
            Text('开启旅程')
              .fontSize(18)
              .fontWeight(600)
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(20)
              .height(20)
              .fillColor(Color.White)
          }
        }
        .width('100%')
        .height(48)
        .backgroundColor('rgba(255,255,255,0.9)')
        .borderRadius(24)
        .shadow({
          radius: 16,
          color: 'rgba(0,0,0,0.1)',
          offsetY: 8
        })

        // 服务条款
        Text('轻触按钮即表示同意服务条款')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.7)')
      }
      .padding(32)
      .margin({ left: 24, right: 24 })
      .borderRadius(32)
      .backdropBlur(20)
      .backgroundColor('rgba(255,255,255,0.2)')
      .border({ width: 1, color: 'rgba(255,255,255,0.4)' })
    }
    .width('100%')
    .height('100%')
  }
}
