import { webview } from '@kit.ArkWeb';
import { AuthService } from '../services/AuthService';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../common/constants/ThemeConstants';
import { DevicePollResult, DevicePollStatus } from '../models/AuthModels';

@Entry
@Component
struct LoginPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  @State isLoading: boolean = false;
  @State isWaiting: boolean = false;
  @State errorMessage: string = '';
  @State userCode: string = '';
  @State webSrc: string = '';
  private webController: webview.WebviewController = new webview.WebviewController();
  private deviceCode: string = '';
  private pollInterval: number = 5;
  private pollTimer: number = -1;
  private isPolling: boolean = false;

  aboutToAppear(): void {
    this.startDeviceFlow();
  }

  aboutToDisappear(): void {
    this.clearTimer();
  }

  private clearTimer(): void {
    if (this.pollTimer !== -1) {
      clearInterval(this.pollTimer);
      this.pollTimer = -1;
    }
  }

  private async startDeviceFlow(): Promise<void> {
    this.clearTimer();
    this.isLoading = true;
    this.isWaiting = false;
    this.errorMessage = '';
    try {
      const info = await AuthService.startDeviceFlow();
      this.deviceCode = info.deviceCode;
      this.pollInterval = info.interval;
      this.userCode = info.userCode;
      this.webSrc = info.verificationUri;
      this.isLoading = false;
      this.isWaiting = true;
      this.startPolling();
    } catch (err) {
      this.isLoading = false;
      this.errorMessage = '获取验证码失败，请检查网络后重试';
    }
  }

  private startPolling(): void {
    this.clearTimer();
    this.pollTimer = setInterval(() => { this.pollOnce(); }, this.pollInterval * 1000);
  }

  private async pollOnce(): Promise<void> {
    if (this.isPolling || !this.isWaiting) { return; }
    this.isPolling = true;
    try {
      const result: DevicePollResult = await AuthService.pollDeviceToken(this.deviceCode);
      if (result.status === DevicePollStatus.SUCCESS) {
        this.clearTimer();
        this.isWaiting = false;
        this.getUIContext().getRouter().back();
      } else if (result.status === DevicePollStatus.SLOW_DOWN) {
        this.pollInterval += 5;
        this.startPolling();
      } else if (result.status === DevicePollStatus.PENDING) {
        // 继续轮询
      } else if (result.status === DevicePollStatus.DENIED) {
        this.clearTimer(); this.isWaiting = false;
        this.errorMessage = '你已在 GitHub 上拒绝授权';
      } else if (result.status === DevicePollStatus.EXPIRED) {
        this.clearTimer(); this.isWaiting = false;
        this.errorMessage = '验证码已过期，请重新开始';
      } else if (result.status === DevicePollStatus.BAD_CODE) {
        this.clearTimer(); this.isWaiting = false;
        this.errorMessage = '验证码无效，请重新开始';
      } else {
        this.clearTimer(); this.isWaiting = false;
        this.errorMessage = '连接失败，请重试';
      }
    } finally {
      this.isPolling = false;
    }
  }

  build() {
    Column() {
      Blank().height(32)
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
          this.getUIContext().getRouter().back();
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
          Text('正在获取验证码…')
            .fontSize($r('app.float.text_size_body'))
            .fontColor(this.T().textSecondary)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.T().background)
      } else if (this.isWaiting) {
        Column() {
          Column({ space: 6 }) {
            Text('在 GitHub 输入以下代码')
              .fontSize(14)
              .fontColor(this.T().textSecondary)
            Text(this.userCode)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.T().accent)
              .letterSpacing(4)
            Text('访问 github.com/login/device 输入上方代码，完成后返回即可')
              .fontSize(12)
              .fontColor(this.T().textTertiary)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 16, bottom: 12 })
          .alignItems(HorizontalAlign.Center)

          Web({ src: this.webSrc, controller: this.webController })
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .layoutWeight(1)
            .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.T().background)
      } else if (this.errorMessage) {
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
              this.startDeviceFlow();
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
