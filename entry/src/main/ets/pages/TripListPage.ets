import { router } from '@kit.ArkUI';
import { Trip } from '../models/Trip';
import { TripService } from '../services/TripService';
import { TripType, TripStatus } from '../models/Trip';
import { AppColors } from '../common/constants/Colors';

function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

@Component
export struct TripListPage {
  @State trips: Trip[] = [];

  async aboutToAppear(): Promise<void> {
    try {
      this.trips = await TripService.getInstance().getAllTrips();

      if (this.trips.length === 0) {
        const mockTrips: Trip[] = [
          {
            id: generateId(),
            name: '巴黎浪漫之旅',
            type: TripType.OTHER,
            startDate: Date.now() - 86400000 * 5,
            endDate: Date.now() - 86400000 * 2,
            destination: '法国·巴黎',
            notes: '埃菲尔铁塔、卢浮宫、塞纳河游船',
            status: TripStatus.COMPLETED,
            coverImage: 'https://images.unsplash.com/photo-1642947392578-b37fbd9a4d45?w=800',
            createdAt: Date.now() - 86400000 * 6,
            updatedAt: Date.now() - 86400000 * 2
          },
          {
            id: generateId(),
            name: '东京美食探索',
            type: TripType.OTHER,
            startDate: Date.now() - 86400000 * 10,
            endDate: Date.now() - 86400000 * 7,
            destination: '日本·东京',
            notes: '寿司、拉面、居酒屋',
            status: TripStatus.COMPLETED,
            coverImage: 'https://images.unsplash.com/photo-1648871647634-0c99b483cb63?w=800',
            createdAt: Date.now() - 86400000 * 11,
            updatedAt: Date.now() - 86400000 * 7
          },
          {
            id: generateId(),
            name: '瑞士雪山徒步',
            type: TripType.WALKING,
            startDate: Date.now() + 86400000 * 7,
            endDate: Date.now() + 86400000 * 14,
            destination: '瑞士',
            notes: '少女峰、马特洪峰',
            status: TripStatus.PLANNING,
            coverImage: 'https://images.unsplash.com/photo-1531366936337-7c912a3de96d?w=800',
            createdAt: Date.now() - 86400000 * 1,
            updatedAt: Date.now() - 86400000 * 1
          }
        ];

        for (const trip of mockTrips) {
          await TripService.getInstance().createTrip(trip);
        }

        this.trips = await TripService.getInstance().getAllTrips();
      }
    } catch (error) {
      console.error('Failed to load trips:', error);
    }
  }

  @Builder
  TripCard(trip: Trip) {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (trip.coverImage) {
          Image(trip.coverImage)
            .width('100%')
            .height(192)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: 24, topRight: 24 })
        } else {
          Column() {
          }
          .width('100%')
          .height(192)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
          })
          .borderRadius({ topLeft: 24, topRight: 24 })
        }

        Column() {
        }
        .width('100%')
        .height(192)
        .linearGradient({
          angle: 180,
          colors: [['transparent', 0.0], ['rgba(0, 0, 0, 0.6)', 1.0]]
        })
        .borderRadius({ topLeft: 24, topRight: 24 })

        Row() {
          Text(trip.status === TripStatus.COMPLETED ? '已完成' : '计划中')
            .fontSize(12)
            .fontColor(AppColors.Primary)
            .fontWeight(500)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .borderRadius(16)
        .position({ x: '100%', y: 16 })
        .translate({ x: '-100%' })

        Text(trip.name)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .padding({ left: 16, bottom: 16 })
      }
      .width('100%')
      .height(192)

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('sys.media.ohos_ic_public_location'))
            .width(16)
            .height(16)
            .fillColor(AppColors.Primary)

          Text(trip.destination || '未设置目的地')
            .fontSize(14)
            .fontColor('#6B7280')
        }
        .alignItems(VerticalAlign.Center)

        Row({ space: 8 }) {
          Image($r('sys.media.ohos_ic_public_clock'))
            .width(16)
            .height(16)
            .fillColor('#F59E0B')

          Text(`${new Date(trip.startDate).toLocaleDateString()} - ${trip.endDate ? new Date(trip.endDate).toLocaleDateString() : '进行中'}`)
            .fontSize(12)
            .fontColor('#9CA3AF')
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(24)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetY: 4
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/TripDetailPage',
        params: {
          tripId: trip.id
        }
      });
    })
  }

  build() {
    Column() {
      Row() {
        Text('我的行程')
          .fontSize(24)
          .fontColor(AppColors.TextPrimary)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button() {
          Image($r('sys.media.ohos_ic_public_add'))
            .width(20)
            .height(20)
            .fillColor(Color.White)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .linearGradient({
          angle: 135,
          colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/CreateTripPage'
          });
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 48, bottom: 24 })
      .backgroundColor(Color.White)
      .shadow({
        radius: 4,
        color: 'rgba(0, 0, 0, 0.04)',
        offsetY: 2
      })

      if (this.trips.length === 0) {
        Column() {
          Text('暂无行程')
            .fontSize(18)
            .fontColor('#9CA3AF')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 16 }) {
          ForEach(this.trips, (trip: Trip) => {
            ListItem() {
              this.TripCard(trip)
            }
          }, (trip: Trip) => trip.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 24, right: 24, bottom: 100 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [
        ['rgba(20, 184, 166, 0.05)', 0.0],
        ['rgba(13, 148, 136, 0.05)', 1.0]
      ]
    })
  }
}
