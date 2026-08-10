import { webview } from '@kit.ArkWeb';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';
import { RepoRepository } from '../../services/RepoRepository';
import { UserRepository } from '../../services/UserRepository';
import { RepoDetailPage } from '../sub/RepoDetailPage';
import { DevProfilePage } from '../sub/DevProfilePage';
import { IssuesPage } from '../sub/IssuesPage';
import { IssueDetailPage } from '../sub/IssueDetailPage';
import type { Repository } from '../../models/User';

class ActivityItem {
  avatar: string = '';
  user: string = '';
  action: string = '';
  repo: string = '';
  time: string = '';
  constructor(a: string, u: string, act: string, r: string, t: string) {
    this.avatar = a;
    this.user = u;
    this.action = act;
    this.repo = r;
    this.time = t;
  }
}

@Component
export struct ExploreTab {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  private mica(): Array<[ResourceColor, number]> {
    const d: boolean = this.themeMode === 'dark';
    return [[d ? DarkTheme.micaStart : LightTheme.micaStart, 0], [d ? DarkTheme.micaEnd : LightTheme.micaEnd, 1]];
  }
  private exploreStack: NavPathStack = new NavPathStack();
  @State trendingRepos: Repository[] = [];
  @State activities: ActivityItem[] = [];
  @State isExploreLoading: boolean = true;
  @State webUrl: string = '';
  @State detailOwner: string = '';
  @State detailRepo: string = '';
  @State detailIssueNumber: number = 0;
  private webCtl: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    this.loadExploreData();
  }

  private async loadExploreData(): Promise<void> {
    try {
      const trending = await RepoRepository.getTrendingRepos();
      this.trendingRepos = trending.items.slice(0, 5);
    } catch (err) {
      this.trendingRepos = [];
    }
    try {
      const events = await UserRepository.getReceivedEvents('github');
      const items: ActivityItem[] = [];
      for (let i = 0; i < Math.min(events.length, 5); i++) {
        const evt = events[i] as Record<string, Object>;
        const repoObj = evt.repo as Record<string, string>;
        const actorObj = evt.actor as Record<string, string>;
        if (repoObj && actorObj) {
          const repoName: string = repoObj.name || '';
          const actorName: string = actorObj.display_login || actorObj.login || '';
          const actionType: string = (evt.type as string || '').replace('Event', '').toLowerCase();
          items.push(new ActivityItem(
            actorName.charAt(0),
            actorName,
            actionType,
            repoName,
            ''
          ));
        }
      }
      this.activities = items;
    } catch (err) {
      this.activities = [];
    } finally {
      this.isExploreLoading = false;
    }
  }

  @Builder
  explorePageMap(name: string, param: ESObject) {
    if (name === 'repoDetail') {
      NavDestination() { RepoDetailPage({ owner: this.detailOwner, repoName: this.detailRepo, onOpenWebView: (u: string) => { this.webUrl = u; this.exploreStack.pushPath({ name: 'repoWeb' }); }, onOpenDev: (uname: string) => { this.detailOwner = uname; this.exploreStack.pushPath({ name: 'devProfile' }); }, onOpenRepo: (o: string, r: string) => { this.detailOwner = o; this.detailRepo = r; this.exploreStack.pushPath({ name: 'repoDetail' }); }, onOpenIssues: (o: string, r: string) => { this.detailOwner = o; this.detailRepo = r; this.exploreStack.pushPath({ name: 'issues' }); } }) }
        .title('仓库详情').linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).padding({ top: 32 })
    } else if (name === 'issues') {
      NavDestination() { IssuesPage({ owner: this.detailOwner, repoName: this.detailRepo, onOpenWebView: (u: string) => { this.webUrl = u; this.exploreStack.pushPath({ name: 'repoWeb' }); }, onOpenIssue: (o: string, r: string, n: number) => { this.detailOwner = o; this.detailRepo = r; this.detailIssueNumber = n; this.exploreStack.pushPath({ name: 'issueDetail' }); } }) }
        .title('议题').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'issueDetail') {
      NavDestination() { IssueDetailPage({ owner: this.detailOwner, repoName: this.detailRepo, number: this.detailIssueNumber, onOpenWebView: (u: string) => { this.webUrl = u; this.exploreStack.pushPath({ name: 'repoWeb' }); }, onOpenRepo: (o: string, r: string) => { this.detailOwner = o; this.detailRepo = r; this.exploreStack.pushPath({ name: 'repoDetail' }); } }) }
        .title('议题详情').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'devProfile') {
      NavDestination() { DevProfilePage({ username: this.detailOwner, onOpenRepo: (o: string, r: string) => { this.detailOwner = o; this.detailRepo = r; this.exploreStack.pushPath({ name: 'repoDetail' }); }, onOpenWebView: (u: string) => { this.webUrl = u; this.exploreStack.pushPath({ name: 'repoWeb' }); } }) }
        .title('开发者').linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).padding({ top: 32 })
    } else if (name === 'repoWeb') {
      NavDestination() {
        Web({ src: this.webUrl, controller: this.webCtl })
          .width('100%').height('100%')
          .darkMode(this.themeMode === 'dark' ? WebDarkMode.On : WebDarkMode.Off)
          .backgroundColor(this.themeMode === 'dark' ? Color.Black : Color.White)
      }.title('GitHub').backgroundColor(this.T().background).padding({ top: 32 })
    }
  }

  build() {
    Navigation(this.exploreStack) {
      Column() {
        // 标题栏 — 固定不滚动
        Row() {
          Text($r('app.string.page_title_explore'))
            .fontSize(26).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).layoutWeight(1)
        }.width('100%').height(56).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)

        // 内容区 — 可滚动
        Scroll() {
          Column() {

          Row({ space: 12 }) {
            this.discoverItem('◈', '热门仓库')
            this.discoverItem('◈', '精选列表')
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .justifyContent(FlexAlign.SpaceBetween)

          Divider()
            .color(this.T().border)
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            Text('动态')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.T().textPrimary)
              .layoutWeight(1)
            Text('▼')
              .fontSize(18)
              .width(44)
              .height(44)
              .textAlign(TextAlign.Center)
              .lineHeight(44)
          }
          .width('100%')
          .height(44)
          .padding({ left: 16, right: 16 })

          Column({ space: 8 }) {
            ForEach(this.activities, (item: ActivityItem, index: number) => {
              this.activityRow(item)
            }, (item: ActivityItem) => `${item.user}_${item.action}_${item.repo}`)
          }

          Column({ space: 12 }) {
            ForEach(this.trendingRepos, (repo: Repository, index: number) => {
              Column() {
                RepoCard({
                  avatarChar: repo.owner.login.charAt(0),
                  owner: repo.owner.login,
                  repo: repo.name,
                  description: repo.description || '',
                  language: repo.language || '',
                  stars: repo.stargazers_count,
                  isStarred: false
                })
              }
              .width('100%')
              .onClick(() => {
                this.detailOwner = repo.owner.login;
                this.detailRepo = repo.name;
                this.webUrl = repo.html_url || '';
                this.exploreStack.pushPath({ name: 'repoDetail' });
              })
            }, (repo: Repository) => repo.id.toString())
          }
          .padding({ left: 16, right: 16 })
          .margin({ top: 12 })

          Blank().height(24)
        }.width('100%').alignItems(HorizontalAlign.Start)
      }.scrollBar(BarState.Off).width('100%')
        .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    }
    .width('100%').height('100%')
    .padding({ top: 32, bottom: 20 })
    .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    }
    .navDestination(this.explorePageMap)
    .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    .width('100%').height('100%')
    .mode(NavigationMode.Stack).hideTitleBar(true).hideToolBar(true)
  }

  @Builder
  activityRow(item: ActivityItem) {
    Row() {
      Text(item.avatar.toUpperCase())
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.T().textPrimary)
        .width(32)
        .height(32)
        .backgroundColor(this.T().surfaceElevated)
        .borderRadius(16)
        .textAlign(TextAlign.Center)
        .lineHeight(32)

      Column() {
        Row() {
          Text(item.user)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.T().textPrimary)
          Text(` ${item.action} `)
            .fontSize(16)
            .fontColor(this.T().textSecondary)
          Text(item.repo)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.T().accent)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        Text(item.time)
          .fontSize(12)
          .fontColor(this.T().textTertiary)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  discoverItem(icon: string, label: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .width(24)
        .height(24)
      Text(label)
        .fontSize(16)
        .fontColor(this.T().textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
    }
    .width('48%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.T().surface)
    .borderRadius(8)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {})
  }
}
