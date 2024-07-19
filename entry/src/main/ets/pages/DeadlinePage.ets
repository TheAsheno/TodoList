@Entry
@Component
export struct DeadlinePage {
  @State message: string = 'Hello World'

  build() {
    Column() {
      Column({ space: 15 }) {
        Row() {
          Text('截止时间').titleStyle()
          Blank()
        }.width('100%')
        .margin(10)

        Divider()
          .strokeWidth(2)
          .lineCap(LineCapStyle.Square)
          .margin({ left: 10, right: 10, bottom: 10 })
      }.width('90%')
      .justifyContent(FlexAlign.Start)
      .height('90%')
    }.pageBgStyle()
  }
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .backgroundImage($r('app.media.img_deadline_bg'))
  .backgroundImageSize({ width: '100%', height: '100%' })
  .justifyContent(FlexAlign.SpaceEvenly)
}

@Extend(Text) function titleStyle() {
  .alignSelf(ItemAlign.Start)
  .fontWeight(FontWeight.Bold)
  .fontSize($r('app.float.font_size_XXL'))
  .margin({ left: 20 })
}