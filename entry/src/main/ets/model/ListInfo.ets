import { ListItemTag, ListType } from '../enums/ListTag'

@Observed
export class EventData {
  id: number;
  name: string;
  note: string;
  createTime: string;
  deadlineTime: string;
  updateTime: string;
  tag: string;
  isDone: boolean;

  constructor(item: {id: number, name: string, note: string, createTime: string, deadlineTime: string, updateTime: string, tag: string, isDone: boolean}) {
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

export const ListData: EventData[] = [
  {
    id: 1,
    name: "背单词",
    note: "背单词啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",
    createTime: "2024-07-16",
    deadlineTime: "2024-07-17",
    updateTime: "2024-07-17",
    tag: ListItemTag.Homework,
    isDone: false
  },
  {
    id: 2,
    name: "线代练习题",
    note: "线代练习题",
    createTime: "2024-07-16",
    deadlineTime: "2024-07-19",
    updateTime: "2024-07-17",
    tag: ListItemTag.Homework,
    isDone: false
  },
  {
    id: 3,
    name: "交团费",
    note: "交团费",
    createTime: "2024-07-16",
    deadlineTime: "2024-07-26",
    updateTime: "2024-07-17",
    tag: ListItemTag.Routine,
    isDone: true
  },
  {
    id: 4,
    name: "拿快递",
    note: "拿快递",
    createTime: "2024-07-16",
    deadlineTime: "2024-07-16",
    updateTime: "2024-07-17",
    tag: ListItemTag.Routine,
    isDone: false
  },
  {
    id: 5,
    name: "维护工具",
    note: "早起",
    createTime: "2024-07-16",
    deadlineTime: "2024-07-26",
    updateTime: "2024-07-17",
    tag: ListItemTag.Development,
    isDone: false
  }
]

export function getListData(type: ListType) {
  let targetList: EventData[] = [];
  let flag: boolean = type == ListType.todoList ? false : true;
  for (let i = 0; i < ListData.length; i++) {
    if (ListData[i].isDone == flag)
      targetList.push(new EventData(ListData[i]));
  }
  return targetList;
}

