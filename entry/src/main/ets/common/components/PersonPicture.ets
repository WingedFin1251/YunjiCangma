import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI PersonPicture — 圆形头像 + 细描边；无图/加载失败时首字母兜底 + 名字散列色。
 */
@Component
export struct PersonPicture {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop url: string = '';
  @Prop name: string = '';
  @Prop size: number = 80;
  @State failed: boolean = false;

  private initials(): string {
    const nm: string = this.name || '';
    return nm.length > 0 ? nm.charAt(0).toUpperCase() : '?';
  }

  private avatarColor(): string {
    const palette: string[] = ['#218BFE', '#2EA44F', '#8957E5', '#FF9529', '#C42B1C', '#00B4AB'];
    const nm: string = this.name || '?';
    let h: number = 0;
    for (let i = 0; i < nm.length; i++) {
      h = (h * 31 + nm.charCodeAt(i)) % 997;
    }
    return palette[h % palette.length];
  }

  build() {
    Stack() {
      if (this.url !== '' && !this.failed) {
        Image(this.url)
          .width(this.size).height(this.size).borderRadius(this.size / 2).objectFit(ImageFit.Cover)
          .onError(() => { this.failed = true; })
      } else {
        Text(this.initials())
          .fontSize(this.size * 0.36).fontWeight(FontWeight.Medium).fontColor(Color.White)
          .width(this.size).height(this.size).borderRadius(this.size / 2).textAlign(TextAlign.Center)
          .backgroundColor(this.avatarColor())
      }
    }
    .width(this.size).height(this.size)
    .borderRadius(this.size / 2)
    .border({ width: 1.5, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
  }
}
