import { Theme, THEME_KEY } from '../common/constants/ThemeConstants';
import { AuthService } from '../services/AuthService';
import { HomeTab } from './tabs/HomeTab';
import { InboxTab } from './tabs/InboxTab';
import { ExploreTab } from './tabs/ExploreTab';
import { ProfileTab } from './tabs/ProfileTab';

@Entry
@Component
struct MainPage {
  @StorageLink(THEME_KEY) @Watch('onThemeChange') currentTheme: string = 'dark';
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  aboutToAppear(): void {
    const saved: string = AppStorage.get<string>(THEME_KEY) || 'dark';
    if (saved === 'light') { Theme.setLight(); } else { Theme.setDark(); }
  }

  onThemeChange(): void {
    if (this.currentTheme === 'light') { Theme.setLight(); } else { Theme.setDark(); }
    AuthService.saveTheme(this.currentTheme);
  }

  @Builder
  tabBarContent(index: number, icon: string, label: ResourceStr) {
    Column() {
      Text(icon)
        .fontSize(20)
        .fontColor(this.currentIndex === index
          ? Theme.accent
          : Theme.textSecondary)
      Text(label)
        .fontSize(10)
        .fontWeight(FontWeight.Lighter)
        .fontColor(this.currentIndex === index
          ? Theme.accent
          : Theme.textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({ maxWidth: 52 })
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController,
        index: this.currentIndex
      }) {
        TabContent() {
          HomeTab()
        }
        .tabBar(this.tabBarContent(0, '☷', $r('app.string.tab_home')))

        TabContent() {
          InboxTab()
        }
        .tabBar(this.tabBarContent(1, '✉', $r('app.string.tab_inbox')))

        TabContent() {
          ExploreTab()
        }
        .tabBar(this.tabBarContent(2, '◎', $r('app.string.tab_explore')))

        TabContent() {
          ProfileTab()
        }
        .tabBar(this.tabBarContent(3, '◉', $r('app.string.tab_profile')))
      }
      .barHeight(52)
      .barBackgroundColor(Theme.surface)
      .backgroundColor(Theme.background)
      .scrollable(false)
      .animationDuration(0)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
      .layoutWeight(1)

      // 小白条沉浸区：底栏颜色向下延伸
      Row()
        .width('100%')
        .height(20)
        .backgroundColor(Theme.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.background)
  }
}
