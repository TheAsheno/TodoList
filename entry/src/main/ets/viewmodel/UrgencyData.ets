export class urgencyLvBean {
  urgencyLv: string;

  constructor(urgencyLv: string) {
    this.urgencyLv = urgencyLv;
  }
}

export class urgencyInfoBean {
  urgencyLv: string;
  days: string;
  depict: string;
  constructor(urgencyLv: string, days: string, depict: string) {
    this.urgencyLv = urgencyLv;
    this.days = days;
    this.depict = depict;
  }
}

export const urgencyItemArr: urgencyInfoBean[] = [
  new urgencyInfoBean('Lv1', '1', '非常紧急'),
  new urgencyInfoBean('Lv2', '3', '紧急'),
  new urgencyInfoBean('Lv3', '5', '还有时间'),
  new urgencyInfoBean('Lv4', '7', '该开始了')
];

export const urgencyLvArr: urgencyLvBean[] = [new urgencyLvBean('Lv1'), new urgencyLvBean('Lv2'),
  new urgencyLvBean('Lv3'), new urgencyLvBean('Lv4')];