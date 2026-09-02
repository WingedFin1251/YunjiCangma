import { HdsTabsController, HdsAnimationMode } from '@kit.UIDesignKit';
import { webview } from '@kit.ArkWeb';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { EmptyState } from '../../common/components/EmptyState';
import { SearchRepository } from '../../services/SearchRepository';
import { NotificationDetailPage } from '../sub/NotificationDetailPage';
import type { GitHubNotification } from '../../models/User';

@Component
export struct InboxTab {
  tabsController?: HdsTabsController;
  onNavChanged?: (hide: boolean) => void;
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  private inboxStack: NavPathStack = new NavPathStack();
  @State navDepth: number = 0;
  @State scrollHidden: boolean = false;
  private mainScroller: Scroller = new Scroller();
  @State webUrl: string = '';
  private webCtl: webview.WebviewController = new webview.WebviewController();
  @State notifOwner: string = '';
  @State notifRepo: string = '';
  @State notifNumber: number = 0;
  @State notifTitle: string = '';
  @State notifRepoFull: string = '';
  @State notifType: string = '';
  @State notifReason: string = '';
  @State notifUpdated: string = '';
  @State notifUnread: boolean = false;
  @State selectedFilter: number = 0;
  @State notifications: GitHubNotification[] = [];
  @State isInboxLoading: boolean = true;
  private filterTabs: string[] = ['收件箱', '重点', '未读', '仓库'];

  aboutToAppear(): void {
    this.loadNotifications();
    setInterval(() => {
      const depth: number = this.inboxStack.getAllPathName().length;
      if (depth > 0 && this.navDepth === 0) {
        this.navDepth = depth;
        if (!this.scrollHidden && this.onNavChanged) { this.scrollHidden = true; this.onNavChanged(true); }
      } else if (depth === 0 && this.navDepth > 0) {
        this.navDepth = 0;
        if (this.scrollHidden) { this.scrollHidden = false; if (this.onNavChanged) this.onNavChanged(false); }
      }
    }, 300);
  }

  private async loadNotifications(): Promise<void> {
    try {
      this.notifications = await SearchRepository.getNotifications();
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
  inboxPageMap(name: string, param: ESObject) {
    if (name === 'notifDetail') {
      NavDestination() { NotificationDetailPage({
        owner: this.notifOwner, repoName: this.notifRepo, issueNumber: this.notifNumber,
        notifTitle: this.notifTitle, repoFullName: this.notifRepoFull, notifType: this.notifType,
        reason: this.notifReason, updatedAt: this.notifUpdated, isUnread: this.notifUnread,
        onOpenWebView: (u: string) => { this.webUrl = u; this.inboxStack.pushPath({ name: 'repoWebView' }); }
      }) }
        .title('消息详情').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'repoWebView') {
      NavDestination() {
        Web({ src: this.webUrl, controller: this.webCtl })
          .width('100%').height('100%')
          .darkMode(this.themeMode === 'dark' ? WebDarkMode.On : WebDarkMode.Off)
          .backgroundColor(this.themeMode === 'dark' ? Color.Black : Color.White)
      }.title('GitHub').backgroundColor(this.T().background).padding({ top: 32 })
    }
  }

  /** 打开通知：解析 subject.url → 原生消息详情（元信息 + 关联内容）；解析失败只显示元信息 + 浏览器按钮 */
  private openNotification(notif: GitHubNotification): void {
    const subj = notif.subject;
    const apiUrl: string = subj ? (subj.url || '') : '';
    this.notifOwner = '';
    this.notifRepo = '';
    this.notifNumber = 0;
    const m: RegExpMatchArray | null = apiUrl.match(/repos\/([^/]+)\/([^/]+)\/(?:issues|pulls|discussions)\/(\d+)/);
    if (m && m[1] && m[2] && m[3]) {
      this.notifOwner = m[1];
      this.notifRepo = m[2];
      this.notifNumber = parseInt(m[3]);
    }
    this.notifTitle = subj ? (subj.title || '') : '';
    this.notifRepoFull = notif.repository ? (notif.repository.full_name || '') : '';
    this.notifType = subj ? (subj.type || '') : '';
    this.notifReason = notif.reason || '';
    this.notifUpdated = notif.updated_at || '';
    this.notifUnread = notif.unread;
    this.inboxStack.pushPath({ name: 'notifDetail' });
  }

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
            .fontColor(this.T().textPrimary)
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
          .width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
        } else if (this.getFilteredNotifications().length > 0) {
          this.buildNotificationList()
        } else {
          Column() {
            EmptyState({ icon: '✉', title: '暂无新消息', subtitle: '所有通知已查看，随心探索开源仓库' })
          }
          .width('100%').layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .padding({ top: 32, bottom: 20 })
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
    List({ space: 0, scroller: this.mainScroller }) {
      ForEach(this.getFilteredNotifications(), (item: GitHubNotification, _index: number) => {
        ListItem() {
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
          .onClick(() => {
            this.openNotification(item);
          })
        }
      }, (item: GitHubNotification) => item.id)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.T().background)
    .padding({ bottom: 76 })
    .onScrollFrameBegin((offsetRemain: number) => {
      if (offsetRemain > 0 && !this.scrollHidden && this.navDepth === 0) {
        this.scrollHidden = true;
        if (this.onNavChanged) this.onNavChanged(true);
      } else if (offsetRemain < 0 && this.scrollHidden) {
        this.scrollHidden = false;
        if (this.onNavChanged) this.onNavChanged(false);
      }
      return { offsetRemain: offsetRemain };
    })
  }
}
