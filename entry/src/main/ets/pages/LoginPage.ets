import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { AuthService } from '../services/AuthService';
import { DarkTheme } from '../common/constants/ThemeConstants';

@Entry
@Component
struct LoginPage {
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
            .fontColor(DarkTheme.textPrimary)
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
          .fontColor(DarkTheme.textPrimary)

        Blank()

        Row().width(36).height(36)
      }
      .width('100%')
      .height(52)
      .padding({ left: 12, right: 12 })
      .backgroundColor(DarkTheme.background)

      if (this.isLoading) {
        Column({ space: 12 }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(DarkTheme.accent)
          Text($r('app.string.login_loading'))
            .fontSize($r('app.float.text_size_body'))
            .fontColor(DarkTheme.textSecondary)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(DarkTheme.background)
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
            .fontColor(DarkTheme.textPrimary)
            .backgroundColor(DarkTheme.accent)
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
        .backgroundColor(DarkTheme.surface)
        .alignItems(HorizontalAlign.Center)
      }

      Text($r('app.string.login_note'))
        .fontSize(11)
        .fontColor(DarkTheme.textSecondary)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ left: 20, right: 20, top: 12, bottom: 20 })
        .backgroundColor(DarkTheme.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DarkTheme.background)
  }
}
