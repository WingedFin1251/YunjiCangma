import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../common/constants/ThemeConstants';

@Component
export struct PrivacyPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  private readonly policyText: string =
    '生效日期：2026年6月11日\n\n' +
    '一、前言与说明\n' +
    '欢迎使用「云笈藏码」（以下简称本应用），本应用是一款面向开发者的第三方非官方开源代码仓库浏览工具，仅通过 GitHub 官方开放接口为用户提供仓库浏览、代码查看、动态与消息管理等服务，与 GitHub, Inc. 无任何官方关联、合作或背书关系。\n\n' +
    '本隐私协议旨在向您说明本应用如何收集、使用、存储和保护您的信息。您在使用本应用前，请仔细阅读本协议，如您使用本应用，即表示您已同意本协议的全部条款。\n\n' +
    '二、我们如何收集与使用信息\n' +
    '1. 信息收集原则：本应用不会收集、存储或上传您的 GitHub 账号密码，所有账号认证均通过 GitHub 官方 OAuth 授权流程完成，我们仅会获取您主动授权的、GitHub 开放的必要信息，且仅用于为您提供核心服务，绝不超出授权范围收集任何信息。\n\n' +
    '2. 我们收集的信息类型：\n' +
    '- 公开个人信息：您通过 GitHub 授权后，从 GitHub 官方接口获取，用于展示您的个人主页、用户名、头像、公开仓库列表、星标项目、关注/粉丝数据。仅临时缓存于您的设备本地，不向任何服务器上传。\n' +
    '- 应用运行日志：仅在您主动开启反馈或出现异常崩溃时收集，用于排查应用故障、优化使用体验。仅存储于您的设备本地，您可随时删除。\n\n' +
    '3. 我们不会收集的信息：\n' +
    '- 您的 GitHub 账号密码、邮箱、手机号等敏感隐私信息；\n' +
    '- 您未授权的 GitHub 私有仓库数据、个人隐私设置；\n' +
    '- 您的地理位置、设备通讯录、相册、麦克风等与本应用功能无关的设备权限信息。\n\n' +
    '4. 信息使用规则：我们仅会将收集的信息用于为您提供本应用的核心功能，如展示仓库、查看代码、同步动态与消息；优化应用性能、修复异常崩溃、提升使用体验；响应您的反馈、处理您的咨询与问题。我们不会将您的信息用于商业广告、营销推广、用户画像等任何非服务必要的用途，也不会向任何第三方出售、转让您的信息。\n\n' +
    '三、信息共享与披露\n' +
    '1. 无主动共享：除法律强制情形外，我们不会向任何第三方共享、披露您的个人信息。\n' +
    '2. 法律强制情形：如根据法律法规、司法机关或行政主管部门的强制要求，需要披露您的信息，我们会在合法合规的范围内配合执行。\n' +
    '3. GitHub 官方接口：您的所有数据交互均通过 GitHub 官方接口完成，相关数据的处理需同时遵循 GitHub 的服务条款与隐私政策。\n\n' +
    '四、您的权利与信息控制\n' +
    '您对自身的信息享有完全的控制权，您可以随时：\n' +
    '1. 退出登录：在本应用的「我的」页面点击「退出登录」，即可清除本地存储的所有授权令牌与缓存数据。\n' +
    '2. 删除缓存数据：您可通过本应用的设置页，一键清除所有本地缓存的仓库、消息等数据。\n' +
    '3. 撤销授权：您可前往 GitHub 账号的「应用授权」页面，随时撤销本应用的访问权限。\n' +
    '4. 联系我们：如您对信息收集、使用有任何疑问或诉求，可通过下文联系方式与我们沟通。\n\n' +
    '五、未成年人保护\n' +
    '本应用主要面向开发者群体，如您为未成年人，请在监护人的陪同下阅读本协议，并在监护人同意后使用本应用。\n\n' +
    '六、协议的更新\n' +
    '我们可能会根据法律法规的变化或应用功能的迭代，适时更新本隐私协议。更新后的协议会在本应用内公示。\n\n' +
    '七、免责声明\n' +
    '1. 本应用为第三方工具，仅提供 GitHub 公开数据的浏览与展示服务，不对 GitHub 官方接口的稳定性、数据完整性负责。\n' +
    '2. 本应用不存储您的 GitHub 账号密码，也不会获取您的私有数据，您的账号安全由 GitHub 官方保护。\n' +
    '3. 本应用仅用于个人学习、非商业用途，您需自行遵守 GitHub 的服务条款。\n\n' +
    '八、联系方式\n' +
    '开发者邮箱：yunjicangma@163.com\n' +
    '反馈渠道：可在本应用「关于」页面提交反馈\n\n' +
    '本协议最终解释权归「云笈藏码」应用开发者所有。';

  build() {
    Scroll() {
      Text(this.policyText)
        .fontSize(14).fontColor(this.T().textSecondary).lineHeight(22)
        .width('100%').padding(20)
    }
    .scrollBar(BarState.Off).width('100%').height('100%')
    .backgroundColor(this.T().background).padding({ top: 8 })
  }
}
