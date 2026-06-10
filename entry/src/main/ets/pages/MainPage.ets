import { getThemeColors, ThemeColors, THEME_KEY } from '../common/constants/ThemeConstants';
import { HomeTab } from './tabs/HomeTab';
import { NotificationsTab } from './tabs/NotificationsTab';
import { ExploreTab } from './tabs/ExploreTab';
import { ProfileTab } from './tabs/ProfileTab';

@Entry
@Component
struct MainPage {
  @StorageLink(THEME_KEY) currentTheme: string = 'dark';
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  private getColors(): ThemeColors {
    return getThemeColors(this.currentTheme);
  }

  /**
   * Tab 栏构建器 — 图标 + 文字，选中时高亮
   */
  @Builder
  tabBarContent(index: number, label: ResourceStr) {
    Column() {
      Text(this.tabIcon(index))
        .fontSize(22)
        .fontColor(this.currentIndex === index
          ? this.getColors().tabSelected
          : this.getColors().tabUnselected)
      Text(label)
        .fontSize(11)
        .fontColor(this.currentIndex === index
          ? this.getColors().tabSelected
          : this.getColors().tabUnselected)
        .margin({ top: 2 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .padding({ top: 6 })
    .onClick(() => {
      this.tabsController.changeIndex(index);
    })
  }

  /**
   * Tab 图标 — 使用 Unicode 符号表示各个 Tab
   */
  private tabIcon(index: number): string {
    switch (index) {
      case 0:
        return '⌂';  // Home
      case 1:
        return '🔔';  // Notifications
      case 2:
        return '⌕';  // Explore / Search
      case 3:
        return '👤';  // Profile
      default:
        return '●';
    }
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController,
      index: this.currentIndex
    }) {
      // Tab 0: Home
      TabContent() {
        HomeTab({ theme: this.currentTheme })
      }
      .tabBar(this.tabBarContent(0, $r('app.string.tab_home')))

      // Tab 1: Notifications
      TabContent() {
        NotificationsTab({ theme: this.currentTheme })
      }
      .tabBar(this.tabBarContent(1, $r('app.string.tab_notifications')))

      // Tab 2: Explore
      TabContent() {
        ExploreTab({ theme: this.currentTheme })
      }
      .tabBar(this.tabBarContent(2, $r('app.string.tab_explore')))

      // Tab 3: Profile
      TabContent() {
        ProfileTab({ theme: this.currentTheme })
      }
      .tabBar(this.tabBarContent(3, $r('app.string.tab_profile')))
    }
    .barMode(BarMode.Fixed)
    .barHeight('56vp')
    .barBackgroundColor(this.getColors().tabBarBackground)
    .backgroundColor(this.getColors().background)
    .scrollable(false)
    .animationDuration(200)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
