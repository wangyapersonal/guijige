import { UIAbility, AbilityConstant, Want, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseService } from '../services/DatabaseService';
import { StorageService } from '../services/StorageService';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'EntryAbility';
const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
    await DatabaseService.getInstance(this.context).init();
    await StorageService.getInstance().init(this.context);
  }

  onDestroy() {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `Failed to load the content. Cause: ${JSON.stringify(err)}`);
      } else {
        hilog.info(DOMAIN, TAG, `Succeeded in loading the content. Data: ${JSON.stringify(data)}`);
      }
    });
  }

  onWindowStageDestroy() {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground() {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }

  onWindowStageWillDestroy(windowStage: window.WindowStage) {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageWillDestroy');
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, `Ability onContinue`);
    return AbilityConstant.OnContinueResult.AGREE;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN, TAG, 'Ability onNewWant');
  }

  onConfigurationUpdate(config: Configuration) {
    hilog.info(DOMAIN, TAG, `Ability onConfigurationUpdate, config: ${JSON.stringify(config)}`);
  }
}