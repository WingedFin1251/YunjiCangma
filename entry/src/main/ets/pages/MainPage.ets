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
      .barBackgroundColor(DarkTheme.surface)
      .backgroundColor(DarkTheme.background)
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
        .backgroundColor(DarkTheme.surface)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }
}
