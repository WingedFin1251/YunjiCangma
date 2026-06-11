import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import type { Repository } from '../../models/User';

class WorkItem {
  icon: string = ''; label: string = ''; color: string = ''; route: string = '';
  constructor(icon: string, label: string, color: string, route: string) {
    this.icon = icon; this.label = label; this.color = color; this.route = route;
  }
}

class FavoriteRepo {
  avatarChar: string = '';
  owner: string = '';
  repo: string = '';
  description: string = '';
  language: string = '';
  stars: number = 0;
  isStarred: boolean = true;
  constructor(r: Repository) {
    this.avatarChar = r.owner.login.charAt(0);
    this.owner = r.owner.login;
    this.repo = r.name;
    this.description = r.description || '';
    this.language = r.language || '';
    this.stars = r.stargazers_count;
    this.isStarred = true;
  }
}

@Component
export struct HomeTab {
  private homeStack: NavPathStack = new NavPathStack();
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State starredRepos: FavoriteRepo[] = [];
  @State isStarredLoading: boolean = true;

  private workItems: WorkItem[] = [
    new WorkItem('●', '议题', '#2EA44F', 'issues'),
    new WorkItem('⇄', '拉取请求', '#218BFE', 'pulls'),
    new WorkItem('◈', '讨论', '#8957E5', 'discussions'),
    new WorkItem('⊞', '项目', '#218BFE', 'projects'),
    new WorkItem('⊡', '仓库', '#B3B3B3', 'repos'),
    new WorkItem('◎', '组织', '#FF9529', 'orgs'),
    new WorkItem('★', '已加星标', '#FFD33D', 'starred'),
  ];

  aboutToAppear(): void {
    this.loadStarredRepos();
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
      const repos: Repository[] = await GitHubAPIService.getStarredRepos();
      this.starredRepos = repos.map((r: Repository) => new FavoriteRepo(r));
    } catch (err) {
      this.starredRepos = [];
    } finally {
      this.isStarredLoading = false;
    }
  }

  @State subItems: Object[] = [];
  @State subLoading: boolean = true;

  private async loadWorkData(type: string): Promise<void> {
    this.subLoading = true; this.subItems = [];
    try {
      const u: string = '';
      if (type === 'issues') this.subItems = await GitHubAPIService.getIssues();
      else if (type === 'pulls') this.subItems = await GitHubAPIService.getPullRequests('');
      else if (type === 'repos') this.subItems = await GitHubAPIService.getMyRepos();
      else if (type === 'orgs') this.subItems = await GitHubAPIService.getOrgs();
      else if (type === 'starred') this.subItems = await GitHubAPIService.getStarredRepos();
    } catch (err) { this.subItems = []; }
    finally { this.subLoading = false; }
  }

  @Builder
  homePageMap(name: string, param: ESObject) {
    NavDestination() {
      Column() {
        if (!this.isLoggedIn) {
          Column({ space: 12 }) {
            Text('🔐').fontSize(40)
            Text('请先登录').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
            Text('登录 GitHub 账号后即可查看').fontSize(14).fontColor(this.T().textSecondary)
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .width('100%').height('100%').backgroundColor(this.T().background)
        } else if (this.subLoading) {
          LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
        } else if (this.subItems.length === 0) {
          Column({ space: 8 }) {
            Text('✉').fontSize(40)
            Text('暂无内容').fontSize(14).fontColor(this.T().textSecondary)
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            .width('100%').height('100%').backgroundColor(this.T().background)
        } else {
          Scroll() {
            Column() {
              ForEach(this.subItems, (item: Object, idx: number) => {
                Column() {
                  Text(((item as Record<string, Object>).title as string) || ((item as Record<string, Object>).login as string) || ((item as Record<string, Object>).full_name as string) || ((item as Record<string, Object>).name as string) || '')
                    .fontSize(16).fontColor(this.T().textPrimary).maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  if ((item as Record<string, Object>).repository_url || (item as Record<string, Object>).html_url) {
                    Text((((item as Record<string, Object>).repository_url as string) || ((item as Record<string, Object>).html_url as string) || '')
                      .replace('https://api.github.com/repos/', ''))
                      .fontSize(12).fontColor(this.T().textTertiary).maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onClick(() => {
                  const html: string = ((item as Record<string, Object>).html_url as string) || '';
                  if (html && param) {
                    (param as Record<string, string>).url = html;
                  }
                })
              }, (item: Object, idx: number) => idx.toString())
            }.width('100%')
          }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
        }
      }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
    }
    .title(this.getWorkTitle(name)).backgroundColor(this.T().background).padding({ top: 32 })
  }

  private getWorkTitle(name: string): string {
    if (name === 'issues') return '议题';
    if (name === 'pulls') return '拉取请求';
    if (name === 'discussions') return '讨论';
    if (name === 'projects') return '项目';
    if (name === 'repos') return '仓库';
    if (name === 'orgs') return '组织';
    if (name === 'starred') return '已加星标';
    return '';
  }

  build() {
    Navigation(this.homeStack) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.page_title_home'))
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.T().textPrimary)
              .layoutWeight(1)
            Row({ space: 20 }) {
              this.navIcon('⌕')
              this.navIcon('＋')
              this.navIcon('⋯')
            }
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          this.sectionHeader('我的项目')

          Column() {
            ForEach(this.workItems, (item: WorkItem, index: number) => {
              this.workListItem(item)
            }, (item: WorkItem) => item.label)
          }

          Divider()
            .color(this.T().border)
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          this.sectionHeader('我的星标')

          Column({ space: 12 }) {
            ForEach(this.starredRepos, (repo: FavoriteRepo, index: number) => {
              RepoCard({
                avatarChar: repo.avatarChar,
                owner: repo.owner,
                repo: repo.repo,
                description: repo.description,
                language: repo.language,
                stars: repo.stars,
                isStarred: repo.isStarred
              })
            }, (repo: FavoriteRepo) => repo.repo)
          }
          .padding({ left: 16, right: 16 })

          Blank().height(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 32, bottom: 64 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    }
    .navDestination(this.homePageMap)
    .backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  sectionHeader(title: string) {
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
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .margin({ top: 16, bottom: 4 })
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
    .onClick(() => { this.loadWorkData(item.route); this.homeStack.pushPath({ name: item.route }); })
  }

  @Builder
  navIcon(icon: string) {
    Text(icon)
      .fontSize(20)
      .width(44)
      .height(44)
      .textAlign(TextAlign.Center)
      .lineHeight(44)
  }
}
