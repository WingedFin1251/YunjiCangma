import { Theme } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import type { Repository } from '../../models/User';

class WorkItem {
  icon: string = '';
  label: string = '';
  color: string = '';
  constructor(icon: string, label: string, color: string) {
    this.icon = icon;
    this.label = label;
    this.color = color;
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
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State starredRepos: FavoriteRepo[] = [];
  @State isStarredLoading: boolean = true;

  private workItems: WorkItem[] = [
    new WorkItem('●', '议题', Theme.issueGreen),
    new WorkItem('⇄', '拉取请求', Theme.prBlue),
    new WorkItem('◈', '讨论', Theme.discussionPurple),
    new WorkItem('⊞', '项目', Theme.accent),
    new WorkItem('⊡', '仓库', Theme.textSecondary),
    new WorkItem('◎', '组织', Theme.orgOrange),
    new WorkItem('★', '已加星标', Theme.starYellow),
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

  @Builder
  homePageMap(name: string, param: ESObject) {}

  build() {
    Navigation(this.homeStack) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.page_title_home'))
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.textPrimary)
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
            .color(Theme.border)
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
      .backgroundColor(Theme.background)
    }
    .navDestination(this.homePageMap)
    .backgroundColor(Theme.background)
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
        .fontColor(Theme.textPrimary)
        .layoutWeight(1)
      Text('⋯')
        .fontSize(18)
        .fontColor(Theme.textSecondary)
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
        .fontColor(Theme.textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
      Text('›')
        .fontSize(20)
        .fontColor(Theme.textSecondary)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Theme.background)
    .onClick(() => {})
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
