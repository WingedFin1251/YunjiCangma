import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { AuthService } from '../../services/AuthService';

@Component
export struct SettingsPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @StorageLink('userFilterEnabled') userFilterEnabled: boolean = true;
  onNavigate?: (name: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        // 深色模式
        this.settingRow('🌙 深色模式', true)
        Divider().color(this.T().border).width('90%')

        // 手动屏蔽词开关
        Row() {
          Text('🛡️ 手动屏蔽词').fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.userFilterEnabled })
            .onChange((isOn: boolean) => { AppStorage.setOrCreate('userFilterEnabled', isOn); })
        }.width('100%').height(52).padding({ left: 20, right: 20 }).alignItems(VerticalAlign.Center)
        Divider().color(this.T().border).width('90%')

        // 使用教程
        this.settingRow('📖 使用教程', false, () => { if (this.onNavigate) this.onNavigate('tutorial'); })

        Divider().color(this.T().border).width('90%')

        // 隐私协议
        this.settingRow('🔒 隐私协议', false, () => { if (this.onNavigate) this.onNavigate('privacy'); })

        // 温馨提示
        this.infoCard('💡 温馨提示', '本应用为第三方非官方客户端，不存储您的账号密码，仅通过 GitHub 官方 OAuth 授权获取访问令牌。使用中如遇到问题，请检查网络连接或重新登录。')

        // 关于
        this.infoCard('ℹ️ 关于云笈藏码', '版本：v0.5.0\n\n云笈藏码 — 开源代码仓库浏览工具\n一款简洁流畅的第三方开源仓库客户端，支持账号授权登录、仓库浏览、代码查看、动态消息、项目收藏等功能。\n\n云笈纳万卷，一码藏乾坤\n\n数据来源：GitHub 官方开放接口\n本应用与 GitHub 无官方关联。')

        Blank().height(48)
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .width('100%').height('100%')
    .backgroundColor(this.T().background)
    .padding({ top: 8 })
  }

  @Builder
  settingRow(label: string, isToggle: boolean, cb?: () => void) {
    Row() {
      Text(label)
        .fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
      if (isToggle) {
        Toggle({ type: ToggleType.Switch, isOn: this.themeMode === 'dark' })
          .onChange((isOn: boolean) => {
            const newTheme: string = isOn ? 'dark' : 'light';
            AuthService.saveTheme(newTheme);
            AppStorage.setOrCreate(THEME_KEY, newTheme);
          })
      } else {
        Text('›').fontSize(20).fontColor(this.T().textSecondary)
      }
    }
    .width('100%').height(52)
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => { if (cb) cb(); })
  }

  @Builder
  infoCard(title: string, content: string) {
    Column({ space: 10 }) {
      Text(title).fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
        .width('100%')
      Text(content).fontSize(14).fontColor(this.T().textSecondary)
        .width('100%').lineHeight(22)
    }
    .width('100%')
    .padding(20)
    .margin({ top: 20 })
  }
}
