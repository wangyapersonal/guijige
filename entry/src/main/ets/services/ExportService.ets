/**
 * 轨迹导出服务
 * 生成轨迹分享图、导出 GPX/KML 等格式
 */

import { Trip } from '../models/Trip';
import { CheckInPoint } from '../models/CheckInPoint';
import { RecordSegment } from '../models/RecordSegment';
import { Location } from '../common/types/CommonTypes';
import { GeoUtils } from '../common/utils/GeoUtils';
import { TimeUtils } from '../common/utils/TimeUtils';

// 导出格式
export enum ExportFormat {
  GPX = 'gpx',      // GPS Exchange Format
  KML = 'kml',      // Google Earth
  GEOJSON = 'geojson',
  IMAGE = 'image'   // 分享图片
}

// 导出选项
export interface ExportOptions {
  format: ExportFormat;
  includePhotos: boolean;
  includeDetails: boolean;
  imageWidth?: number;
  imageHeight?: number;
}

// 导出结果
export interface ExportResult {
  success: boolean;
  data?: string;
  filePath?: string;
  error?: string;
}

export class ExportService {
  private static instance: ExportService;
  
  static getInstance(): ExportService {
    if (!ExportService.instance) {
      ExportService.instance = new ExportService();
    }
    return ExportService.instance;
  }
  
  private constructor() {}
  
  /**
   * 导出行程为指定格式
   */
  async exportTrip(
    trip: Trip,
    segments: RecordSegment[],
    checkInPoints: CheckInPoint[],
    options: ExportOptions
  ): Promise<ExportResult> {
    try {
      switch (options.format) {
        case ExportFormat.GPX:
          return this.exportAsGPX(trip, segments, checkInPoints, options);
        
        case ExportFormat.KML:
          return this.exportAsKML(trip, segments, checkInPoints, options);
        
        case ExportFormat.GEOJSON:
          return this.exportAsGeoJSON(trip, segments, checkInPoints, options);
        
        case ExportFormat.IMAGE:
          return this.exportAsImage(trip, segments, checkInPoints, options);
        
        default:
          return { success: false, error: 'Unsupported format' };
      }
    } catch (error) {
      return { success: false, error: (error as Error).message };
    }
  }
  
  /**
   * 导出为 GPX 格式
   */
  private async exportAsGPX(
    trip: Trip,
    segments: RecordSegment[],
    checkInPoints: CheckInPoint[],
    options: ExportOptions
  ): Promise<ExportResult> {
    const gpxLines: string[] = [
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<gpx version="1.1" creator="轨迹哥" xmlns="http://www.topografix.com/GPX/1/1">',
      `  <metadata>`,
      `    <name>${this.escapeXml(trip.name)}</name>`,
      `    <desc>${this.escapeXml(trip.description || '')}</desc>`,
      `    <time>${new Date(trip.startTime).toISOString()}</time>`,
      `  </metadata>`
    ];
    
    // 添加打卡点作为 waypoints
    for (const point of checkInPoints) {
      gpxLines.push(
        `  <wpt lat="${point.latitude}" lon="${point.longitude}">`,
        `    <name>${this.escapeXml(point.placeName || '打卡点')}</name>`,
        `    <time>${new Date(point.timestamp).toISOString()}</time>`,
        `  </wpt>`
      );
    }
    
    // 添加轨迹段
    for (let i = 0; i < segments.length; i++) {
      const segment = segments[i];
      gpxLines.push(`  <trk>`);
      gpxLines.push(`    <name>轨迹段 ${i + 1}</name>`);
      gpxLines.push(`    <trkseg>`);
      
      for (const trackPoint of segment.trackPoints) {
        gpxLines.push(
          `      <trkpt lat="${trackPoint.latitude}" lon="${trackPoint.longitude}">`,
          trackPoint.altitude ? `        <ele>${trackPoint.altitude}</ele>` : '',
          `        <time>${new Date(trackPoint.timestamp).toISOString()}</time>`,
          `      </trkpt>`
        );
      }
      
      gpxLines.push(`    </trkseg>`);
      gpxLines.push(`  </trk>`);
    }
    
    gpxLines.push('</gpx>');
    
    return {
      success: true,
      data: gpxLines.filter(line => line).join('\n')
    };
  }
  
  /**
   * 导出为 KML 格式
   */
  private async exportAsKML(
    trip: Trip,
    segments: RecordSegment[],
    checkInPoints: CheckInPoint[],
    options: ExportOptions
  ): Promise<ExportResult> {
    const kmlLines: string[] = [
      '<?xml version="1.0" encoding="UTF-8"?>',
      '<kml xmlns="http://www.opengis.net/kml/2.2">',
      '  <Document>',
      `    <name>${this.escapeXml(trip.name)}</name>`,
      `    <description>${this.escapeXml(trip.description || '')}</description>`,
      '',
      '    <!-- 轨迹样式 -->',
      '    <Style id="trackStyle">',
      '      <LineStyle>',
      '        <color>ff0000ff</color>',
      '        <width>4</width>',
      '      </LineStyle>',
      '    </Style>',
      '',
      '    <!-- 打卡点样式 -->',
      '    <Style id="checkInStyle">',
      '      <IconStyle>',
      '        <scale>1.2</scale>',
      '      </IconStyle>',
      '    </Style>'
    ];
    
    // 添加打卡点
    for (const point of checkInPoints) {
      kmlLines.push(
        '    <Placemark>',
        `      <name>${this.escapeXml(point.placeName || '打卡点')}</name>`,
        '      <styleUrl>#checkInStyle</styleUrl>',
        '      <Point>',
        `        <coordinates>${point.longitude},${point.latitude},0</coordinates>`,
        '      </Point>',
        '    </Placemark>'
      );
    }
    
    // 添加轨迹
    for (let i = 0; i < segments.length; i++) {
      const segment = segments[i];
      const coords = segment.trackPoints
        .map(p => `${p.longitude},${p.latitude},${p.altitude || 0}`)
        .join(' ');
      
      kmlLines.push(
        '    <Placemark>',
        `      <name>轨迹段 ${i + 1}</name>`,
        '      <styleUrl>#trackStyle</styleUrl>',
        '      <LineString>',
        '        <coordinates>' + coords + '</coordinates>',
        '      </LineString>',
        '    </Placemark>'
      );
    }
    
    kmlLines.push('  </Document>', '</kml>');
    
    return {
      success: true,
      data: kmlLines.join('\n')
    };
  }
  
  /**
   * 导出为 GeoJSON 格式
   */
  private async exportAsGeoJSON(
    trip: Trip,
    segments: RecordSegment[],
    checkInPoints: CheckInPoint[],
    options: ExportOptions
  ): Promise<ExportResult> {
    const features: object[] = [];
    
    // 打卡点
    for (const point of checkInPoints) {
      features.push({
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [point.longitude, point.latitude]
        },
        properties: {
          id: point.id,
          name: point.placeName,
          type: point.type,
          timestamp: point.timestamp,
          address: point.address
        }
      });
    }
    
    // 轨迹段
    for (let i = 0; i < segments.length; i++) {
      const segment = segments[i];
      const coords = segment.trackPoints.map(p => [p.longitude, p.latitude]);
      
      features.push({
        type: 'Feature',
        geometry: {
          type: 'LineString',
          coordinates: coords
        },
        properties: {
          id: segment.id,
          index: i + 1,
          startTime: segment.startTime,
          endTime: segment.endTime,
          distance: segment.distance,
          mode: segment.mode
        }
      });
    }
    
    const geojson = {
      type: 'FeatureCollection',
      properties: {
        tripId: trip.id,
        name: trip.name,
        description: trip.description,
        startTime: trip.startTime,
        endTime: trip.endTime,
        totalDistance: trip.totalDistance
      },
      features
    };
    
    return {
      success: true,
      data: JSON.stringify(geojson, null, 2)
    };
  }
  
  /**
   * 导出为分享图片
   * （需要配合 Canvas 绘制，这里提供数据准备）
   */
  private async exportAsImage(
    trip: Trip,
    segments: RecordSegment[],
    checkInPoints: CheckInPoint[],
    options: ExportOptions
  ): Promise<ExportResult> {
    // 计算轨迹边界
    let minLat = Infinity, maxLat = -Infinity;
    let minLng = Infinity, maxLng = -Infinity;
    
    for (const segment of segments) {
      for (const point of segment.trackPoints) {
        minLat = Math.min(minLat, point.latitude);
        maxLat = Math.max(maxLat, point.latitude);
        minLng = Math.min(minLng, point.longitude);
        maxLng = Math.max(maxLng, point.longitude);
      }
    }
    
    // 准备图片数据
    const imageData = {
      trip: {
        name: trip.name,
        description: trip.description,
        startDate: TimeUtils.formatDate(trip.startTime),
        endDate: trip.endTime ? TimeUtils.formatDate(trip.endTime) : '',
        totalDistance: GeoUtils.formatDistance(trip.totalDistance),
        checkInCount: trip.checkInCount,
        trackSegmentCount: trip.trackSegmentCount
      },
      bounds: {
        minLat, maxLat, minLng, maxLng
      },
      segments: segments.map(s => ({
        id: s.id,
        points: s.trackPoints.map(p => ({
          lat: p.latitude,
          lng: p.longitude
        }))
      })),
      checkInPoints: checkInPoints.map(p => ({
        id: p.id,
        lat: p.latitude,
        lng: p.longitude,
        name: p.placeName,
        type: p.type
      }))
    };
    
    // 实际图片生成需要在 UI 层使用 Canvas 组件
    // 这里返回数据，由调用方绘制
    return {
      success: true,
      data: JSON.stringify(imageData)
    };
  }
  
  /**
   * XML 转义
   */
  private escapeXml(str: string): string {
    if (!str) return '';
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }
  
  /**
   * 生成分享文本
   */
  generateShareText(trip: Trip): string {
    const lines = [
      `📍 ${trip.name}`,
      '',
      `📅 ${TimeUtils.formatDate(trip.startTime)}`,
      trip.destinations.length > 0 ? `🎯 ${trip.destinations.join(' → ')}` : '',
      '',
      `📊 行程统计`,
      `- 总里程：${GeoUtils.formatDistance(trip.totalDistance)}`,
      `- 轨迹段：${trip.trackSegmentCount} 段`,
      `- 打卡点：${trip.checkInCount} 个`,
      '',
      `— 来自「轨迹哥」`
    ];
    
    return lines.filter(l => l).join('\n');
  }
}
