import { map, mapCommon } from '@kit.MapKit';
import { Trip } from '../models/Trip';
import { CheckInPoint } from '../models/CheckInPoint';
import { RecordSegment } from '../models/RecordSegment';

@Component
export struct TripMap {
  @State mapOptions: mapCommon.MapOptions = {
    position: {
      target: { latitude: 39.9, longitude: 116.4 },
      zoom: 10
    }
  };
  @State cameraPosition: mapCommon.CameraPosition = {
    target: { latitude: 39.9, longitude: 116.4 },
    zoom: 10,
    tilt: 0
  };
  @State markers: Array<mapCommon.Marker> = [
    {
      position: { latitude: 39.9, longitude: 116.4 }
    }
  ];
  @State polylines: Array<mapCommon.Polyline> = [
    {
      points: [{ latitude: 39.9, longitude: 116.4 }]
    }
  ];
  @State circles: Array<mapCommon.Circle> = [];

  build() {
    Map() {
      Marker({ position: this.markers[0].position })
      Polyline({ points: [{ latitude: 39.9, longitude: 116.4 }] })
      Circle({ center: { latitude: 39.9, longitude: 116.4 }, radius: 1000 })
    }
    .mapOptions(this.mapOptions)
    .cameraPosition(this.cameraPosition)
    .onCameraMove((event: mapCommon.MapEvent) => {
      console.info('onCameraMove');
    })
    .onCameraMoveEnd((event: mapCommon.MapEvent) => {
      console.info('onCameraMoveEnd');
    })
  }

  updateMap(trip: Trip, checkInPoints: CheckInPoint[], recordSegments: RecordSegment[]): void {
    if (trip) {
      this.mapOptions = {
        position: {
          target: { latitude: 39.9, longitude: 116.4 },
          zoom: 10
        }
      }
    }
  }
}
