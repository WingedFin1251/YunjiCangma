import { getThemeColors, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
export struct NotificationsTab {
  @Prop theme: string = 'dark';
  private notifStack: NavPathStack = new NavPathStack();

  private getColors(): ThemeColors {
    return getThemeColors(this.theme);
  }

  @Builder
  notifPageMap(name: string, param: Object) {
    // 未来子页面路由映射
  }

  build() {
    Navigation(this.notifStack) {
      Column({ space: 12 }) {
        // 通知铃铛图标
        Text('🔔')
          .fontSize(48)

        Text($r('app.string.no_notifications'))
          .fontSize($r('app.float.body_font_size'))
          .fontColor(this.getColors().textPrimary)

        Text($r('app.string.notifications_hint'))
          .fontSize($r('app.float.caption_font_size'))
          .fontColor(this.getColors().textSecondary)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getColors().background)
    }
    .navDestination(this.notifPageMap)
    .title($r('app.string.notifications_title'))
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor(this.getColors().background)
    .width('100%')
    .height('100%')
    .hideNavBar(false)
  }
}
