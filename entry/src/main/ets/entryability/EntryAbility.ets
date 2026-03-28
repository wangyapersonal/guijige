import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseService } from '../services/DatabaseService';
import { StorageService } from '../services/StorageService';
import { AuthService } from '../services/AuthService';
import { LocationService } from '../services/LocationService';
import { SyncService } from '../services/SyncService';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    // 设置颜色模式
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    // 初始化服务
    try {
      // 数据库服务
      const dbService = DatabaseService.getInstance();
      await dbService.init();
      hilog.info(DOMAIN, TAG, 'DatabaseService initialized');
      
      // 存储服务
      const storageService = StorageService.getInstance();
      await storageService.init();
      hilog.info(DOMAIN, TAG, 'StorageService initialized');
      
      // 认证服务
      const authService = AuthService.getInstance();
      await authService.init();
      hilog.info(DOMAIN, TAG, 'AuthService initialized, isLoggedIn: %{public}s', 
        authService.isLoggedIn().toString());
      
      // 定位服务
      const locationService = LocationService.getInstance();
      locationService.init(this.context);
      hilog.info(DOMAIN, TAG, 'LocationService initialized');
      
      // 同步服务
      const syncService = SyncService.getInstance();
      await syncService.init();
      hilog.info(DOMAIN, TAG, 'SyncService initialized');
    } catch (error: Error) {
      hilog.error(DOMAIN, TAG, 'Service initialization failed: %{public}s', JSON.stringify(error));
    }
    
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }
}
