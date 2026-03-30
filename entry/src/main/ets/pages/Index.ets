import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

@Entry
@Component
struct Index {
  @State private bgTranslateX: number = -50;
  @State private cardOpacity: number = 0;
  @State private cardTranslateY: number = 20;

  aboutToAppear() {
    // ✅ 1. 背景图横向移动动画（8秒内从 -50 移动到 50）
    animateTo({
      duration: 8000,
      curve: Curve.Linear
    }, () => {
      this.bgTranslateX = 50;
    });

    // ✅ 2. 卡片淡入动画（延迟 0.3 秒）
    setTimeout(() => {
      animateTo({
        duration: 800,
        curve: Curve.EaseOut
      }, () => {
        this.cardOpacity = 1;
        this.cardTranslateY = 0;
      });
    }, 300);
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // ✅ 1. 背景图（使用 Image 组件，带横向移动动画）
      Image($r('app.media.splash_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .translate({ x: this.bgTranslateX })

      // ✅ 2. 渐变遮罩
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

      // ✅ 3. 玻璃态卡片（带淡入动画）
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
