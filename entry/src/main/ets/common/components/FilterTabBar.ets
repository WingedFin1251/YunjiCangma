import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/**
 * 筛选标签栏组件
 * 规范：背景 #1E1E1E，高度 40dp，圆角 8dp
 * 支持左右滑动、点击切换
 *
 * 使用示例：
 *   FilterTabBar({
 *     tabs: ['收件箱', '重点', '未读', '仓库'],
 *     selectedIndex: 0
 *   })
 */
@Component
export struct FilterTabBar {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @Prop tabs: string[] = [];
  @State @Watch('onSelectedChange') selectedIndex: number = 0;
  onChange?: (index: number) => void;

  private onSelectedChange(): void {
    if (this.onChange) {
      this.onChange(this.selectedIndex);
    }
  }

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          Text(tab)
            .fontSize(14)
            .fontColor(this.selectedIndex === index
              ? this.T().textPrimary
              : this.T().textSecondary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedIndex === index
              ? this.T().surfaceElevated
              : Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              this.selectedIndex = index;
            })
        }, (tab: string, index: number) => `${tab}_${index}`)
      }
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(40)
    .backgroundColor(this.T().surface)
  }
}
