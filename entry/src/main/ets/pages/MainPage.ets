import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { HdsTabs, HdsTabsController, HdsTabsFloatingStyle, hdsMaterial } from '@kit.UIDesignKit';
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
  private T(): ThemeColors {
    const d: boolean = this.currentTheme === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated,
      border: d ? DarkTheme.border : LightTheme.border,
      textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary,
      textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary,
      textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary,
      accent: d ? DarkTheme.accent : LightTheme.accent,
      issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen,
      prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue,
      discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple,
      orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange,
      starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow,
      clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback
    };
  }
  @State currentIndex: number = 0;
  private tabsController: HdsTabsController = new HdsTabsController();

  onThemeChange(): void {
    AuthService.saveTheme(this.currentTheme);
    try {
      const isDark: boolean = this.currentTheme !== 'light';
      const ctx = this.getUIContext().getHostContext();
      if (ctx !== undefined && ctx !== null) {
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

  /** 选中项亮色渐变（accent → 亮） */
  private tabGradient(selected: boolean): Array<[ResourceColor, number]> {
    if (!selected) {
      return [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0)', 1]];
    }
    if (this.currentTheme === 'dark') {
      return [['#218BFE', 0], ['#4CC2FF', 1]];
    }
    return [['#0969DA', 0], ['#1F8FFF', 1]];
  }

  /** 选中项光晕色 */
  private glowShadow(): string {
    return this.currentTheme === 'dark' ? 'rgba(76,194,255,0.45)' : 'rgba(9,105,218,0.35)';
  }

  /** HdsTabs 悬浮样式（液态玻璃沉浸材质） */
  private buildFloatingStyle(): HdsTabsFloatingStyle {
    return {
      barSideMargin: 16,
      barBottomMargin: 36,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      }
    };
  }

  @Builder
  tabBarContent(index: number, icon: string, label: ResourceStr) {
    Column({ space: 2 }) {
      // 光感胶囊：选中时图标置于亮色渐变胶囊中，带光晕
      Column() {
        Text(icon)
          .fontSize(20)
          .fontColor(this.currentIndex === index ? Color.White : this.T().textSecondary)
      }
      .width(44)
      .height(34)
      .borderRadius(17)
      .justifyContent(FlexAlign.Center)
      .linearGradient({ colors: this.tabGradient(this.currentIndex === index) })
      .shadow({
        radius: this.currentIndex === index ? 12 : 0,
        color: this.currentIndex === index ? this.glowShadow() : 'rgba(0,0,0,0)',
        offsetY: 0
      })
      .animation({ duration: 200, curve: Curve.FastOutSlowIn })

      Text(label)
        .fontSize(10)
        .fontWeight(FontWeight.Lighter)
        .fontColor(this.currentIndex === index ? this.T().accent : this.T().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 52 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => { this.tabsController.changeIndex(index); })
  }

  build() {
    Column() {
      HdsTabs({
        barPosition: BarPosition.End,
        index: this.currentIndex,
        controller: this.tabsController
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
      .barOverlap(true)
      .barBackgroundColor(Color.Transparent)
      .barBackgroundBlurStyle(BlurStyle.COMPONENT_THIN)
      .barFloatingStyle(this.buildFloatingStyle())
      .backgroundColor(this.T().background)
      .scrollable(false)
      .animationDuration(0)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.T().background)
  }
}
