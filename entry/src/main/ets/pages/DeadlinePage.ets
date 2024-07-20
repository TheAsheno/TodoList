import router from '@ohos.router'
import { getCircleColor } from '../common/utils/ColorUtil'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { EventAction } from '../enums/EventAction'
import emitter from '@ohos.events.emitter'
import dayjs from "dayjs";
import { UrgencyValue } from '../enums/UrgencyValue'

@Entry
@Component
export struct DeadlinePage {
  private EventTable: EventTable = new EventTable();
  @State lv1ListData: Array<EventData> = [];
  @State lv2ListData: Array<EventData> = [];
  @State lv3ListData: Array<EventData> = [];
  @State lv4ListData: Array<EventData> = [];
  @State expireListData: Array<EventData> = [];
  lv1DaysLater = dayjs().add(UrgencyValue.Lv1, 'day').format("YYYY-MM-DD HH:mm");
  lv2DaysLater = dayjs().add(UrgencyValue.Lv2, 'day').format("YYYY-MM-DD HH:mm");
  lv3DaysLater = dayjs().add(UrgencyValue.Lv3, 'day').format("YYYY-MM-DD HH:mm");
  lv4DaysLater = dayjs().add(UrgencyValue.Lv4, 'day').format("YYYY-MM-DD HH:mm");

  aboutToAppear() {
    this.EventTable.getRdbStore(() => {
      this.initOrRefresh()
    });
    emitter.on({ eventId: 1 }, () => {
      this.initOrRefresh();
    })
    emitter.on({ eventId: 2 }, () => {
      this.initOrRefresh();
    })
  }

  initOrRefresh() {
    this.EventTable.queryData((result: EventData[]) => {
      this.lv1ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: dayjs().format("YYYY-MM-DD HH:mm"), end: this.lv1DaysLater }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv2ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.lv1DaysLater, end: this.lv2DaysLater }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv3ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.lv2DaysLater, end: this.lv3DaysLater }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv4ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.lv3DaysLater, end: this.lv4DaysLater }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.expireListData = result;
    }, { isDone: false, orderByDeadlineTimeAsc: true, deadlineTimeExpire: true });
  }

  updateEvent(newEvent: EventData) {
    this.EventTable.updateData(newEvent, () => {
      emitter.emit({ eventId: 1 })
    });
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Row() {
          Text('截止时间').titleStyle()
          Blank()
        }.width('100%')
        .margin(10)

        List({ space: 15 }) {

          ListItem() {
            listHeader('已过期')
          }

          ListItemGroup() {
            ForEach(this.expireListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  updateList: () => {
                    this.updateEvent(item);
                    this.expireListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            listHeader('非常紧急', `（${UrgencyValue.Lv1}天内）`)
          }

          ListItemGroup() {
            ForEach(this.lv1ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv1ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            listHeader('紧急', `（${UrgencyValue.Lv2}天内）`)
          }

          ListItemGroup() {
            ForEach(this.lv2ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv2ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            listHeader('还有时间', `（${UrgencyValue.Lv3}天内）`)
          }

          ListItemGroup() {
            ForEach(this.lv3ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv3ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            listHeader('该开始了', `（${UrgencyValue.Lv4}天内）`)
          }

          ListItemGroup() {
            ForEach(this.lv4ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv4ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()

        }.layoutWeight(1)
        .height('90%')
      }.width('90%')
      .justifyContent(FlexAlign.Start)
      .height('90%')
    }.pageBgStyle()
  }
}

@Component
struct EventItem {
  @ObjectLink event: EventData;
  updateList: () => void;

  build() {
    Column({ space: 10 }) {
      Row({ space: 10 }) {
        Image(this.event.isDone ? $r('app.media.ic_done') : $r('app.media.ic_todo'))
          .height($r('app.float.icon_size_S'))
          .width($r('app.float.icon_size_S'))
          .onClick(() => {
            this.event.isDone = !this.event.isDone;
            this.updateList();
          })
        Text(this.event.name)
          .fontSize($r('app.float.font_size_M'))
          .opacity(this.event.isDone ? 0.4 : 1)
          .decoration({ type: this.event.isDone ? TextDecorationType.LineThrough : TextDecorationType.None })
        Blank()
        Column() {
          Text(dayjs(this.event.deadlineTime).format("YYYY-MM-DD")).fontSize($r('app.float.font_size_M'))
          Text(dayjs(this.event.deadlineTime).format("HH:mm A")).fontSize($r('app.float.font_size_S'))
        }.alignItems(HorizontalAlign.End)

        Circle()
          .circleStyle(getCircleColor(this.event.deadlineTime))
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        router.pushUrl({ url: 'pages/EventPage', params: { event: this.event, action: EventAction.Update } })
      })

      Progress({
        value: UrgencyValue.Lv4 * 24 - dayjs(this.event.deadlineTime).diff(dayjs(), 'hour'),
        total: UrgencyValue.Lv4 * 24,
        type: ProgressType.Linear
      })
        .width('90%')
        .height(4)
        .alignSelf(ItemAlign.End)
        .color(getCircleColor(this.event.deadlineTime))
    }.padding(10)
  }
}

@Builder function listHeader(listTitle: string, promptText?: string) {
  Column({ space: 5 }) {
    Divider()
      .strokeWidth(1)
      .lineCap(LineCapStyle.Square)
      .margin({ top: 10, bottom: 10 })
    Row({ space: 10 }) {
      Text(listTitle).typeStyle()
      if (promptText)
        Text(promptText)
          .fontSize($r('app.float.font_size_S'))
          .fontColor(Color.Grey)
      Blank()
    }.width('100%')
  }.margin({ top: 15 })
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .backgroundImage($r("app.media.img_deadline_bg"))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Extend(Text) function titleStyle() {
  .alignSelf(ItemAlign.Start)
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.float.font_size_XXL'))
  .margin({ left: 20 })
}

@Extend(Text) function typeStyle() {
  .fontSize($r('app.float.font_size_MP'))
  .alignSelf(ItemAlign.Start)
}

@Extend(ListItemGroup) function listBgStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r('app.color.listBackground'))
  .borderRadius(15)
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}