import UrgencyDataModel from '../model/UrgencyDataModel';
import { urgencyInfoBean } from '../viewmodel/UrgencyData';
import emitter from '@ohos.events.emitter'
import promptAction from '@ohos.promptAction'

@CustomDialog
export struct urgencyModifyDialog {
  @State urgencyList: Array<urgencyInfoBean> = [];
  colorList: Resource[] = [$r('app.color.deadlineLv1Color'), $r('app.color.deadlineLv2Color'), $r('app.color.deadlineLv3Color'), $r('app.color.deadlineLv4Color')]
  controller: CustomDialogController = new CustomDialogController({
    builder: urgencyModifyDialog
  })

  aboutToAppear() {
    UrgencyDataModel.getUrgencyList();
    this.urgencyList = UrgencyDataModel.urgencyList;
  }

  checkUrgency() {
    let tmp = 0;
    for (let i = 0; i < 4; i++) {
      if (!this.urgencyList[i].days || !this.urgencyList[i].depict) {
        promptAction.showToast({
          message: '输入不能为空',
          duration: 2000,
          bottom: 50
        });
        return false;
      }
      if (Number(this.urgencyList[i].days) <= tmp) {
        promptAction.showToast({
          message: '天数需要严格递增',
          duration: 2000,
          bottom: 50
        });
        return false;
      }
      tmp = Number(this.urgencyList[i].days);
    }
    return true;
  }

  build() {
    Column({ space: 10 }) {
      Column({ space: 20 }) {
        Row() {
          Text('紧急程度').fontSize(20)
        }.width('100%')
        .justifyContent(FlexAlign.Center)

        List({ space: 10 }) {
          ForEach(this.urgencyList, (item: urgencyInfoBean, index) => {
            ListItem() {
              this.urgencyItem(index, item, this.colorList[index])
            }
          })
        }

        Row() {
          Button('取消')
            .fontColor($r("app.color.closeButtonColor"))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.controller.close())
          Button('确认')
            .fontColor(Color.Red)
            .backgroundColor(Color.Transparent)
            .onClick(async () => {
              if (this.checkUrgency()) {
                await UrgencyDataModel.updateUrgency(this.urgencyList);
                emitter.emit({ eventId: 3 })
                this.controller.close()
              }
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

  @Builder urgencyItem(index: number, urgency: urgencyInfoBean, color: Resource) {
    Row({ space: 10 }) {
      Circle()
        .circleStyle(color)
      Text(urgency.urgencyLv)
      TextInput({ placeholder: '天', text: urgency.days })
        .width(52)
        .type(InputType.Number)
        .onChange((value) => {
          this.urgencyList[index].days = value;
        })
      TextInput({ placeholder: '描述', text: urgency.depict })
        .width(160)
        .onChange((value) => {
          this.urgencyList[index].depict = value;
        })
    }.width('100%')
  }
}

@Extend(Circle) function circleStyle(color: ResourceColor) {
  .height(10)
  .width(10)
  .fill(color)
}