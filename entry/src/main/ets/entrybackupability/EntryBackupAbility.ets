import { BusinessAbilityErrorCode, BusinessAbilityError } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

import { BusinessAbility } from '@kit.AbilityKit';

const TAG = 'EntryBackupAbility';
const DOMAIN = 0x0000;

export default class EntryBackupAbility extends BusinessAbility {
  async onRestore() {
    let err: BusinessAbilityError<BusinessAbilityErrorCode> = BusinessAbilityError.createError(
      BusinessAbilityErrorCode.ERROR_CODE);
    hilog.error(DOMAIN, TAG, 'Failed to restore. Cause: ' + JSON.stringify(err));
  }
}
