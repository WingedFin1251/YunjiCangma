import { DarkTheme } from '../../common/constants/ThemeConstants';
import { EmptyState } from '../../common/components/EmptyState';

/**
 * 收件箱 Inbox (Tab 2)
 * 布局：顶部导航栏 → 筛选标签栏 → 主内容区（空状态/通知列表）
 */
@Component
export struct InboxTab {
  private inboxStack: NavPathStack = new NavPathStack();
  @State selectedFilter: number = 0;
  private filterTabs: string[] = ['收件箱', '重点', '未读', '仓库'];

  @Builder
  inboxPageMap(name: string, param: Object) {}

  build() {
    Navigation(this.inboxStack) {
      Column() {
        // === 顶部导航栏 ===
        Row() {
          Text($r('app.string.page_title_inbox'))
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(DarkTheme.textPrimary)
            .layoutWeight(1)

          // 右侧功能图标：更多
          Text('⋯')
            .fontSize(20)
            .width(44)
            .height(44)
            .textAlign(TextAlign.Center)
            .lineHeight(44)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)

        // === 筛选标签栏 ===
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.filterTabs, (tab: string, index: number) => {
              Row() {
                Text(tab)
                  .fontSize(14)
                  .fontColor(this.selectedFilter === index
                    ? DarkTheme.textPrimary
                    : DarkTheme.textSecondary)
                // 下拉指示器
                if (index === 0 || index === 3) {
                  Text('▼')
                    .fontSize(8)
                    .fontColor(this.selectedFilter === index
                      ? DarkTheme.textPrimary
                      : DarkTheme.textSecondary)
                    .margin({ left: 4 })
                }
              }
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.selectedFilter === index
                ? DarkTheme.surfaceElevated
                : Color.Transparent)
              .borderRadius(8)
              .onClick(() => {
                this.selectedFilter = index;
              })
            }, (tab: string, index: number) => `${tab}_${index}`)
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(40)
        .backgroundColor(DarkTheme.surface)

        // 分割线
        Divider()
          .color(DarkTheme.border)
          .width('100%')

        // === 主内容区：空状态 ===
        EmptyState({
          icon: '✉',
          title: '都赶上了！',
          subtitle: '休息一下，写一些代码，做您最擅长的事'
        })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 32, bottom: 64 })
      .backgroundColor(DarkTheme.background)
    }
    .navDestination(this.inboxPageMap)
    .backgroundColor(DarkTheme.background)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}
