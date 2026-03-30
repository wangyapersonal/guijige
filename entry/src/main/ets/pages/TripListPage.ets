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

  private primaryAlpha10 = 'rgba(20, 184, 166, 0.1)';
  private primaryAlpha20 = 'rgba(20, 184, 166, 0.2)';

  async aboutToAppear(): Promise<void> {
    try {
      this.trips = await TripService.getInstance().getAllTrips();

      // 如果没有数据，添加测试数据
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
      // 封面图区域（使用渐变色作为占位符）
      Stack({ alignContent: Alignment.BottomStart }) {
        // 封面背景
        Column() {
        }
        .width('100%')
        .height(180)
        .linearGradient({
          angle: 135,
          colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
        })
        .borderRadius({ topLeft: 24, topRight: 24 })

        // 渐变遮罩
        Column() {
        }
        .width('100%')
        .height(180)
        .linearGradient({
          angle: 180,
          colors: [['transparent', 0.0], ['rgba(0, 0, 0, 0.4)', 1.0]]
        })
        .borderRadius({ topLeft: 24, topRight: 24 })

        // 状态徽章
        Row() {
          Text(trip.status === 'completed' ? '已完成' : '计划中')
            .fontSize(12)
            .fontColor(AppColors.Primary)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .borderRadius(16)
        .position({ x: '100%', y: 16 })
        .translate({ x: '-100%' })

        // 标题
        Text(trip.name)
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 8 })
      }
      .width('100%')
      .height(180)
      .padding({ left: 16, right: 16, bottom: 16 })

      // 信息区域
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
            .fillColor('#9CA3AF')

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
      radius: 8,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetY: 2
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
      // 顶部 Header
      Row() {
        Text('我的行程')
          .fontSize(24)
          .fontColor(AppColors.TextPrimary)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button() {
          Column() {
          }
          .width(40)
          .height(40)
          .borderRadius(20)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.Primary, 0.0], [AppColors.PrimaryDark, 1.0]]
          })
        }
        .width(40)
        .height(40)
        .backgroundColor('transparent')
        .onClick(() => {
          router.pushUrl({
            url: 'pages/CreateTripPage'
          });
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 48, bottom: 24 })

      // 行程列表
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
    .backgroundColor(AppColors.Background)
  }
}
