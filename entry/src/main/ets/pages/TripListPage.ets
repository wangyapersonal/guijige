/**
 * 行程列表页
 */

import { TripService } from '../services/TripService';
import { Trip } from '../models/Trip';
import { TripStatus } from '../common/constants/Constants';
import { TimeUtils } from '../common/utils/TimeUtils';
import { GeoUtils } from '../common/utils/GeoUtils';
import router from '@ohos.router';

@Entry
@Component
struct TripListPage {
  @State trips: Trip[] = [];
  @State isLoading: boolean = true;
  
  private tripService: TripService = TripService.getInstance();
  
  async aboutToAppear() {
    await this.loadTrips();
  }
  
  async loadTrips() {
    try {
      this.isLoading = true;
      this.trips = await this.tripService.getAllTrips();
    } catch (error: Error) {
      console.error('Load trips error', error);
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
        
        Text('我的行程')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
        
        Blank()
        
        Button('+ 新建')
          .fontSize(14)
          .height(32)
          .backgroundColor('#2196F3')
          .onClick(() => {
            router.pushUrl({ url: 'pages/CreateTripPage' });
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
      } else if (this.trips.length === 0) {
        // 空状态
        Column() {
          Text('📭')
            .fontSize(64)
          
          Text('还没有行程')
            .fontSize(18)
            .fontColor('#424242')
            .margin({ top: 16 })
          
          Text('创建你的第一个旅行行程吧')
            .fontSize(14)
            .fontColor('#757575')
            .margin({ top: 8 })
          
          Button('创建行程')
            .width(160)
            .height(44)
            .backgroundColor('#2196F3')
            .fontColor(Color.White)
            .borderRadius(22)
            .margin({ top: 24 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/CreateTripPage' });
            })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 行程列表
        List() {
          ForEach(
            this.trips,
            (trip: Trip) => {
              ListItem() {
                this.TripCard(trip)
              }
              .margin({ top: 12 })
            },
            (trip: Trip) => trip.id
          )
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  TripCard(trip: Trip) {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('🗓️ ')
              .fontSize(16)
            
            Text(trip.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212121')
          }
          
          Row() {
            Text(`${TimeUtils.formatDate(trip.startTime)} - ${trip.endTime ? TimeUtils.formatDate(trip.endTime) : '进行中'}`)
              .fontSize(14)
              .fontColor('#757575')
            
            Text(` | ${trip.destinations.join(', ')}`)
              .fontSize(14)
              .fontColor('#757575')
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 状态标签
        Text(this.getStatusText(trip.status))
          .fontSize(12)
          .fontColor(this.getStatusColor(trip.status))
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(this.getStatusBgColor(trip.status))
          .borderRadius(10)
      }
      .width('100%')
      
      Divider()
        .color('#E0E0E0')
        .margin({ top: 16, bottom: 16 })
      
      Row() {
        Column() {
          Text(GeoUtils.formatDistance(trip.totalDistance))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')
          
          Text('总里程')
            .fontSize(12)
            .fontColor('#757575')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text(`${trip.checkInCount}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#212121')
          
          Text('打卡点')
            .fontSize(12)
            .fontColor('#757575')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        
        Column() {
          Text('→')
            .fontSize(20)
            .fontColor('#9E9E9E')
        }
        .width(40)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .onClick(() => {
      router.pushUrl({
        url: 'pages/TripDetailPage',
        params: { tripId: trip.id }
      });
    })
  }
  
  private getStatusText(status: TripStatus): string {
    switch (status) {
      case TripStatus.NOT_STARTED:
        return '未开始';
      case TripStatus.ONGOING:
        return '进行中';
      case TripStatus.COMPLETED:
        return '已完成';
      default:
        return '';
    }
  }
  
  private getStatusColor(status: TripStatus): ResourceColor {
    switch (status) {
      case TripStatus.NOT_STARTED:
        return '#757575';
      case TripStatus.ONGOING:
        return '#4CAF50';
      case TripStatus.COMPLETED:
        return '#2196F3';
      default:
        return '#757575';
    }
  }
  
  private getStatusBgColor(status: TripStatus): ResourceColor {
    switch (status) {
      case TripStatus.NOT_STARTED:
        return '#F5F5F5';
      case TripStatus.ONGOING:
        return '#E8F5E9';
      case TripStatus.COMPLETED:
        return '#E3F2FD';
      default:
        return '#F5F5F5';
    }
  }
}
