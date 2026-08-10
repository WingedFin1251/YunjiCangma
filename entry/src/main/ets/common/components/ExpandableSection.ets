import { DarkTheme, LightTheme, THEME_KEY } from '../constants/ThemeConstants';

/**
 * WinUI Expander 折叠区块 — 标题栏（旋转箭头 + 可选 accent 副文本）+ 展开内容淡入过渡。
 */
@Component
export struct ExpandableSection {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop title: string = '';
  @Prop icon: string = '';
  @Prop accentText: string = '';
  @Prop initialExpanded: boolean = false;
  @State expanded: boolean = false;
  @BuilderParam content: () => void;

  aboutToAppear(): void {
    this.expanded = this.initialExpanded;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        if (this.icon !== '') {
          Text(this.icon).fontSize(16)
        }
        Text(this.title).fontSize(17).fontWeight(FontWeight.Medium)
          .fontColor(this.themeMode === 'dark' ? DarkTheme.textPrimary : LightTheme.textPrimary)
          .layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.accentText !== '') {
          Text(this.accentText).fontSize(13).fontWeight(FontWeight.Medium)
            .fontColor(this.themeMode === 'dark' ? DarkTheme.accent : LightTheme.accent)
            .maxLines(1)
        }
        Text('▾').fontSize(14)
          .fontColor(this.themeMode === 'dark' ? DarkTheme.textTertiary : LightTheme.textTertiary)
          .rotate({ angle: this.expanded ? 180 : 0 })
          .animation({ duration: 200, curve: Curve.FastOutSlowIn })
      }
      .width('100%').height(48).padding({ left: 16, right: 16 }).alignItems(VerticalAlign.Center)
      .onClick(() => { this.expanded = !this.expanded; })

      if (this.expanded) {
        Column() {
          this.content()
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 18 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.FastOutSlowIn }))
      }
    }
    .width('100%')
    .borderRadius(8)
    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.cardGlass : LightTheme.cardGlass)
    .backdropBlur(20)
    .border({ width: 1, color: this.themeMode === 'dark' ? DarkTheme.cardStroke : LightTheme.cardStroke })
  }
}
