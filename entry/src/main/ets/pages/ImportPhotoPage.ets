/**
 * 照片导入页
 */

// @ts-nocheck
import { PhotoService, PhotoScanResult, PhotoInfo } from '../services/PhotoService';
import { CheckInService } from '../services/CheckInService';
import { TimeUtils } from '../common/utils/TimeUtils';
import { CheckInType } from '../common/constants/Constants';
import router from '@ohos.router';

interface ImportParams {
  tripId: string;
  date: string;
}

@Entry
@Component
struct ImportPhotoPage {
  @State tripId: string = '';
  @State selectedDate: string = '';
  @State isLoading: boolean = false;
  @State scanResult: PhotoScanResult | null = null;
  @State selectedPhotos: Set<string> = new Set();
  @State isImporting: boolean = false;
  
  private photoService: PhotoService = PhotoService.getInstance();
  private checkInService: CheckInService = CheckInService.getInstance();
  
  async aboutToAppear() {
    const params = router.getParams() as ImportParams;
    this.tripId = params?.tripId || '';
    this.selectedDate = params?.date || TimeUtils.getToday();
    
    await this.scanPhotos();
  }
  
  async scanPhotos() {
    this.isLoading = true;
    
    try {
      const startTime = new Date(this.selectedDate + ' 00:00:00').getTime();
      const endTime = new Date(this.selectedDate + ' 23:59:59').getTime();
      
      // TODO: 获取行程目的地
      this.scanResult = await this.photoService.scanPhotos(startTime, endTime);
      
      // 默认全选有定位且在范围内的照片
      this.scanResult.photos.forEach(photo => {
        if (photo.hasLocation && !photo.isAnomaly) {
          this.selectedPhotos.add(photo.uri);
        }
      });
      
    } catch (error) {
      console.error('Scan photos error', error);
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
        
        Text(`导入照片 - ${this.selectedDate}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
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
          
          Text('扫描相册中...')
            .fontSize(16)
            .fontColor('#757575')
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.scanResult) {
        Scroll() {
          Column() {
            // 扫描结果
            this.ScanResultCard()
            
            // 待导入照片
            if (this.scanResult.withLocation > 0) {
              Column() {
                Text(`📷 待导入照片 (${this.selectedPhotos.size}张)`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 12 })
                
                // 照片网格
                Grid() {
                  ForEach(
                    this.scanResult.photos.filter(p => p.hasLocation && !p.isAnomaly),
                    (photo: PhotoInfo) => {
                      GridItem() {
                        this.PhotoItem(photo)
                      }
                    },
                    (photo: PhotoInfo) => photo.uri
                  )
                }
                .columnsTemplate('1fr 1fr 1fr')
                .rowsGap(8)
                .columnsGap(8)
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 20 })
            }
            
            // 异常照片
            if (this.scanResult.anomaly > 0) {
              Column() {
                Row() {
                  Text('⚠️ 已排除 (异常定位)')
                    .fontSize(14)
                    .fontColor('#FF9800')
                }
                .width('100%')
                .margin({ bottom: 8 })

                ForEach(
                  this.scanResult.photos.filter(p => p.isAnomaly),
                  (photo: PhotoInfo) => {
                    Column() {
                      Row() {
                        Text('⬜')
                          .fontSize(16)

                        Text(photo.fileName)
                          .fontSize(14)
                          .fontColor('#757575')
                          .margin({ left: 8 })
                          .layoutWeight(1)
                      }
                      .width('100%')
                      .padding(12)
                      .backgroundColor('#FFF3E0')
                      .borderRadius(6)
                      .margin({ bottom: 6 })

                      Text('(不在目的地范围)')
                        .fontSize(12)
                        .fontColor('#9E9E9E')
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#FFF8E1')
                    .borderRadius(8)
                    .margin({ bottom: 4 })
                  },
                  (photo: PhotoInfo) => photo.uri
                )
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 20 })
            }
            
            // 操作按钮
            Row() {
              Button('全选')
                .width('20%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .fontColor('#212121')
                .onClick(() => this.selectAll())
              
              Button('取消全选')
                .width('25%')
                .height(40)
                .backgroundColor('#F5F5F5')
                .fontColor('#212121')
                .onClick(() => this.deselectAll())
              
              Button(`导入 ${this.selectedPhotos.size} 张`)
                .width('40%')
                .height(40)
                .backgroundColor(this.selectedPhotos.size > 0 ? '#2196F3' : '#BDBDBD')
                .fontColor(Color.White)
                .enabled(this.selectedPhotos.size > 0 && !this.isImporting)
                .onClick(() => this.importPhotos())
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ top: 30, bottom: 20 })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
  }
  
  @Builder
  ScanResultCard() {
    Column() {
      Text('📊 扫描结果')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })
      
      Row() {
        Text(`找到 ${this.scanResult!.total} 张照片`)
          .fontSize(14)
          .fontColor('#424242')
      }
      
      Row() {
        Text(`✓ 有定位信息: ${this.scanResult!.withLocation} 张`)
          .fontSize(14)
          .fontColor('#4CAF50')
      }
      .margin({ top: 8 })
      
      Row() {
        Text(`- 无定位信息: ${this.scanResult!.withoutLocation} 张 (跳过)`)
          .fontSize(14)
          .fontColor('#757575')
      }
      .margin({ top: 4 })
      
      if (this.scanResult!.anomaly > 0) {
        Row() {
          Text(`⚠ 异常定位: ${this.scanResult!.anomaly} 张 (已排除)`)
            .fontSize(14)
            .fontColor('#FF9800')
        }
        .margin({ top: 4 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  PhotoItem(photo: PhotoInfo) {
    Stack({ alignContent: Alignment.TopRight }) {
      // 照片占位
      Column() {
        Text('📷')
          .fontSize(32)
        
        Text(TimeUtils.formatTime(photo.timestamp))
          .fontSize(10)
          .fontColor('#757575')
          .margin({ top: 4 })
      }
      .width('100%')
      .height(100)
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Center)
      .borderRadius(8)
      
      // 选中标记
      if (this.selectedPhotos.has(photo.uri)) {
        Text('✓')
          .fontSize(16)
          .fontColor(Color.White)
          .width(24)
          .height(24)
          .backgroundColor('#2196F3')
          .borderRadius(12)
          .textAlign(TextAlign.Center)
          .margin({ top: 4, right: 4 })
      } else {
        Row()
          .width(24)
          .height(24)
          .border({ width: 2, color: '#BDBDBD' })
          .borderRadius(12)
          .margin({ top: 4, right: 4 })
      }
    }
    .width('100%')
    .onClick(() => {
      if (this.selectedPhotos.has(photo.uri)) {
        this.selectedPhotos.delete(photo.uri);
      } else {
        this.selectedPhotos.add(photo.uri);
      }
    })
  }
  
  private selectAll() {
    this.scanResult?.photos
      .filter(p => p.hasLocation && !p.isAnomaly)
      .forEach(p => this.selectedPhotos.add(p.uri));
  }
  
  private deselectAll() {
    this.selectedPhotos.clear();
  }
  
  private async importPhotos() {
    if (this.selectedPhotos.size === 0) return;
    
    this.isImporting = true;
    
    try {
      const photos = this.scanResult?.photos.filter(p => this.selectedPhotos.has(p.uri)) || [];
      
      for (const photo of photos) {
        if (photo.latitude && photo.longitude) {
          await this.checkInService.checkIn({
            tripId: this.tripId,
            latitude: photo.latitude,
            longitude: photo.longitude,
            type: CheckInType.PHOTO_IMPORT,
            photoPath: photo.uri
          });
        }
      }
      
      // 导入完成，返回
      router.back();
      
    } catch (error) {
      console.error('Import photos error', error);
    } finally {
      this.isImporting = false;
    }
  }
}
