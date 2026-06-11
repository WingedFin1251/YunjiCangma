import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RepoCard } from '../../common/components/RepoCard';
import { AuthService } from '../../services/AuthService';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import type { User } from '../../models/User';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import { SettingsPage } from '../SettingsPage';
import { TutorialPage } from '../TutorialPage';
import { PrivacyPage } from '../PrivacyPage';

@Component
export struct ProfileTab {
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @State user: User | null = null;
  @State isLoading: boolean = false;
  @State listItems: Object[] = [];
  @State listLoading: boolean = true;
  @State webUrl: string = '';
  private profileStack: NavPathStack = new NavPathStack();
  private webCtl: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void { this.loadUserData(); }

  onLoginChanged(): void {
    if (this.isLoggedIn) { this.loadUserData(); } else { this.user = null; }
  }

  private async loadUserData(): Promise<void> {
    await AuthService.loadToken();
    if (AuthService.isLoggedIn()) {
      this.isLoading = true;
      try { this.user = await GitHubAPIService.getCurrentUser(); }
      catch (err) { await AuthService.logout(); this.user = null; }
      finally { this.isLoading = false; }
    }
  }

  private async loadList(type: string): Promise<void> {
    this.listLoading = true; this.listItems = [];
    try {
      const u: string = this.user?.login || '';
      if (type === 'repoList') { this.listItems = await GitHubAPIService.getMyRepos(); }
      else if (type === 'followers') { this.listItems = await GitHubAPIService.getUserFollowers(u); }
      else if (type === 'following') { this.listItems = await GitHubAPIService.getUserFollowing(u); }
    } catch (err) { this.listItems = []; }
    finally { this.listLoading = false; }
  }

  private langColor(lang: string): string {
    const m: Record<string, string> = {
      'JavaScript': '#F7DF1E', 'TypeScript': '#3178C6', 'Python': '#3572A5',
      'Java': '#B07219', 'C': '#555555', 'C++': '#F34B7D', 'C#': '#178600',
      'Go': '#00ADD8', 'Rust': '#DEA584', 'Swift': '#F05138', 'Kotlin': '#A97BFF',
      'Dart': '#00B4AB', 'Ruby': '#701516', 'PHP': '#4F5D95', 'HTML': '#E34C26',
      'CSS': '#563D7C', 'Vue': '#41B883', 'Shell': '#89E051'
    };
    return m[lang] || '#B3B3B3';
  }

  @Builder profilePageMap(name: string, param: ESObject) {
    if (name === 'repoList') {
      NavDestination() {
        Column() {
          if (this.listLoading) {
            LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
          } else if (this.listItems.length === 0) {
            Column({ space: 8 }) {
              Text('✉').fontSize(40)
              Text('暂无仓库，前往发现更多优质开源项目').fontSize(14).fontColor(this.T().textSecondary)
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
          } else {
            Scroll() {
              Column({ space: 12 }) {
                ForEach(this.listItems, (item: Object, idx: number) => {
                  Column() {
                    RepoCard({
                      avatarChar: (((item as Record<string, Object>).owner as Record<string, string>).login || '?').charAt(0),
                      owner: ((item as Record<string, Object>).owner as Record<string, string>).login || '',
                      repo: ((item as Record<string, Object>).name as string) || '',
                      description: ((item as Record<string, Object>).description as string) || '',
                      language: ((item as Record<string, Object>).language as string) || '',
                      stars: (item as Record<string, Object>).stargazers_count as number || 0,
                      isStarred: true
                    })
                  }
                  .width('100%')
                  .onClick(() => {
                    const url: string = ((item as Record<string, Object>).html_url as string) || '';
                    if (url) { this.webUrl = url; this.profileStack.pushPath({ name: 'repoWeb' }); }
                  })
                }, (item: Object, idx: number) => idx.toString())
              }.width('100%').padding({ left: 16, right: 16 })
            }.scrollBar(BarState.Off).width('100%').height('100%')
          }
        }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
      }.title('我的仓库').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'repoWeb') {
      NavDestination() {
        Web({ src: this.webUrl, controller: this.webCtl })
          .width('100%').height('100%')
          .darkMode(this.themeMode === 'dark' ? WebDarkMode.On : WebDarkMode.Off)
          .backgroundColor(this.themeMode === 'dark' ? Color.Black : Color.White)
      }.title('仓库详情').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'followers' || name === 'following') {
      NavDestination() {
        Column() {
          if (this.listLoading) {
            LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
          } else if (this.listItems.length === 0) {
            Column({ space: 8 }) {
              Text('✉').fontSize(40)
              Text('暂无内容').fontSize(14).fontColor(this.T().textSecondary)
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
          } else {
            Scroll() {
              Column() {
                ForEach(this.listItems, (item: Object, idx: number) => {
                  Row() {
                    Text(((item as Record<string, Object>).login as string) || '')
                      .fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
                    Text('›').fontSize(18).fontColor(this.T().textSecondary)
                  }.width('100%').height(48).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
                }, (item: Object, idx: number) => idx.toString())
              }.width('100%')
            }.scrollBar(BarState.Off).width('100%').height('100%')
          }
        }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
      }
      .title(name === 'followers' ? '粉丝' : '关注中').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'settings') {
      NavDestination() { SettingsPage({ onNavigate: (n: string) => { this.profileStack.pushPath({ name: n }); } }) }
        .title('设置').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'tutorial') {
      NavDestination() { TutorialPage() }
        .title('使用教程').backgroundColor(this.T().background).padding({ top: 32 })
    } else if (name === 'privacy') {
      NavDestination() { PrivacyPage() }
        .title('隐私协议').backgroundColor(this.T().background).padding({ top: 32 })
    }
  }

  build() {
    Navigation(this.profileStack) {
      Scroll() {
        Column() {
          Row() {
            Blank()
            Row({ space: 20 }) {
              this.navIcon('↗')
              Text('☰').fontSize($r('app.float.icon_size_normal'))
                .width($r('app.float.size_nav_icon_hit')).height($r('app.float.size_nav_icon_hit'))
                .textAlign(TextAlign.Center).lineHeight($r('app.float.size_nav_icon_hit'))
                .onClick(() => { this.profileStack.pushPath({ name: 'settings' }); })
            }
          }.width('100%').height(52).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)

          if (this.isLoading) {
            LoadingProgress().width(40).height(40).color(this.T().accent).margin({ top: 60 })
          } else if (this.isLoggedIn && this.user) {
            Column({ space: 8 }) {
              Image(this.user!.avatar_url)
                .width($r('app.float.size_avatar_lg')).height($r('app.float.size_avatar_lg'))
                .borderRadius(24).objectFit(ImageFit.Cover)
              Text(this.user!.name || this.user!.login)
                .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
              Row() {
                Text('💬').fontSize(14).margin({ right: 8 })
                Text('Set status...').fontSize(14).fontColor(this.T().textSecondary)
              }.width('80%').height($r('app.float.size_status_input'))
                .padding({ left: 12, right: 12 }).backgroundColor(this.T().surfaceElevated)
                .borderRadius(8).alignItems(VerticalAlign.Center)
              Row({ space: 24 }) {
                this.statCol(this.user!.public_repos.toString(), 'Repos')
                this.statCol(this.user!.followers.toString(), 'Followers')
                this.statCol(this.user!.following.toString(), 'Following')
              }.margin({ top: 12 })
              Row() {
                Text('Log Out').fontSize(14).fontColor('#f85149')
              }.width('70%').height(42).justifyContent(FlexAlign.Center)
                .backgroundColor(this.T().surfaceElevated).borderRadius(8).margin({ top: 16 })
                .onClick(() => { AuthService.logout(); this.user = null; })
            }.alignItems(HorizontalAlign.Center).padding({ top: 24, bottom: 16 }).width('100%')
          } else {
            Column({ space: 12 }) {
              Text('👤').fontSize(28)
                .width($r('app.float.size_avatar_lg')).height($r('app.float.size_avatar_lg'))
                .backgroundColor(this.T().surfaceElevated).borderRadius(24)
                .textAlign(TextAlign.Center).lineHeight($r('app.float.size_avatar_lg'))
              Text('Sign in to GitHub').fontSize(16).fontColor(this.T().textSecondary)
              Row() {
                Text('Sign In with GitHub').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
              }.width('70%').height(44).justifyContent(FlexAlign.Center)
                .backgroundColor(this.T().accent).borderRadius(8).margin({ top: 8 })
                .onClick(() => { router.pushUrl({ url: 'pages/LoginPage' }); })
            }.alignItems(HorizontalAlign.Center).padding({ top: 40, bottom: 24 }).width('100%')
          }

          if (this.isLoggedIn && this.user) {
            Column({ space: 0 }) {
              this.resRow('仓库', this.user.public_repos, 'repoList')
              this.resRow('关注中', this.user.following, 'following')
              this.resRow('粉丝', this.user.followers, 'followers')
            }.margin({ top: 24 })
          }

          Blank().height(24)
        }.width('100%').alignItems(HorizontalAlign.Center).padding({ top: 32, bottom: 64 })
      }.scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off)
        .width('100%').height('100%').backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    }
    .navDestination(this.profilePageMap).backgroundColor(this.themeMode === 'dark' ? this.T().background : this.T().background)
    .width('100%').height('100%').mode(NavigationMode.Stack).hideTitleBar(true).hideToolBar(true)
  }

  @Builder statCol(v: string, l: string) {
    Column() {
      Text(v).fontSize(18).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(l).fontSize(11).fontColor(this.T().textTertiary)
    }
  }

  @Builder resRow(label: string, count: number, route: string) {
    Row() {
      Text(label).fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
      Text(count.toString()).fontSize(12).fontColor(this.T().textTertiary).margin({ right: 8 })
      Text('›').fontSize(20).fontColor(this.T().textSecondary)
    }.width('100%').height(52).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
    .onClick(() => { this.loadList(route); this.profileStack.pushPath({ name: route }); })
  }

  @Builder navIcon(icon: string) {
    Text(icon).fontSize($r('app.float.icon_size_normal'))
      .width($r('app.float.size_nav_icon_hit')).height($r('app.float.size_nav_icon_hit'))
      .textAlign(TextAlign.Center).lineHeight($r('app.float.size_nav_icon_hit'))
  }
}
