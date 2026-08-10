import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI 亚克力卡片 — 半透明底 + backdropBlur + 细描边 + 圆角。
 * 用法：AcrylicCard() { ...内容... }，内容在父组件作用域内渲染。
 */
@Component
export struct AcrylicCard {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop cornerRadius: number = 8;
  @Prop paddingV: number = 18;
  @Prop paddingH: number = 16;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(this.cornerRadius)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.cardGlass : LightTheme.cardGlass)
    .backdropBlur(20)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
    .padding({ left: this.paddingH, right: this.paddingH, top: this.paddingV, bottom: this.paddingV })
  }
}
