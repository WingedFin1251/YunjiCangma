import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/**
 * 底部 Tab 栏构建器
 * 规范：52dp 高，22dp 图标，12sp Light 文字
 * 选中：图标+文字 #218BFE
 * 未选中：图标+文字 #B3B3B3
 * 点击即时切换，无动画
 *
 * 使用示例（在 MainPage @Builder 中调用 TabBar 内联）：
 *   TabBarItem({ label: '主页', icon: '⌂', isSelected: currentIndex === 0 })
 */
@Component
export struct TabBarItem {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @Prop label: string = '';
  @Prop icon: string = '';
  @Prop isSelected: boolean = false;

  build() {
    Column() {
      Text(this.icon)
        .fontSize(22)
        .fontColor(this.isSelected ? this.T().accent : this.T().textSecondary)
      Text(this.label)
        .fontSize(12)
        .fontWeight(FontWeight.Light)
        .fontColor(this.isSelected ? this.T().accent : this.T().textSecondary)
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}
