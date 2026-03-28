import { map, mapCommon, Location } from '@kit.MapKit';

export class MapService {
  private static instance: MapService;
  private mapController: map.MapComponentController;
  private mapOptions: mapCommon.MapOptions;

  private constructor() {
  }

  static getInstance(): MapService {
    if (!MapService.instance) {
      MapService.instance = new MapService();
    }
    return MapService.instance;
  }

  setMapController(mapController: map.MapComponentController): void {
    this.mapController = mapController;
  }

  getMapController(): map.MapComponentController {
    return this.mapController;
  }

  setMapOptions(mapOptions: mapCommon.MapOptions): void {
    this.mapOptions = mapOptions;
  }

  getMapOptions(): mapCommon.MapOptions {
    return this.mapOptions;
  }

  setCameraPosition(position: mapCommon.CameraPosition): void {
    this.mapController.setCameraPosition(position);
  }

  async getCameraPosition(): Promise<mapCommon.CameraPosition> {
    return await this.mapController.getCameraPosition();
  }
}
