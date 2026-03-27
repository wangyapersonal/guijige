/**
 * 创建行程页
 */

import { TripService } from '../services/TripService';
import { CreateTripParams } from '../models/Trip';
import { TimeUtils } from '../common/utils/TimeUtils';
import router from '@ohos.router';

@Entry
@Component
struct CreateTripPage {
  @State tripName: string = '';
  @State startDate: string = '';
  @State endDate: string = '';
  @State selectedDestinations: string[] = [];
  @State tripDays: number = 0;
  @State isCreating: boolean = false;
  
  // 省份列表
  private provinces: string[] = [
    '北京', '上海', '天津', '重庆',
    '西藏', '云南', '四川', '新疆', '青海', '甘肃',
    '海南', '广东', '广西', '福建', '浙江', '江苏',
    '山东', '河南', '湖北', '湖南', '江西', '安徽',
    '河北', '山西', '陕西', '宁夏', '内蒙古', '辽宁',
    '吉林', '黑龙江', '贵州'
  ];
  
  private tripService: TripService = TripService.getInstance();
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back())
        
        Text('创建行程')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      Scroll() {
        Column() {
          // 行程名称
          Column() {
            Text('行程名称 *')
              .fontSize(14)
              .fontColor('#757575')
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '输入行程名称' })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value) => {
                this.tripName = value;
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 20 })
          
          // 日期选择
          Row() {
            Column() {
              Text('开始日期 *')
                .fontSize(14)
                .fontColor('#757575')
                .margin({ bottom: 8 })
              
              Row() {
                Text('📅')
                  .fontSize(16)
                
                Text(this.startDate || '选择日期')
                  .fontSize(16)
                  .fontColor(this.startDate ? '#212121' : '#9E9E9E')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                // TODO: 日期选择器
                this.startDate = TimeUtils.formatDate(Date.now());
                this.calculateDays();
              })
            }
            .layoutWeight(1)
            
            Column() {
              Text('结束日期 *')
                .fontSize(14)
                .fontColor('#757575')
                .margin({ bottom: 8 })
              
              Row() {
                Text('📅')
                  .fontSize(16)
                
                Text(this.endDate || '选择日期')
                  .fontSize(16)
                  .fontColor(this.endDate ? '#212121' : '#9E9E9E')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onClick(() => {
                // TODO: 日期选择器
                const tomorrow = Date.now() + 10 * 24 * 60 * 60 * 1000;
                this.endDate = TimeUtils.formatDate(tomorrow);
                this.calculateDays();
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 20 })
          
          // 行程天数
          if (this.tripDays > 0) {
            Row() {
              Text('行程天数')
                .fontSize(14)
                .fontColor('#757575')
              
              Blank()
              
              Text(`${this.tripDays} 天`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#2196F3')
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#E3F2FD')
            .borderRadius(8)
            .margin({ bottom: 20 })
          }
          
          // 目的地选择
          Column() {
            Text('目的地 * (可多选)')
              .fontSize(14)
              .fontColor('#757575')
              .margin({ bottom: 8 })
            
            // 已选择的目的地
            if (this.selectedDestinations.length > 0) {
              Row() {
                ForEach(this.selectedDestinations, (dest: string) => {
                  Row() {
                    Text(dest)
                      .fontSize(14)
                      .fontColor('#2196F3')
                    
                    Text(' ×')
                      .fontSize(14)
                      .fontColor('#2196F3')
                      .onClick(() => {
                        this.selectedDestinations = this.selectedDestinations.filter(d => d !== dest);
                      })
                  }
                  .padding({ left: 12, right: 8, top: 6, bottom: 6 })
                  .backgroundColor('#E3F2FD')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                })
              }
              .width('100%')
              .flexWrap(FlexWrap.Wrap)
              .margin({ bottom: 12 })
            }
            
            // 省份网格
            Grid() {
              ForEach(this.provinces, (province: string) => {
                GridItem() {
                  Row() {
                    if (this.selectedDestinations.includes(province)) {
                      Text('●')
                        .fontSize(12)
                        .fontColor('#2196F3')
                        .margin({ right: 4 })
                    }
                    
                    Text(province)
                      .fontSize(14)
                      .fontColor(this.selectedDestinations.includes(province) ? '#2196F3' : '#424242')
                  }
                  .width('100%')
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.selectedDestinations.includes(province) ? '#E3F2FD' : '#F5F5F5')
                  .borderRadius(8)
                  .onClick(() => {
                    if (this.selectedDestinations.includes(province)) {
                      this.selectedDestinations = this.selectedDestinations.filter(d => d !== province);
                    } else {
                      this.selectedDestinations = [...this.selectedDestinations, province];
                    }
                  })
                }
              })
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .width('100%')
            .height(400)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      
      // 创建按钮
      Column() {
        Button('✈️ 创建行程')
          .width('100%')
          .height(50)
          .fontSize(18)
          .backgroundColor(this.canCreate() ? '#2196F3' : '#BDBDBD')
          .enabled(this.canCreate() && !this.isCreating)
          .onClick(() => this.createTrip())
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  private calculateDays() {
    if (this.startDate && this.endDate) {
      const start = new Date(this.startDate).getTime();
      const end = new Date(this.endDate).getTime();
      if (end >= start) {
        this.tripDays = TimeUtils.getDaysBetween(start, end) + 1;
      } else {
        this.tripDays = 0;
      }
    }
  }
  
  private canCreate(): boolean {
    return this.tripName.length > 0 &&
           this.startDate.length > 0 &&
           this.endDate.length > 0 &&
           this.selectedDestinations.length > 0 &&
           this.tripDays > 0;
  }
  
  private async createTrip() {
    if (!this.canCreate()) return;
    
    this.isCreating = true;
    
    try {
      const params: CreateTripParams = {
        name: this.tripName,
        destinations: this.selectedDestinations,
        startTime: new Date(this.startDate).getTime(),
        endTime: new Date(this.endDate).getTime()
      };
      
      const trip = await this.tripService.createTrip(params);
      
      if (trip) {
        // 创建成功，返回
        router.back();
      }
    } catch (error) {
      console.error('Create trip error', error);
    } finally {
      this.isCreating = false;
    }
  }
}
