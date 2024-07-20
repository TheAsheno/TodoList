import TagTable from '../common/database/tables/TagTable'
import TagData from '../viewmodel/TagData'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import promptAction from '@ohos.promptAction'

@CustomDialog
export struct tagCustomDialog {
  private TagTable: TagTable = new TagTable();
  private EventTable: EventTable = new EventTable();
  controller: CustomDialogController = new CustomDialogController({
    builder: tagCustomDialog
  })
  @State isEdit: boolean = false;
  @State isInsert: boolean = false;
  tagZnName: string = '';
  tagEnName: string = '';
  @State tags: Array<TagData> = [{ id: 5, znName: '哈哈哈', enName: 'hahaha', icon: 'ic_tag_custom.svg' }];

  aboutToAppear() {
    this.TagTable.getRdbStore(() => {
      this.TagTable.queryData((result: TagData[]) => {
        this.tags = result;
      }, { isCustom: true })
    })
    this.EventTable.getRdbStore(() => {

    })
  }

  insertTag() {
    let tmp: TagData = { id: 0, znName: this.tagZnName, enName: this.tagEnName, icon: 'ic_tag_custom.svg' };
    this.TagTable.insertData(tmp, (id) => {
      tmp.id = id;
      this.tags.push(tmp);
      this.isInsert = false;
    })
  }

  deleteTag(tagIndex: number) {
    this.EventTable.queryData((result: EventData[]) => {
      if (result.length == 0)
        this.TagTable.deleteData(this.tags[tagIndex].id, () => {
          this.tags.splice(tagIndex, 1);
        });
      else
        promptAction.showToast({
          message: '无法删除正在使用的标签',
          duration: 2000,
          bottom: 50
        });
    }, { tag: this.tags[tagIndex].znName })
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row({ space: 15 }) {
          Text('自定义标签').fontSize($r('app.float.font_size_MP'))
          Blank()
          if (this.isInsert)
            this.imageItem($r('app.media.ic_leftArrow'), !this.isEdit, () => this.isInsert = false)
          else
            this.imageItem($r('app.media.ic_addTag2'), !this.isEdit, () => this.isInsert = true)
          this.imageItem($r('app.media.ic_mg'), !this.isInsert && this.tags.length != 0, () => this.isEdit = !this.isEdit)
        }.width('100%')
        .justifyContent(FlexAlign.Start)
        if (this.isInsert) {
          TextInput({ placeholder: '中文名称'})
            .onChange((value) => {
              this.tagZnName = value;
            })
          TextInput({ placeholder: '英文名称（可以为空）'})
          .onChange((value) => {
            this.tagEnName = value;
          })
          Row() {
            Button('取消')
              .fontColor($r('app.color.closeTagButtonColor'))
              .backgroundColor(Color.Transparent)
              .onClick(() => this.controller.close())
            Button('确认')
              .fontColor(Color.Red)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.insertTag();
              })
          }.width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
        else {
          if (this.tags.length == 0)
            Image($r('app.media.ic_empty'))
              .width($r('app.float.icon_size_XL'))
              .height($r('app.float.icon_size_XL'))
          else
          List() {
            ForEach(this.tags, (tag: TagData, index) => {
              this.tagItem(tag, index)
            })
          }.tagListStyle()
          Button('关闭')
            .fontColor($r('app.color.closeTagButtonColor'))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.controller.close())

        }
      }
      .backgroundColor("#EEEEEE")
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }
    .width('80%')
  }

  @Builder imageItem(icon: Resource, enable: boolean, callback: () => void) {
    Image(icon)
      .enabled(enable)
      .width($r('app.float.icon_size_M'))
      .height($r('app.float.icon_size_M'))
      .onClick(callback)
  }

  @Builder tagItem(tag: TagData, index: number) {
    Row() {
      if (this.isEdit) {
        Image($r('app.media.ic_delete'))
          .width($r('app.float.icon_size_S'))
          .height($r('app.float.icon_size_S'))
          .margin({ right: 5 })
          .onClick(() => this.deleteTag(index))
      }
      Text(tag.znName)
        .fontSize(15)
      if (tag.enName)
        Text(' - ' + tag.enName).fontSize($r('app.float.font_size_M'))
      Blank()
      Image($rawfile(`${tag.icon}`))
        .width($r('app.float.icon_size_S'))
        .height($r('app.float.icon_size_S'))
    }.width('100%')
    .padding(15)
  }
}


@Extend(List) function tagListStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r('app.color.listBackground'))
  .borderRadius(15)
  .constraintSize({ maxHeight: 300 })
}