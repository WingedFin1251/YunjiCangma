import { Theme } from '../constants/ThemeConstants';

/**
 * 筛选标签栏组件
 * 规范：背景 #1E1E1E，高度 40dp，圆角 8dp
 * 支持左右滑动、点击切换
 *
 * 使用示例：
 *   FilterTabBar({
 *     tabs: ['收件箱', '重点', '未读', '仓库'],
 *     selectedIndex: 0
 *   })
 */
@Component
export struct FilterTabBar {
  @Prop tabs: string[] = [];
  @State @Watch('onSelectedChange') selectedIndex: number = 0;
  onChange?: (index: number) => void;

  private onSelectedChange(): void {
    if (this.onChange) {
      this.onChange(this.selectedIndex);
    }
  }

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.tabs, (tab: string, index: number) => {
          Text(tab)
            .fontSize(14)
            .fontColor(this.selectedIndex === index
              ? Theme.textPrimary
              : Theme.textSecondary)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedIndex === index
              ? Theme.surfaceElevated
              : Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              this.selectedIndex = index;
            })
        }, (tab: string, index: number) => `${tab}_${index}`)
      }
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(40)
    .backgroundColor(Theme.surface)
  }
}
