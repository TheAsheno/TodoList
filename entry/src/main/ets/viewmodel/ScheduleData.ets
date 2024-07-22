@Observed
export default class ScheduleData {
  id: number;
  text: string;
  time: string;
  eventId: number;

  constructor(item: { id: number, text: string, time: string, eventId: number } ) {
    this.id = item.id;
    this.text = item.text;
    this.time = item.time;
    this.eventId = item.eventId;
  }
}