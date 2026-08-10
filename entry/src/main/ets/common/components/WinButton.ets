import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI 风格按钮 — 图标 + 文字 + 细描边 + 按压反馈。
 * 在 Row 中并列时传 flex: 1 均分宽度（0 = 按内容自适应）。
 */
@Component
export struct WinButton {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop label: string = '';
  @Prop icon: string = '';
  @Prop tint: string = '#218BFE';
  @Prop flex: number = 0;
  onAction?: () => void;

  @Styles
  pressedStyle() {
    .scale({ x: 0.97, y: 0.97 })
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFillPressed : LightTheme.ctrlFillPressed)
  }

  build() {
    Row({ space: 6 }) {
      if (this.icon !== '') {
        Text(this.icon).fontSize(15).fontColor(this.tint)
      }
      Text(this.label).fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.tint)
    }
    .layoutWeight(this.flex).height(40).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
    .borderRadius(8)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
    .stateStyles({ pressed: this.pressedStyle })
    .onClick(() => { if (this.onAction) this.onAction(); })
  }
}
