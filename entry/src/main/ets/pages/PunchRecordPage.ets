import { router } from '@kit.ArkUI';
import { CheckInPoint, CheckInType } from '../models/CheckInPoint';
import { CheckInService } from '../services/CheckInService';
import { AppColors } from '../common/constants/Colors';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct PunchRecordPage {
  @State locationName: string = '埃菲尔铁塔';
  @State description: string = '';
  @State latitude: number = 48.8584;
  @State longitude: number = 2.2945;
  @State isDragging: boolean = false;

  private accentAlpha10 = 'rgba(245, 158, 11, 0.1)';
  private accentAlpha30 = 'rgba(245, 158, 11, 0.3)';

  async saveCheckIn(): Promise<void> {
    try {
      if (!this.locationName.trim()) {
        console.warn('Location name is required');
        return;
      }

      const checkIn: CheckInPoint = {
        id: generateId(),
        tripId: 'default',
        name: this.locationName,
        type: CheckInType.MANUAL,
        latitude: this.latitude,
        longitude: this.longitude,
        timestamp: Date.now(),
        createdAt: Date.now()
      };

      await CheckInService.getInstance().createCheckIn(checkIn);
      router.back();
    } catch (error) {
      console.error('Failed to save check-in:', error);
    }
  }

  build() {
    Column() {
      // 返回按钮（固定在顶部）
      Row() {
        Button() {
          Column() {
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor(Color.White)
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.back();
        })

        Blank()

        Text('单次打卡')
          .fontSize(18)
          .fontColor('#1F2937')
          .fontWeight(FontWeight.Bold)

        Blank()

        Column() {
        }
        .width(40)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 48 })
      .position({ x: 0, y: 0 })
      .zIndex(10)

      // 地图区域
      Stack() {
        // 模拟地图背景（网格）
        Column() {
          // 这里应该放真实地图，现在用网格占位
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#E5E7EB')

        // 拖拽提示
        Column() {
          Text('拖动地图选择位置')
            .fontSize(14)
            .fontColor('#1F2937')
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .borderRadius(20)
        .backdropBlur(10)
        .position({ x: '50%', y: 96 })
        .translate({ x: '-50%' })

        // 中心定位针
        Column() {
          Image($r('sys.media.ohos_ic_public_location'))
            .width(48)
            .height(48)
            .fillColor(AppColors.Accent)

          // 阴影
          Column() {
          }
          .width(16)
          .height(6)
          .backgroundColor('rgba(0, 0, 0, 0.2)')
          .borderRadius(3)
          .blur(4)
          .margin({ top: -8 })
        }
        .position({ x: '50%', y: '45%' })
        .translate({ x: '-50%', y: '-100%' })
      }
      .width('100%')
      .layoutWeight(1)

      // 底部面板
      Column({ space: 24 }) {
        // 当前位置
        Row({ space: 16 }) {
          Column() {
            Image($r('sys.media.ohos_ic_public_location'))
              .width(24)
              .height(24)
              .fillColor(AppColors.Accent)
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor(this.accentAlpha10)

          Column({ space: 4 }) {
            Text('当前定位')
              .fontSize(14)
              .fontColor('#9CA3AF')
              .fontWeight(500)

            TextInput({ text: this.locationName })
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2937')
              .backgroundColor(Color.Transparent)
              .borderWidth(0)
              .onChange((value: string) => {
                this.locationName = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        // 心情描述
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Image($r('sys.media.ohos_ic_public_message'))
              .width(16)
              .height(16)
              .fillColor('#9CA3AF')

            Text('心情描述')
              .fontSize(14)
              .fontColor('#9CA3AF')
          }

          TextArea({ placeholder: '记录此刻的感受...' })
            .fontSize(14)
            .fontColor('#374151')
            .backgroundColor('#F9FAFB')
            .borderRadius(16)
            .border({ width: 1, color: '#E5E7EB' })
            .placeholderColor('#9CA3AF')
            .height(100)
            .onChange((value: string) => {
              this.description = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 操作按钮
        Row({ space: 12 }) {
          Button() {
            Row({ space: 8 }) {
              Image($r('sys.media.ohos_ic_public_camera'))
                .width(20)
                .height(20)
                .fillColor(AppColors.Primary)

              Text('添加照片')
                .fontSize(16)
                .fontColor(AppColors.Primary)
            }
          }
          .layoutWeight(1)
          .height(52)
          .backgroundColor(Color.White)
          .borderRadius(26)
          .border({ width: 2, color: AppColors.Primary })

          Button() {
            Text('确认打卡')
              .fontSize(16)
              .fontColor(Color.White)
              .fontWeight(500)
          }
          .layoutWeight(1)
          .height(52)
          .borderRadius(26)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.Primary, 0.0], ['#0D9488', 1.0]]
          })
          .shadow({
            radius: 16,
            color: 'rgba(20, 184, 166, 0.3)',
            offsetY: 8
          })
          .onClick(() => {
            this.saveCheckIn();
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 32, topRight: 32 })
      .shadow({
        radius: 32,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetY: -16
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F9FA')
  }
}
