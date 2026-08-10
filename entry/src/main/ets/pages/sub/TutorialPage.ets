import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
export struct TutorialPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        // 沉浸标题栏占位：初始避开标题栏，滚动时滑入磨砂下
        Blank(100)
        this.step('1', '登录 GitHub 账号', '点击底部「我的」→「登录账号」，在 WebView 中授权 GitHub OAuth，完成后即可访问您的仓库与数据。')
        this.step('2', '浏览仓库', '在「我的」页面点击「仓库」查看您的所有仓库，点击任一仓库卡片即可在 WebView 中查看详情。')
        this.step('3', '查看通知', '在「消息」页面查看 GitHub 通知，通过筛选标签快速定位未读或重点消息。')
        this.step('4', '发现热门项目', '在「发现」页面浏览 GitHub 热门仓库与活动动态，点击仓库卡片跳转详情。')
        this.step('5', '管理收藏', '在「首页」查看您已加星标的仓库，随时回顾感兴趣的项目。')
        this.step('6', '切换主题', '点击「我的」→ 右上角 ☰ →「设置」→ 深色模式开关，随心切换浅色 / 深色主题。')
        Blank().height(48)
      }.width('100%')
    }
    .scrollBar(BarState.Off).width('100%').height('100%')
    .backgroundColor(this.T().background).padding({ top: 8 })
  }

  @Builder
  step(num: string, title: string, desc: string) {
    Row() {
      Text(num).fontSize(14).fontWeight(FontWeight.Bold).fontColor(this.T().accent)
        .width(28).height(28).borderRadius(14)
        .backgroundColor(this.T().surfaceElevated).textAlign(TextAlign.Center).lineHeight(28)
      Column({ space: 4 }) {
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
        Text(desc).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20)
      }.alignItems(HorizontalAlign.Start).margin({ left: 14 }).layoutWeight(1)
    }
    .width('100%').padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .alignItems(VerticalAlign.Top)
  }
}
