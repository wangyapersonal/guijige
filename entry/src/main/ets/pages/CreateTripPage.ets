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
  @State selectedCountries: string[] = [];
  @State selectedCities: string[] = [];
  @State showCountryPicker: boolean = false;
  @State showCityPicker: boolean = false;

  private primaryAlpha10 = 'rgba(20, 184, 166, 0.1)';
  private accentAlpha10 = 'rgba(245, 158, 11, 0.1)';

  private countries: string[] = ['中国', '日本', '韩国', '泰国', '新加坡', '马来西亚', '法国', '德国', '意大利', '英国', '美国', '加拿大'];
  private cities: Record<string, string[]> = {
    '中国': ['北京', '上海', '广州', '深圳', '成都', '杭州', '西安', '厦门'],
    '日本': ['东京', '大阪', '京都', '北海道', '福冈', '名古屋'],
    '韩国': ['首尔', '釜山', '济州岛', '仁川', '大邱'],
    '泰国': ['曼谷', '清迈', '普吉岛', '芭提雅', '甲米'],
    '新加坡': ['新加坡'],
    '马来西亚': ['吉隆坡', '槟城', '马六甲', '沙巴'],
    '法国': ['巴黎', '尼斯', '里昂', '马赛', '普罗旺斯'],
    '德国': ['柏林', '慕尼黑', '法兰克福', '汉堡', '科隆'],
    '意大利': ['罗马', '米兰', '威尼斯', '佛罗伦萨', '那不勒斯'],
    '英国': ['伦敦', '曼彻斯特', '爱丁堡', '利物浦', '牛津'],
    '美国': ['纽约', '洛杉矶', '旧金山', '芝加哥', '拉斯维加斯'],
    '加拿大': ['多伦多', '温哥华', '蒙特利尔', '渥太华', '卡尔加里']
  };

  async createTrip(): Promise<void> {
    try {
      if (!this.tripName.trim()) {
        console.warn('Trip name is required');
        return;
      }

      // 构建目的地字符串
      const destinationParts: string[] = [];
      if (this.selectedCountries.length > 0) {
        destinationParts.push(this.selectedCountries.join('、'));
      }
      if (this.selectedCities.length > 0) {
        destinationParts.push(this.selectedCities.join('、'));
      }
      this.destination = destinationParts.join('·') || '未设置目的地';

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

              Column({ space: 8 }) {
                // 已选国家标签
                if (this.selectedCountries.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.selectedCountries, (country: string) => {
                      Row({ space: 4 }) {
                        Text(country)
                          .fontSize(14)
                          .fontColor(AppColors.TextPrimary)

                        Image($r('sys.media.ohos_ic_public_cancel'))
                          .width(16)
                          .height(16)
                          .fillColor('#9CA3AF')
                          .onClick(() => {
                            this.selectedCountries = this.selectedCountries.filter(c => c !== country);
                            this.selectedCities = [];
                          })
                      }
                      .padding({ left: 12, right: 8, top: 6, bottom: 6 })
                      .backgroundColor('rgba(20, 184, 166, 0.1)')
                      .borderRadius(16)
                    }, (country: string) => country)
                  }
                  .width('100%')
                }

                // 已选城市标签
                if (this.selectedCities.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.selectedCities, (city: string) => {
                      Row({ space: 4 }) {
                        Text(city)
                          .fontSize(14)
                          .fontColor(AppColors.TextPrimary)

                        Image($r('sys.media.ohos_ic_public_cancel'))
                          .width(16)
                          .height(16)
                          .fillColor('#9CA3AF')
                          .onClick(() => {
                            this.selectedCities = this.selectedCities.filter(c => c !== city);
                          })
                      }
                      .padding({ left: 12, right: 8, top: 6, bottom: 6 })
                      .backgroundColor('rgba(245, 158, 11, 0.1)')
                      .borderRadius(16)
                    }, (city: string) => city)
                  }
                  .width('100%')
                }

                // 添加按钮
                Row({ space: 8 }) {
                  Button() {
                    Text('+ 国家')
                      .fontSize(14)
                      .fontColor(AppColors.Primary)
                  }
                  .height(32)
                  .padding({ left: 12, right: 12 })
                  .backgroundColor('rgba(20, 184, 166, 0.1)')
                  .borderRadius(16)
                  .onClick(() => {
                    this.showCountryPicker = true;
                  })

                  if (this.selectedCountries.length > 0) {
                    Button() {
                      Text('+ 城市')
                        .fontSize(14)
                        .fontColor(AppColors.Accent)
                    }
                    .height(32)
                    .padding({ left: 12, right: 12 })
                    .backgroundColor('rgba(245, 158, 11, 0.1)')
                    .borderRadius(16)
                    .onClick(() => {
                      this.showCityPicker = true;
                    })
                  }
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F9FAFB')
            .borderRadius(16)
            .border({ width: 1, color: '#E5E7EB' })
            .alignItems(VerticalAlign.Top)
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
    .bindSheet(this.showCountryPicker, this.CountryPickerBuilder(), {
      height: 400,
      showClose: false,
      onDisappear: () => {
        this.showCountryPicker = false
      }
    })
    .bindSheet(this.showCityPicker, this.CityPickerBuilder(), {
      height: 400,
      showClose: false,
      onDisappear: () => {
        this.showCityPicker = false
      }
    })
  }

  @Builder
  CountryPickerBuilder() {
    Column({ space: 0 }) {
      Column({ space: 16 }) {
        Row() {
          Text('选择国家')
            .fontSize(18)
            .fontColor('#1F2937')
            .fontWeight(FontWeight.Bold)

          Blank()

          Text('确定')
            .fontSize(16)
            .fontColor('#14B8A6')
            .onClick(() => {
              this.showCountryPicker = false
            })
        }
        .width('100%')

        List({ space: 8 }) {
          ForEach(this.countries, (country: string) => {
            ListItem() {
              Row({ space: 12 }) {
                Text(country)
                  .fontSize(16)
                  .fontColor('#1F2937')
                  .layoutWeight(1)

                if (this.selectedCountries.includes(country)) {
                  Image($r('sys.media.ohos_ic_public_ok'))
                    .width(20)
                    .height(20)
                    .fillColor('#14B8A6')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.selectedCountries.includes(country) ? 'rgba(20, 184, 166, 0.1)' : '#F9FAFB')
              .borderRadius(16)
              .onClick(() => {
                if (this.selectedCountries.includes(country)) {
                  this.selectedCountries = this.selectedCountries.filter(c => c !== country);
                } else {
                  this.selectedCountries.push(country);
                }
              })
            }
          }, (country: string) => country)
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }

  @Builder
  CityPickerBuilder() {
    Column({ space: 0 }) {
      Column({ space: 16 }) {
        Row() {
          Text('选择城市')
            .fontSize(18)
            .fontColor('#1F2937')
            .fontWeight(FontWeight.Bold)

          Blank()

          Text('确定')
            .fontSize(16)
            .fontColor('#14B8A6')
            .onClick(() => {
              this.showCityPicker = false
            })
        }
        .width('100%')

        let allCities: string[] = [];
        this.selectedCountries.forEach(country => {
          if (this.cities[country]) {
            allCities = allCities.concat(this.cities[country]);
          }
        });

        List({ space: 8 }) {
          ForEach(allCities, (city: string) => {
            ListItem() {
              Row({ space: 12 }) {
                Text(city)
                  .fontSize(16)
                  .fontColor('#1F2937')
                  .layoutWeight(1)

                if (this.selectedCities.includes(city)) {
                  Image($r('sys.media.ohos_ic_public_ok'))
                    .width(20)
                    .height(20)
                    .fillColor('#14B8A6')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.selectedCities.includes(city) ? 'rgba(245, 158, 11, 0.1)' : '#F9FAFB')
              .borderRadius(16)
              .onClick(() => {
                if (this.selectedCities.includes(city)) {
                  this.selectedCities = this.selectedCities.filter(c => c !== city);
                } else {
                  this.selectedCities.push(city);
                }
              })
            }
          }, (city: string) => city)
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}
