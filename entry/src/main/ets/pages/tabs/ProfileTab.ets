import { getThemeColors, ThemeColors, THEME_KEY } from '../../common/constants/ThemeConstants';

@Component
export struct ProfileTab {
  @Prop theme: string = 'dark';
  private profileStack: NavPathStack = new NavPathStack();

  private getColors(): ThemeColors {
    return getThemeColors(this.theme);
  }

  @Builder
  profilePageMap(name: string, param: Object) {
    // 未来子页面路由映射
  }

  build() {
    Navigation(this.profileStack) {
      Column({ space: 16 }) {
        // 头像占位
        Circle()
          .width($r('app.float.avatar_size'))
          .height($r('app.float.avatar_size'))
          .fill(this.getColors().surface)
          .border({
            width: 1,
            color: this.getColors().border
          })

        // 用户名
        Text($r('app.string.profile_username'))
          .fontSize($r('app.float.page_title_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getColors().textPrimary)

        Text($r('app.string.profile_userhandle'))
          .fontSize($r('app.float.caption_font_size'))
          .fontColor(this.getColors().textSecondary)

        // 分割线
        Divider()
          .color(this.getColors().border)
          .width('90%')
          .margin({ top: 16, bottom: 8 })

        // 深色模式开关
        Row() {
          Text('🌙')
            .fontSize(18)
            .margin({ right: 10 })

          Text($r('app.string.dark_mode_label'))
            .fontSize($r('app.float.body_font_size'))
            .fontColor(this.getColors().textPrimary)

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.theme === 'dark' })
            .onChange((isOn: boolean) => {
              AppStorage.setOrCreate(THEME_KEY, isOn ? 'dark' : 'light');
            })
        }
        .width('85%')
        .height(48)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.getColors().surface)
        .borderRadius(10)
        .border({
          width: 1,
          color: this.getColors().border
        })
        .alignItems(VerticalAlign.Center)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor(this.getColors().background)
    }
    .navDestination(this.profilePageMap)
    .title($r('app.string.profile_title'))
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor(this.getColors().background)
    .width('100%')
    .height('100%')
    .hideNavBar(false)
  }
}
