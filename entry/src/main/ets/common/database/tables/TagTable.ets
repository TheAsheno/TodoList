import relationalStore from '@ohos.data.relationalStore';
import Rdb from '../Rdb';
import TagData from '../../../viewmodel/TagData';
import CommonConstants from '../../constants/CommonConstants';

export default class TagTable {
  private tagTable = new Rdb(CommonConstants.TAG_TABLE.tableName, CommonConstants.TAG_TABLE.sqlCreate,
    CommonConstants.TAG_TABLE.sqlInit, CommonConstants.TAG_TABLE.columns);

  constructor(callback: Function = () => {}) {
    this.tagTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function = () => {}) {
    this.tagTable.getRdbStore(callback);
  }

  insertData(tag: TagData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(tag);
    this.tagTable.insertData(valueBucket, callback);
  }

  deleteData(tag: TagData, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TAG_TABLE.tableName);
    predicates.equalTo('id', tag.id);
    this.tagTable.deleteData(predicates, callback);
  }

  updateData(tag: TagData, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(tag);
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TAG_TABLE.tableName);
    predicates.equalTo('id', tag.id);
    this.tagTable.updateData(predicates, valueBucket, callback);
  }

  queryData(callback: Function) {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.TAG_TABLE.tableName);
    this.tagTable.queryData(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {
        console.log(`${CommonConstants.TAG_TABLE_TAG}` + 'Query no results!');
        callback([]);
      }
      else {
        resultSet.goToFirstRow();
        const result: TagData[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: TagData = {
            id: 0,
            znName: '',
            enName: '',
            icon: '',
          };
          tmp.id = resultSet.getDouble(resultSet.getColumnIndex('id'));
          tmp.znName = resultSet.getString(resultSet.getColumnIndex('znName'));
          tmp.enName = resultSet.getString(resultSet.getColumnIndex('enName'));
          tmp.icon = resultSet.getString(resultSet.getColumnIndex('icon'));
          result.push(new TagData(tmp));
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
}

function generateBucket(tag: TagData): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.znName = tag.znName;
  obj.enName = tag.enName;
  obj.icon = tag.icon;
  return obj;
}