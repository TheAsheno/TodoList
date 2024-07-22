import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';

@Entry
@Component
struct SearchPage {
  private EventTable: EventTable = new EventTable();
  @State searchText: string = "";
  @State searchList: EventData[] = []

  getSearchList() {
    this.EventTable.queryData((result: EventData[]) => {
      this.searchList = result;
    }, { text: this.searchText });
  }

  aboutToAppear() {
    this.EventTable.getRdbStore(() => {
      this.EventTable.queryData((result: EventData[]) => {
        this.searchList = result;
      });
    })
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 10 }) {
          Image($r('app.media.ic_leftArrow'))
            .width($r('app.float.icon_size_M'))
            .height($r('app.float.icon_size_M'))
            .onClick(() => router.back())
          Search({ placeholder: 'search' })
            .width('90%')
            .onChange((value) => {
              this.searchText = value;
              this.getSearchList();
            })
        }.margin(10)
      }.width('100%')
      .backgroundColor($r('app.color.searchFillBgColor'))
      if (this.searchText) {
        Row() {
          Text('搜索到 ' + this.searchList.length + ' 条结果')
            .fontSize($r('app.float.font_size_M'))
            .fontColor($r('app.color.promptTextColor'))
        }.width('90%')
        .justifyContent(FlexAlign.Start)
      }
      if (this.searchList.length == 0) {
        Column({ space: 20 }) {
          Image($r('app.media.ic_noData'))
            .width($r('app.float.icon_size_XXL'))
            .height($r('app.float.icon_size_XXL'))
          Text('没有匹配的结果')
            .fontSize($r('app.float.font_size_MP'))
            .fontColor($r('app.color.promptTextColor'))
        }.height('100%')
        .offset({ x: 0, y: -100 })
        .justifyContent(FlexAlign.Center)
      }
      else {
        List({ space: 10 }) {
          ForEach(this.searchList, (item) => {
            ListItem() {
              this.searchItem(item)
            }
          })
        }.width('90%')
        .divider({
          strokeWidth: 1,
          color: this.searchText ? $r('app.color.dividerColor') : $r('app.color.dividerReverseColor'),
          startMargin: 0,
          endMargin: 0
        })
      }
    }.height('100%')
    .width('100%')
    .backgroundColor(this.searchText ? $r('app.color.searchFillBgColor') : $r('app.color.searchNoneBgColor'))
  }

  @Builder searchItem(item: EventData) {
    Column() {
      Row({ space: 10 }) {
        Text(item.name).fontSize($r('app.float.font_size_MP'))
        Blank()
        Text(item.deadlineTime).fontSize($r('app.float.font_size_M'))
        Text(item.tag)
          .padding(2)
          .fontSize($r('app.float.font_size_S'))
          .backgroundColor($r('app.color.tagBgColor'))
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        if (!this.searchText)
          router.back();
        else
          router.pushUrl({ url: 'pages/EventPage', params: { event: item } })
      })
      Text(item.note).noteStyle()
    }.padding(10)
  }
}

@Extend(Text) function noteStyle() {
  .fontSize($r('app.float.font_size_S'))
  .fontColor(Color.Grey)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .alignSelf(ItemAlign.Start)
}