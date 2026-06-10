import { getThemeColors, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
export struct ExploreTab {
  @Prop theme: string = 'dark';
  private exploreStack: NavPathStack = new NavPathStack();

  private getColors(): ThemeColors {
    return getThemeColors(this.theme);
  }

  @Builder
  explorePageMap(name: string, param: Object) {
    // 未来子页面路由映射
  }

  build() {
    Navigation(this.exploreStack) {
      Column({ space: 20 }) {
        // 搜索框占位
        Row() {
          Text('🔍')
            .fontSize(16)
            .margin({ right: 8 })
          Text($r('app.string.search_placeholder'))
            .fontSize(14)
            .fontColor(this.getColors().textSecondary)
        }
        .width('90%')
        .height(40)
        .backgroundColor(this.getColors().surface)
        .borderRadius(8)
        .border({
          width: 1,
          color: this.getColors().border
        })
        .padding({ left: 12, right: 12 })
        .alignItems(VerticalAlign.Center)

        // 探索提示
        Column({ space: 12 }) {
          Text('🧭')
            .fontSize(36)

          Text($r('app.string.explore_subtitle'))
            .fontSize($r('app.float.body_font_size'))
            .fontColor(this.getColors().textSecondary)
        }
        .margin({ top: 40 })
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getColors().background)
      .padding({ top: 20 })
    }
    .navDestination(this.explorePageMap)
    .title($r('app.string.explore_title'))
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor(this.getColors().background)
    .width('100%')
    .height('100%')
    .hideNavBar(false)
  }
}
