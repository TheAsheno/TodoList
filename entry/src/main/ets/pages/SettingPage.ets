import TagTable  from '../common/database/tables/TagTable'
import TagData from '../viewmodel/TagData'

@Entry
@Component
export struct SettingPage {
  private TagTable: TagTable = new TagTable();
  @State tags: Array<TagData> = [];
  @State flag: string = '0';
  aboutToAppear() {
    this.TagTable.getRdbStore(() => {
      this.TagTable.queryData((result) => {
        this.tags = result;
        this.flag = this.tags.length.toString();
      })
    })
  }
  build() {
    Row() {
      Column() {
        Text(this.flag).fontSize(30)
        List() {
          ForEach(this.tags, (tag: TagData) => {
            ListItem() {
              Text(tag.znName).fontSize(20)
            }
          })
        }
      }
      .width('100%')
    }
    .height('100%')
  }
}