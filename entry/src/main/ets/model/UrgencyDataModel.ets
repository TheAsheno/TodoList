import common from '@ohos.app.ability.common';
import dataStorage from '@ohos.data.preferences';
import { urgencyLvArr, urgencyInfoBean, urgencyItemArr } from '../viewmodel/UrgencyData';
import { Logger } from '../common/utils/Logger';
import CommonConstants from '../common/constants/CommonConstants';
import dayjs from "dayjs";

class UrgencyDataModel {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  public urgencyList: Array<urgencyInfoBean> = urgencyItemArr;

  constructor() {
    this.context.config.colorMode
    this.saveDefaultData();
  }

  async saveDefaultData() {
    try {
      let preferences = await dataStorage.getPreferences(this.context, CommonConstants.PREFERENCE_INSTANCE_NAME);
      let isExist = await preferences.has(CommonConstants.PREFERENCE_URGENCY_KEY);
      if (!isExist) {
        preferences.put(CommonConstants.PREFERENCE_URGENCY_KEY, JSON.stringify(urgencyLvArr));
        preferences.flush();
        urgencyItemArr.forEach((item: urgencyInfoBean) => {
          let urgency: urgencyInfoBean = item;
          let res = preferences.put(item.urgencyLv, JSON.stringify(urgency));
          preferences.flush();
          res.then(() => {
            Logger.info('', 'Put the value successfully.' + item.urgencyLv);
          }).catch((err: Error) => {
            Logger.error('', `Put the value failed with err: ${err}`);
          })
        })
      }
      else
        this.getUrgencyList();
    } catch (err) {
      Logger.error('', `Put the value failed with err: ${err}`);
    }
  }

  async getUrgencyList() {
    let preferences = await dataStorage.getPreferences(this.context, CommonConstants.PREFERENCE_INSTANCE_NAME);
    let urgencyLvs = await preferences.get(CommonConstants.PREFERENCE_URGENCY_KEY, '');
    this.urgencyList = [];
    JSON.parse(urgencyLvs.toString()).forEach(async (item: urgencyInfoBean) => {
      let urgency = await preferences.get(item.urgencyLv, '');
      this.urgencyList.push(JSON.parse(urgency.toString()));
    })
  }

  async updateUrgency(urgencyList: Array<urgencyInfoBean>) {
    let preferences = await dataStorage.getPreferences(this.context, CommonConstants.PREFERENCE_INSTANCE_NAME);
    for (let i = 0; i < urgencyList.length; i++) {
      await preferences.put(urgencyList[i].urgencyLv, JSON.stringify(urgencyList[i]));
    }
    await preferences.flush();
    this.urgencyList = urgencyList;
  }

  getCircleColor(deadlineTime: string) {
    let daysDiff = dayjs(deadlineTime).diff(dayjs(),'day', true)
    if (daysDiff < 0)
      return $r('app.color.deadlineExpireColor');
    else if (daysDiff < Number(this.urgencyList[0].days))
      return $r('app.color.deadlineLv1Color');
    else if (daysDiff < Number(this.urgencyList[1].days))
      return $r('app.color.deadlineLv2Color');
    else if (daysDiff < Number(this.urgencyList[2].days))
      return $r('app.color.deadlineLv3Color');
    else if (daysDiff < Number(this.urgencyList[3].days))
      return $r('app.color.deadlineLv4Color');
    else
      return $r('app.color.deadlineResidualColor');
  }
}

const UrgencyData = new UrgencyDataModel();

export default UrgencyData;