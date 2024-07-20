import { tagCustomDialog } from '../view/tagCustomDialog'
import { urgencyModifyDialog } from '../view/urgencyModifyDialog'

@Entry
@Component
export struct SettingPage {
  tagAddDialogController: CustomDialogController = new CustomDialogController({
    builder: tagCustomDialog(),
    customStyle: true,
    autoCancel: false
  })
  urgencyModifyDialogController: CustomDialogController = new CustomDialogController({
    builder: urgencyModifyDialog(),
    customStyle: true,
    autoCancel: false
  })
  build() {
    Column(){
      Column() {
        List({ space: 40 }) {
          ListItem() {
            settingItem($r('app.media.ic_modify'), '修改紧急程度', () => {
              this.urgencyModifyDialogController.open();
            })
          }
          ListItem() {
            settingItem($r('app.media.ic_addTag'), '自定义标签', () => {
              this.tagAddDialogController.open();
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
      .backgroundColor('#F5F7F8')
    }.pageBgStyle()
  }
}

@Builder function settingItem(icon: Resource, text: string, callback: () => void) {
  Row({ space: 15 }) {
    Image(icon)
      .height($r('app.float.icon_size_M'))
      .width($r('app.float.icon_size_M'))
    Text(text)
      .fontSize($r('app.float.font_size_M'))
    Blank()
    Image($r('app.media.ic_rightArrow'))
      .width($r('app.float.icon_size_M'))
      .height($r('app.float.icon_size_M'))
  }.width('100%')
  .onClick(callback)
}

@Extend(Column) function pageBgStyle() {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .backgroundImage($r("app.media.img_setting_bg"))
  .backgroundImageSize({ width: '100%', height: '43%' })
  .justifyContent(FlexAlign.End)
}