import dayjs from "dayjs";
import { UrgencyValue } from '../../enums/UrgencyValue'

export function getCircleColor(deadlineTime: string) {
  let daysDiff = dayjs(deadlineTime).diff(dayjs(),'day', true)
  if (daysDiff < 0)
    return Color.Grey;
  else if (daysDiff < UrgencyValue.Lv1)
    return $r('app.color.deadlineLv1Color');
  else if (daysDiff < UrgencyValue.Lv2)
    return $r('app.color.deadlineLv2Color');
  else if (daysDiff < UrgencyValue.Lv3)
    return $r('app.color.deadlineLv3Color');
  else
    return $r('app.color.deadlineLv4Color');
}