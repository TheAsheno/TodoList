import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { tagDialog } from '../view/tagDialog'
import { dateFormat }  from '../common/utils/DateUtil'

@Entry
@Component
struct AddEventPage {
  //private EventTable: EventTable = new EventTable();
  //private TagTable: TagTable = new TagTable();
  @State isEdit: boolean = false;
  @Provide selectTag: string = '';
  @State date: Date = new Date();
  @State isTimeChoose: boolean = false;
  tagDialogController: CustomDialogController = new CustomDialogController({
    builder: tagDialog(),
    customStyle: true,
    autoCancel: false
  })

  build() {
    Column() {
      Column({ space: 15 }) {
        Row({ space: 20 }) {
          Image($r('app.media.ic_sort'))
            .width(30)
            .height(30)
          Image($r("app.media.ic_mg"))
            .width(30)
            .height(30)
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
              Button(this.isTimeChoose ? dateFormat(this.date) : "截止时间")
                .btStyle(() => {
                  DatePickerDialog.show({
                    start: new Date(),
                    end: new Date("2100-12-31"),
                    selected: this.date,
                    onAccept: (value: DatePickerResult) => {
                      this.date.setFullYear(value.year, value.month, value.day)
                      this.isTimeChoose = true;
                    }
                  })
                })
            }
          }

          ListItem() {
            inputItem({ icon: $r('app.media.ic_note') }) {
              TextArea()
                .width(250)
                .height(300)
                .padding(20)
                .backgroundColor(Color.Transparent)
                .borderColor(Color.Black)
                .borderWidth(1)
                .caretColor(Color.Black)
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
    Row({ space: 10 }) {
      Image(this.icon)
        .height(25)
        .width(25)
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
  .fontSize(30)
  .margin({ left: 20 })
}

@Extend(Button) function btStyle(callback: () => void) {
  .fontSize(15)
  .fontColor(Color.Grey)
  .backgroundColor('#DFDFDE')
  .onClick(callback)
}