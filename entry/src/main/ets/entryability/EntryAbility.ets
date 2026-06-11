import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AuthService } from '../services/AuthService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    AuthService.init(this.context);
    AppStorage.setOrCreate('authToken', '');
    AppStorage.setOrCreate('isLoggedIn', false);

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 加载持久化 token + 主题
    await AuthService.loadToken();
    const savedTheme: string = await AuthService.loadTheme();
    AppStorage.setOrCreate('currentTheme', savedTheme);

    // 全屏沉浸 — 状态栏透明叠加，窗口延伸至屏幕顶部
    try {
      const mainWindow = windowStage.getMainWindowSync();
      mainWindow.setWindowLayoutFullScreen(true);
      const isDark: boolean = savedTheme !== 'light';
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: '#00FFFFFF',
        statusBarContentColor: isDark ? '#FFFFFF' : '#1F2328',
        navigationBarColor: isDark ? '#1E1E1E' : '#F6F8FA'
      });
    } catch (err) {
      hilog.warn(DOMAIN, 'testTag', 'Failed to set immersive window. Cause: %{public}s', JSON.stringify(err));
    }

    // 同步系统颜色模式 → NavDestination 标题/返回按钮可见
    this.context.getApplicationContext().setColorMode(
      savedTheme !== 'light' ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
    );

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
