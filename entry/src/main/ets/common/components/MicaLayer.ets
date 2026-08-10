import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI Mica 背景层 — 两个 accent 柔光斑（radialGradient）。
 * 放在页面根部 Stack 最底层；上层卡片的 backdropBlur 会模糊它形成亚克力质感。
 */
@Component
export struct MicaLayer {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';

  private blob(): string {
    return this.themeMode === 'dark' ? DarkTheme.micaBlob : LightTheme.micaBlob;
  }

  private blobGradient(): Array<[ResourceColor, number]> {
    return [[this.blob(), 0], ['rgba(0,0,0,0)', 1]];
  }

  build() {
    Stack() {
      Column()
        .width('100%').height('100%')
        .radialGradient({
          center: ['82%', '12%'],
          radius: '60%',
          colors: this.blobGradient()
        })
      Column()
        .width('100%').height('100%')
        .radialGradient({
          center: ['12%', '94%'],
          radius: '65%',
          colors: this.blobGradient()
        })
    }
    .width('100%').height('100%')
  }
}
