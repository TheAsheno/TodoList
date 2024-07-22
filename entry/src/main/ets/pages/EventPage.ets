import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import ScheduleTable from '../common/database/tables/ScheduleTable';
import ScheduleData from '../viewmodel/ScheduleData';
import { scheduleDialog } from '../view/scheduleDialog'
import emitter from '@ohos.events.emitter'
import dayjs from "dayjs";
import UrgencyDataModel from '../model/UrgencyDataModel';

@Entry
@Component
struct EventPage {
  params = router.getParams();
  @State event: EventData = this.params['event'];
  @State isScheduleOpen: boolean = false;
  @Provide newSchedule: ScheduleData = new ScheduleData({ id: 0, text: '', time: '', eventId: this.event.id });
  @State scheduleList: Array<ScheduleData> = [];
  private ScheduleTable: ScheduleTable = new ScheduleTable();
  private EventTable: EventTable = new EventTable();
  @Provide selectTag: string = '';
  @State selectTime: string = '';
  @State selectDate: string = '';
  selectDeadline: Date = new Date();
  noteText: string = '';
  titleText: string = '';
  scroller: Scroller = new Scroller()
  scheduleDialogController: CustomDialogController = new CustomDialogController({
    builder: scheduleDialog({ eventId: this.event.id }),
    customStyle: true,
    autoCancel: false
  })

  deleteEvent() {
    if (this.scheduleList.length > 0) {
      for (let i = 0; i < this.scheduleList.length; i++)
        this.ScheduleTable.deleteData(this.scheduleList[i].id, () => {});
    }
    this.EventTable.deleteData(this.event.id, () => {
      emitter.emit({ eventId: 1 })
      router.back();
    });
  }

  insertSchedule() {
    this.scheduleList.push(this.newSchedule);
    this.isScheduleOpen = true;
    this.scroller.scrollEdge(Edge.Bottom)
  }

  getResidualDays(time: string) {
    let diff = dayjs(time).diff(dayjs(), 'day');
    if (diff < 0)
      return '已过期';
    else
      return  '还有' + (diff + 1) + '天';
  }

  aboutToAppear() {
    this.titleText = this.event.name;
    this.noteText = this.event.note;
    this.selectTag = this.event.tag;
    this.selectDeadline = new Date(this.event.deadlineTime);
    this.selectDate = dayjs(this.selectDeadline).format("YYYY-MM-DD");
    this.selectTime = dayjs(this.selectDeadline).format("HH:mm");
    this.EventTable.getRdbStore(() => {});
    this.ScheduleTable.getRdbStore(() => {
      this.ScheduleTable.queryData((result) => {
        this.scheduleList = result;
        if (this.scheduleList.length != 0) {
          this.isScheduleOpen = true;
          this.scroller.scrollEdge(Edge.Bottom)
        }
      }, { eventId: this.event.id })
    })
    emitter.on({ eventId: 4 }, () => {
      this.insertSchedule();
    })
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Row({ space: 30 }) {
          Image($r('app.media.ic_leftArrow'))
            .width($r('app.float.icon_size_L'))
            .height($r('app.float.icon_size_L'))
            .onClick(() => router.back())
          if (!this.event.isDone)
            Image($r('app.media.ic_addTag2'))
              .width($r('app.float.icon_size_L'))
              .height($r('app.float.icon_size_L'))
              .onClick(() => this.scheduleDialogController.open())
        }.width('100%')
        .justifyContent(FlexAlign.End)

        Text(this.event.name)
          .titleStyle()
          .margin({ left: 10, right: 10, bottom: 10 })

        Column({ space: 10 }) {
          Divider()
            .strokeWidth(2)
            .lineCap(LineCapStyle.Square)
            .margin({ left: 10, right: 10 })


          Row({ space: 10 }) {
            Image($rawfile('ic_tag_rt.svg'))
              .width($r('app.float.icon_size_S'))
              .height($r('app.float.icon_size_S'))
            Text(this.event.tag)
              .fontSize($r('app.float.font_size_M'))
            Blank()
            if (!this.event.isDone) {
              Text(this.getResidualDays(this.event.deadlineTime))
              Circle()
                .circleStyle(UrgencyDataModel.getCircleColor(this.event.deadlineTime))
            }
          }.width('80%')

          Divider()
            .strokeWidth(2)
            .lineCap(LineCapStyle.Square)
            .margin({ left: 10, right: 10 })
        }

        Stack({ alignContent: Alignment.Bottom }) {
          Column({ space: 15 }) {
            List({ space: 15 }) {
              ListItem() {
                infoItem({ text: '截止时间', time: this.event.deadlineTime })
              }
              ListItem() {
                infoItem({ text: '完成时间', time: this.event.isDone ? this.event.updateTime : '' })
              }
              ListItem() {
                infoItem({ text: '创建时间', time: this.event.createTime })
              }
            }.listBgStyle()

            if (this.event.note) {
              Row({ space: 10 }) {
                Image($r('app.media.ic_note'))
                  .height($r('app.float.icon_size_M'))
                  .width($r('app.float.icon_size_M'))
                  .fillColor($r('app.color.noteFontColor'))
                Text(this.event.note)
                  .fontColor($r('app.color.noteFontColor'))
                  .fontSize($r('app.float.font_size_M'))
                  .layoutWeight(1)
              }.width('90%')
              .padding(20)
              .borderRadius(10)
              .alignItems(VerticalAlign.Top)
              .backgroundColor($r('app.color.noteBgColor'))
            }

            Divider()
              .strokeWidth(2)
              .lineCap(LineCapStyle.Square)
              .margin({ left: 10, right: 10 })

            Column() {
              Row({ space: 10 }) {
                Image($r('app.media.ic_rightArrow'))
                  .height($r('app.float.icon_size_M'))
                  .width($r('app.float.icon_size_M'))
                  .rotate({ angle: this.isScheduleOpen ? 90 : 0 })
                  .animation({ duration: 200 })
                Text('任务进度')
                  .fontSize($r('app.float.font_size_M'))
              }.margin(10)
              .width('90%')
              .enabled(this.scheduleList.length != 0)
              .onClick(() => {
                this.isScheduleOpen = !this.isScheduleOpen;
              })
              .justifyContent(FlexAlign.Start)

              if (this.isScheduleOpen) {
                Scroll(this.scroller) {
                  List() {
                    ForEach(this.scheduleList, (item, index) => {
                      this.scheduleItem(item, index)
                    })
                  }.width('90%')
                  .height('100%')
                  .padding(5)
                }
                .height(200)
                .scrollable(ScrollDirection.Vertical)
                .scrollBarColor(Color.Grey)
                .scrollBar(BarState.On)
                .scrollBarWidth(5)
              }
            }
          }.height('100%')

          Column({ space: 5 }) {
            Button(this.event.isDone ? '未完成任务' : '完成任务')
              .width(280)
              .height(45)
              .fontSize($r('app.float.font_size_MP'))
              .fontColor($r("app.color.completeButtonFontColor"))
              .backgroundColor($r("app.color.completeButtonBgColor"))
              .onClick(() => {
                this.event.isDone = !this.event.isDone;
                this.EventTable.updateData(this.event, () => {
                  emitter.emit({ eventId: 1 })
                })
              })
            Button('删除任务')
              .scale({ x: 0.8, y: 0.8 })
              .width(220)
              .height(45)
              .fontSize($r('app.float.font_size_MP'))
              .fontColor($r('app.color.deleteButtonFontColor'))
              .backgroundColor($r('app.color.deleteButtonBgColor'))
              .onClick(() => {
                AlertDialog.show(
                  {
                    title: '删除该任务？',
                    message: '删除后无法恢复，您确认要删除吗？',
                    autoCancel: true,
                    alignment: DialogAlignment.Bottom,
                    offset: { dx: 0, dy: -20 },
                    primaryButton: {
                      value: '确认',
                      fontColor: $r('app.color.confirmButtonColor'),
                      action: () => {
                        this.deleteEvent();
                      }
                    },
                    secondaryButton: {
                      value: '取消',
                      action: () => {
                      }
                    }
                  }
                )
              })
          }.offset({ y: 20 })
        }.layoutWeight(1)
      }.width('90%')
      .justifyContent(FlexAlign.Start)
      .height('90%')
    }.pageBgStyle()
  }

  @Builder scheduleItem(item: ScheduleData, index: number) {
    Row({ space: 15 }) {
      Stack({ alignContent: Alignment.Top }) {
        if (this.scheduleList.length - 1 != index) {
          Line()
            .strokeWidth(2)
            .startPoint([0, 10])
            .endPoint([0, 50])
            .stroke($r('app.color.CircleStrokeColor'))
            .strokeLineCap(LineCapStyle.Square)
          Circle()
            .offset({ x: -1 })
            .height(10)
            .width(10)
            .fill($r('app.color.CircleFillColor'))
            .stroke($r('app.color.CircleStrokeColor'))
        }
        else {
          Circle()
            .offset({ x: -1 })
            .height(15)
            .width(15)
            .fill($r('app.color.CircleStrokeColor'))
            .stroke($r('app.color.CircleStrokeColor'))
        }
      }.width(40)
      .height('100%')

      Column() {
        Text(dayjs(item.time).format("MM-DD")).fontSize($r('app.float.font_size_M'))
        Text(dayjs(item.time).format("HH:mm")).fontSize($r('app.float.font_size_S'))
      }

      Text(item.text)
        .width(170)
        .fontSize($r('app.float.font_size_S'))
    }.width('90%')
    .height(50)
    .alignItems(VerticalAlign.Top)
  }
}

@Component
struct infoItem {
  @Prop text: string;
  @Prop time: string;
  build() {
    Row({ space: 10 }) {
      Image($r('app.media.ic_rightArrow'))
        .height($r('app.float.icon_size_M'))
        .width($r('app.float.icon_size_M'))
      Text(this.text)
        .fontSize($r('app.float.font_size_M')).fontSize($r('app.float.font_size_M'))
      Blank()
      if (this.time)
      Column() {
        Text(dayjs(this.time).format("YYYY-MM-DD")).fontSize($r('app.float.font_size_M'))
        Text(dayjs(this.time).format("HH:mm")).fontSize($r('app.float.font_size_S'))
      }.alignItems(HorizontalAlign.End)
    }.width('100%')
    .height(40)
  }
}

@Extend(List) function listBgStyle() {
  .padding(10)
  .margin({ left: 10, right: 10 })
  //.divider({ strokeWidth: 2, color: $r('app.color.dividerReverseColor'), startMargin: 0, endMargin: 0 })
  //.backgroundColor($r("app.color.listBgColor"))
  .borderRadius(15)
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .backgroundImage($r("app.media.img_event_bg"))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Extend(Text) function titleStyle() {
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.float.font_size_XL'))
  .margin({ left: 20 })
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}