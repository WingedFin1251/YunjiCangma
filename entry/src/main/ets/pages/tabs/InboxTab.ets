import { Theme } from '../../common/constants/ThemeConstants';
import { EmptyState } from '../../common/components/EmptyState';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import type { GitHubNotification } from '../../models/User';

@Component
export struct InboxTab {
  private inboxStack: NavPathStack = new NavPathStack();
  @State selectedFilter: number = 0;
  @State notifications: GitHubNotification[] = [];
  @State isInboxLoading: boolean = true;
  private filterTabs: string[] = ['收件箱', '重点', '未读', '仓库'];

  aboutToAppear(): void {
    this.loadNotifications();
  }

  private async loadNotifications(): Promise<void> {
    try {
      this.notifications = await GitHubAPIService.getNotifications();
    } catch (err) {
      this.notifications = [];
    } finally {
      this.isInboxLoading = false;
    }
  }

  /** 筛选后的通知列表 */
  private getFilteredNotifications(): GitHubNotification[] {
    if (this.selectedFilter === 1 || this.selectedFilter === 2) {
      return this.notifications.filter((n: GitHubNotification) => n.unread);
    }
    return this.notifications;
  }

  /** 通知类型图标 */
  private getNotifIcon(notif: GitHubNotification): string {
    const stype: string = notif.subject.type;
    if (stype === 'Issue') return '●';
    if (stype === 'PullRequest') return '⇄';
    if (stype === 'Discussion') return '◈';
    return '✉';
  }

  private getNotifIconColor(notif: GitHubNotification): string {
    const stype: string = notif.subject.type;
    if (stype === 'Issue') return Theme.issueGreen;
    if (stype === 'PullRequest') return Theme.prBlue;
    if (stype === 'Discussion') return Theme.discussionPurple;
    return Theme.textSecondary;
  }

  @Builder
  inboxPageMap(name: string, param: ESObject) {}

  build() {
    Navigation(this.inboxStack) {
      Column() {
        // === 顶部导航栏 ===
        Row() {
          Text($r('app.string.page_title_inbox'))
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textPrimary)
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
                    ? Theme.textPrimary
                    : Theme.textSecondary)
                // 下拉指示器
                if (index === 0 || index === 3) {
                  Text('▼')
                    .fontSize(8)
                    .fontColor(this.selectedFilter === index
                      ? Theme.textPrimary
                      : Theme.textSecondary)
                    .margin({ left: 4 })
                }
              }
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.selectedFilter === index
                ? Theme.surfaceElevated
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
        .backgroundColor(Theme.surface)

        // 分割线
        Divider()
          .color(Theme.border)
          .width('100%')

        // === 主内容区 ===
        if (this.isInboxLoading) {
          Column() {
            LoadingProgress().width(32).height(32).color(Theme.accent).margin({ top: 80 })
          }
          .width('100%').height('100%').backgroundColor(Theme.background)
        } else if (this.getFilteredNotifications().length > 0) {
          this.buildNotificationList()
        } else {
          EmptyState({ icon: '✉', title: '暂无新消息', subtitle: '所有通知已查看，随心探索开源仓库' })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 32, bottom: 64 })
      .backgroundColor(Theme.background)
    }
    .navDestination(this.inboxPageMap)
    .backgroundColor(Theme.background)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  buildNotificationList() {
    Scroll() {
      Column() {
        ForEach(this.getFilteredNotifications(), (item: GitHubNotification, index: number) => {
          Row() {
            Text(this.getNotifIcon(item))
              .fontSize(16)
              .fontColor(this.getNotifIconColor(item))
              .width(24)
              .height(24)
              .textAlign(TextAlign.Center)

            Column() {
              Text(item.subject.title)
                .fontSize(14)
                .fontColor(Theme.textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.repository.full_name)
                .fontSize(12)
                .fontColor(Theme.textTertiary)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            if (item.unread) {
              Circle()
                .width(8)
                .height(8)
                .fill(Theme.accent)
            }
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)
        }, (item: GitHubNotification) => item.id)
      }
      .width('100%')
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.background)
  }
}
