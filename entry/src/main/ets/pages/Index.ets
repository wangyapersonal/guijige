import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    setTimeout(() => {
      router.replaceUrl({
        url: 'pages/TripListPage'
      })
    }, 2000);
  }

  build() {
    Column() {
      Image($r('sys.media.ohos_ic_public_app_logo'))
        .objectFit(ImageFit.Contain)
        .height($r('app.integer.login_logo_image_height'))
        .width($r('app.integer.login_logo_image_width'))
        .margin({ top: $r('app.integer.login_logo_margin_top'), bottom: $r('app.integer.login_logo_margin_bottom') })
      Text($r('app.string.login_page'))
        .fontSize($r('app.integer.login_page_font_size'))
        .fontWeight(500)
        .lineHeight($r('app.integer.login_page_text_height'))
        .margin({ bottom: $r('app.integer.login_page_margin_bottom') })
      Text($r('app.string.login_page'))
        .fontSize($r('app.integer.login_page_font_size'))
        .fontWeight(500)
        .lineHeight($r('app.integer.login_page_text_height'))
        .margin({ bottom: $r('app.integer.login_page_margin_bottom') })
    }
    .height('100%')
    .padding({ left: $r('app.integer.login_page_padding_left'), right: $r('app.integer.login_page_padding_right') })
  }
}
