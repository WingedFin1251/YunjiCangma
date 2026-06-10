import { DarkTheme } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';

/** 我的工作列表项 */
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

/** 收藏仓库数据 */
class FavoriteRepo {
  avatarChar: string = '';
  owner: string = '';
  repo: string = '';
  description: string = '';
  language: string = '';
  stars: number = 0;
  isStarred: boolean = false;

  constructor(a: string, o: string, r: string, d: string, l: string, s: number, star: boolean) {
    this.avatarChar = a;
    this.owner = o;
    this.repo = r;
    this.description = d;
    this.language = l;
    this.stars = s;
    this.isStarred = star;
  }
}

/**
 * 主页 (Tab 1, 默认首页)
 */
@Component
export struct HomeTab {
  private homeStack: NavPathStack = new NavPathStack();

  private workItems: WorkItem[] = [
    new WorkItem('🟢', '议题', DarkTheme.issueGreen),
    new WorkItem('🔵', '拉取请求', DarkTheme.prBlue),
    new WorkItem('🟣', '讨论', DarkTheme.discussionPurple),
    new WorkItem('📁', '项目', DarkTheme.accent),
    new WorkItem('📦', '仓库', DarkTheme.textSecondary),
    new WorkItem('🟠', '组织', DarkTheme.orgOrange),
    new WorkItem('⭐', '已加星标', DarkTheme.starYellow),
  ];

  private favoriteRepos: FavoriteRepo[] = [
    new FavoriteRepo('F', 'flutter', 'flutter', 'Flutter makes it easy and fast to build beautiful apps', 'Dart', 168000, false),
    new FavoriteRepo('T', 'torvalds', 'linux', 'Linux kernel source tree', 'C', 182000, true),
  ];

  @Builder
  homePageMap(name: string, param: Object) {}

  build() {
    Navigation(this.homeStack) {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.page_title_home'))
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(DarkTheme.textPrimary)
              .layoutWeight(1)
            Row({ space: 20 }) {
              this.navIcon('🔍')
              this.navIcon('➕')
              this.navIcon('⋯')
            }
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          this.sectionHeader('我的工作')

          Column() {
            ForEach(this.workItems, (item: WorkItem, index: number) => {
              this.workListItem(item)
            }, (item: WorkItem) => item.label)
          }

          Divider()
            .color(DarkTheme.border)
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          this.sectionHeader('收藏夹')

          Column({ space: 12 }) {
            ForEach(this.favoriteRepos, (repo: FavoriteRepo, index: number) => {
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
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor(DarkTheme.background)
    }
    .navDestination(this.homePageMap)
    .backgroundColor(DarkTheme.background)
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
        .fontColor(DarkTheme.textPrimary)
        .layoutWeight(1)
      Text('⋯')
        .fontSize(18)
        .fontColor(DarkTheme.textSecondary)
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
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)
      Text(item.label)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)
      Text('›')
        .fontSize(20)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(DarkTheme.background)
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
