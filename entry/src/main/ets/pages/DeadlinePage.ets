import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import emitter from '@ohos.events.emitter'
import dayjs from "dayjs";
import UrgencyDataModel from '../model/UrgencyDataModel';
import { urgencyInfoBean } from '../viewmodel/UrgencyData';

@Entry
@Component
export struct DeadlinePage {
  private EventTable: EventTable = new EventTable();
  @Provide totalCount: number = 0;
  @State @Watch('onUrgencyChange') urgencyList: Array<urgencyInfoBean> = [];
  @State @Watch('onListChange') lv1ListData: Array<EventData> = [];
  @State @Watch('onListChange') lv2ListData: Array<EventData> = [];
  @State @Watch('onListChange') lv3ListData: Array<EventData> = [];
  @State @Watch('onListChange') lv4ListData: Array<EventData> = [];
  @State @Watch('onListChange') expireListData: Array<EventData> = [];
  @State @Watch('onListChange') residualListData: Array<EventData> = [];
  @State daysLaterList: string[] = [];
  @Provide maxDays: number = 0;

  onUrgencyChange() {
    if (this.urgencyList.length == 4) {
      this.daysLaterList = [];
      for (let i = 0; i < 4; i++) {
        this.daysLaterList[i] = dayjs().add(Number(this.urgencyList[i].days), 'day').format("YYYY-MM-DD HH:mm");
      }
      this.maxDays = Number(this.urgencyList[3].days);
      this.initOrRefresh()
    }
  }

  aboutToAppear() {
    this.urgencyList = UrgencyDataModel.urgencyList;
    this.EventTable.getRdbStore(() => {});
    emitter.on({ eventId: 1 }, () => {
      this.initOrRefresh();
    })
    emitter.on({ eventId: 2 }, () => {
      this.initOrRefresh();
    })
    emitter.on({ eventId: 3 }, () => {
      this.urgencyList = UrgencyDataModel.urgencyList;
    })
  }

  initOrRefresh() {
    this.EventTable.queryData((result: EventData[]) => {
      this.lv1ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: dayjs().format("YYYY-MM-DD HH:mm"), end: this.daysLaterList[0] }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv2ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.daysLaterList[0], end: this.daysLaterList[1] }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv3ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.daysLaterList[1], end: this.daysLaterList[2] }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.lv4ListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeBetween: { begin: this.daysLaterList[2], end: this.daysLaterList[3] }
    });
    this.EventTable.queryData((result: EventData[]) => {
      this.expireListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      deadlineTimeExpire: true });
    this.EventTable.queryData((result: EventData[]) => {
      this.residualListData = result;
    }, {
      isDone: false,
      orderByDeadlineTimeAsc: true,
      greaterThanDeadlineTime: this.daysLaterList[3] });
  }

  onListChange() {
    this.totalCount = this.lv1ListData.length + this.lv2ListData.length + this.lv3ListData.length + this.lv4ListData.length + this.expireListData.length + this.residualListData.length;
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

        Divider()
          .strokeWidth(2)
          .lineCap(LineCapStyle.Square)
          .margin({ left: 10, right: 10, bottom: 10 })

        Column({ space: 20 }) {
          Row() {
            Text('待办事项').fontSize($r('app.float.font_size_MP'))
            Blank()
            Text(`总数：${this.totalCount}`)
              .fontSize($r('app.float.font_size_M'))
          }.width('100%')

          Row() {
            lineItem({ length: this.residualListData.length, color: $r('app.color.deadlineResidualColor') })
            lineItem({ length: this.lv4ListData.length, color: $r('app.color.deadlineLv4Color') })
            lineItem({ length: this.lv3ListData.length, color: $r('app.color.deadlineLv3Color') })
            lineItem({ length: this.lv2ListData.length, color: $r('app.color.deadlineLv2Color') })
            lineItem({ length: this.lv1ListData.length, color: $r('app.color.deadlineLv1Color') })
            lineItem({ length: this.expireListData.length, color: $r('app.color.deadlineExpireColor') })
          }.width('90%')
          .justifyContent(FlexAlign.Start)
        }.width('100%')

        List({ space: 15 }) {
          if (this.expireListData.length != 0) {
            ListItem() {
              this.listHeader('已过期')
            }
            ListItemGroup() {
              ForEach(this.expireListData, (item, index) => {
                ListItem() {
                  EventItem({ event: item,
                    color: $r('app.color.deadlineExpireColor'),
                    updateList: () => {
                      this.updateEvent(item);
                      this.expireListData.splice(index, 1);
                    } })
                }
              })
            }.listBgStyle()
          }

          ListItem() {
            this.listHeader('Lv1', 1)
          }

          ListItemGroup() {
            ForEach(this.lv1ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  color: $r('app.color.deadlineLv1Color'),
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv1ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            this.listHeader('Lv2', 2)
          }

          ListItemGroup() {
            ForEach(this.lv2ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  color: $r('app.color.deadlineLv2Color'),
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv2ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()


          ListItem() {
            this.listHeader('Lv3', 3)
          }

          ListItemGroup() {
            ForEach(this.lv3ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  color: $r('app.color.deadlineLv3Color'),
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv3ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()

          ListItem() {
            this.listHeader('Lv4', 4)
          }

          ListItemGroup() {
            ForEach(this.lv4ListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  color: $r('app.color.deadlineLv4Color'),
                  updateList: () => {
                    this.updateEvent(item);
                    this.lv4ListData.splice(index, 1);
                  } })
              }
            })
          }.listBgStyle()

          ListItem() {
            this.listHeader('其余任务')
          }

          ListItemGroup() {
            ForEach(this.residualListData, (item, index) => {
              ListItem() {
                EventItem({ event: item,
                  color: $r('app.color.deadlineResidualColor'),
                  updateList: () => {
                    this.updateEvent(item);
                    this.residualListData.splice(index, 1);
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
  @Builder listHeader(listTitle: string, index?: number) {
  Column({ space: 5 }) {
    Divider()
      .strokeWidth(1)
      .lineCap(LineCapStyle.Square)
      .margin({ top: 10, bottom: 10 })
    if (!index) {
      Row({ space: 10 }) {
        Text(listTitle).typeStyle()
        Blank()
      }.width('100%')
    }
    else if (this.urgencyList.length == 4) {
      Row({ space: 10 }) {
        Text(this.urgencyList[index - 1].depict).typeStyle()
        Text(`（${this.urgencyList[index - 1].days}天内）`)
          .fontSize($r('app.float.font_size_S'))
          .fontColor($r('app.color.promptTextColor'))
        Blank()
      }.width('100%')
    }
  }.margin({ top: 15 })
}
}

@Component
struct lineItem {
  @Consume totalCount: number;
  @Prop length: number;
  color: Resource;

  build() {
    if (this.length != 0) {
      Line()
        .strokeWidth(8)
        .startPoint([0, 0])
        .endPoint([this.length / this.totalCount * 320, 0])
        .stroke(this.color)
        .strokeLineCap(LineCapStyle.Round)
    }
  }
}

@Component
struct EventItem {
  @ObjectLink event: EventData;
  @Consume maxDays: number;
  updateList: () => void;
  color: Resource;

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
          .circleStyle(this.color)
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        router.pushUrl({ url: 'pages/EventPage', params: { event: this.event } })
      })
      if (this.maxDays)
        Progress({
          value: this.maxDays * 24 - dayjs(this.event.deadlineTime).diff(dayjs(), 'hour'),
          total: this.maxDays * 24,
          type: ProgressType.Linear
        })
          .width('90%')
          .height(4)
          .alignSelf(ItemAlign.End)
          .color(this.color)
    }.padding(10)
  }
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
  .backgroundColor($r("app.color.listBgColor"))
  .borderRadius(15)
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}