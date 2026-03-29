import { router } from '@kit.ArkUI';
import { CheckInPoint, CheckInType } from '../models/CheckInPoint';
import { CheckInService } from '../services/CheckInService';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct PunchRecordPage {
  @State locationName: string = '巴黎埃菲尔铁塔附近';
  @State description: string = '';
  @State latitude: number = 48.8584;
  @State longitude: number = 2.2945;

  build() {
    Column() {
      // 顶部内容区域
      Column() {
        // 顶部标题栏
        Row() {
          Button() {
            Image($r('sys.media.ohos_ic_public_arrow_left'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back();
          })

          Text('位置打卡')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.5)' })

          Blank()
        }
        .width('100%')
        .padding(24)
        .padding({ top: 48 })
        .backgroundColor(Color.Transparent)

        // 交互地图区域
        Stack({ alignContent: Alignment.Top }) {
          Image($r('app.media.bg_map'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(0.8)
            .blendMode(BlendMode.MULTIPLY)

          // 中心定位图标
          Column({ space: 4 }) {
            Text('拖拽地图调整位置')
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor('rgba(0,0,0,0.7)')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .backdropBlur(10)
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.5)' })
            Image($r('sys.media.ohos_ic_public_location_filled'))
              .width(40)
              .height(40)
              .fillColor('#F97316')
            Circle()
              .width(12)
              .height(3)
              .fill('rgba(0,0,0,0.3)')
              .blur(2)
          }
          .position({ x: '50%' })
          .translate({ x: '-50%' })

          // 重新定位按钮
          Button() {
            Image($r('sys.media.ohos_ic_public_location_on'))
              .width(20)
              .height(20)
              .fillColor('#4B5563')
          }
          .type(ButtonType.Normal)
          .width(48)
          .height(48)
          .backgroundColor(Color.White)
          .borderRadius(24)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)' })
          .position({ x: '100%' })
          .translate({ x: '-72' })
          .margin({ bottom: 8 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#E5E7EB')

      // 底部面板
      Column({ space: 24 }) {
        Row({ space: 16 }) {
          Column() {
            Image($r('sys.media.ohos_ic_public_location_filled'))
              .width(24)
              .height(24)
              .fillColor('#F97316')
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#FFEDD5')

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

        // 备注输入
        TextArea({ placeholder: '记录下这一刻的心情或趣事吧...' })
          .fontSize(14)
          .fontColor('#374151')
          .backgroundColor('#F9FAFB')
          .borderRadius(16)
          .border({ width: 1, color: '#F3F4F6' })
          .placeholderColor('#9CA3AF')
          .onChange((value: string) => {
            this.description = value;
          })

        // 确认打卡按钮
        Button('确认打卡')
          .width('100%')
          .height(56)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor(this.locationName ? '#0D9488' : '#D1D5DB')
          .borderRadius(16)
          .shadow({ radius: 16, color: 'rgba(13, 148, 136, 0.3)' })
          .onClick(() => {
            this.saveCheckIn();
          })
      }
      .width('100%')
      .padding(24)
      .borderRadius({ topLeft: 32, topRight: 32 })
      .backgroundColor(Color.White)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)' })
      .margin({ top: -24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F3F4F6')
  }

  private async saveCheckIn(): Promise<void> {
    if (!this.locationName) {
      return;
    }

    const checkIn: CheckInPoint = {
      id: generateId(),
      tripId: '',
      name: this.locationName,
      type: CheckInType.MANUAL,
      latitude: this.latitude,
      longitude: this.longitude,
      timestamp: Date.now(),
      createdAt: Date.now()
    };

    await CheckInService.getInstance().createCheckIn(checkIn);
    router.back();
  }
}
