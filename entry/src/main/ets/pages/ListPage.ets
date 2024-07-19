import router from '@ohos.router'
import { getCircleColor } from '../common/utils/ColorUtil'
import { dateFormat }  from '../common/utils/DateUtil'
import EventTable from '../common/database/tables/EventTable';
import EventData from '../viewmodel/EventData';
import { tagDialog } from '../view/tagDialog'
import emitter from '@ohos.events.emitter'

@Entry
@Component
export struct ListPage {
  private EventTable: EventTable = new EventTable();
  @Provide @Watch('onSelectTagChange') selectTag: string = '';
  @State events: Array<EventData> = [];
  @State index: number = -1;
  @State pageIndex: number = 1;
  @State isInsert: boolean = false;
  @State isEdit: boolean = false;
  @StorageLink('currentTabIndex') @Watch('onPageChange') currentTabIndex: number = 0
  @State newEvent: EventData = {
    id: 0,
    name: 'do homework',
    note: '做作业',
    createTime: '2024-07-18',
    deadlineTime: '2024-07-20',
    updateTime: '2024-07-18',
    tag: '作业',
    isDone: false
  };
  @State deleteList: number[] = [];
  @State todoListData: Array<EventData> = [];
  @State doneListData: Array<EventData> = [];
  tagDialogController: CustomDialogController = new CustomDialogController({
    builder: tagDialog(),
    customStyle: true,
    autoCancel: false
  })

  aboutToAppear() {
    this.EventTable.getRdbStore(() => {
      this.initOrRefresh()
    });
    emitter.on({ eventId: 1 }, () => {
      this.initOrRefresh();
    })
  }

  onSelectTagChange() {
    this.initOrRefresh();
  }

  onPageChange() {
    if (this.currentTabIndex == this.pageIndex)
      this.initOrRefresh();
  }

  async initOrRefresh(todoFlag: boolean = true, doneFlag: boolean = true) {
    this.isEdit = false;
    this.deleteList = [];

    let threeDaysAgo = new Date();
    threeDaysAgo.setDate(new Date().getDate() - 3);

    if (todoFlag) {
      this.EventTable.queryData((result: EventData[]) => {
        this.todoListData = result;
      }, { isDone: false, orderByUpdateTimeDesc: true, tag: this.selectTag });
    }
    if (doneFlag) {
      this.EventTable.queryData((result: EventData[]) => {
        this.doneListData = result;
      }, { isDone: true, orderByUpdateTimeDesc: true, tag: this.selectTag, timeGreaterThanOrEqualTo: dateFormat(threeDaysAgo) });
    }
  }

  updateEvent(newEvent: EventData) {
    this.EventTable.updateData(newEvent, () => {
    });
    let list = this.events;
    this.events = [];
    list[this.index] = newEvent;
    this.events = list;
    this.index = -1;
  }

  deleteEvent() {
    if (this.deleteList.length > 0) {
      for (let i = 0; i < this.deleteList.length; i++)
        this.EventTable.deleteData(this.deleteList[i], () => {});
      this.todoListData = this.todoListData.filter(event => !this.deleteList.includes(event.id));
      this.doneListData = this.doneListData.filter(event => !this.deleteList.includes(event.id))
      this.deleteList = [];
    }
    this.isEdit = false;
  }

  selectEvent(item: EventData) {
    this.isInsert = false;
    this.index = this.events.indexOf(item);
    this.newEvent = {
      id: item.id,
      name: item.name,
      note: item.note,
      createTime: item.createTime,
      deadlineTime: item.deadlineTime,
      updateTime: item.updateTime,
      tag: item.tag,
      isDone: item.isDone
    };
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column({ space: 15 }) {
          Row({ space: 20 }) {
            if (this.isEdit)
              Image($r('app.media.ic_delete'))
                .height($r('app.float.icon_size_M'))
                .width($r('app.float.icon_size_M'))
                .onClick(() => this.deleteEvent())
            else
              Image($r('app.media.ic_sort'))
                .width($r('app.float.icon_size_L'))
                .height($r('app.float.icon_size_L'))
                .onClick(() => {
                  if (!this.isEdit)
                    this.tagDialogController.open()
                })
            Image($r("app.media.ic_mg"))
              .width($r('app.float.icon_size_L'))
              .height($r('app.float.icon_size_L'))
              .onClick(() => {
                this.deleteList = [];
                this.isEdit = !this.isEdit;
              })
          }.width('100%')
          .margin(10)
          .justifyContent(FlexAlign.End)

          Row() {
            Text('任务清单').titleStyle()
            Blank()
            if (this.selectTag)
              this.selectTagItem()
          }.width('100%')
          .margin(10)

          TextInput({ placeholder: 'search' })
            .height(40)
            .focusable(false)
            .onClick(() => {
              this.isEdit = false;
              router.pushUrl({ url: 'pages/SearchPage' })
            })

          List({ space: 20 }) {
            ListItem() {
              listHeader('待办事项')
            }

            ListItemGroup() {
              ForEach(this.todoListData, (item, index) => {
                ListItem() {
                  EventItem({ event: item,
                    isEdit: this.isEdit,
                    deleteList: $deleteList,
                    updateList: () => {
                      this.updateEvent(item);
                      this.doneListData.unshift(item);
                      this.todoListData.splice(index, 1);
                    } })
                }
              })
            }.listBgStyle()

            ListItem() {
              listHeader('已办事项', '（仅展示近三天完成的任务）')
            }

            ListItemGroup() {
              ForEach(this.doneListData, (item: EventData, index) => {
                ListItem() {
                  EventItem({ event: item,
                    isEdit: this.isEdit,
                    deleteList: $deleteList,
                    updateList: () => {
                      this.updateEvent(item);
                      this.todoListData.unshift(item)
                      this.doneListData.splice(index, 1)
                    } })
                }
              })
            }.listBgStyle()
          }.layoutWeight(1)
          .height('90%')
        }.width('90%')
        .justifyContent(FlexAlign.Start)
        .margin({ top: 20, bottom: 20 })
        if (!this.isEdit)
          Image($r('app.media.ic_addEvent'))
            .height($r('app.float.icon_size_XL'))
            .width($r('app.float.icon_size_XL'))
            .offset({ x: -10, y: -30 })
            .fillColor($r('app.color.addEventButtonColor'))
            .opacity(0.8)
            .onClick(() => {
                router.pushUrl({ url: 'pages/AddEventPage' })
            })
      }
    }.pageBgStyle()
  }
  @Builder selectTagItem() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_tags'))
        .height($r('app.float.icon_size_S'))
        .width($r('app.float.icon_size_S'))
      Text(this.selectTag)
        .fontSize($r('app.float.font_size_S'))
        .fontColor(Color.Grey)
      Image($r('app.media.ic_close2'))
        .height($r('app.float.icon_size_S'))
        .width($r('app.float.icon_size_S'))
        .onClick(() => {
          this.selectTag = '';
        })
    }.padding(5)
    .borderRadius(15)
    .backgroundColor('#EBECF1')
  }
}

@Builder function listHeader(listTitle: string, promptText?: string) {
  Column() {
    Divider()
      .strokeWidth(1)
      .lineCap(LineCapStyle.Square)
      .margin({ top: 10, bottom: 10 })
    Row({ space: 10}) {
      Text(listTitle).typeStyle()
      if (promptText)
        Text(promptText)
          .fontSize($r('app.float.font_size_S'))
          .fontColor(Color.Grey)
      Blank()
    }.width('100%')
  }
}

@Component
struct EventItem {
  @ObjectLink event: EventData;
  updateList: () => void;
  @Link deleteList: number[];
  @StorageLink('currentEventId') currentEventId: number = -1;
  @Prop isEdit: boolean;

  build() {
    Column() {
      Row({ space: 10 }) {
        if (this.isEdit) {
          Checkbox()
            .width(18)
            .height(18)
            .margin(0)
            .onChange((value) => {
              if (value) {
                this.deleteList.push(this.event.id)
              }
              else {
                let index = this.deleteList.indexOf(this.event.id);
                this.deleteList.splice(index, 1)
              }
            })
        }
        else {
          Image(this.event.isDone ? $r('app.media.ic_done') : $r('app.media.ic_todo'))
            .height($r('app.float.icon_size_S'))
            .width($r('app.float.icon_size_S'))
            .onClick(() => {
              this.event.isDone = !this.event.isDone;
              this.updateList();
            })
        }
        Text(this.event.name)
          .fontSize($r('app.float.font_size_M'))
          .opacity(this.event.isDone ? 0.4 : 1)
          .decoration({ type: this.event.isDone ? TextDecorationType.LineThrough : TextDecorationType.None })
        Blank()
        Text(this.event.deadlineTime).fontSize($r('app.float.font_size_S'))
        Text(this.event.tag)
          .padding(2)
          .fontSize($r('app.float.font_size_S'))
          .backgroundColor('#DDDDDD')
        if (!this.event.isDone) {
          Circle()
            .circleStyle(getCircleColor(this.event.deadlineTime))
        }
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {
        //this.currentEventId = this.event.id;
        router.pushUrl({ url: 'pages/EventPage', params: { event: this.event } })
      })
    }.padding(10)
  }
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .backgroundImage($r('app.media.img_list_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Extend(Text) function titleStyle() {
  .alignSelf(ItemAlign.Start)
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.float.font_size_XXL'))
  .margin({ left: 20 })
}

@Extend(Text) function typeStyle() {
  .fontSize($r('app.float.font_size_MP'))
  .alignSelf(ItemAlign.Start)
}

@Extend(ListItemGroup) function listBgStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r('app.color.listBackground'))
  .borderRadius(15)
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}