export function getCircleColor(deadlineTime: string) {
  let currentDate = new Date();
  let targetDate = new Date(deadlineTime);
  let daysDiff = targetDate.getDate() - currentDate.getDate();
  if (daysDiff < 0)
    return Color.Grey;
  else if (daysDiff < 1)
    return Color.Red;
  else if (daysDiff < 3)
    return Color.Orange;
  else if (daysDiff < 7)
    return Color.Yellow;
  else
    return Color.Green;
}