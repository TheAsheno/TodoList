import router from '@ohos.router'
import EventData from '../viewmodel/EventData';

@Entry
@Component
struct EventPage {
  params = router.getParams();
  event: EventData = this.params['event'];
  build() {
    Row() {
      Column() {
        Text(this.event.name).fontSize(25)
      }
      .width('100%')
    }
    .height('100%')
  }
}