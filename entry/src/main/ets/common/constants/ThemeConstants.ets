/**
 * 主题色彩系统 — 深色/浅色双模式
 * AppStorage Key: 'currentTheme' ('dark' | 'light')
 */

export const THEME_KEY: string = 'currentTheme';

/** 主题色值接口 */
export interface ThemeColors {
  background: string; surface: string; surfaceElevated: string;
  border: string; textPrimary: string; textSecondary: string;
  textTertiary: string; accent: string; issueGreen: string;
  prBlue: string; discussionPurple: string; orgOrange: string;
  starYellow: string; clickFeedback: string;
}

/** 深色主题色值 */
export class DarkTheme {
  static readonly background: string = '#121212';
  static readonly surface: string = '#1E1E1E';
  static readonly surfaceElevated: string = '#2A2A2A';
  static readonly border: string = '#333333';
  static readonly textPrimary: string = '#FFFFFF';
  static readonly textSecondary: string = '#B3B3B3';
  static readonly textTertiary: string = '#757575';
  static readonly accent: string = '#218BFE';
  static readonly issueGreen: string = '#2EA44F';
  static readonly prBlue: string = '#218BFE';
  static readonly discussionPurple: string = '#8957E5';
  static readonly orgOrange: string = '#FF9529';
  static readonly starYellow: string = '#FFD33D';
  static readonly clickFeedback: string = '#383838';
}

/** 浅色主题色值 */
export class LightTheme {
  static readonly background: string = '#FFFFFF';
  static readonly surface: string = '#F6F8FA';
  static readonly surfaceElevated: string = '#EAEEF2';
  static readonly border: string = '#D0D7DE';
  static readonly textPrimary: string = '#1F2328';
  static readonly textSecondary: string = '#656D76';
  static readonly textTertiary: string = '#959DA5';
  static readonly accent: string = '#0969DA';
  static readonly issueGreen: string = '#1A7F37';
  static readonly prBlue: string = '#0969DA';
  static readonly discussionPurple: string = '#8250DF';
  static readonly orgOrange: string = '#CF6A00';
  static readonly starYellow: string = '#9A6700';
  static readonly clickFeedback: string = '#E0E4E8';
}

/** 主题色值获取：themeMode + 属性名 → 色值 */
function darkColors(): ThemeColors {
  return { background: '#121212', surface: '#1E1E1E', surfaceElevated: '#2A2A2A',
    border: '#333333', textPrimary: '#FFFFFF', textSecondary: '#B3B3B3',
    textTertiary: '#757575', accent: '#218BFE', issueGreen: '#2EA44F',
    prBlue: '#218BFE', discussionPurple: '#8957E5', orgOrange: '#FF9529',
    starYellow: '#FFD33D', clickFeedback: '#383838' };
}
function lightColors(): ThemeColors {
  return { background: '#FFFFFF', surface: '#F6F8FA', surfaceElevated: '#EAEEF2',
    border: '#D0D7DE', textPrimary: '#1F2328', textSecondary: '#656D76',
    textTertiary: '#959DA5', accent: '#0969DA', issueGreen: '#1A7F37',
    prBlue: '#0969DA', discussionPurple: '#8250DF', orgOrange: '#CF6A00',
    starYellow: '#9A6700', clickFeedback: '#E0E4E8' };
}
