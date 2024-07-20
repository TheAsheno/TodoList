import { UrgencyDays, UrgencyText } from '../enums/UrgencyValue'

@CustomDialog
export struct urgencyModifyDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: urgencyModifyDialog
  })

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row() {
          Text('紧急程度').fontSize(20)
        }.width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          urgencyItem(1, $r('app.color.deadlineLv1Color'), UrgencyDays.Lv1, UrgencyText.Lv1)
        }

        Row() {
          urgencyItem(2, $r('app.color.deadlineLv2Color'), UrgencyDays.Lv2, UrgencyText.Lv2)
        }

        Row() {
          urgencyItem(3, $r('app.color.deadlineLv3Color'), UrgencyDays.Lv3, UrgencyText.Lv3)
        }
        Row() {
          urgencyItem(4, $r('app.color.deadlineLv4Color'), UrgencyDays.Lv4, UrgencyText.Lv4)
        }
        Row() {
          Button('取消')
            .fontColor($r('app.color.closeTagButtonColor'))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.controller.close())
          Button('确认')
            .fontColor(Color.Red)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.controller.close()
            })
        }.width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .backgroundColor("#EEEEEE")
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 5 })
      .borderRadius(10)
    }
    .width('80%')
  }
}

@Builder function urgencyItem(index: number, color: Resource, urgencyDays: number, urgencyText: string) {
  Row({ space: 10 }) {
    Circle()
      .circleStyle(color)
    Text(`Lv${index}`)
    TextInput({ placeholder: '天', text: urgencyDays.toString() })
      .width(50)
      .type(InputType.Number)
    TextInput({ placeholder: '描述', text: urgencyText})
      .width(160)
  }.width('100%')
}


@Extend(List) function tagListStyle() {
  .divider({ strokeWidth: 2, color: $r('app.color.dividerColor'), startMargin: 0, endMargin: 0 })
  .backgroundColor($r('app.color.listBackground'))
  .borderRadius(15)
  .constraintSize({ maxHeight: 300 })
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}