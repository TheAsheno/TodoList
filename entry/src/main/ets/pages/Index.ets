import { ListPage } from './ListPage'
import { DeadlinePage } from './DeadlinePage'
import { SettingPage } from './SettingPage'

AppStorage.SetOrCreate('currentTabIndex', 0);
AppStorage.SetOrCreate('currentEventId', -1);

@Entry
@Component
struct Index {
  @StorageLink('currentTabIndex') currentTabIndex: number = 0
  build() {
    Tabs() {
      TabContent() {
        ListPage()
      }.tabBar(this.barBuilder(0, '清单', $r('app.media.list')))
      TabContent() {
        DeadlinePage()
      }.tabBar(this.barBuilder(1, '截止', $r('app.media.time')))
      TabContent() {
        SettingPage()
      }.tabBar(this.barBuilder(2, '设置', $r('app.media.set')))
    }
    .barPosition(BarPosition.End)
    .onChange((index) => {
      this.currentTabIndex = index;
    })
  }

  @Builder barBuilder(index: number, title: string, icon: Resource) {
    Column() {
      Image(icon)
        .tabIconStyle(index === this.currentTabIndex ? Color.Black : $r('app.color.tabFocusColor'))
      Text(title)
        .tabTitleStyle(index === this.currentTabIndex ? Color.Black : $r('app.color.tabFocusColor'))
    }
  }
}

@Extend(Text) function tabTitleStyle(color: ResourceColor) {
  .fontSize(10)
  .fontWeight(FontWeight.Medium)
  .fontColor(color)
  .margin({ bottom: 5 })
}

@Extend(Image) function tabIconStyle(color: ResourceColor) {
  .width(25)
  .height(25)
  .margin(5)
  .fillColor(color)
}

