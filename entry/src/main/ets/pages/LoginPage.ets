import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { AuthService } from '../services/AuthService';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../common/constants/ThemeConstants';

@Entry
@Component
struct LoginPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State oauthUrl: string = '';
  @State webSrc: string = '';
  private webController: webview.WebviewController = new webview.WebviewController();
  private isProcessing: boolean = false;

  aboutToAppear(): void {
    const url: string = AuthService.buildOAuthUrl();
    this.oauthUrl = url;
    this.webSrc = url;
  }

  private async handleOAuthCallback(url: string): Promise<void> {
    if (this.isProcessing) return;
    this.isProcessing = true;

    const code: string | null = AuthService.extractCodeFromUrl(url);
    if (!code) {
      this.errorMessage = 'Failed to extract authorization code';
      this.isProcessing = false;
      return;
    }
    this.isLoading = true;
    this.errorMessage = '';
    try {
      const token: string = await AuthService.exchangeCodeForToken(code);
      if (token) {
        router.back();
      } else {
        this.errorMessage = 'Token exchange failed';
      }
    } catch (err) {
      this.errorMessage = 'Authentication failed. Please try again.';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Button() {
          Text('✕')
            .fontSize(20)
            .fontColor(this.T().textPrimary)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        Blank()

        Text($r('app.string.login_title'))
          .fontSize($r('app.float.text_size_section'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.T().textPrimary)

        Blank()

        Row().width(36).height(36)
      }
      .width('100%')
      .height(52)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.T().background)

      if (this.isLoading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(this.T().accent)
          Text($r('app.string.login_loading'))
            .fontSize($r('app.float.text_size_body'))
            .fontColor(this.T().textSecondary)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.T().background)
      } else if (this.webSrc) {
        Web({ src: this.webSrc, controller: this.webController })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            if (AuthService.isOAuthCallback(url)) {
              this.handleOAuthCallback(url);
              return true;  // 拦截加载，WebView 不跳转
            }
            return false;
          })
          .onErrorReceive(() => {
            this.errorMessage = 'Failed to load login page';
          })
          .layoutWeight(1)
          .width('100%')
      }

      if (this.errorMessage) {
        Column({ space: 12 }) {
          Text(this.errorMessage)
            .fontSize($r('app.float.text_size_body'))
            .fontColor('#f85149')
            .textAlign(TextAlign.Center)

          Button($r('app.string.login_retry'))
            .fontSize(14)
            .fontColor(this.T().textPrimary)
            .backgroundColor(this.T().accent)
            .borderRadius(6)
            .height(40)
            .padding({ left: 24, right: 24 })
            .onClick(() => {
              this.errorMessage = '';
              const newUrl: string = AuthService.buildOAuthUrl();
              this.oauthUrl = newUrl;
              this.webSrc = newUrl;
            })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.T().surface)
        .alignItems(HorizontalAlign.Center)
      }

      Text($r('app.string.login_note'))
        .fontSize(11)
        .fontColor(this.T().textSecondary)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
        .backgroundColor(this.T().background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.T().background)
  }
}
