/**
 * 主题色彩系统 — 深色/浅色双模式
 * AppStorage Key: 'currentTheme' ('dark' | 'light')
 */

export const THEME_KEY: string = 'currentTheme';

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
class LightColors {
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

/** 当前主题（可变，由 MainPage 根据 AppStorage 切换） */
export class Theme {
  static background: string = DarkTheme.background;
  static surface: string = DarkTheme.surface;
  static surfaceElevated: string = DarkTheme.surfaceElevated;
  static border: string = DarkTheme.border;
  static textPrimary: string = DarkTheme.textPrimary;
  static textSecondary: string = DarkTheme.textSecondary;
  static textTertiary: string = DarkTheme.textTertiary;
  static accent: string = DarkTheme.accent;
  static issueGreen: string = DarkTheme.issueGreen;
  static prBlue: string = DarkTheme.prBlue;
  static discussionPurple: string = DarkTheme.discussionPurple;
  static orgOrange: string = DarkTheme.orgOrange;
  static starYellow: string = DarkTheme.starYellow;
  static clickFeedback: string = DarkTheme.clickFeedback;

  static setDark(): void {
    Theme.background = DarkTheme.background;
    Theme.surface = DarkTheme.surface;
    Theme.surfaceElevated = DarkTheme.surfaceElevated;
    Theme.border = DarkTheme.border;
    Theme.textPrimary = DarkTheme.textPrimary;
    Theme.textSecondary = DarkTheme.textSecondary;
    Theme.textTertiary = DarkTheme.textTertiary;
    Theme.accent = DarkTheme.accent;
    Theme.issueGreen = DarkTheme.issueGreen;
    Theme.prBlue = DarkTheme.prBlue;
    Theme.discussionPurple = DarkTheme.discussionPurple;
    Theme.orgOrange = DarkTheme.orgOrange;
    Theme.starYellow = DarkTheme.starYellow;
    Theme.clickFeedback = DarkTheme.clickFeedback;
  }

  static setLight(): void {
    Theme.background = LightColors.background;
    Theme.surface = LightColors.surface;
    Theme.surfaceElevated = LightColors.surfaceElevated;
    Theme.border = LightColors.border;
    Theme.textPrimary = LightColors.textPrimary;
    Theme.textSecondary = LightColors.textSecondary;
    Theme.textTertiary = LightColors.textTertiary;
    Theme.accent = LightColors.accent;
    Theme.issueGreen = LightColors.issueGreen;
    Theme.prBlue = LightColors.prBlue;
    Theme.discussionPurple = LightColors.discussionPurple;
    Theme.orgOrange = LightColors.orgOrange;
    Theme.starYellow = LightColors.starYellow;
    Theme.clickFeedback = LightColors.clickFeedback;
  }
}
