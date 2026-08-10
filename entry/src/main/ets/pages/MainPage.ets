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

  /** 液态玻璃栏背景（半透明，配合 backdropBlur） */
  private glassColor(): string {
    return this.currentTheme === 'dark' ? 'rgba(30,30,30,0.55)' : 'rgba(255,255,255,0.6)';
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

  @Builder
  floatingItem(index: number, icon: string, label: ResourceStr) {
    Column({ space: 2 }) {
      // 图标置于亮色渐变胶囊中（选中时），带光晕
      Column() {
        Text(icon)
          .fontSize(20)
          .fontColor(this.currentIndex === index ? Color.White : this.T().textSecondary)
      }
      .width(44)
      .height(38)
      .borderRadius(19)
      .justifyContent(FlexAlign.Center)
      .linearGradient({ colors: this.tabGradient(this.currentIndex === index) })
      .shadow({
        radius: this.currentIndex === index ? 14 : 0,
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
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .onClick(() => { this.currentIndex = index; })
  }

  build() {
    Stack() {
      // 四个 Tab 页：visibility 切换保留各自状态
      HomeTab()
        .visibility(this.currentIndex === 0 ? Visibility.Visible : Visibility.None)
        .width('100%').height('100%')
      InboxTab()
        .visibility(this.currentIndex === 1 ? Visibility.Visible : Visibility.None)
        .width('100%').height('100%')
      ExploreTab()
        .visibility(this.currentIndex === 2 ? Visibility.Visible : Visibility.None)
        .width('100%').height('100%')
      ProfileTab()
        .visibility(this.currentIndex === 3 ? Visibility.Visible : Visibility.None)
        .width('100%').height('100%')

      // 底部手势条（表面色延伸）
      Row()
        .width('100%').height(20)
        .backgroundColor(this.T().surface)
        .align(Alignment.Bottom)

      // 悬浮液态玻璃 tab 栏
      Column() {
        Row({ space: 4 }) {
          this.floatingItem(0, '☷', $r('app.string.tab_home'))
          this.floatingItem(1, '✉', $r('app.string.tab_inbox'))
          this.floatingItem(2, '◎', $r('app.string.tab_explore'))
          this.floatingItem(3, '◉', $r('app.string.tab_profile'))
        }
        .width('100%')
        .height(58)
        .borderRadius(29)
        .backgroundColor(this.glassColor())
        .backdropBlur(20)
        .border({ width: 1, color: this.T().border })
        .shadow({ radius: 16, color: 'rgba(0,0,0,0.28)', offsetY: 6 })
        .padding({ left: 8, right: 8 })
      }
      .width('100%')
      .align(Alignment.Bottom)
      .padding({ left: 16, right: 16, bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.T().background)
  }
}
