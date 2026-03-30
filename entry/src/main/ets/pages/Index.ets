import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

@Entry
@Component
struct Index {
  @State private bgScale: number = 1.0;
  @State private bgTranslateX: number = -100;
  @State private bgRotate: number = 0;
  @State private cardOpacity: number = 0;
  @State private cardTranslateY: number = 20;

  aboutToAppear() {
    // 缩放动画（5秒内 1.0 → 1.15）
    animateTo({
      duration: 5000,
      curve: Curve.EaseInOut
    }, () => {
      this.bgScale = 1.15;
      this.bgTranslateX = 0;
      this.bgRotate = 360;
    });

    // 渐变动画（3秒循环，3次 0.5 → 0.8 → 0.5）
    animateTo({
      duration: 5000,
      curve: Curve.Linear
    }, () => {
      this.bgTranslateX = 100;
      this.bgRotate = 360;
    });

    // 缩放动画反向（5秒内 1.15 → 1.0）
    animateTo({
      duration: 5000,
      curve: Curve.EaseInOut
    }, () => {
      this.bgScale = 1.0;
      this.bgTranslateX = -100;
      this.bgRotate = 0;
    });
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图（使用 Image 组件)
      Image($r('app.media.splash_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .scale({ x: this.bgScale, y: this.bgScale })
        .translate({ x: this.bgTranslateX })
        .rotate({ z: this.bgRotate })

      // 渐变遮罩
      Column() {
      }
      .width('100%')
      .height('100%')
      .linearGradient({
        angle: 180,
        colors: [
          ['rgba(0, 0, 0, 0.2)', 0.0],
          ['rgba(0, 0, 0, 0.1)', 0.5],
          ['rgba(0, 0, 0, 0.4)', 1.0]
        ]
      })

      // 玻璃态卡片
      Column({ space: 24 }) {
        // Logo 区域
        Stack() {
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

          Image($r('app.media.icon'))
            .width(60)
            .height(60)
        }

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

        Text('记录世界的每一个角落')
          .fontSize(14)
          .fontColor(AppColors.TextSecondary)
          .fontWeight(500)

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

        Text('继续使用即表示同意服务条款和隐私政策')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.8)')
      }
      .padding(40)
      .margin({ left: 24, right: 24 })
      .borderRadius(24)
      .backdropBlur(40)
      .backgroundColor('rgba(255, 255, 255, 0.85)')
      .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
      .shadow({
        radius: 24,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetY: 12
      })
      .opacity(this.cardOpacity)
      .translate({ y: this.cardTranslateY })
    }
    .width('100%')
    .height('100%')
  }
}
