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
    Column() {
      Image($r('app.media.icon'))
        .objectFit(ImageFit.Contain)
        .height(120)
        .width(120)
        .margin({ top: 200, bottom: 40 })
      Text('轨迹记录')
        .fontSize(24)
        .fontWeight(500)
        .lineHeight(32)
        .margin({ bottom: 20 })
      Text('正在加载...')
        .fontSize(16)
        .fontWeight(400)
        .lineHeight(24)
        .margin({ bottom: 40 })
    }
    .height('100%')
    .padding({ left: 40, right: 40 })
    .justifyContent(FlexAlign.Center)
  }
}