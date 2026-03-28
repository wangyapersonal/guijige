/**
 * 首页
 */

import { AuthService } from '../services/AuthService';
import { TripService } from '../services/TripService';
import { LocationService } from '../services/LocationService';
import { CheckInService } from '../services/CheckInService';
import { Trip } from '../models/Trip';
import { GeoUtils } from '../common/utils/GeoUtils';
import { TimeUtils } from '../common/utils/TimeUtils';
import { TripStatus } from '../common/constants/Constants';

@Entry
@Component
struct IndexPage {
  @State currentTrip: Trip | null = null;
  @State isLoading: boolean = true;
  @State isRecording: boolean = false;
  @State currentDistance: number = 0;
  @State currentDuration: number = 0;
  @State addressText: string = '获取位置中...';
  
  private authService: AuthService = AuthService.getInstance();
  private tripService: TripService = TripService.getInstance();
  private locationService: LocationService = LocationService.getInstance();
  private checkInService: CheckInService = CheckInService.getInstance();
  
  async aboutToAppear() {
    // 检查登录状态
    if (!this.authService.isLoggedIn()) {
      // TODO: 跳转登录页
      return;
    }
    
    // 加载数据
    await this.loadData();
    
    // 自动打卡（如果在行程日期内）
    await this.autoCheckInIfNeeded();
  }
  
  async loadData() {
    try {
      this.isLoading = true;
      
      // 获取当前进行中的行程
      this.currentTrip = await this.tripService.getOngoingTrip();
      
      // 获取当前位置
      const location = await this.locationService.getCurrentLocation();
      if (location) {
        this.addressText = `${location.latitude.toFixed(4)}, ${location.longitude.toFixed(4)}`;
      }
      
    } catch (error) {
      console.error('Load data error', error);
    } finally {
      this.isLoading = false;
    }
  }
  
  async autoCheckInIfNeeded() {
    if (!this.currentTrip) return;
    
    const now = Date.now();
    if (now >= this.currentTrip.startTime && 
        (!this.currentTrip.endTime || now <= this.currentTrip.endTime)) {
      // 在行程日期内，自动打卡
      await this.checkInService.autoCheckIn(this.currentTrip.id);
    }
  }
  
  build() {
    Column() {
      // 顶部栏
      this.TitleBar()
      
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#2196F3')
          
          Text('加载中...')
            .fontSize(16)
            .fontColor('#757575')
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 主内容
        Scroll() {
          Column() {
            // 地图区域
            this.MapSection()
            
            // 当前行程卡片
            if (this.currentTrip) {
              this.CurrentTripCard()
              
              // 操作按钮
              this.ActionButtons()
            } else {
              // 无行程
              this.NoTripCard()
            }
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
  TitleBar() {
    Row() {
      Text('轨迹哥')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
      
      Blank()
      
      if (this.currentTrip) {
        Text('第3天')
          .fontSize(14)
          .fontColor('#757575')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor('#E3F2FD')
          .borderRadius(12)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(Color.White)
  }
  
  @Builder
  MapSection() {
    Column() {
      // 地图占位
      Column() {
        Text('🗺️')
          .fontSize(60)
        
        Text('地图加载中...')
          .fontSize(14)
          .fontColor('#757575')
          .margin({ top: 8 })
      }
      .width('100%')
      .height(300)
      .backgroundColor('#E0E0E0')
      .justifyContent(FlexAlign.Center)
      .borderRadius(16)
      .margin(16)
    }
  }
  
  @Builder
  CurrentTripCard() {
    Column() {
      Row() {
        Text('🗓️ ')
          .fontSize(18)
        
        Text(this.currentTrip?.name || '')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#212121')
      }
      .width('100%')
      .margin({ bottom: 12 })
      
      Row() {
        Text(`${TimeUtils.formatDate(this.currentTrip?.startTime || 0)}`)
          .fontSize(14)
          .fontColor('#757575')
        
        Text(' - ')
          .fontSize(14)
          .fontColor('#757575')
        
        Text(this.currentTrip?.endTime 
          ? TimeUtils.formatDate(this.currentTrip.endTime) 
          : '?')
          .fontSize(14)
          .fontColor('#757575')
        
        Text(` | ${this.currentTrip?.destinations.join(', ')}`)
          .fontSize(14)
          .fontColor('#757575')
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      Row() {
        Text(`今日：轨迹 ${GeoUtils.formatDistance(this.currentDistance)}`)
          .fontSize(14)
          .fontColor('#424242')
        
        Text(' | ')
          .fontSize(14)
          .fontColor('#757575')
        
        Text(`打卡 ${this.currentTrip?.checkInCount || 0} 个`)
          .fontSize(14)
          .fontColor('#424242')
      }
      .width('100%')
    }
    .width('92%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 8 })
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
  }
  
  @Builder
  ActionButtons() {
    Row({ space: 16 }) {
      // 记录按钮
      Button() {
        Column() {
          Text('📍')
            .fontSize(28)
          
          Text('记录')
            .fontSize(14)
            .fontColor('#757575')
            .margin({ top: 4 })
        }
      }
      .width(100)
      .height(100)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        // TODO: 开始记录
      })
      
      // 打卡按钮
      Button() {
        Column() {
          Text('✨')
            .fontSize(28)
          
          Text('打卡')
            .fontSize(14)
            .fontColor('#757575')
            .margin({ top: 4 })
        }
      }
      .width(100)
      .height(100)
      .backgroundColor('#FF9800')
      .borderRadius(16)
      .shadow({
        radius: 8,
        color: '#33FF9800',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => this.handleCheckIn())
    }
    .width('92%')
    .margin({ top: 20 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }
  
  @Builder
  NoTripCard() {
    Column() {
      Text('📱')
        .fontSize(48)
        .margin({ bottom: 16 })
      
      Text('暂无进行中的行程')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#424242')
      
      Text('创建一个新行程开始记录吧')
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
          // TODO: 跳转创建行程页
        })
    }
    .width('92%')
    .padding(40)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ left: 16, right: 16, top: 8 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
  
  private async handleCheckIn() {
    if (!this.currentTrip) return;
    
    try {
      const point = await this.checkInService.manualCheckIn(this.currentTrip.id);
      if (point) {
        // TODO: 显示打卡成功提示
        console.info('CheckIn success', point.id);
        await this.loadData();
      }
    } catch (error) {
      console.error('CheckIn error', error);
    }
  }
}
