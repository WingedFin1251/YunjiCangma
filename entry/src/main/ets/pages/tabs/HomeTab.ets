import { HdsNavDestination, HdsTabsController, HdsAnimationMode } from '@kit.UIDesignKit'
import { buildTitleBar } from '../../common/utils/NavTitleBar';
import { webview } from '@kit.ArkWeb';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';
import { RepoRepository } from '../../services/RepoRepository';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import { WorkPage } from '../sub/WorkPage';
import { SearchPage } from '../sub/SearchPage';
import { DevProfilePage } from '../sub/DevProfilePage';
import { IssuesPage } from '../sub/IssuesPage';
import { IssueDetailPage } from '../sub/IssueDetailPage';
import { StarredReposPage } from '../sub/StarredReposPage';
import { NewIssuePage } from '../sub/NewIssuePage';
import { RepoDetailPage } from '../sub/RepoDetailPage';
import type { Repository } from '../../models/User';

class WorkItem {
  icon: string = ''; label: string = ''; color: string = ''; route: string = '';
  constructor(icon: string, label: string, color: string, route: string) {
    this.icon = icon; this.label = label; this.color = color; this.route = route;
  }
}

/** 仓库跳转参数（避免共享状态被当前页绑定，造成双重导航） */
class RepoParam {
  owner: string = '';
  repo: string = '';
  constructor(o: string, r: string) { this.owner = o; this.repo = r; }
}

class FavoriteRepo {
  avatarChar: string = '';
  owner: string = '';
  repo: string = '';
  description: string = '';
  language: string = '';
  stars: number = 0;
  isStarred: boolean = true;
  htmlUrl: string = '';
  constructor(r: Repository) {
    this.avatarChar = r.owner.login.charAt(0);
    this.owner = r.owner.login;
    this.repo = r.name;
    this.description = r.description || '';
    this.language = r.language || '';
    this.stars = r.stargazers_count;
    this.isStarred = true;
    this.htmlUrl = r.html_url || '';
  }
}

@Component
export struct HomeTab {
  tabsController?: HdsTabsController;
  onNavChanged?: (hide: boolean) => void;
  private homeStack: NavPathStack = new NavPathStack();
  @State navDepth: number = 0;
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  private mica(): Array<[ResourceColor, number]> {
    const d: boolean = this.themeMode === 'dark';
    return [[d ? DarkTheme.micaStart : LightTheme.micaStart, 0], [d ? DarkTheme.micaEnd : LightTheme.micaEnd, 1]];
  }
  private paramOwner(param: ESObject): string {
    const p = param as RepoParam;
    return p && p.owner ? p.owner : this.repoOwner;
  }
  private paramRepo(param: ESObject): string {
    const p = param as RepoParam;
    return p && p.repo ? p.repo : this.repoName;
  }
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State starredRepos: FavoriteRepo[] = [];
  @State isStarredLoading: boolean = true;
  @State webUrl: string = '';
  @State repoOwner: string = '';
  @State repoName: string = '';
  @State detailIssueNumber: number = 0;
  private webCtl: webview.WebviewController = new webview.WebviewController();
  private searchScroller: Scroller = new Scroller();
  private starredScroller: Scroller = new Scroller();
  private newIssueScroller: Scroller = new Scroller();
  private issuesScroller: Scroller = new Scroller();
  private issueDetailScroller: Scroller = new Scroller();
  private repoDetailScroller: Scroller = new Scroller();
  private devProfileScroller: Scroller = new Scroller();
  private workScroller: Scroller = new Scroller();

  private workItems: WorkItem[] = [
    new WorkItem('●', '议题', '#2EA44F', 'issues'),
    new WorkItem('⇄', '拉取请求', '#218BFE', 'pulls'),
    new WorkItem('◈', '讨论', '#8957E5', 'discussions'),
    new WorkItem('⊞', '项目', '#218BFE', 'projects'),
    new WorkItem('⊡', '仓库', '#B3B3B3', 'repos'),
    new WorkItem('◎', '组织', '#FF9529', 'orgs'),
    new WorkItem('★', '已加星标', '#FFD33D', 'starredPage'),
  ];

  aboutToAppear(): void {
    this.loadStarredRepos();
    // 导航深度变化 → 隐藏/显示底栏（首页不随滚动隐藏）
    setInterval(() => {
      const depth: number = this.homeStack.getAllPathName().length;
      if (depth > 0 && this.navDepth === 0) {
        this.navDepth = depth;
        if (this.onNavChanged) this.onNavChanged(true);
      } else if (depth === 0 && this.navDepth > 0) {
        this.navDepth = 0;
        if (this.onNavChanged) this.onNavChanged(false);
      }
    }, 300);
  }

  onLoginChanged(): void {
    if (this.isLoggedIn) {
      this.loadStarredRepos();
    } else {
      this.starredRepos = [];
    }
  }

  private async loadStarredRepos(): Promise<void> {
    try {
      const repos: Repository[] = await RepoRepository.getStarredRepos();
      this.starredRepos = repos.map((r: Repository) => new FavoriteRepo(r));
    } catch (err) {
      this.starredRepos = [];
    } finally {
      this.isStarredLoading = false;
    }
  }

  /** 刷新首页（重载星标列表） */
  private refreshHome(): void {
    this.isStarredLoading = true;
    this.loadStarredRepos();
  }

  private getWorkTitle(name: string): string {
    if (name === 'issues') return '议题'; if (name === 'pulls') return '拉取请求';
    if (name === 'discussions') return '讨论'; if (name === 'projects') return '项目';
    if (name === 'repos') return '仓库'; if (name === 'orgs') return '组织';
    if (name === 'starred') return '已加星标'; return '';
  }

  @Builder
  homePageMap(name: string, param: ESObject) {
    if (name === 'search') {
      HdsNavDestination() { SearchPage({ scroller: this.searchScroller, onOpenRepo: (owner: string, repo: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(owner, repo) }); } }) }
        .titleBar(buildTitleBar('搜索')).backgroundColor(this.T().background).bindToScrollable([this.searchScroller])
    } else if (name === 'starredPage') {
      HdsNavDestination() { StarredReposPage({ scroller: this.starredScroller, onOpenRepo: (o: string, r: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(o, r) }); } }) }
        .titleBar(buildTitleBar('已加星标')).backgroundColor(this.T().background).bindToScrollable([this.starredScroller])
    } else if (name === 'newIssue') {
      HdsNavDestination() { NewIssuePage({ scroller: this.newIssueScroller, onCreated: () => { this.homeStack.pop(); } }) }
        .titleBar(buildTitleBar('新建议题')).backgroundColor(this.T().background).bindToScrollable([this.newIssueScroller])
    } else if (name === 'issues') {
      HdsNavDestination() { IssuesPage({ scroller: this.issuesScroller, owner: this.repoOwner, repoName: this.repoName, onOpenWebView: (u: string) => { this.webUrl = u; this.homeStack.pushPath({ name: 'repoWebView' }); }, onOpenIssue: (o: string, r: string, n: number) => { this.repoOwner = o; this.repoName = r; this.detailIssueNumber = n; this.homeStack.pushPath({ name: 'issueDetail' }); } }) }
        .titleBar(buildTitleBar('议题')).backgroundColor(this.T().background).bindToScrollable([this.issuesScroller])
    } else if (name === 'issueDetail') {
      HdsNavDestination() { IssueDetailPage({ scroller: this.issueDetailScroller, owner: this.repoOwner, repoName: this.repoName, issueNumber: this.detailIssueNumber, onOpenWebView: (u: string) => { this.webUrl = u; this.homeStack.pushPath({ name: 'repoWebView' }); }, onOpenRepo: (o: string, r: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(o, r) }); } }) }
        .titleBar(buildTitleBar('议题详情')).backgroundColor(this.T().background).bindToScrollable([this.issueDetailScroller])
    } else if (name === 'repoWeb') {
      HdsNavDestination() {
        RepoDetailPage({ scroller: this.repoDetailScroller, owner: this.paramOwner(param), repoName: this.paramRepo(param), onOpenWebView: (url: string) => { this.webUrl = url; this.homeStack.pushPath({ name: 'repoWebView' }); }, onOpenDev: (uname: string) => { this.repoOwner = uname; this.homeStack.pushPath({ name: 'devProfile' }); }, onOpenRepo: (o: string, r: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(o, r) }); }, onOpenIssues: (o: string, r: string) => { this.repoOwner = o; this.repoName = r; this.homeStack.pushPath({ name: 'issues' }); } })
      }.titleBar(buildTitleBar('仓库详情')).linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).bindToScrollable([this.repoDetailScroller])
    } else if (name === 'devProfile') {
      HdsNavDestination() { DevProfilePage({ scroller: this.devProfileScroller, username: this.repoOwner, onOpenRepo: (o: string, r: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(o, r) }); }, onOpenWebView: (u: string) => { this.webUrl = u; this.homeStack.pushPath({ name: 'repoWebView' }); } }) }
        .titleBar(buildTitleBar('开发者')).linearGradient({ colors: this.mica(), direction: GradientDirection.RightBottom }).bindToScrollable([this.devProfileScroller])
    } else if (name === 'repoWebView') {
      HdsNavDestination() {
        Column() {
          Web({ src: this.webUrl, controller: this.webCtl })
            .width('100%').layoutWeight(1)
            .darkMode(this.themeMode === 'dark' ? WebDarkMode.On : WebDarkMode.Off)
            .backgroundColor(this.themeMode === 'dark' ? Color.Black : Color.White)
        }
        .width('100%').height('100%').padding({ top: 100 })
      }.titleBar(buildTitleBar('GitHub')).backgroundColor(this.T().background)
    } else {
      HdsNavDestination() { WorkPage({ scroller: this.workScroller, _title: this.getWorkTitle(name), dataType: name, onOpenRepo: (o: string, r: string) => { this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(o, r) }); } }) }
        .titleBar(buildTitleBar(this.getWorkTitle(name))).backgroundColor(this.T().background).bindToScrollable([this.workScroller])
    }
  }

  build() {
    Navigation(this.homeStack) {
      Column() {
        Row() {
          Text($r('app.string.page_title_home')).fontSize(26).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).layoutWeight(1)
          Row({ space: 20 }) {
            this.headerIcon($r('app.media.ic_search_line_d'), $r('app.media.ic_search_line_l'), () => { this.homeStack.pushPath({ name: 'search' }); })
            this.headerIcon($r('app.media.ic_add_line_d'), $r('app.media.ic_add_line_l'), () => { this.homeStack.pushPath({ name: 'newIssue' }); })
            this.headerIcon($r('app.media.ic_refresh_line_d'), $r('app.media.ic_refresh_line_l'), () => { this.refreshHome(); })
          }
        }.width('100%').padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Bottom)

        Scroll() {
          Column() {
            this.sectionHeader('我的项目')
            Column() { ForEach(this.workItems, (item: WorkItem, index: number) => { this.workListItem(item) }, (item: WorkItem) => item.label) }
            Divider().color(this.T().border).width('100%').margin({ top: 12, bottom: 8 })
            this.sectionHeader('我的星标', () => { this.homeStack.pushPath({ name: 'starredPage' }); })
            Column({ space: 12 }) {
              ForEach(this.starredRepos, (repo: FavoriteRepo, index: number) => {
                Column() {
                  RepoCard({ avatarChar: repo.avatarChar, owner: repo.owner, repo: repo.repo, description: repo.description, language: repo.language, stars: repo.stars, isStarred: repo.isStarred })
                }.width('100%').onClick(() => { this.webUrl = repo.htmlUrl; this.homeStack.pushPath({ name: 'repoWeb', param: new RepoParam(repo.owner, repo.repo) }); })
              }, (repo: FavoriteRepo) => repo.repo)
            }.padding({ left: 16, right: 16 })
            Blank().height(76)
          }.width('100%').alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }).width('100%').backgroundColor(this.T().background)

      }
      .width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 32, bottom: 20 })
    }
    .navDestination(this.homePageMap).backgroundColor(this.T().background).width('100%').height('100%')
    .mode(NavigationMode.Stack).hideTitleBar(true).hideToolBar(true)
  }

  @Builder
  sectionHeader(title: string, onMore?: () => void) {
    Row() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.T().textPrimary)
        .layoutWeight(1)
      Text('⋯')
        .fontSize(18)
        .fontColor(this.T().textSecondary)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .onClick(() => { if (onMore) onMore(); })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  workListItem(item: WorkItem) {
    Row() {
      Text(item.icon)
        .fontSize(20)
        .fontColor(item.color)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
      Text(item.label)
        .fontSize(16)
        .fontColor(this.T().textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
      Text('›')
        .fontSize(20)
        .fontColor(this.T().textSecondary)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(this.T().background)
    .onClick(() => { this.homeStack.pushPath({ name: item.route }); })
  }

  @Builder
  headerIcon(lineDark: Resource, lineLight: Resource, onClick?: () => void) {
    Column() {
      Image(this.themeMode === 'dark' ? lineDark : lineLight)
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
    }
    .width(44)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => { if (onClick) onClick(); })
  }
}
