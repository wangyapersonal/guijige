import { router } from '@kit.ArkUI';
import { AppColors } from '../common/constants/Colors';

@Entry
@Component
struct Index {
  // 背景X偏移量（控制移动）
  @State private bgOffsetX: number = 0;
  // 卡片透明度
  @State private cardOpacity: number = 0;
  // 卡片Y偏移
  @State private cardTranslateY: number = 30;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景层（单图平移）
      Stack() {
        Image($r('app.media.splash_background'))
          .width('120%')  // 宽度大于屏幕，有移动空间
          .height('100%')
          .objectFit(ImageFit.Cover)
          .translate({ x: this.bgOffsetX })
      }
      .width('100%')
      .height('100%')
      .clip(true)  // 裁掉屏幕外部分

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
    .onAppear(() => {
      this.startBgAnimation();
      this.startCardAnimation();
    })
  }

  // 启动背景平移动画（参考示例代码）
  startBgAnimation() {
    const uiContext = this.getUIContext();

    const animate = () => {
      // 1) 复位：回到起始点（无动画，瞬间跳）
      this.bgOffsetX = 0;

      // 2) 缓慢左移（动画）
      uiContext.animateTo({
        duration: 10000,  // 10秒超慢
        curve: Curve.Linear,  // 匀速
        iterations: 1,
        onFinish: () => {
          animate();  // 结束后立刻重新开始 → 无限循环
        }
      }, () => {
        // 目标：向左移动 20%（图片宽度 120% - 屏幕 100% = 20%）
        this.bgOffsetX = -80;
      });
    };

    animate();  // 启动
  }

  // 启动卡片淡入动画
  startCardAnimation() {
    setTimeout(() => {
      animateTo({
        duration: 600,
        curve: Curve.EaseOut
      }, () => {
        this.cardOpacity = 1;
        this.cardTranslateY = 0;
      });
    }, 500);
  }
}
