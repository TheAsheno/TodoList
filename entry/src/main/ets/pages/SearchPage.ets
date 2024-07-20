import router from '@ohos.router'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { EventAction } from '../enums/EventAction'

@Entry
@Component
struct SearchPage {
  @StorageLink('currentEventId') currentEventId: number = -1;
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
      .backgroundColor(Color.White)
      if (this.searchText) {
        Row() {
          Text('搜索到 ' + this.searchList.length + ' 条结果')
            .fontSize($r('app.float.font_size_M'))
            .fontColor(Color.Grey)
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
            .fontColor(Color.Grey)
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
          color: this.searchText ? $r('app.color.dividerColor') : Color.Grey,
          startMargin: 0,
          endMargin: 0
        })
        .onClick(() => {
          if (!this.searchText)
            router.back();
        })
      }
    }.height('100%')
    .width('100%')
    .backgroundColor(this.searchText ? Color.White : '#C7C8CC')
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
          .backgroundColor('#DDDDDD')
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        this.currentEventId = item.id;
        router.pushUrl({ url: 'pages/EventPage', params: { event: item, action: EventAction.Update } })
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