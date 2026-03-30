import { router } from '@kit.ArkUI';
import { Trip, TripType, TripStatus } from '../models/Trip';
import { TripService } from '../services/TripService';
import { AppColors } from '../common/constants/Colors';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct CreateTripPage {
  @State tripName: string = '';
  @State startDate: number = Date.now();
  @State endDate: number | undefined = undefined;
  @State destination: string = '';
  @State notes: string = '';
  @State tripType: TripType = TripType.OTHER;

  private primaryAlpha10 = 'rgba(20, 184, 166, 0.1)';
  private accentAlpha10 = 'rgba(245, 158, 11, 0.1)';

  async createTrip(): Promise<void> {
    try {
      if (!this.tripName.trim()) {
        console.warn('Trip name is required');
        return;
      }

      const trip: Trip = {
        id: generateId(),
        name: this.tripName,
        type: this.tripType,
        startDate: this.startDate,
        endDate: this.endDate,
        destination: this.destination,
        notes: this.notes,
        status: TripStatus.PLANNING,
        createdAt: Date.now(),
        updatedAt: Date.now()
      };

      await TripService.getInstance().createTrip(trip);
      router.back();
    } catch (error) {
      console.error('Failed to create trip:', error);
    }
  }

  build() {
    Column() {
      // 顶部 Header
      Row() {
        Button() {
          Column() {
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor(Color.Transparent)
        }
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

        Text('新建行程')
          .fontSize(18)
          .fontColor('#1F2937')
          .fontWeight(FontWeight.Bold)

        Blank()
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 48, bottom: 24 })

      Scroll() {
        Column({ space: 32 }) {
          // 封面上传区域
          Column() {
            Column() {
              Image($r('sys.media.ohos_ic_public_add'))
                .width(48)
                .height(48)
                .fillColor('#D1D5DB')

              Text('上传行程封面')
                .fontSize(16)
                .fontColor('#9CA3AF')
                .fontWeight(500)
                .margin({ top: 12 })
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F9FAFB')
          .borderRadius(24)
          .border({ width: 2, color: '#E5E7EB', style: BorderStyle.Dashed })

          // 行程名称
          Column({ space: 12 }) {
            Text('行程名称')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)

            TextInput({ placeholder: '例如：浪漫巴黎之旅' })
              .fontSize(16)
              .fontColor('#1F2937')
              .backgroundColor('#F9FAFB')
              .borderRadius(16)
              .border({ width: 1, color: '#E5E7EB' })
              .padding(16)
              .placeholderColor('#9CA3AF')
              .onChange((value: string) => {
                this.tripName = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 行程类型
          Column({ space: 12 }) {
            Text('行程类型')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)

            Row({ space: 12 }) {
              Button() {
                Text('自驾')
                  .fontSize(14)
                  .fontColor(this.tripType === TripType.DRIVING ? Color.White : '#6B7280')
              }
              .height(36)
              .padding({ left: 20, right: 20 })
              .backgroundColor(this.tripType === TripType.DRIVING ? AppColors.Primary : '#F3F4F6')
              .borderRadius(18)
              .onClick(() => {
                this.tripType = TripType.DRIVING;
              })

              Button() {
                Text('骑行')
                  .fontSize(14)
                  .fontColor(this.tripType === TripType.CYCLING ? Color.White : '#6B7280')
              }
              .height(36)
              .padding({ left: 20, right: 20 })
              .backgroundColor(this.tripType === TripType.CYCLING ? AppColors.Primary : '#F3F4F6')
              .borderRadius(18)
              .onClick(() => {
                this.tripType = TripType.CYCLING;
              })

              Button() {
                Text('徒步')
                  .fontSize(14)
                  .fontColor(this.tripType === TripType.WALKING ? Color.White : '#6B7280')
              }
              .height(36)
              .padding({ left: 20, right: 20 })
              .backgroundColor(this.tripType === TripType.WALKING ? AppColors.Primary : '#F3F4F6')
              .borderRadius(18)
              .onClick(() => {
                this.tripType = TripType.WALKING;
              })

              Button() {
                Text('其他')
                  .fontSize(14)
                  .fontColor(this.tripType === TripType.OTHER ? Color.White : '#6B7280')
              }
              .height(36)
              .padding({ left: 20, right: 20 })
              .backgroundColor(this.tripType === TripType.OTHER ? AppColors.Primary : '#F3F4F6')
              .borderRadius(18)
              .onClick(() => {
                this.tripType = TripType.OTHER;
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 日期选择
          Column({ space: 12 }) {
            Text('出发日期')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)

            Row({ space: 12 }) {
              Column() {
                Image($r('sys.media.ohos_ic_public_clock'))
                  .width(20)
                  .height(20)
                  .fillColor(AppColors.Primary)
              }
              .width(48)
              .height(48)
              .borderRadius(16)
              .backgroundColor(this.primaryAlpha10)

              Text(new Date(this.startDate).toLocaleDateString())
                .fontSize(16)
                .fontColor('#1F2937')
                .layoutWeight(1)

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F9FAFB')
            .borderRadius(16)
            .border({ width: 1, color: '#E5E7EB' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 目的地
          Column({ space: 12 }) {
            Text('目的地')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)

            Row({ space: 12 }) {
              Column() {
                Image($r('sys.media.ohos_ic_public_location'))
                  .width(20)
                  .height(20)
                  .fillColor(AppColors.Accent)
              }
              .width(48)
              .height(48)
              .borderRadius(16)
              .backgroundColor(this.accentAlpha10)

              TextInput({ text: this.destination, placeholder: '例如：法国·巴黎' })
                .fontSize(16)
                .fontColor('#1F2937')
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.destination = value;
                })

              Image($r('sys.media.ohos_ic_public_arrow_right'))
                .width(20)
                .height(20)
                .fillColor('#9CA3AF')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F9FAFB')
            .borderRadius(16)
            .border({ width: 1, color: '#E5E7EB' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 备注说明
          Column({ space: 12 }) {
            Text('备注说明')
              .fontSize(14)
              .fontColor('#6B7280')
              .fontWeight(500)

            TextArea({ placeholder: '添加行程备注（可选）...' })
              .fontSize(14)
              .fontColor('#374151')
              .backgroundColor('#F9FAFB')
              .borderRadius(16)
              .border({ width: 1, color: '#E5E7EB' })
              .placeholderColor('#9CA3AF')
              .height(100)
              .padding(16)
              .onChange((value: string) => {
                this.notes = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 24, right: 24, bottom: 120 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部保存按钮
      Column() {
        Button() {
          Text('保存行程')
            .fontSize(18)
            .fontColor(Color.White)
            .fontWeight(500)
        }
        .width('100%')
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
          this.createTrip();
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 32 })
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .backdropBlur(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F9FA')
  }
}
