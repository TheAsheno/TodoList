import relationalStore from '@ohos.data.relationalStore';
import Rdb from '../Rdb';
import EventData from '../../../viewmodel/EventData';
import CommonConstants from '../../constants/CommonConstants';
import dayjs from "dayjs";

export default class EventTable {
  private eventTable = new Rdb(CommonConstants.EVENT_TABLE.tableName, CommonConstants.EVENT_TABLE.sqlCreate,
    CommonConstants.EVENT_TABLE.sqlInit,CommonConstants.EVENT_TABLE.columns);

  constructor(callback: Function = () => {}) {
    this.eventTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {}) {
    this.eventTable.getRdbStore(callback);
  }

  insertData(event: EventData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(event, true);
    this.eventTable.insertData(valueBucket, callback);
  }

  deleteData(id: number, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.EVENT_TABLE.tableName);
    predicates.equalTo('id', id);
    this.eventTable.deleteData(predicates, callback);
  }

  updateData(event: EventData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(event, false);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.EVENT_TABLE.tableName);
    predicates.equalTo('id', event.id);
    this.eventTable.updateData(predicates, valueBucket, callback);
  }

  queryData(callback: Function, options?: {
    text?: string,
    isDone?: boolean,
    tag?: string,
    orderByCreateTimeDesc?: boolean,
    orderByDeadlineTimeDesc?: boolean,
    orderByUpdateTimeDesc?: boolean,
    limit?: number,
    timeGreaterThanOrEqualTo?: string
  }) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.EVENT_TABLE.tableName);
    if (options) {
      if (options.text !== undefined)
        predicates.like('name', `%${options.text}%`).or().like('note', `%${options.text}%`);
      if (options.isDone !== undefined)
        predicates.equalTo('isDone', options.isDone);
      if (options.tag)
        predicates.equalTo('tag', options.tag);
      if (options.orderByCreateTimeDesc !== undefined)
        predicates.orderByDesc('createTime');
      if (options.orderByDeadlineTimeDesc !== undefined)
        predicates.orderByDesc('deadlineTime');
      if (options.orderByUpdateTimeDesc !== undefined)
        predicates.orderByDesc('updateTime');
      if (options.limit)
        predicates.limitAs(options.limit);
      if (options.timeGreaterThanOrEqualTo)
        predicates.greaterThanOrEqualTo('updateTime', options.timeGreaterThanOrEqualTo)
    }
    this.eventTable.queryData(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.EVENT_TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: EventData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: EventData = {
            id: 0,
            name: '',
            note: '',
            createTime: '',
            deadlineTime: '',
            updateTime: '',
            tag: '',
            isDone: false
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.name = resultSet.getString(resultSet.getColumnIndex('name'));
          tmp.note = resultSet.getString(resultSet.getColumnIndex('note'));
          tmp.createTime = resultSet.getString(resultSet.getColumnIndex('createTime'));
          tmp.deadlineTime = resultSet.getString(resultSet.getColumnIndex('deadlineTime'));
          tmp.updateTime = resultSet.getString(resultSet.getColumnIndex('updateTime'));
          tmp.tag = resultSet.getString(resultSet.getColumnIndex('tag'));
          tmp.isDone = resultSet.getDouble(resultSet.getColumnIndex('isDone')) === 1;
          result.push(new EventData(tmp));
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}

function generateBucket(event: EventData, isInsert: boolean): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.name = event.name;
  obj.note = event.note;
  obj.createTime = isInsert ? dayjs().format("YYYY-MM-DD") : event.createTime;
  obj.deadlineTime = event.deadlineTime;
  obj.updateTime = dayjs().format("YYYY-MM-DD");
  obj.tag = event.tag;
  obj.isDone = isInsert ? false : event.isDone;
  return obj;
}