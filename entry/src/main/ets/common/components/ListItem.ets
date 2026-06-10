import { DarkTheme } from '../constants/ThemeConstants';

/**
 * 列表功能项组件
 * 规范：左图标(24dp) + 右文字(16sp)，条目高度52dp，整行可点击
 * 点击反馈色 #383838
 *
 * 使用示例：
 *   ListItem({
 *     icon: '🟢',
 *     label: '议题',
 *     showArrow: true
 *   })
 */
@Component
export struct ListItem {
  @Prop icon: string = '';
  @Prop label: string = '';
  @Prop iconColor: ResourceColor = DarkTheme.accent;
  @Prop showArrow: boolean = false;
  @Prop badgeCount: number = 0;
  onItemClick?: () => void;

  build() {
    Row() {
      // 彩色图标
      Text(this.icon)
        .fontSize(20)
        .width(24)
        .height(24)
        .textAlign(TextAlign.Center)

      // 功能名称
      Text(this.label)
        .fontSize(16)
        .fontColor(DarkTheme.textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)

      // 右侧数量标签
      if (this.badgeCount > 0) {
        Text(this.badgeCount.toString())
          .fontSize(12)
          .fontColor(DarkTheme.textTertiary)
          .margin({ right: 8 })
      }

      // 箭头
      if (this.showArrow) {
        Text('›')
          .fontSize(20)
          .fontColor(DarkTheme.textSecondary)
      }
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor(DarkTheme.background)
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick();
      }
    })
    .responseRegion({
      x: 0, y: 0,
      width: '100%',
      height: 52
    })
  }
}
