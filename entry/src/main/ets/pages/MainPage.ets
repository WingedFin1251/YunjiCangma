import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { HdsTabs, HdsTabsController, HdsTabsFloatingStyle, HdsAnimationMode, hdsMaterial } from '@kit.UIDesignKit';
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
  @State bottomAvoidAreaHeight: number = 12;
  private tabsController: HdsTabsController = new HdsTabsController();

  aboutToAppear(): void {
    // 确保首次加载时状态栏颜色正确（@Watch 首次不触发）
    this.onThemeChange();
    // HDS IMMERSIVE 材质渲染后会覆盖状态栏颜色，延迟重新设置
    setTimeout(() => { this.onThemeChange(); }, 300);
    // 动态计算底部导航栏避让高度（与 PiliPlus 一致）
    try {
      const ctx = this.getUIContext().getHostContext();
      if (ctx) {
        window.getLastWindow(ctx).then((w: window.Window) => {
          const bottomArea = w.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          const h: number = bottomArea.bottomRect.height;
          this.bottomAvoidAreaHeight = h === 0 ? 12 : (px2vp(h) + 1);
          w.on('avoidAreaChange', (data) => {
            if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
              const bh: number = data.area.bottomRect.height;
              this.bottomAvoidAreaHeight = bh === 0 ? 12 : (px2vp(bh) + 1);
            }
          });
        }).catch(() => {});
      }
    } catch (_) {}
  }

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
        }).catch(() => {});
      }
    } catch (_) {}
  }

  /** HdsTabs 悬浮样式（与 PiliPlus ohos 一致） */
  private buildFloatingStyle(): HdsTabsFloatingStyle {
    let level: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.ADAPTIVE;
    if (this.glowLevel === 0) level = hdsMaterial.MaterialLevel.GENTLE;
    else if (this.glowLevel === 2) level = hdsMaterial.MaterialLevel.EXQUISITE;
    return {
      barBottomMargin: this.bottomAvoidAreaHeight,
      adaptToHandedness: true,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.IMMERSIVE,
        materialLevel: level
      }
    };
  }

  @Builder
  tabBarContent(index: number, grayDark: Resource, grayLight: Resource, accentDark: Resource, accentLight: Resource, label: ResourceStr) {
    Column({ space: 3 }) {
      if (this.currentIndex === index) {
        // 选中：accent 色描边线稿
        Image(this.currentTheme === 'dark' ? accentDark : accentLight)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .animation({ duration: 200, curve: Curve.FastOutSlowIn })
      } else {
        // 未选中：灰描边线稿（按主题取色）
        Image(this.currentTheme === 'dark' ? grayDark : grayLight)
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
          .animation({ duration: 200, curve: Curve.FastOutSlowIn })
      }

      Text(label)
        .fontSize(10.5)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? this.T().accent : this.T().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
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
          HomeTab({ tabsController: this.tabsController, onNavChanged: (hide: boolean) => {
            if (hide) {
              this.tabsController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            } else {
              this.tabsController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            }
          } })
        }
        .tabBar(this.tabBarContent(0, $r('app.media.tab_home_line_d'), $r('app.media.tab_home_line_l'), $r('app.media.tab_home_line_a_d'), $r('app.media.tab_home_line_a_l'), $r('app.string.tab_home')))

        TabContent() {
          InboxTab({ tabsController: this.tabsController, onNavChanged: (hide: boolean) => {
            if (hide) {
              this.tabsController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            } else {
              this.tabsController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            }
          } })
        }
        .tabBar(this.tabBarContent(1, $r('app.media.tab_inbox_line_d'), $r('app.media.tab_inbox_line_l'), $r('app.media.tab_inbox_line_a_d'), $r('app.media.tab_inbox_line_a_l'), $r('app.string.tab_inbox')))

        TabContent() {
          ExploreTab({ tabsController: this.tabsController, onNavChanged: (hide: boolean) => {
            if (hide) {
              this.tabsController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            } else {
              this.tabsController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            }
          } })
        }
        .tabBar(this.tabBarContent(2, $r('app.media.tab_explore_line_d'), $r('app.media.tab_explore_line_l'), $r('app.media.tab_explore_line_a_d'), $r('app.media.tab_explore_line_a_l'), $r('app.string.tab_explore')))

        TabContent() {
          ProfileTab({ tabsController: this.tabsController, onNavChanged: (hide: boolean) => {
            if (hide) {
              this.tabsController.applyHideAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            } else {
              this.tabsController.applyShowAnimation(HdsAnimationMode.SCROLL_ANIMATION);
            }
          } })
        }
        .tabBar(this.tabBarContent(3, $r('app.media.tab_profile_line_d'), $r('app.media.tab_profile_line_l'), $r('app.media.tab_profile_line_a_d'), $r('app.media.tab_profile_line_a_l'), $r('app.string.tab_profile')))
      }
      .barHeight(56)
      .barOverlap(true)
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
