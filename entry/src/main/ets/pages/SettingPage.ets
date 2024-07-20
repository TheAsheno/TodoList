@Entry
@Component
export struct SettingPage {
  build() {
    Column(){
      Column() {
        List({ space: 40 }) {
          ListItem() {
            settingItem($r('app.media.ic_modify'), '修改紧急程度', () => {

            })
          }
          ListItem() {
            settingItem($r('app.media.ic_addtag'), '添加自定义标签', () => {

            })
          }
          ListItem() {
            settingItem($r('app.media.ic_theme'), '切换主题肤色', () => {

            })
          }
        }.margin(10)
        .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
      }.height('60%')
      .width('100%')
      .padding(30)
      .borderRadius({ topLeft: 30, topRight: 30})
      .backgroundColor(Color.White)
    }.pageBgStyle()
  }
}

@Builder function settingItem(icon: Resource, text: string, callback: () => void) {
  Row({ space: 15 }) {
    Image(icon)
      .height(25)
      .width(25)
    Text(text)
      .fontSize(16)
    Blank()
    Image($r('app.media.ic_rightArrow'))
      .width(25)
      .height(25)
  }.width('100%')
  .onClick(callback)
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .backgroundColor(Color.Grey)
  //.backgroundImage($r("app.media.img_deadline_bg"))
  //.backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.End)
}