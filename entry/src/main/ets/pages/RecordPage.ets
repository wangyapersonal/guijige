/**
 * 记录页（持续记录）
 */

import { RecordService } from '../services/RecordService';
import { LocationService } from '../services/LocationService';
import { Trip } from '../models/Trip';
import { RecordMode } from '../common/constants/Constants';
import { GeoUtils } from '../common/utils/GeoUtils';
import { TimeUtils } from '../common/utils/TimeUtils';
import router from '@ohos.router';

interface RecordParams {
  tripId: string;
}

@Entry
@Component
struct RecordPage {
  @State tripId: string = '';
  @State recordMode: RecordMode = RecordMode.DRIVING;
  @State isRecording: boolean = false;
  @State isPaused: boolean = false;
  @State startTime: number = 0;
  @State distance: number = 0;
  @State duration: number = 0;
  @State currentSpeed: number = 0;
  @State showModeSelector: boolean = true;
  
  private locationService: LocationService = LocationService.getInstance();
  private recordService: RecordService | null = null;
  
  aboutToAppear() {
    const params = router.getParams() as RecordParams;
    this.tripId = params?.tripId || '';
    
    // 检查是否有未完成的记录
    this.checkUnfinishedRecord();
  }
  
  aboutToDisappear() {
    if (this.isRecording) {
      this.locationService.stopContinuousTracking();
    }
  }
  
  async checkUnfinishedRecord() {
    // TODO: 检查是否有未完成的记录
  }
  
  build() {
    Column() {
      if (this.showModeSelector) {
        // 运动方式选择
        this.ModeSelector()
      } else {
        // 记录页面
        this.RecordView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  @Builder
  ModeSelector() {
    Column() {
      Text('开始记录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 40 })
      
      Text('选择运动方式：')
        .fontSize(16)
        .fontColor('#757575')
        .margin({ bottom: 20 })
      
      // 自驾
      this.ModeCard(
        '🚗',
        '自驾（默认）',
        '适合公路旅行、城市间移动',
        RecordMode.DRIVING
      )
      
      // 骑行
      this.ModeCard(
        '🚴',
        '骑行',
        '适合骑行游览、环湖骑行',
        RecordMode.CYCLING
      )
      
      // 步行
      this.ModeCard(
        '🚶',
        '步行',
        '适合城市漫步、景区游玩',
        RecordMode.WALKING
      )
      
      Blank()
      
      Button('开始记录')
        .width('85%')
        .height(50)
        .fontSize(18)
        .backgroundColor('#2196F3')
        .borderRadius(25)
        .margin({ bottom: 40 })
        .onClick(() => this.startRecord())
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
  
  @Builder
  ModeCard(icon: string, title: string, desc: string, mode: RecordMode) {
    Row() {
      Text(icon)
        .fontSize(32)
        .margin({ right: 16 })
      
      Column() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#212121')
        
        Text(desc)
          .fontSize(14)
          .fontColor('#757575')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      
      Radio({ value: mode, group: 'recordMode' })
        .checked(this.recordMode === mode)
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.recordMode = mode;
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.recordMode === mode ? '#E3F2FD' : Color.White)
    .borderRadius(12)
    .border({
      width: this.recordMode === mode ? 2 : 1,
      color: this.recordMode === mode ? '#2196F3' : '#E0E0E0'
    })
    .margin({ bottom: 12 })
    .onClick(() => {
      this.recordMode = mode;
    })
  }
  
  @Builder
  RecordView() {
    Stack({ alignContent: Alignment.Top }) {
      // 地图背景
      Column() {
        Text('🗺️')
          .fontSize(80)
        
        Text('地图加载中...')
          .fontSize(16)
          .fontColor('#757575')
          .margin({ top: 12 })
      }
      .width('100%')
      .height('65%')
      .backgroundColor('#E0E0E0')
      .justifyContent(FlexAlign.Center)
      
      // 顶部状态栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(Color.White)
          .onClick(() => {
            if (this.isRecording && !this.isPaused) {
              // 正在记录，显示确认框
              // TODO: 确认退出
            } else {
              router.back();
            }
          })
        
        Blank()
        
        Text(this.formatTime(this.duration))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Blank()
        
        if (this.isRecording && !this.isPaused) {
          Text('⏸ 暂停')
            .fontSize(16)
            .fontColor(Color.White)
            .onClick(() => this.pauseRecord())
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .linearGradient({
        angle: 180,
        colors: [['#33000000', 0], ['#00000000', 1]]
      })
      
      // 底部数据面板
      Column() {
        // 数据展示
        Row() {
          Column() {
            Text('📍')
              .fontSize(20)
            
            Text(GeoUtils.formatDistance(this.distance))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212121')
            
            Text('距离')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          
          Column() {
            Text('⏱️')
              .fontSize(20)
            
            Text(this.formatTime(this.duration))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212121')
            
            Text('时长')
              .fontSize(12)
              .fontColor('#757575')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('rgba(0,0,0,0.7)')
        .borderRadius({ topLeft: 20, topRight: 20 })
        
        // 控制按钮
        Row() {
          if (this.isPaused) {
            Button('▶️ 继续')
              .width('40%')
              .height(50)
              .fontSize(18)
              .backgroundColor('#4CAF50')
              .borderRadius(25)
              .onClick(() => this.resumeRecord())
          } else {
            Button('⏸ 暂停')
              .width('40%')
              .height(50)
              .fontSize(18)
              .backgroundColor('#FF9800')
              .borderRadius(25)
              .enabled(this.isRecording)
              .onClick(() => this.pauseRecord())
          }
          
          Button('⏹ 结束')
            .width('40%')
            .height(50)
            .fontSize(18)
            .backgroundColor('#F44336')
            .borderRadius(25)
            .enabled(this.isRecording)
            .onClick(() => this.stopRecord())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .padding({ bottom: 30, top: 10 })
        .backgroundColor(Color.White)
      }
      .width('100%')
      .position({ x: 0, y: '55%' })
    }
    .width('100%')
    .height('100%')
  }
  
  private async startRecord() {
    this.showModeSelector = false;
    this.isRecording = true;
    this.isPaused = false;
    this.startTime = Date.now();
    this.distance = 0;
    this.duration = 0;
    
    // 开始持续定位
    await this.locationService.startContinuousTracking((location) => {
      this.onLocationUpdate(location);
    });
    
    // 开始计时
    this.startTimer();
  }
  
  private pauseRecord() {
    this.isPaused = true;
    this.locationService.stopContinuousTracking();
  }
  
  private async resumeRecord() {
    this.isPaused = false;
    await this.locationService.startContinuousTracking((location) => {
      this.onLocationUpdate(location);
    });
  }
  
  private async stopRecord() {
    this.isRecording = false;
    this.locationService.stopContinuousTracking();
    
    // TODO: 保存记录
    
    router.back();
  }
  
  private onLocationUpdate(location: any) {
    if (!this.isRecording || this.isPaused) return;
    
    // 更新速度
    this.currentSpeed = location.speed || 0;
    
    // TODO: 累加距离
  }
  
  private startTimer() {
    setInterval(() => {
      if (this.isRecording && !this.isPaused) {
        this.duration = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000);
  }
  
  private formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    
    if (h > 0) {
      return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    }
    return `${m}:${s.toString().padStart(2, '0')}`;
  }
}
