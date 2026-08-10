import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../common/constants/ThemeConstants';
import { AuthService } from '../services/AuthService';
import { HomeTab } from './tabs/HomeTab';
import { InboxTab } from './tabs/InboxTab';
import { ExploreTab } from './tabs/ExploreTab';
import { ProfileTab } from './tabs/ProfileTab';

@Entry
@Component
struct MainPage {
  @StorageLink(THEME_KEY) @Watch('onThemeChange') currentTheme: string = 'dark';
  private T(): ThemeColors { const d = this.currentTheme === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  onThemeChange(): void {
    AuthService.saveTheme(this.currentTheme);
    try {
      const isDark: boolean = this.currentTheme !== 'light';
      const ctx = this.getUIContext().getHostContext();
      if (ctx !== undefined && ctx !== null) {
        // 同步系统颜色模式 → NavDestination 标题栏/系统组件颜色跟随主题
        const appCtx = ctx.getApplicationContext();
        if (appCtx !== undefined && appCtx !== null) {
          appCtx.setColorMode(isDark ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        }
        window.getLastWindow(ctx).then((w) => {
          w.setWindowSystemBarProperties({
            statusBarContentColor: isDark ? '#FFFFFF' : '#1F2328'
          });
          w.setWindowBackgroundColor(isDark ? '#121212' : '#F6F8FA');
        });
      }
    } catch (_) {}
  }

  @Builder
  tabBarContent(index: number, icon: string, label: ResourceStr) {
    Column() {
      Text(icon)
        .fontSize(20)
        .fontColor(this.currentIndex === index
          ? this.T().accent
          : this.T().textSecondary)
      Text(label)
        .fontSize(10)
        .fontWeight(FontWeight.Lighter)
        .fontColor(this.currentIndex === index
          ? this.T().accent
          : this.T().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 52 })
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.currentIndex
      }) {
        TabContent() {
          HomeTab()
        }
        .tabBar(this.tabBarContent(0, '☷', $r('app.string.tab_home')))

        TabContent() {
          InboxTab()
        }
        .tabBar(this.tabBarContent(1, '✉', $r('app.string.tab_inbox')))

        TabContent() {
          ExploreTab()
        }
        .tabBar(this.tabBarContent(2, '◎', $r('app.string.tab_explore')))

        TabContent() {
          ProfileTab()
        }
        .tabBar(this.tabBarContent(3, '◉', $r('app.string.tab_profile')))
      }
      .barHeight(52)
      .barBackgroundColor(this.T().surface)
      .backgroundColor(this.T().background)
      .scrollable(false)
      .animationDuration(0)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)

      // 小白条沉浸区：底栏颜色向下延伸
      Row()
        .width('100%')
        .height(20)
        .backgroundColor(this.T().surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.T().background)
  }
}
