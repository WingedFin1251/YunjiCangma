import { router } from '@kit.ArkUI';
import { DarkTheme } from '../../common/constants/ThemeConstants';
import { AuthService } from '../../services/AuthService';
import { GitHubAPIService } from '../../services/GitHubAPIService';
import type { User } from '../../models/User';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';

/** 个人资源列表项 */
class ResourceItem {
  label: string = '';
  count: number = 0;

  constructor(label: string, count: number) {
    this.label = label;
    this.count = count;
  }
}

/**
 * 个人资料 (Tab 4)
 */
@Component
export struct ProfileTab {
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State user: User | null = null;
  @State isLoading: boolean = false;
  private profileStack: NavPathStack = new NavPathStack();

  private resourceItems: ResourceItem[] = [
    new ResourceItem('仓库', 42),
    new ResourceItem('组织', 3),
    new ResourceItem('已加星标', 128),
  ];

  aboutToAppear(): void {
    this.loadUserData();
  }

  /** 登录状态变化时自动刷新用户数据 */
  onLoginChanged(): void {
    if (this.isLoggedIn) {
      this.loadUserData();
    } else {
      this.user = null;
    }
  }

  private async loadUserData(): Promise<void> {
    await AuthService.loadToken();
    if (AuthService.isLoggedIn()) {
      this.isLoading = true;
      try {
        this.user = await GitHubAPIService.getCurrentUser();
      } catch (err) {
        await AuthService.logout();
        this.user = null;
      } finally {
        this.isLoading = false;
      }
    }
  }

  private handleLogoutClick(): void {
    AuthService.logout();
    this.user = null;
  }

  @Builder
  profilePageMap(name: string, param: Object) {}

  build() {
    Navigation(this.profileStack) {
      Scroll() {
        Column() {
          Row() {
            Blank()
            Row({ space: 20 }) {
              this.topIcon('↗')
              this.topIcon('☰')
            }
          }
          .width('100%')
          .height(52)
          .padding({ left: 16, right: 16 })
          .alignItems(VerticalAlign.Center)

          if (this.isLoading) {
            LoadingProgress()
              .width(40)
              .height(40)
              .color(DarkTheme.accent)
              .margin({ top: 60 })
          } else if (this.isLoggedIn && this.user) {
            this.buildLoggedInProfile()
          } else {
            this.buildLoggedOutProfile()
          }

          Column({ space: 0 }) {
            ForEach(this.resourceItems, (item: ResourceItem, index: number) => {
              this.resourceRow(item)
            }, (item: ResourceItem) => item.label)
          }
          .margin({ top: 24 })

          Blank().height(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 32, bottom: 64 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .backgroundColor(DarkTheme.background)
    }
    .navDestination(this.profilePageMap)
    .backgroundColor(DarkTheme.background)
    .width('100%')
    .height('100%')
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  buildLoggedInProfile() {
    Column({ space: 8 }) {
      Image(this.user!.avatar_url)
        .width($r('app.float.size_avatar_lg'))
        .height($r('app.float.size_avatar_lg'))
        .borderRadius(24)
        .objectFit(ImageFit.Cover)

      Text(this.user!.name || this.user!.login)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)

      Row() {
        Text('💬')
          .fontSize(14)
          .margin({ right: 8 })
        Text('Set status...')
          .fontSize(14)
          .fontColor(DarkTheme.textSecondary)
      }
      .width('80%')
      .height($r('app.float.size_status_input'))
      .padding({ left: 12, right: 12 })
      .backgroundColor(DarkTheme.surfaceElevated)
      .borderRadius(8)
      .alignItems(VerticalAlign.Center)

      Row({ space: 8 }) {
        ForEach([1, 2, 3], (i: number, index: number) => {
          Text('🏅')
            .fontSize(16)
            .width(20)
            .height(20)
        }, (i: number) => `badge_${i}`)
      }
      .margin({ top: 8 })

      Row({ space: 24 }) {
        this.statColumn(this.user!.public_repos.toString(), 'Repos')
        this.statColumn(this.user!.followers.toString(), 'Followers')
        this.statColumn(this.user!.following.toString(), 'Following')
      }
      .margin({ top: 12 })

      Row() {
        Text('Log Out')
          .fontSize(14)
          .fontColor('#f85149')
      }
      .width('70%')
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(DarkTheme.surfaceElevated)
      .borderRadius(8)
      .margin({ top: 16 })
      .onClick(() => {
        this.handleLogoutClick();
      })
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 24, bottom: 16 })
    .width('100%')
  }

  @Builder
  buildLoggedOutProfile() {
    Column({ space: 12 }) {
      Text('👤')
        .fontSize(28)
        .width($r('app.float.size_avatar_lg'))
        .height($r('app.float.size_avatar_lg'))
        .backgroundColor(DarkTheme.surfaceElevated)
        .borderRadius(24)
        .textAlign(TextAlign.Center)
        .lineHeight($r('app.float.size_avatar_lg'))

      Text('Sign in to GitHub')
        .fontSize(16)
        .fontColor(DarkTheme.textSecondary)

      Row() {
        Text('Sign In with GitHub')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(DarkTheme.textPrimary)
      }
      .width('70%')
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(DarkTheme.accent)
      .borderRadius(8)
      .margin({ top: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/LoginPage' });
      })
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 40, bottom: 24 })
    .width('100%')
  }

  @Builder
  statColumn(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(DarkTheme.textPrimary)
      Text(label)
        .fontSize(11)
        .fontColor(DarkTheme.textTertiary)
    }
  }

  @Builder
  resourceRow(item: ResourceItem) {
    Row() {
      Text(item.label)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)
        .layoutWeight(1)
      Text(item.count.toString())
        .fontSize(12)
        .fontColor(DarkTheme.textTertiary)
        .margin({ right: 8 })
      Text('›')
        .fontSize(20)
        .fontColor(DarkTheme.textSecondary)
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {})
  }

  @Builder
  topIcon(icon: string) {
    Text(icon)
      .fontSize($r('app.float.icon_size_normal'))
      .width($r('app.float.size_nav_icon_hit'))
      .height($r('app.float.size_nav_icon_hit'))
      .textAlign(TextAlign.Center)
      .lineHeight($r('app.float.size_nav_icon_hit'))
  }
}
