/**
 * 地图组件 - 封装华为地图
 */

import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { MapService, MapMarker, MapPolyline } from '../services/MapService';
import { Location } from '../common/types/CommonTypes';

@Component
export struct TripMap {
  @Prop initialLatitude: number = 39.9042;  // 北京
  @Prop initialLongitude: number = 116.4074;
  @Prop initialZoom: number = 12;
  @Prop showLocationButton: boolean = true;
  @Prop showZoomControls: boolean = true;
  
  @Link markers: MapMarker[];
  @Link polylines: MapPolyline[];
  
  private mapController?: map.MapComponentController;
  private mapService: MapService = MapService.getInstance();
  
  // 地图初始化回调
  private onMapReady?: (controller: map.MapComponentController) => void;
  
  aboutToDisappear() {
    // 清理资源
    if (this.mapController) {
      this.mapService.destroy();
    }
  }
  
  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 地图组件
      MapComponent({
        mapOptions: {
          position: {
            target: {
              latitude: this.initialLatitude,
              longitude: this.initialLongitude
            },
            zoom: this.initialZoom
          },
          mapType: mapCommon.MapType.NORMAL,
          zoomControlsEnabled: this.showZoomControls
        },
        callBack: (controller: map.MapComponentController) => {
          this.onMapReady?.(controller);
          this.mapController = controller;
          this.mapService.setMapController(controller);
          console.info('TripMap', 'Map ready');
        }
      })
        .width('100%')
        .height('100%')
      
      // 定位按钮
      if (this.showLocationButton) {
        Button() {
          Text('📍')
            .fontSize(24)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(24)
        .shadow({ radius: 8, color: '#40000000' })
        .margin({ right: 16, bottom: 16 })
        .onClick(() => this.goToCurrentLocation())
      }
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 设置地图准备回调
   */
  setOnMapReady(callback: (controller: map.MapComponentController) => void): void {
    this.onMapReady = callback;
  }
  
  /**
   * 移动到当前位置
   */
  private async goToCurrentLocation(): Promise<void> {
    // 需要配合 LocationService
    // 由父组件实现
  }
  
  /**
   * 获取地图控制器
   */
  getMapController(): map.MapComponentController | undefined {
    return this.mapController;
  }
}

/**
 * 简化版地图视图 - 用于行程详情页
 */
@Component
export struct TripMapView {
  @Prop locations: Location[] = [];
  @Prop showPath: boolean = true;
  @Prop pathColor: string = 'blue';
  @Prop pathWidth: number = 4;
  
  build() {
    Stack() {
      TripMap({
        initialLatitude: this.locations[0]?.latitude || 39.9042,
        initialLongitude: this.locations[0]?.longitude || 116.4074,
        initialZoom: 14,
        showLocationButton: false,
        markers: [],
        polylines: []
      })
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 记录页地图 - 实时显示轨迹
 */
@Component
export struct RecordingMapView {
  @Prop currentLocation: Location | null = null;
  @Prop recordedPoints: Location[] = [];
  @Prop isRecording: boolean = false;
  
  build() {
    Stack() {
      TripMap({
        initialLatitude: this.currentLocation?.latitude || 39.9042,
        initialLongitude: this.currentLocation?.longitude || 116.4074,
        initialZoom: 16,
        showLocationButton: true,
        markers: [],
        polylines: []
      })
      
      // 录制状态指示器
      if (this.isRecording) {
        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill('#FF0000')
          
          Text(' 录制中')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#80000000')
        .borderRadius(16)
        .position({ x: 16, y: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
