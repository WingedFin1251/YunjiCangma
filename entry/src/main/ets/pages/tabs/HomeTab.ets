import { getThemeColors, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
export struct HomeTab {
  @Prop theme: string = 'dark';
  private homeStack: NavPathStack = new NavPathStack();

  private getColors(): ThemeColors {
    return getThemeColors(this.theme);
  }

  @Builder
  homePageMap(name: string, param: Object) {
    // 未来子页面路由映射
  }

  build() {
    Navigation(this.homeStack) {
      Column() {
        // 欢迎区域
        Column({ space: 12 }) {
          // Octocat 图标占位
          Text('🐙')
            .fontSize(64)

          Text($r('app.string.welcome_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getColors().textPrimary)

          Text($r('app.string.welcome_subtitle'))
            .fontSize(14)
            .fontColor(this.getColors().textSecondary)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.getColors().background)
    }
    .navDestination(this.homePageMap)
    .title($r('app.string.home_title'))
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor(this.getColors().background)
    .width('100%')
    .height('100%')
    .hideNavBar(false)
  }
}
