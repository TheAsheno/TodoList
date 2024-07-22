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
      this.TagTable.queryData((result: TagData[]) => {
        this.tags = result;
      })
    })
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row() {
          Text('标签').fontSize($r('app.float.font_size_MP'))
        }.width('100%')
        .justifyContent(FlexAlign.Center)

        List() {
          ForEach(this.tags, (tag: TagData) => {
            this.tagItem(tag)
          })
        }.tagListStyle()

        Button('关闭')
          .fontColor($r("app.color.closeButtonColor"))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.controller.close())
      }
      .backgroundColor($r('app.color.dialogBgColor'))
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }.width('80%')
  }

  @Builder tagItem(tag: TagData) {
    Row() {
      Text(tag.znName)
        .fontSize($r('app.float.font_size_M'))
      if (tag.enName)
        Text(' - ' + tag.enName).fontSize($r('app.float.font_size_M'))
      Blank()
      Image($rawfile(`${tag.icon}`))
        .width($r('app.float.icon_size_S'))
        .height($r('app.float.icon_size_S'))
    }.width('100%')
    .padding(15)
    .onClick(() => {
      this.selectTag = tag.znName;
      this.controller.close();
    })
  }
}

@Extend(List) function tagListStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r("app.color.listBgColor"))
  .borderRadius(15)
  .constraintSize({ maxHeight: 300 })
}