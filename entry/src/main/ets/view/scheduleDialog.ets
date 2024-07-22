import promptAction from '@ohos.promptAction'
import emitter from '@ohos.events.emitter'
import ScheduleTable from '../common/database/tables/ScheduleTable';
import ScheduleData from '../viewmodel/ScheduleData';
import dayjs from "dayjs";

@CustomDialog
export struct scheduleDialog {
  private ScheduleTable: ScheduleTable = new ScheduleTable();
  @Prop eventId: number;
  controller: CustomDialogController = new CustomDialogController({
    builder: scheduleDialog
  })
  @Consume newSchedule: ScheduleData;
  @State text: string = '';

  aboutToAppear() {
    this.ScheduleTable.getRdbStore(() => {});
  }

  insertSchedule() {
    let tmp: ScheduleData = new ScheduleData({ id: 0, text: this.text, time: dayjs().format("YYYY-MM-DD HH:mm"), eventId: this.eventId })
    this.ScheduleTable.insertData(tmp, (id) => {
      tmp.id = id;
      this.newSchedule = new ScheduleData(tmp);
      emitter.emit({ eventId: 4 });
      this.controller.close();
    });
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Text('更新进度').fontSize($r('app.float.font_size_MP'))

        TextInput({ placeholder: '不超过40个字' })
          .onChange((value) => {
            this.text = value;
          })
        Row() {
          Button('取消')
            .fontColor($r("app.color.closeButtonColor"))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.controller.close())
          Button('确认')
            .fontColor($r('app.color.confirmButtonColor'))
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              if (!this.text)
                promptAction.showToast({
                  message: '请输入文本',
                  duration: 2000,
                  bottom: 50
                });
              else {
                this.insertSchedule();
              }
            })
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .backgroundColor($r('app.color.dialogBgColor'))
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }
    .width('80%')
  }
}