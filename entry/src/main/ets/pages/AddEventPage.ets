import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { tagDialog } from '../view/tagDialog'
import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'
import dayjs from "dayjs";

@Entry
@Component
struct AddEventPage {
  private EventTable: EventTable = new EventTable();
  @Provide selectTag: string = '';
  @State selectTime: string = '';
  @State selectDate: string = '';
  selectDeadline: Date = new Date();
  noteText: string = '';
  titleText: string = '';
  @State isDateChoose: boolean = false;
  @State isTimeChoose: boolean = false;
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
    if (!this.isDateChoose) {
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
    callback(null, tmp);
  }

  insertEvent(newEvent: EventData) {
    this.EventTable.insertData(newEvent, (id: number) => {
      newEvent.id = id;
    });
  }

  aboutToAppear() {
    this.selectDeadline.setHours(0, 0);
    this.EventTable.getRdbStore(() => {
    });
  }

  build() {
    Column() {
      Column({ space: 15 }) {
        Row({ space: 20 }) {
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
                  this.insertEvent(newEvent);
                  emitter.emit({ eventId: 1 })
                  router.back();
                }
              })
            })
        }.width('100%')
        .justifyContent(FlexAlign.End)

        Row() {
          Text('新建事项').titleStyle()
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
              TextInput({ placeholder: '标题' })
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
                Button(this.isDateChoose ? this.selectDate : "截止时间")
                  .btStyle(() => {
                    DatePickerDialog.show({
                      start: new Date(),
                      end: new Date("2100-12-31"),
                      selected: this.selectDeadline,
                      onAccept: (value: DatePickerResult) => {
                        this.selectDeadline.setFullYear(value.year, value.month, value.day)
                        this.selectDate = dayjs(this.selectDeadline).format("YYYY-MM-DD");
                        this.isDateChoose = true;
                      }
                    })
                  })
                if (this.isDateChoose)
                  Button((this.isTimeChoose ? this.selectTime : "0:0"))
                    .btStyle(() => {
                      TimePickerDialog.show({
                        selected: this.selectDeadline,
                        useMilitaryTime: true,
                        onAccept: (value: TimePickerResult) => {
                          this.selectDeadline.setHours(value.hour, value.minute);
                          this.selectTime = dayjs(this.selectDeadline).format("HH:mm");
                          this.isTimeChoose = true;
                        }
                      })
                    })
              }
            }
          }

          ListItem() {
            inputItem({ icon: $r('app.media.ic_note') }) {
              TextArea({ placeholder: '笔记' })
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