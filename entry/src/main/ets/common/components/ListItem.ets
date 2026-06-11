import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/**
 * 列表功能项组件
 * 规范：左图标(24dp) + 右文字(16sp)，条目高度52dp，整行可点击
 * 点击反馈色 #383838
 *
 * 使用示例：
 *   ListItem({
 *     icon: '🟢',
 *     label: '议题',
 *     showArrow: true
 *   })
 */
@Component
export struct ListItem {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @Prop icon: string = '';
  @Prop label: string = '';
  @Prop iconColor: ResourceColor = this.T().accent;
  @Prop showArrow: boolean = false;
  @Prop badgeCount: number = 0;
  onItemClick?: () => void;

  build() {
    Row() {
      // 彩色图标
      Text(this.icon)
        .fontSize(20)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)

      // 功能名称
      Text(this.label)
        .fontSize(16)
        .fontColor(this.T().textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)

      // 右侧数量标签
      if (this.badgeCount > 0) {
        Text(this.badgeCount.toString())
          .fontSize(12)
          .fontColor(this.T().textTertiary)
          .margin({ right: 8 })
      }

      // 箭头
      if (this.showArrow) {
        Text('›')
          .fontSize(20)
          .fontColor(this.T().textSecondary)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.T().background)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
    .responseRegion({
      x: 0, y: 0,
      width: '100%',
      height: 52
    })
  }
}
