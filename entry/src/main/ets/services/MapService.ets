/**
 * 地图服务
 * 使用华为地图组件显示轨迹
 */

// @ts-nocheck
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { Location } from '../common/types/CommonTypes';

// 地图标记点
export interface MapMarker {
  id: string;
  latitude: number;
  longitude: number;
  title?: string;
  snippet?: string;
  icon?: string;
}

// 地图折线
export interface MapPolyline {
  id: string;
  points: Location[];
  color: string;
  width: number;
}

// 地图相机位置
export interface CameraPosition {
  latitude: number;
  longitude: number;
  zoom: number;
}

export class MapService {
  private static instance: MapService;
  private mapController: map.MapComponentController | null = null;
  private markers: Map<string, map.Marker> = new Map();
  private polylines: Map<string, map.Polyline> = new Map();
  
  // 默认配置
  private readonly DEFAULT_ZOOM = 15;
  private readonly MIN_ZOOM = 3;
  private readonly MAX_ZOOM = 20;
  
  static getInstance(): MapService {
    if (!MapService.instance) {
      MapService.instance = new MapService();
    }
    return MapService.instance;
  }
  
  private constructor() {}
  
  /**
   * 初始化地图控制器
   */
  setMapController(controller: map.MapComponentController): void {
    this.mapController = controller;
    console.info('MapService', 'Map controller set');
  }
  
  /**
   * 移动到指定位置
   */
  async moveToLocation(
    latitude: number,
    longitude: number,
    zoom?: number
  ): Promise<boolean> {
    if (!this.mapController) {
      console.warn('MapService', 'Map controller not initialized');
      return false;
    }
    
    try {
      const cameraPosition: mapCommon.CameraPosition = {
        target: {
          latitude,
          longitude
        },
        zoom: zoom || this.DEFAULT_ZOOM
      };
      
      await this.mapController.setCameraPosition(cameraPosition);
      return true;
    } catch (error) {
      console.error('MapService', 'moveToLocation error', error);
      return false;
    }
  }
  
  /**
   * 移动到当前位置
   */
  async moveToCurrentLocation(): Promise<boolean> {
    // 这个方法需要配合 LocationService 使用
    // 在组件中调用更合适
    return false;
  }
  
  /**
   * 添加标记点
   */
  async addMarker(marker: MapMarker): Promise<string | null> {
    if (!this.mapController) {
      console.warn('MapService', 'Map controller not initialized');
      return null;
    }
    
    try {
      const markerOptions: map.MarkerOptions = {
        position: {
          latitude: marker.latitude,
          longitude: marker.longitude
        },
        title: marker.title || '',
        snippet: marker.snippet || '',
        clickable: true,
        draggable: false
      };
      
      const mapMarker = await this.mapController.addMarker(markerOptions);
      this.markers.set(marker.id, mapMarker);
      
      console.info('MapService', 'Marker added', marker.id);
      return marker.id;
    } catch (error) {
      console.error('MapService', 'addMarker error', error);
      return null;
    }
  }
  
  /**
   * 移除标记点
   */
  async removeMarker(markerId: string): Promise<boolean> {
    if (!this.mapController) {
      return false;
    }
    
    const marker = this.markers.get(markerId);
    if (!marker) {
      return false;
    }
    
    try {
      await this.mapController.removeMarker(marker);
      this.markers.delete(markerId);
      return true;
    } catch (error) {
      console.error('MapService', 'removeMarker error', error);
      return false;
    }
  }
  
  /**
   * 清除所有标记点
   */
  async clearAllMarkers(): Promise<void> {
    if (!this.mapController) {
      return;
    }
    
    try {
      for (const [id, marker] of this.markers) {
        await this.mapController.removeMarker(marker);
      }
      this.markers.clear();
    } catch (error) {
      console.error('MapService', 'clearAllMarkers error', error);
    }
  }
  
  /**
   * 添加轨迹线
   */
  async addPolyline(polyline: MapPolyline): Promise<string | null> {
    if (!this.mapController || polyline.points.length < 2) {
      return null;
    }
    
    try {
      const points: mapCommon.LatLng[] = polyline.points.map(p => ({
        latitude: p.latitude,
        longitude: p.longitude
      }));
      
      const polylineOptions: map.PolylineOptions = {
        points,
        color: this.parseColor(polyline.color),
        width: polyline.width,
        clickable: false
      };
      
      const mapPolyline = await this.mapController.addPolyline(polylineOptions);
      this.polylines.set(polyline.id, mapPolyline);
      
      console.info('MapService', 'Polyline added', polyline.id);
      return polyline.id;
    } catch (error) {
      console.error('MapService', 'addPolyline error', error);
      return null;
    }
  }
  
  /**
   * 移除轨迹线
   */
  async removePolyline(polylineId: string): Promise<boolean> {
    if (!this.mapController) {
      return false;
    }
    
    const polyline = this.polylines.get(polylineId);
    if (!polyline) {
      return false;
    }
    
    try {
      await this.mapController.removePolyline(polyline);
      this.polylines.delete(polylineId);
      return true;
    } catch (error) {
      console.error('MapService', 'removePolyline error', error);
      return false;
    }
  }
  
  /**
   * 清除所有轨迹线
   */
  async clearAllPolylines(): Promise<void> {
    if (!this.mapController) {
      return;
    }
    
    try {
      for (const [id, polyline] of this.polylines) {
        await this.mapController.removePolyline(polyline);
      }
      this.polylines.clear();
    } catch (error) {
      console.error('MapService', 'clearAllPolylines error', error);
    }
  }
  
  /**
   * 调整视野以包含所有点
   */
  async fitBounds(locations: Location[], padding: number = 50): Promise<boolean> {
    if (!this.mapController || locations.length === 0) {
      return false;
    }
    
    try {
      let minLat = Infinity, maxLat = -Infinity;
      let minLng = Infinity, maxLng = -Infinity;
      
      for (const loc of locations) {
        minLat = Math.min(minLat, loc.latitude);
        maxLat = Math.max(maxLat, loc.latitude);
        minLng = Math.min(minLng, loc.longitude);
        maxLng = Math.max(maxLng, loc.longitude);
      }
      
      // 计算中心点
      const centerLat = (minLat + maxLat) / 2;
      const centerLng = (minLng + maxLng) / 2;
      
      // 计算合适的缩放级别（简化版）
      const latSpan = maxLat - minLat;
      const lngSpan = maxLng - minLng;
      const maxSpan = Math.max(latSpan, lngSpan);
      
      let zoom = this.DEFAULT_ZOOM;
      if (maxSpan > 0.1) zoom = 8;
      else if (maxSpan > 0.05) zoom = 10;
      else if (maxSpan > 0.01) zoom = 12;
      else if (maxSpan > 0.005) zoom = 14;
      
      await this.moveToLocation(centerLat, centerLng, zoom);
      return true;
    } catch (error) {
      console.error('MapService', 'fitBounds error', error);
      return false;
    }
  }
  
  /**
   * 获取当前相机位置
   */
  async getCameraPosition(): Promise<CameraPosition | null> {
    if (!this.mapController) {
      return null;
    }
    
    try {
      const position = await this.mapController.getCameraPosition();
      return {
        latitude: position.target.latitude,
        longitude: position.target.longitude,
        zoom: position.zoom
      };
    } catch (error) {
      console.error('MapService', 'getCameraPosition error', error);
      return null;
    }
  }
  
  /**
   * 设置地图类型
   */
  async setMapType(type: 'normal' | 'satellite' | 'terrain'): Promise<void> {
    if (!this.mapController) {
      return;
    }
    
    try {
      const mapType = type === 'satellite' 
        ? mapCommon.MapType.SATELLITE 
        : type === 'terrain'
          ? mapCommon.MapType.TERRAIN
          : mapCommon.MapType.NORMAL;
      
      await this.mapController.setMapType(mapType);
    } catch (error) {
      console.error('MapService', 'setMapType error', error);
    }
  }
  
  /**
   * 解析颜色字符串为数字
   */
  private parseColor(color: string): number {
    // 简单的颜色解析
    const colors: Record<string, number> = {
      'red': 0xFFFF0000,
      'green': 0xFF00FF00,
      'blue': 0xFF0000FF,
      'yellow': 0xFFFFFF00,
      'orange': 0xFFFFA500,
      'purple': 0xFF800080,
      'cyan': 0xFF00FFFF,
      'magenta': 0xFFFF00FF,
      'white': 0xFFFFFFFF,
      'black': 0xFF000000,
      'gray': 0xFF808080
    };
    
    if (colors[color.toLowerCase()]) {
      return colors[color.toLowerCase()];
    }
    
    // 默认蓝色
    return 0xFF2196F3;
  }
  
  /**
   * 销毁地图
   */
  destroy(): void {
    this.markers.clear();
    this.polylines.clear();
    this.mapController = null;
    console.info('MapService', 'destroyed');
  }
}
