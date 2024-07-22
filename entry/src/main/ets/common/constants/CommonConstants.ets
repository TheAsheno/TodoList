import relationalStore from '@ohos.data.relationalStore';
import { EventTable, TagTable, ScheduleTable } from '../../viewmodel/ConstantsInterface';

export default class CommonConstants {

  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };

  static readonly EVENT_TABLE: EventTable = {
    tableName: 'eventTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS eventTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, ' +
    'note TEXT, createTime TEXT, deadlineTime TEXT, updateTime TEXT, tag TEXT, isDone BOOLEAN)',
    sqlInit: '',
    columns: ['id', 'name', 'note', 'createTime', 'deadlineTime', 'updateTime', 'tag', 'isDone']
  }

  static readonly TAG_TABLE: TagTable = {
    tableName: 'tagTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS tagTable(id INTEGER PRIMARY KEY AUTOINCREMENT, znName TEXT, enName TEXT, icon TEXT)',
    sqlInit: "INSERT INTO tagTable (znName, enName, icon) SELECT * FROM (SELECT '作业', 'homework', 'ic_tag_hw.svg' UNION ALL SELECT '开发', 'development', 'ic_tag_dev.svg' UNION ALL SELECT '日常', 'routine', 'ic_tag_rt.svg' UNION ALL SELECT '实验', 'experiment', 'ic_tag_exp.svg') WHERE NOT EXISTS (SELECT * FROM tagTable);",
    columns: ['id', 'znName', 'enName', 'icon']
  }

  static readonly SCHEDULE_TABLE: TagTable = {
    tableName: 'scheduleTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS scheduleTable(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, time TEXT, eventId INTEGER)',
    sqlInit: '',
    columns: ['id', 'text', 'time', 'eventId']
  }

  static readonly PREFERENCE_INSTANCE_NAME: string = 'myStore';
  static readonly PREFERENCE_URGENCY_KEY: string = 'urgencyLvArr';

  static readonly RDB_TAG = '[Debug.Rdb]';
  static readonly EVENT_TABLE_TAG = '[Debug.EventTable]';
  static readonly TAG_TABLE_TAG = '[Debug.TagTable]';
  static readonly SCHEDULE_TABLE_TAG = '[Debug.ScheduleTable]';
  static readonly INDEX_TAG = '[Debug.Index]';
}