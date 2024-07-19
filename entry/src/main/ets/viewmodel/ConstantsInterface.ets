export interface EventTable {
  tableName: string;
  sqlCreate: string;
  sqlInit: string;
  columns: string[];
}

export interface TagTable {
  tableName: string;
  sqlCreate: string;
  sqlInit: string;
  columns: string[];
}