/**
 * 照片服务
 */

// @ts-nocheck
import { PhotoInfo, DestinationBounds } from '../models/PhotoInfo';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import image from '@ohos.multimedia.image';
import { TimeUtils } from '../common/utils/TimeUtils';

// 照片信息模型（如果不存在则创建）
export interface PhotoScanResult {
  total: number;
  withLocation: number;
  withoutLocation: number;
  anomaly: number;
  photos: PhotoInfo[];
}

export class PhotoService {
  private static instance: PhotoService;

  static getInstance(): PhotoService {
    if (!PhotoService.instance) {
      PhotoService.instance = new PhotoService();
    }
    return PhotoService.instance;
  }

  /**
   * 扫描相册
   */
  async scanPhotos(
    startDate: number,
    endDate: number,
    destinationBounds?: DestinationBounds[]
  ): Promise<PhotoScanResult> {
    const result: PhotoScanResult = {
      total: 0,
      withLocation: 0,
      withoutLocation: 0,
      anomaly: 0,
      photos: []
    };

    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> | null = null;
    try {
      const photoAccess = photoAccessHelper.getPhotoAccessHelper();

      // 构建查询
      const predicates: photoAccessHelper.FetchOptions = {
        fetchColumns: [
          'uri',
          'photo_file_name',
          'date_added',
          'latitude',
          'longitude'
        ]
      };

      fetchResult = await photoAccess.getAssets(predicates);

      while (fetchResult !== null) {
        const asset = await fetchResult.getNextObject();
        if (!asset) break;

        const photoTime = asset.dateAdded * 1000;

        // 时间范围过滤
        if (photoTime < startDate || photoTime > endDate) continue;

        result.total++;

        const photoInfo: PhotoInfo = {
          uri: asset.uri,
          fileName: asset.photoFileName || '',
          latitude: asset.latitude,
          longitude: asset.longitude,
          timestamp: photoTime,
          hasLocation: asset.latitude !== null && asset.longitude !== null
        };

        if (photoInfo.hasLocation) {
          result.withLocation++;

          // 检查是否在目的地范围内
          if (destinationBounds && destinationBounds.length > 0) {
            photoInfo.isInRange = this.isInDestinationRange(
              photoInfo.latitude!,
              photoInfo.longitude!,
              destinationBounds
            );

            if (!photoInfo.isInRange) {
              photoInfo.isAnomaly = true;
              result.anomaly++;
            }
          }
        } else {
          result.withoutLocation++;
        }

        result.photos.push(photoInfo);
      }

    } catch (error) {
      console.error('PhotoService', 'scanPhotos error', error);
    } finally {
      if (fetchResult) {
        fetchResult.close();
      }
    }

    return result;
  }

  /**
   * 判断是否在目的地范围
   */
  private isInDestinationRange(
    latitude: number,
    longitude: number,
    bounds: DestinationBounds[]
  ): boolean {
    return bounds.some(bound =>
      latitude >= bound.minLat &&
      latitude <= bound.maxLat &&
      longitude >= bound.minLon &&
      longitude <= bound.maxLng
    );
  }

  /**
   * 生成缩略图
   */
  async generateThumbnail(uri: string): Promise<string | null> {
    let imageSource: image.ImageSource | null = null;
    let pixelMap: image.PixelMap | null = null;
    try {
      imageSource = image.createImageSource(uri);
      const decodingOptions: image.DecodingOptions = {
        desiredSize: { width: 200, height: 200 },
        editable: true
      };

      pixelMap = await imageSource.createPixelMap(decodingOptions);
      // TODO: 保存缩略图

      return uri; // 简化返回
    } catch (error) {
      console.error('PhotoService', 'generateThumbnail error', error);
      return null;
    } finally {
      if (pixelMap) {
        pixelMap.release();
      }
      if (imageSource) {
        imageSource.release();
      }
    }
  }

  /**
   * 获取目的地边界框
   */
  getDestinationBounds(destinations: string[]): DestinationBounds[] {
    // 预定义省份边界框（简化版）
    const boundsMap: Record<string, DestinationBounds> = {
      '西藏': { minLat: 26, maxLat: 37, minLon: 78, maxLng: 100 },
      '云南': { minLat: 21, maxLat: 30, minLon: 97, maxLng: 107 },
      '四川': { minLat: 26, maxLat: 34, minLon: 97, maxLng: 109 },
      '北京': { minLat: 39.5, maxLat: 41.5, minLon: 115.5, maxLng: 117.5 },
      '上海': { minLat: 30.5, maxLat: 32, minLon: 120.5, maxLng: 122.5 },
      '海南': { minLat: 18, maxLat: 20.5, minLon: 108.5, maxLng: 111.5 }
    };

    return destinations
      .map(d => boundsMap[d])
      .filter(b => b !== undefined);
  }
}
