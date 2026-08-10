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
  @StorageLink('glowLevel') glowLevel: number = 1;
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

  /** 选中项光晕半径（按档位：弱/均衡/强） */
  private glowRadius(): number {
    if (this.glowLevel === 2) return 22;
    if (this.glowLevel === 0) return 6;
    return 12;
  }

  /** 选中项亮色渐变（按档位调整亮度） */
  private tabGradient(selected: boolean): Array<[ResourceColor, number]> {
    if (!selected) {
      return [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0)', 1]];
    }
    if (this.glowLevel === 0) {
      return this.currentTheme === 'dark' ? [['#218BFE', 0], ['#2E9BFE', 1]] : [['#0969DA', 0], ['#0B78E8', 1]];
    }
    if (this.glowLevel === 2) {
      return this.currentTheme === 'dark' ? [['#1E8CFF', 0], ['#6ED4FF', 1]] : [['#0077E6', 0], ['#3AA6FF', 1]];
    }
    return this.currentTheme === 'dark' ? [['#218BFE', 0], ['#4CC2FF', 1]] : [['#0969DA', 0], ['#1F8FFF', 1]];
  }

  /** 选中项光晕色（按档位调整透明度） */
  private glowShadow(): string {
    const dark: boolean = this.currentTheme === 'dark';
    if (this.glowLevel === 2) return dark ? 'rgba(76,194,255,0.7)' : 'rgba(9,105,218,0.55)';
    if (this.glowLevel === 0) return dark ? 'rgba(76,194,255,0.2)' : 'rgba(9,105,218,0.15)';
    return dark ? 'rgba(76,194,255,0.45)' : 'rgba(9,105,218,0.35)';
  }

  /** HdsTabs 悬浮样式（液态玻璃沉浸材质 + 背板蒙层，材质等级随光感档位） */
  private buildFloatingStyle(): HdsTabsFloatingStyle {
    const dark: boolean = this.currentTheme === 'dark';
    let level: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.ADAPTIVE;
    if (this.glowLevel === 0) level = hdsMaterial.MaterialLevel.GENTLE;
    else if (this.glowLevel === 2) level = hdsMaterial.MaterialLevel.EXQUISITE;
    return {
      barSideMargin: 16,
      barBottomMargin: 36,
      gradientMask: {
        maskColor: dark ? '#33000000' : '#66F1F3F5',
        maskHeight: 68
      },
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: level
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
        radius: this.currentIndex === index ? this.glowRadius() : 0,
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
