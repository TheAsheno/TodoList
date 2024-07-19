import TagTable from '../common/database/tables/TagTable'
import TagData from '../viewmodel/TagData'

@CustomDialog
export struct tagDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: tagDialog
  })
  private TagTable: TagTable = new TagTable();
  @State tags: Array<TagData> = [];
  @Consume selectTag: string;

  aboutToAppear() {
    this.TagTable.getRdbStore(() => {
      this.TagTable.queryData((result) => {
        this.tags = result;
      })
    })
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row() {
          Text('标签').fontSize(20)
        }.width('100%')
        .justifyContent(FlexAlign.Center)

        List() {
          ForEach(this.tags, (tag: TagData) => {
            tagItem(tag, () => {
              this.selectTag = tag.znName;
              this.controller.close();
            })
          })
        }.tagListStyle()

        Button('关闭')
          .fontColor($r('app.color.closeTagButtonColor'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.controller.close())
      }
      .backgroundColor("#EEEEEE")
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }
    .width('80%')
  }
}

@Builder function tagItem(tag: TagData, callback: () => void) {
  Row() {
    Text(tag.znName)
      .fontSize(15)
    if (tag.enName)
      Text(' - ' + tag.enName).fontSize(15)
    Blank()
    Image($rawfile(`${tag.icon}`))
      .width(20)
      .height(20)
  }.width('100%')
  .padding(15)
  .onClick(() => {
    callback();
  })
}

@Extend(List) function tagListStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r('app.color.listBackground'))
  .borderRadius(15)
  .constraintSize({ maxHeight: 300 })
}