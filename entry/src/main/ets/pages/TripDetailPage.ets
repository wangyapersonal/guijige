/**
 * 行程详情页
 */

import { TripService } from '../services/TripService';
import { CheckInService } from '../services/CheckInService';
import { Trip } from '../models/Trip';
import { CheckInPoint } from '../models/CheckInPoint';
import { TripStatus } from '../common/constants/Constants';
import { TimeUtils } from '../common/utils/TimeUtils';
import { GeoUtils } from '../common/utils/GeoUtils';
import router from '@ohos.router';

interface TripDetailParams {
  tripId: string;
}

@Entry
@Component
struct TripDetailPage {
  @State trip: Trip | null = null;
  @State checkInPoints: CheckInPoint[] = [];
  @State isLoading: boolean = true;
  
  private tripService: TripService = TripService.getInstance();
  private checkInService: CheckInService = CheckInService.getInstance();
  private tripId: string = '';
  
  async aboutToAppear() {
    // 获取参数
    const params = router.getParams() as TripDetailParams;
    this.tripId = params?.tripId || '';
    
    if (this.tripId) {
      await this.loadData();
    }
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      this.trip = await this.tripService.getTrip(this.tripId);
      
      if (this.trip) {
        this.checkInPoints = await this.checkInService.getCheckInPoints({
          tripId: this.tripId
        });
      }
    } catch (error) {
      console.error('Load data error', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back())
        
        Text(this.trip?.name || '行程详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        
        Blank()
        
        Text('编辑')
          .fontSize(16)
          .fontColor('#2196F3')
          .onClick(() => {
            // TODO: 编辑行程
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#2196F3')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.trip) {
        Scroll() {
          Column() {
            // 地图区域
            Column() {
              Text('🗺️')
                .fontSize(60)
              
              Text('轨迹地图')
                .fontSize(14)
                .fontColor('#757575')
                .margin({ top: 8 })
            }
            .width('100%')
            .height(250)
            .backgroundColor('#E0E0E0')
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .margin(16)
            
            // 行程信息
            Column() {
              Row() {
                Text('📅 ')
                  .fontSize(16)
                
                Text(`${TimeUtils.formatDate(this.trip.startTime)} - ${TimeUtils.formatDate(this.trip.endTime || Date.now())}`)
                  .fontSize(16)
                  .fontColor('#424242')
              }
              .width('100%')
              
              Row() {
                Text('📍 ')
                  .fontSize(16)
                
                Text(this.trip.destinations.join(', '))
                  .fontSize(16)
                  .fontColor('#424242')
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('92%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            
            // 统计卡片
            Row() {
              this.StatCard('轨迹段', `${this.trip.trackSegmentCount}`)
              this.StatCard('打卡点', `${this.trip.checkInCount}`)
              this.StatCard('总里程', GeoUtils.formatDistance(this.trip.totalDistance))
            }
            .width('92%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 16 })
            
            // 快捷操作
            Row() {
              Button() {
                Column() {
                  Text('📅')
                    .fontSize(24)
                  Text('每日行程')
                    .fontSize(12)
                    .fontColor('#757575')
                    .margin({ top: 4 })
                }
              }
              .width(75)
              .height(75)
              .backgroundColor(Color.White)
              .borderRadius(12)
              
              Button() {
                Column() {
                  Text('📷')
                    .fontSize(24)
                  Text('导入照片')
                    .fontSize(12)
                    .fontColor('#757575')
                    .margin({ top: 4 })
                }
              }
              .width(75)
              .height(75)
              .backgroundColor(Color.White)
              .borderRadius(12)
              
              Button() {
                Column() {
                  Text('📤')
                    .fontSize(24)
                  Text('导出')
                    .fontSize(12)
                    .fontColor('#757575')
                    .margin({ top: 4 })
                }
              }
              .width(75)
              .height(75)
              .backgroundColor(Color.White)
              .borderRadius(12)
              
              Button() {
                Column() {
                  Text('⚡')
                    .fontSize(24)
                  Text('异常处理')
                    .fontSize(12)
                    .fontColor('#757575')
                    .margin({ top: 4 })
                }
              }
              .width(75)
              .height(75)
              .backgroundColor(Color.White)
              .borderRadius(12)
            }
            .width('92%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 16 })
            
            // 打卡点列表
            Column() {
              Text('打卡记录')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })
              
              if (this.checkInPoints.length === 0) {
                Column() {
                  Text('📍')
                    .fontSize(40)
                  
                  Text('暂无打卡记录')
                    .fontSize(14)
                    .fontColor('#757575')
                    .margin({ top: 8 })
                }
                .width('100%')
                .padding(40)
              } else {
                ForEach(this.checkInPoints, (point: CheckInPoint) => {
                  Row() {
                    Column() {
                      Row() {
                        Text(this.getTypeIcon(point.type))
                          .fontSize(16)
                        
                        Text(point.placeName || point.address || '未命名地点')
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#212121')
                          .margin({ left: 8 })
                      }
                      
                      Text(TimeUtils.formatDateTime(point.timestamp))
                        .fontSize(12)
                        .fontColor('#757575')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)
                    
                    Text('→')
                      .fontSize(16)
                      .fontColor('#9E9E9E')
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .borderRadius(8)
                  .margin({ bottom: 8 })
                })
              }
            }
            .width('92%')
            .margin({ top: 24 })
            .alignItems(HorizontalAlign.Start)
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  StatCard(title: string, value: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
      
      Text(title)
        .fontSize(12)
        .fontColor('#757575')
        .margin({ top: 4 })
    }
    .width(100)
    .height(80)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }
  
  private getTypeIcon(type: string): string {
    switch (type) {
      case 'auto':
        return '📍';
      case 'manual':
        return '✨';
      case 'photo':
        return '📷';
      default:
        return '📍';
    }
  }
}
