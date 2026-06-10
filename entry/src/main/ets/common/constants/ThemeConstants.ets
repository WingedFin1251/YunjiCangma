/**
 * GitHub 移动端深色模式 UI 色彩系统
 * 规范版本：V1.0
 * 设计模式：全局深色模式（唯一主题）
 */
export class DarkTheme {
  /** 页面底层背景 #121212 (18,18,18) */
  static readonly background: string = '#121212';

  /** 卡片/标签栏/列表项 #1E1E1E (30,30,30) */
  static readonly surface: string = '#1E1E1E';

  /** 按钮常态/输入框背景 #2A2A2A (42,42,42) */
  static readonly surfaceElevated: string = '#2A2A2A';

  /** 分割线/边框 #333333 (51,51,51) */
  static readonly border: string = '#333333';

  /** 一级文本 #FFFFFF (255,255,255) */
  static readonly textPrimary: string = '#FFFFFF';

  /** 二级文本 #B3B3B3 (179,179,179) */
  static readonly textSecondary: string = '#B3B3B3';

  /** 三级文本 #757575 (117,117,117) */
  static readonly textTertiary: string = '#757575';

  /** 品牌主色 #218BFE (33,139,254) */
  static readonly accent: string = '#218BFE';

  /** 议题图标色 #2EA44F (46,164,79) */
  static readonly issueGreen: string = '#2EA44F';

  /** 拉取请求图标色 #218BFE (33,139,254) */
  static readonly prBlue: string = '#218BFE';

  /** 讨论图标色 #8957E5 (137,87,229) */
  static readonly discussionPurple: string = '#8957E5';

  /** 组织图标色 #FF9529 (255,149,41) */
  static readonly orgOrange: string = '#FF9529';

  /** 星标图标色 #FFD33D (255,211,61) */
  static readonly starYellow: string = '#FFD33D';

  /** 点击反馈底色 #383838 (56,56,56) */
  static readonly clickFeedback: string = '#383838';
}
