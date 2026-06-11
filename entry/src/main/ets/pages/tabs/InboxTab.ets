import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { EmptyState } from '../../common/components/EmptyState';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import type { GitHubNotification } from '../../models/User';

@Component
export struct InboxTab {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
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
    if (stype === 'Issue') return this.T().issueGreen;
    if (stype === 'PullRequest') return this.T().prBlue;
    if (stype === 'Discussion') return this.T().discussionPurple;
    return this.T().textSecondary;
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
            .fontColor(this.T().textPrimary)
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
                    ? this.T().textPrimary
                    : this.T().textSecondary)
                // 下拉指示器
                if (index === 0 || index === 3) {
                  Text('▼')
                    .fontSize(8)
                    .fontColor(this.selectedFilter === index
                      ? this.T().textPrimary
                      : this.T().textSecondary)
                    .margin({ left: 4 })
                }
              }
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.selectedFilter === index
                ? this.T().surfaceElevated
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
        .backgroundColor(this.T().surface)

        // 分割线
        Divider()
          .color(this.T().border)
          .width('100%')

        // === 主内容区 ===
        if (this.isInboxLoading) {
          Column() {
            LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
          }
          .width('100%').height('100%').backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
        } else if (this.getFilteredNotifications().length > 0) {
          this.buildNotificationList()
        } else {
          EmptyState({ icon: '✉', title: '暂无新消息', subtitle: '所有通知已查看，随心探索开源仓库' })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 24, bottom: 20 })
      .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    }
    .navDestination(this.inboxPageMap)
    .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
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
                .fontColor(this.T().textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.repository.full_name)
                .fontSize(12)
                .fontColor(this.T().textTertiary)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            if (item.unread) {
              Circle()
                .width(8)
                .height(8)
                .fill(this.T().accent)
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
    .backgroundColor(this.T().background)
  }
}
