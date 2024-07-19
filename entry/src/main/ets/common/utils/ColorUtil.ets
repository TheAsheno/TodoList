export function getCircleColor(deadlineTime: string) {
  let currentDate = new Date();
  let targetDate = new Date(deadlineTime);
  let daysDiff = targetDate.getDate() - currentDate.getDate();
  if (daysDiff < 0)
    return Color.Grey;
  else if (daysDiff < 1)
    return $r('app.color.deadlineLv1Color');
  else if (daysDiff < 3)
    return $r('app.color.deadlineLv2Color');
  else if (daysDiff < 7)
    return $r('app.color.deadlineLv3Color');
  else
    return $r('app.color.deadlineLv4Color');
}