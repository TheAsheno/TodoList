import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { tagDialog } from '../view/tagDialog'
import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'
import dayjs from "dayjs";
import { EventAction } from '../enums/EventAction'

@Entry
@Component
struct EventPage {
  params = router.getParams();
  event: EventData = this.params['event'];
  action: EventAction = this.params['action'];

  private EventTable: EventTable = new EventTable();
  @Provide selectTag: string = '';
  @State selectTime: string = '';
  @State selectDate: string = '';
  selectDeadline: Date = new Date();
  noteText: string = '';
  titleText: string = '';
  tagDialogController: CustomDialogController = new CustomDialogController({
    builder: tagDialog(),
    customStyle: true,
    autoCancel: false
  })

  checkEvent(callback: (err: string, newEvent: EventData) => void) {
    if (!this.titleText) {
      callback('标题不能为空', null);
      return;
    }
    if (!this.selectTag) {
      callback('请选择标签', null);
      return;
    }
    if (!this.selectDate) {
      callback('请输入截止时间', null);
      return;
    }
    let tmp: EventData = {
      id: 0,
      name: this.titleText,
      note: this.noteText,
      createTime: '',
      deadlineTime: this.selectDate + ' ' + this.selectTime,
      updateTime: '',
      tag: this.selectTag,
      isDone: false
    };
    if (this.action == EventAction.Update) {
      tmp.id = this.event.id;
      tmp.createTime = this.event.createTime;
      tmp.isDone = this.event.isDone;
    }
    callback(null, tmp);
  }

  insertEvent(newEvent: EventData) {
    this.EventTable.insertData(newEvent, (id: number) => {
      newEvent.id = id;
    });
  }

  updateEvent(newEvent: EventData) {
    this.EventTable.updateData(newEvent, () => {});
  }

  aboutToAppear() {
    if (this.action == EventAction.Update) {
      this.titleText = this.event.name;
      this.noteText = this.event.note;
      this.selectTag = this.event.tag;
      this.selectDeadline = new Date(this.event.deadlineTime);
      this.selectDate = dayjs(this.selectDeadline).format("YYYY-MM-DD");
      this.selectTime = dayjs(this.selectDeadline).format("HH:mm");
    }
    else if (this.action == EventAction.Insert)
      this.selectDeadline.setHours(0, 0);
    this.EventTable.getRdbStore(() => {
    });
  }

  build() {
    Column() {
      Column({ space: 15 }) {
        Row({ space: 30 }) {
          if (this.action == EventAction.Update)
            Image($r('app.media.ic_delete'))
              .width($r('app.float.icon_size_L'))
              .height($r('app.float.icon_size_L'))
              .onClick(() => {
                AlertDialog.show(
                  {
                    title: '删除该事项？',
                    message: '删除后无法恢复，您确认要删除吗？',
                    autoCancel: true,
                    alignment: DialogAlignment.Bottom,
                    offset: { dx: 0, dy: -20 },
                    primaryButton: {
                      value: '确认',
                      fontColor: Color.Red,
                      action: () => {
                        this.EventTable.deleteData(this.event.id, () => {});
                        emitter.emit({ eventId: 1 })
                        router.back();
                      }
                    },
                    secondaryButton: {
                      value: '取消',
                      action: () => {}
                    }
                  }
                )
              })
          Image($r('app.media.ic_leftArrow'))
            .width($r('app.float.icon_size_L'))
            .height($r('app.float.icon_size_L'))
            .onClick(() => router.back())
          Image($r("app.media.ic_yes"))
            .width($r('app.float.icon_size_L'))
            .height($r('app.float.icon_size_L'))
            .onClick(() => {
              this.checkEvent((err, newEvent) => {
                if (err) {
                  promptAction.showToast({
                    message: err,
                    duration: 2000,
                    bottom: 50
                  });
                }
                else {
                  if (this.action == EventAction.Insert)
                    this.insertEvent(newEvent);
                  else if (this.action == EventAction.Update)
                    this.updateEvent(newEvent);
                  emitter.emit({ eventId: 1 })
                  router.back();
                }
              })
            })
        }.width('100%')
        .justifyContent(FlexAlign.End)

        Row() {
          Text(this.action == EventAction.Insert ? '新建事项' : '查看事项').titleStyle()
          Blank()
        }.width('100%')
        .margin(10)

        Divider()
          .strokeWidth(2)
          .lineCap(LineCapStyle.Square)
          .margin({ left: 10, right: 10, bottom: 10 })

        List({ space: 30 }) {
          ListItem() {
            inputItem({ icon: $r('app.media.ic_title') }) {
              TextInput({ placeholder: '标题', text: this.titleText })
                .height(40)
                .layoutWeight(1)
                .caretColor(Color.Black)
                .onChange((value) => {
                  this.titleText = value;
                })
            }
          }

          ListItem() {
            inputItem({ icon: $r('app.media.ic_tags') }) {
              Button(this.selectTag ? this.selectTag : '选择标签')
                .btStyle(() => {
                  this.tagDialogController.open()
                })
            }
          }

          ListItem() {
            inputItem({ icon: $r('app.media.ic_time') }) {
              Row({ space: 10 }) {
                Button(this.selectDate ? this.selectDate : "截止时间")
                  .btStyle(() => {
                    DatePickerDialog.show({
                      start: new Date(),
                      end: new Date("2100-12-31"),
                      selected: this.selectDeadline,
                      onAccept: (value: DatePickerResult) => {
                        this.selectDeadline.setFullYear(value.year, value.month, value.day)
                        this.selectDate = dayjs(this.selectDeadline).format("YYYY-MM-DD");
                      }
                    })
                  })
                if (this.selectDate)
                  Button((this.selectTime ? this.selectTime : "0:0"))
                    .btStyle(() => {
                      TimePickerDialog.show({
                        selected: this.selectDeadline,
                        useMilitaryTime: true,
                        onAccept: (value: TimePickerResult) => {
                          this.selectDeadline.setHours(value.hour, value.minute);
                          this.selectTime = dayjs(this.selectDeadline).format("HH:mm");
                        }
                      })
                    })
              }
            }
          }

          ListItem() {
            inputItem({ icon: $r('app.media.ic_note') }) {
              TextArea({ placeholder: '笔记', text: this.noteText })
                .width(280)
                .height(300)
                .padding(20)
                .fontSize($r('app.float.font_size_MP'))
                .backgroundColor(Color.Transparent)
                .borderColor(Color.Black)
                .borderWidth(1)
                .caretColor(Color.Black)
                .onChange((value) => {
                  this.noteText = value;
                })
            }
          }
        }.width('90%')
      }.width('90%')
      .justifyContent(FlexAlign.Start)
      .height('90%')
    }.pageBgStyle()
  }
}

@Component
struct inputItem {
  icon: Resource;
  @BuilderParam content: () => void;

  build() {
    Row({ space: 15 }) {
      Image(this.icon)
        .height($r('app.float.icon_size_M'))
        .width($r('app.float.icon_size_M'))
      this.content()
    }

    .alignItems(VerticalAlign.Top)
  }
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .backgroundImage($r('app.media.img_add_bg7'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Extend(Text) function titleStyle() {
  .alignSelf(ItemAlign.Start)
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.float.font_size_XXL'))
  .margin({ left: 20 })
}

@Extend(Button) function btStyle(callback: () => void) {
  .fontSize($r('app.float.font_size_M'))
  .fontColor(Color.Grey)
  .backgroundColor('#DFDFDE')
  .onClick(callback)
}