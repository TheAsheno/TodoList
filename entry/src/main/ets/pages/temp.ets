import { EventData, ListData } from '../model/ListInfo'
import router from '@ohos.router'
import { getCircleColor } from '../common/utils/ColorUtil'
import { ListItemTag } from '../enums/ListTag'
import { TagIconMap } from '../viewmodel//TagIconMap'
import { ListType } from '../enums//ListTag'

@Entry
@Component
export struct temp {
  @State searchText: string = "";
  @State todoListData: EventData[] = [];
  @State doneListData: EventData[] = [];
  @State showWhichList: ListType = ListType.todoList;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: InfoDialog(),
    customStyle: true,
    autoCancel: false
  })
  @State isEdit: boolean = false;

  async getPostInfoPage() {
    for (let i = 0; i < ListData.length; i++) {
      if (ListData[i].isDone)
        this.doneListData.push(new EventData(ListData[i]));
      else
        this.todoListData.push(new EventData(ListData[i]));
    }
  }

  async refresh() {
    this.todoListData = [];
    this.doneListData = [];
    await this.getPostInfoPage();
  }

  aboutToAppear() {
    this.getPostInfoPage();
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column({ space: 15 }) {
          Row({ space: 15 }) {
            Image($r('app.media.ic_sort'))
              .width(25)
              .height(25)
              .onClick(() => this.dialogController.open())
            Image($r("app.media.ic_mg"))
              .width(25)
              .height(25)
          }.width('100%')
          .margin(10)
          .justifyContent(FlexAlign.End)

          Row() {
            Text('任务清单').titleStyle()
            Blank()
            this.selectTagItem()
          }.width('100%')
          .margin(10)

          TextInput({ placeholder: 'search' })
            .height(40)
            .focusable(false)
            .onClick(() => router.pushUrl({ url: 'pages/SearchPage' }))



          List({ space: 15 }) {

            ListItem() {
              listHeader('待办事项')
            }

            ListItemGroup() {
              ForEach(this.todoListData, (data, index) => {
                ListItem() {
                  listItem({ item: data,
                    updateList: () => {
                      this.doneListData.unshift(data),
                      this.todoListData.splice(index, 1)
                    } })
                }
              })
            }.listBgStyle()

            ListItem() {
              listHeader('已办事项')
            }

            ListItemGroup() {
              ForEach(this.doneListData, (data, index) => {
                ListItem() {
                  listItem({ item: data,
                    updateList: () => {
                      this.todoListData.unshift(data)
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

        if (this.isEdit) {

        }
        else {
          Image($r('app.media.ic_addEvent'))
            .height(60)
            .width(60)
            .offset({ x: -10, y: -30 })
            .fillColor('#3572EF')
            .onClick(() => {

            })
        }
      }
    }.pageBgStyle()
  }
  @Builder selectTagItem() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_tags'))
        .height(20)
        .width(20)
      Text('开发')
        .fontSize(12)
        .fontColor(Color.Grey)
      Image($r('app.media.ic_close2'))
        .height(20)
        .width(20)
    }.padding(5)
    .borderRadius(15)
    .backgroundColor('#EBECF1')
  }
}

@Builder function listHeader(listTitle: string) {
  Column() {
    Divider()
      .strokeWidth(1)
      .lineCap(LineCapStyle.Square)
      .margin({ top: 10, bottom: 10 })
    Row() {
      Text(listTitle).typeStyle()
      Blank()
      Toggle({ type: ToggleType.Switch })
        .margin(0)
        .width(40)
        .height(20)
        .selectedColor('#D9D9D9')
        .switchPointColor(Color.White)
    }.width('100%')
  }
}

@Component
struct listItem {
  @ObjectLink item: EventData;
  updateList: () => void;
  build() {
    Column() {
      Row({ space: 10 }) {
        if (this.item.isDone) {
          Image($r('app.media.ic_done'))
            .height(18)
            .width(18)
            .onClick(() => {
              this.item.isDone = false;
              this.updateList();
            })
        }
        else {
          Image($r("app.media.ic_todo"))
            .height(18)
            .width(18)
            .onClick(() => {
              this.item.isDone = true;
              this.updateList();
            })
        }
        /*
        Checkbox()
          .width(18)
          .height(18)
          .margin(0)
          .select(this.item.isDone)
          .selectedColor(Color.Black)
          .onChange((value) => {
            this.item.isDone = value;
            this.updateList();
          })*/
        Text(this.item.name).fontSize(15)
        Blank()
        Text(this.item.deadlineTime).fontSize(12)
        Text(this.item.tag)
          .padding(2)
          .fontSize(12)
          .backgroundColor('#DDDDDD')
        if (!this.item.isDone) {
          Circle()
            .circleStyle(getCircleColor(this.item.deadlineTime))
        }
        Checkbox()
          .width(18)
          .height(18)
      }.height(30)
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .onClick(() => {

      })
    }.padding(10)
  }
}

@CustomDialog
struct InfoDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: InfoDialog
  })
  @State tagList: string[] = [ListItemTag.Homework, ListItemTag.Development, ListItemTag.Routine, ListItemTag.Experiment];

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row() {
          Text('分类列表').fontSize(20)
          Blank()
        }.width('100%')

        List() {
          ForEach(this.tagList, (tag) => {
            tagItem(tag)
          })
        }.divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
        .backgroundColor("#F5F5F5")
        .borderRadius(15)
        .constraintSize({ maxHeight: 300 })

        Button('关闭')
          .fontColor('#0F67B1')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.controller.close())
      }
      .backgroundColor("#EEEEEE")
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }
    .backgroundColor(Color.Transparent)
    .width('80%')
  }
}

@Builder function tagItem(tagName: string) {
  Row() {
    Text(tagName)
      .fontSize(15)
    Blank()
    Image($rawfile(TagIconMap[tagName]))
      .width(20)
      .height(20)
  }.width('100%')
  .padding(15)
  .onClick(() => {
    router.pushUrl({ url: 'pages/TagPage' })
  })
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
  .fontSize(30)
  .margin({ left: 20 })
}

@Extend(Text) function typeStyle() {
  .fontSize(18)
  .alignSelf(ItemAlign.Start)
}

@Extend(ListItemGroup) function listBgStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor("#F5F5F5")
  .borderRadius(15)
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}