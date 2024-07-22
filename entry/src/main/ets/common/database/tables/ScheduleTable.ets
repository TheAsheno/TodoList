import relationalStore from '@ohos.data.relationalStore';
import Rdb from '../Rdb';
import ScheduleData from '../../../viewmodel/ScheduleData';
import CommonConstants from '../../constants/CommonConstants';

export default class ScheduleTable {
  private eventTable = new Rdb(CommonConstants.SCHEDULE_TABLE.tableName, CommonConstants.SCHEDULE_TABLE.sqlCreate,
    CommonConstants.SCHEDULE_TABLE.sqlInit,CommonConstants.SCHEDULE_TABLE.columns);

  constructor(callback: Function = () => {}) {
    this.eventTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {}) {
    this.eventTable.getRdbStore(callback);
  }

  insertData(note: ScheduleData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(note, true);
    this.eventTable.insertData(valueBucket, callback);
  }

  deleteData(id: number, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.SCHEDULE_TABLE.tableName);
    predicates.equalTo('id', id);
    this.eventTable.deleteData(predicates, callback);
  }

  updateData(note: ScheduleData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(note, false);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.SCHEDULE_TABLE.tableName);
    predicates.equalTo('id', note.id);
    this.eventTable.updateData(predicates, valueBucket, callback);
  }

  queryData(callback: Function, options?: {
    eventId?: number
  }) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.SCHEDULE_TABLE.tableName);
    if (options) {
      if (options.eventId)
        predicates.equalTo('eventId', options.eventId);
    }
    this.eventTable.queryData(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.SCHEDULE_TABLE_TAG}` + 'Query no results!');
        callback([]);
      } else {
        resultSet.goToFirstRow();
        const result: ScheduleData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: ScheduleData = {
            id: 0,
            text: '',
            time: '',
            eventId: 0
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.text = resultSet.getString(resultSet.getColumnIndex('text'));
          tmp.time = resultSet.getString(resultSet.getColumnIndex('time'));
          tmp.eventId = resultSet.getDouble(resultSet.getColumnIndex('eventId'));
          result.push(new ScheduleData(tmp));
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}

function generateBucket(note: ScheduleData, isInsert: boolean): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.text = note.text;
  obj.time = note.time;
  obj.eventId = note.eventId;
  return obj;
}