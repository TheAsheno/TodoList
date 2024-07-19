@Observed
export default class TagData {
  id: number;
  znName: string;
  enName: string;
  icon: string;

  constructor(item: { id: number, znName: string, enName: string, icon: string } ) {
    this.id = item.id;
    this.znName = item.znName;
    this.enName = item.enName;
    this.icon = item.icon;
  }
}