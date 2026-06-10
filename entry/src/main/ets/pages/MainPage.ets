import { DarkTheme } from '../common/constants/ThemeConstants';
import { HomeTab } from './tabs/HomeTab';
import { InboxTab } from './tabs/InboxTab';
import { ExploreTab } from './tabs/ExploreTab';
import { ProfileTab } from './tabs/ProfileTab';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  /**
   * Tab 栏构建器 — 平板适配：10sp 文字 + 20fp 几何符号
   */
  @Builder
  tabBarContent(index: number, icon: string, label: ResourceStr) {
    Column() {
      Text(icon)
        .fontSize(20)
        .fontColor(this.currentIndex === index
          ? DarkTheme.accent
          : DarkTheme.textSecondary)
      Text(label)
        .fontSize(10)
        .fontWeight(FontWeight.Lighter)
        .fontColor(this.currentIndex === index
          ? DarkTheme.accent
          : DarkTheme.textSecondary)
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
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController,
      index: this.currentIndex
    }) {
      TabContent() {
        HomeTab()
      }
      .tabBar(this.tabBarContent(0, '⌂', $r('app.string.tab_home')))

      TabContent() {
        InboxTab()
      }
      .tabBar(this.tabBarContent(1, '✉', $r('app.string.tab_inbox')))

      TabContent() {
        ExploreTab()
      }
      .tabBar(this.tabBarContent(2, '⊕', $r('app.string.tab_explore')))

      TabContent() {
        ProfileTab()
      }
      .tabBar(this.tabBarContent(3, '◉', $r('app.string.tab_profile')))
    }
    .barHeight(52)
    .barBackgroundColor(DarkTheme.surface)
    .backgroundColor(DarkTheme.background)
    .scrollable(false)
    .animationDuration(0)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .width('100%')
    .height('100%')
  }
}
