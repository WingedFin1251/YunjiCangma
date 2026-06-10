/**
 * GitHub 品牌色彩系统
 * 深色主题对应 GitHub.com 暗色模式
 * 浅色主题对应 GitHub.com 亮色模式
 */

export interface ThemeColors {
  background: string;
  surface: string;
  border: string;
  textPrimary: string;
  textSecondary: string;
  accent: string;
  tabBarBackground: string;
  tabSelected: string;
  tabUnselected: string;
  statusBar: string;
}

export const DarkThemeColors: ThemeColors = {
  background: '#0d1117',
  surface: '#161b22',
  border: '#30363d',
  textPrimary: '#e6edf3',
  textSecondary: '#8b949e',
  accent: '#58a6ff',
  tabBarBackground: '#161b22',
  tabSelected: '#ffffff',
  tabUnselected: '#8b949e',
  statusBar: '#0d1117'
};

export const LightThemeColors: ThemeColors = {
  background: '#ffffff',
  surface: '#f6f8fa',
  border: '#d0d7de',
  textPrimary: '#1f2328',
  textSecondary: '#656d76',
  accent: '#0969da',
  tabBarBackground: '#ffffff',
  tabSelected: '#1f2328',
  tabUnselected: '#656d76',
  statusBar: '#ffffff'
};

/** AppStorage 主题键名 */
export const THEME_KEY = 'currentTheme';

export function getThemeColors(theme: string): ThemeColors {
  return theme === 'dark' ? DarkThemeColors : LightThemeColors;
}
