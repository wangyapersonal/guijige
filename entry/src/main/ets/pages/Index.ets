import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

@Entry
@Component
struct Index {
  build() {
    Stack({ alignContent: Alignment.Center }) {
      // ✅ 1. 添加背景图（Unsplash 风景图）
      Image('https://images.unsplash.com/photo-1620841611656-0cd634390d48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzY2VuaWMlMjBtb3VudGFpbiUyMGxhbmRzY2FwZSUyMHRyYXZlbHxlbnwxfHx8fDE3NzQ4Mzk0OTd8MA&ixlib=rb-4.1.0&q=80&w=1080')
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // ✅ 2. 渐变遮罩
      Column() {
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [['rgba(0, 0, 0, 0.2)', 0.0], ['rgba(0, 0, 0, 0.1)', 0.5], ['rgba(0, 0, 0, 0.4)', 1.0]]
      })

      // 玻璃态卡片
      Column({ space: 24 }) {
        // Logo 区域（圆形渐变背景）
        Stack() {
          // 圆形渐变背景
          Column() {
          }
          .width(96)
          .height(96)
          .borderRadius(48)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
          })
          .shadow({
            radius: 24,
            color: 'rgba(20, 184, 166, 0.3)',
            offsetY: 8
          })

          // Logo 图标
          Image($r('app.media.icon'))
            .width(60)
            .height(60)
        }
        .width(96)
        .height(96)

        // 品牌名称
        Column({ space: 4 }) {
          Text('轨迹哥')
            .fontSize(32)
            .fontColor(AppColors.TextPrimary)
            .fontWeight(FontWeight.Bold)

          Text('Journey Tracker')
            .fontSize(12)
            .fontColor(AppColors.TextSecondary)
            .letterSpacing(2)
        }

        // 标语
        Text('记录世界的每一个角落')
          .fontSize(14)
          .fontColor(AppColors.TextSecondary)
          .fontWeight(500)

        // 开启旅程按钮
        Button() {
          Row({ space: 8 }) {
            Text('开启旅程')
              .fontSize(18)
              .fontWeight(600)
              .fontColor(Color.White)
            Image($r('sys.media.ohos_ic_public_arrow_right'))
              .width(20)
              .height(20)
              .fillColor(Color.White)
          }
        }
        .width('100%')
        .height(52)
        .borderRadius(26)
        .linearGradient({
          angle: 135,
          colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
        })
        .shadow({
          radius: 16,
          color: 'rgba(20, 184, 166, 0.3)',
          offsetY: 8
        })
        .onClick(() => {
          router.replaceUrl({
            url: 'pages/MainTabPage'
          });
        })

        // 服务条款
        Text('继续使用即表示同意服务条款和隐私政策')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.8)')
      }
      .padding(40)
      .margin({ left: 24, right: 24 })
      .borderRadius(24)  // ✅ 3. 修改圆角 48px → 24px
      .backdropBlur(40)
      .backgroundColor('rgba(255, 255, 255, 0.85)')
      .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
      .shadow({  // ✅ 4. 调整阴影参数
        radius: 24,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetY: 12
      })
    }
    .width('100%')
    .height('100%')
  }
}
