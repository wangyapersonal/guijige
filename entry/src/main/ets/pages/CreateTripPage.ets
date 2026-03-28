import { router } from '@kit.ArkUI';
import { Trip, TripType, TripStatus } from '../models/Trip';
import { TripService } from '../services/TripService';
import { TimeUtils } from '../common/utils/TimeUtils';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct CreateTripPage {
  @State tripName: string = '';
  @State tripType: TripType = TripType.WALKING;
  @State destination: string = '';
  @State notes: string = '';

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back()
          })
        Text('新建行程')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      Column() {
        Column() {
          Text('行程名称')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入行程名称' })
            .fontSize(16)
            .onChange((value: string) => {
              this.tripName = value;
            })

          Divider()
            .height(1)
            .width('100%')
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })

        Column() {
          Text('出行方式')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Row() {
            ForEach([TripType.WALKING, TripType.CYCLING, TripType.DRIVING, TripType.OTHER], (type: TripType) => {
              Text(this.getTripTypeName(type))
                .fontSize(14)
                .fontColor(this.tripType === type ? Color.White : '#182431')
                .textAlign(TextAlign.Center)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.tripType === type ? '#0A59F7' : '#F1F3F5')
                .borderRadius(16)
                .onClick(() => {
                  this.tripType = type;
                })
            })
          }

          Divider()
            .height(1)
            .width('100%')
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })

        Column() {
          Text('目的地')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入目的地（可选）' })
            .fontSize(16)
            .onChange((value: string) => {
              this.destination = value;
            })

          Divider()
            .height(1)
            .width('100%')
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })

        Column() {
          Text('备注')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          TextArea({ placeholder: '请输入备注信息（可选）' })
            .fontSize(16)
            .onChange((value: string) => {
              this.notes = value;
            })

          Divider()
            .height(1)
            .width('100%')
            .margin({ top: 12 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
      .borderRadius({
        topLeft: 24,
        topRight: 24
      })
      .padding({
        top: 12,
        bottom: 12
      })

      Button('创建')
        .width('60%')
        .height(40)
        .fontSize(16)
        .fontWeight(500)
        .onClick(() => {
          this.createTrip();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({
      bottom: 24
    })
  }

  private getTripTypeName(type: TripType): string {
    switch (type) {
      case TripType.WALKING:
        return '步行';
      case TripType.CYCLING:
        return '骑行';
      case TripType.DRIVING:
        return '驾车';
      case TripType.OTHER:
        return '其他';
      default:
        return '步行';
    }
  }

  private async createTrip(): Promise<void> {
    if (!this.tripName) {
      return;
    }

    const trip: Trip = {
      id: generateId(),
      name: this.tripName,
      type: this.tripType,
      destination: this.destination || undefined,
      startDate: Date.now(),
      notes: this.notes || undefined,
      status: TripStatus.ACTIVE,
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    await TripService.getInstance().createTrip(trip);
    router.back();
  }
}
