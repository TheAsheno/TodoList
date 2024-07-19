@Observed
export default class EventData {
  id: number;
  name: string;
  note: string;
  createTime: string;
  deadlineTime: string;
  updateTime: string;
  tag: string;
  isDone: boolean;

  constructor(item: { id: number, name: string, note: string, createTime: string, deadlineTime: string, updateTime: string, tag: string, isDone: boolean } ) {
    this.id = item.id;
    this.name = item.name;
    this.note = item.note;
    this.createTime = item.createTime;
    this.deadlineTime = item.deadlineTime;
    this.updateTime = item.updateTime;
    this.tag = item.tag;
    this.isDone = item.isDone;
  }
}