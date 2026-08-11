import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';

@Component
export struct UserAgreementPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  private readonly policyText: string =
    '生效日期：2026年6月11日\n\n' +
    '一、服务说明\n' +
    '「云笈藏码」（以下简称本应用）是一款第三方非官方开源代码仓库浏览工具，通过 GitHub 官方开放接口提供服务，与 GitHub, Inc. 无任何官方关联、合作或背书关系。\n\n' +
    '二、账号与授权\n' +
    '1. 本应用通过 GitHub 官方 Device Flow 授权流程获取访问令牌，不存储您的 GitHub 账号密码。\n' +
    '2. 您有权随时在 GitHub 账号设置中撤销对本应用的授权，也可在本应用内退出登录，清除本地存储的授权令牌。\n\n' +
    '三、使用规范\n' +
    '1. 您在使用本应用时应遵守 GitHub 的服务条款以及您所在地的法律法规，不得利用本应用从事任何违法或侵权活动。\n' +
    '2. 本应用仅用于合法的代码浏览与学习用途，请勿用于任何违反 GitHub 政策或第三方权利的行为。\n' +
    '3. 您应自行对其使用本应用的行为负责，包括因您操作产生的任何后果。\n\n' +
    '四、服务变更与中断\n' +
    '本应用可能因 GitHub 接口调整、应用功能迭代、运营策略变化等原因变更或中断部分服务，我们将尽力提前公示。\n\n' +
    '五、知识产权\n' +
    '1. 本应用代码遵循 GNU GPL v3.0 开源协议，具体以应用仓库内 LICENSE 文件为准。\n' +
    '2. 您在使用本应用过程中浏览的仓库、代码等内容的知识产权归其各自权利人所有，请您尊重相关权利。\n\n' +
    '六、免责声明\n' +
    '1. 本应用为第三方工具，不对 GitHub 官方接口的稳定性、数据完整性负责。\n' +
    '2. 因不可抗力、网络故障、GitHub 服务异常或第三方原因导致的损失，本应用不承担责任。\n' +
    '3. 本应用不存储您的账号密码，您的账号安全由 GitHub 官方保护。\n\n' +
    '七、协议修订\n' +
    '本协议可能适时更新，更新后的版本将在应用内公示。您继续使用本应用即视为接受修订后的协议。\n\n' +
    '八、联系我们\n' +
    '如对本协议有任何疑问，请通过应用内隐私政策中的联系方式与我们联系。';

  build() {
    Scroll() {
      Column() {
        // 沉浸标题栏占位：初始避开标题栏，滚动时滑入磨砂下
        Blank(100)
        Text(this.policyText)
          .fontSize(14).fontColor(this.T().textSecondary).lineHeight(22)
          .width('100%').padding(20)
      }.width('100%')
    }
    .scrollBar(BarState.Off).width('100%').height('100%')
    .backgroundColor(this.T().background).padding({ top: 8 })
  }
}
