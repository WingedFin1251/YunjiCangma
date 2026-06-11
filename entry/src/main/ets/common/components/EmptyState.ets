import { Theme } from '../constants/ThemeConstants';

/**
 * 空状态组件（收件箱专用）
 * 规范：垂直居中排布（图标 + 主文案 + 辅助文案）
 * 图标 120dp×120dp，主文案 20sp Medium，辅助文案 14sp Regular
 *
 * 使用示例：
 *   EmptyState({
 *     icon: '📭',
 *     title: '都赶上了！',
 *     subtitle: '休息一下，写一些代码，做您最擅长的事'
 *   })
 */
@Component
export struct EmptyState {
  @Prop icon: string = '✉';
  @Prop title: string = '';
  @Prop subtitle: string = '';

  build() {
    Column({ space: 16 }) {
      Text(this.icon)
        .fontSize(60)
        .width(120)
        .height(120)
        .textAlign(TextAlign.Center)
        .lineHeight(120)

      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.textPrimary)
        .textAlign(TextAlign.Center)

      Text(this.subtitle)
        .fontSize(14)
        .fontColor(Theme.textSecondary)
        .textAlign(TextAlign.Center)
        .padding({ left: 40, right: 40 })
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }
}
