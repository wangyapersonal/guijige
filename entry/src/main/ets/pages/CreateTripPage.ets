import { router } from '@kit.ArkUI';
import { Trip, TripType, TripStatus } from '../models/Trip';
import { TripService } from '../services/TripService';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Entry
@Component
struct CreateTripPage {
  @State tripName: string = '';
  @State startDate: string = '';
  @State endDate: string = '';
  @State destinations: string[] = [];
  @State selectedCountry: string = '';
  @State selectedCity: string = '';
  @State notes: string = '';

  build() {
    Column() {
      // 顶部 Header
      Row() {
        Button() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(24)
            .height(24)
            .fillColor('#4B5563')
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Text('新建行程')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')

        Blank()
      }
      .width('100%')
      .padding(24)
      .backgroundColor(Color.White)
      .border({ width: { bottom: 1 }, color: '#F3F4F6' })

      Scroll() {
        Column({ space: 24 }) {
          // 封面上传区域
          Column() {
            Image($r('sys.media.ohos_ic_public_add'))
              .width(32)
              .height(32)
              .fillColor('#D1D5DB')
            Text('上传行程封面')
              .fontSize(14)
              .fontColor('#9CA3AF')
              .fontWeight(500)
          }
          .width('100%')
          .height(160)
          .justifyContent(FlexAlign.Center)
          .border({ width: 2, color: '#E5E7EB', style: BorderStyle.Dashed })
          .borderRadius(16)
          .backgroundColor('#F9FAFB')

          // 行程名称
          Column({ space: 8 }) {
            Text('行程名称')
              .fontSize(14)
              .fontColor('#374151')
              .fontWeight(500)

            TextInput({ placeholder: '例如：浪漫巴黎之旅' })
              .backgroundColor('#F9FAFB')
              .borderRadius(12)
              .placeholderColor('#9CA3AF')
              .onChange((value: string) => {
                this.tripName = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 日期选择
          Row({ space: 16 }) {
            Column({ space: 8 }) {
              Text('出发日期')
                .fontSize(14)
                .fontColor('#374151')
                .fontWeight(500)

              TextInput({ text: this.startDate })
                .backgroundColor('#F9FAFB')
                .borderRadius(12)
                .type(InputType.Normal)
                .onChange((value: string) => {
                  this.startDate = value;
                })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('结束日期')
                .fontSize(14)
                .fontColor('#374151')
                .fontWeight(500)

              TextInput({ text: this.endDate })
                .backgroundColor('#F9FAFB')
                .borderRadius(12)
                .type(InputType.Normal)
                .onChange((value: string) => {
                  this.endDate = value;
                })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          // 多目的地选择
          Column({ space: 16 }) {
            Row({ space: 8 }) {
              Image($r('sys.media.ohos_ic_public_location'))
                .width(16)
                .height(16)
                .fillColor('#0D9488')
              Text('途径目的地')
                .fontSize(14)
                .fontColor('#374151')
                .fontWeight(500)
              Text('*')
                .fontSize(14)
                .fontColor('#EF4444')
            }
            .alignItems(VerticalAlign.Center)

            // 已选目的地标签
            if (this.destinations.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.destinations, (dest: string) => {
                  Row({ space: 6 }) {
                    Text(dest)
                      .fontSize(14)
                      .fontColor('#0D9488')
                      .fontWeight(500)
                    Button() {
                      Image($r('sys.media.ohos_ic_public_cancel'))
                        .width(14)
                        .height(14)
                        .fillColor('#14B8A6')
                    }
                    .type(ButtonType.Normal)
                    .backgroundColor('rgba(20, 184, 166, 0.1)')
                    .borderRadius(8)
                    .height(24)
                    .padding({ left: 6, right: 6 })
                    .onClick(() => {
                      this.destinations = this.destinations.filter(d => d !== dest);
                    })
                  }
                  .alignItems(VerticalAlign.Center)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor('#F0FDFA')
                  .border({ width: 1, color: '#CCFBF1' })
                  .borderRadius(8)
                }, (dest: string) => dest)
              }
              .width('100%')
            }

            // 目的地选择器
            Row({ space: 8 }) {
              Select([
                { value: '选择国家' },
                { value: '中国' },
                { value: '日本' },
                { value: '法国' },
                { value: '意大利' },
                { value: '瑞士' },
                { value: '英国' },
                { value: '美国' },
                { value: '泰国' }
              ])
              .selectedOptionFont({ size: 14 })
              .optionFont({ size: 14 })
              .optionWidth(200)
              .optionHeight(300)
              .backgroundColor('#F9FAFB')
              .onSelect((index: number, text?: string | undefined) => {
                if (index === 0) {
                  this.selectedCountry = '';
                  this.selectedCity = '';
                } else {
                  this.selectedCountry = text || '';
                  this.selectedCity = '';
                }
              })

              Select([
                { value: '选择城市' }
              ])
              .selectedOptionFont({ size: 14 })
              .optionFont({ size: 14 })
              .optionWidth(200)
              .optionHeight(300)
              .backgroundColor('#F9FAFB')
              .enabled(this.selectedCountry !== '')
              .onSelect((index: number, text?: string | undefined) => {
                if (index === 0) {
                  this.selectedCity = '';
                } else {
                  this.selectedCity = text || '';
                }
              })

              Button() {
                Image($r('sys.media.ohos_ic_public_add'))
                  .width(20)
                  .height(20)
                  .fillColor('#6B7280')
              }
              .type(ButtonType.Normal)
              .backgroundColor('#F9FAFB')
              .borderRadius(12)
              .width(48)
              .height(48)
              .enabled(this.selectedCountry !== '' && this.selectedCity !== '')
              .onClick(() => {
                if (this.selectedCountry && this.selectedCity) {
                  const dest = `${this.selectedCountry} · ${this.selectedCity}`;
                  if (!this.destinations.includes(dest)) {
                    this.destinations.push(dest);
                  }
                  this.selectedCity = '';
                }
              })
            }
            .width('100%')

            if (this.destinations.length === 0) {
              Text('请至少添加一个目的地城市')
                .fontSize(12)
                .fontColor('#9CA3AF')
            }
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#F3F4F6' })
          .shadow({ radius: 4, color: 'rgba(0,0,0,0.02)' })

          // 备注说明
          Column({ space: 8 }) {
            Text('备注说明 (可选)')
              .fontSize(14)
              .fontColor('#374151')
              .fontWeight(500)

            TextArea({ placeholder: '记录一些旅行心得或重要事项...' })
              .backgroundColor('#F9FAFB')
              .borderRadius(12)
              .placeholderColor('#9CA3AF')
              .onChange((value: string) => {
                this.notes = value;
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          // 保存按钮
          Button('保存行程')
            .width('100%')
            .height(56)
            .fontSize(18)
            .fontWeight(600)
            .backgroundColor(this.destinations.length > 0 ? '#0D9488' : '#D1D5DB')
            .borderRadius(16)
            .shadow({ radius: 16, color: 'rgba(13, 148, 136, 0.2)' })
            .onClick(() => {
              this.saveTrip();
            })
        }
        .width('100%')
        .padding(24)
      }
      .layoutWeight(1)

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  private async saveTrip(): Promise<void> {
    if (this.destinations.length === 0) {
      return;
    }

    const trip: Trip = {
      id: generateId(),
      name: this.tripName || '未命名行程',
      type: TripType.OTHER,
      destination: this.destinations.join(','),
      startDate: this.startDate ? new Date(this.startDate).getTime() : Date.now(),
      notes: this.notes || undefined,
      status: TripStatus.ACTIVE,
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    await TripService.getInstance().createTrip(trip);
    router.back();
  }
}
