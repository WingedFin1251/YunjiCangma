/**
 * 底部 Tab 栏构建器
 * 提供可复用的 TabBar 样式工具
 *
 * 当前 MainPage 使用内联 @Builder，
 * 此文件预留用于未来抽取公共 Tab 栏组件。
 */

export interface TabBarConfig {
  index: number;
  label: ResourceStr;
  iconNormal: string;
  selectedColor: ResourceColor;
  unselectedColor: ResourceColor;
  isSelected: boolean;
}
