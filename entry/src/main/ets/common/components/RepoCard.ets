import { Theme } from '../constants/ThemeConstants';

/**
 * 仓库卡片组件（全局复用）
 * 规范：背景 #1E1E1E，圆角 8dp，阴影，宽度撑满
 *
 * 使用示例：
 *   RepoCard({
 *     avatarChar: 'O',
 *     owner: 'octocat',
 *     repo: 'Hello-World',
 *     description: 'My first repo',
 *     language: 'TypeScript',
 *     stars: 1200,
 *     isStarred: false
 *   })
 */
@Component
export struct RepoCard {
  @Prop avatarChar: string = '?';
  @Prop owner: string = '';
  @Prop repo: string = '';
  @Prop description: string = '';
  @Prop language: string = '';
  @Prop stars: number = 0;
  @Prop isStarred: boolean = false;
  @State starred: boolean = false;

  aboutToAppear(): void {
    this.starred = this.isStarred;
  }

  build() {
    Column() {
      // 头部：头像 + 用户名/仓库名
      Row() {
        // 圆形头像
        Text(this.avatarChar.toUpperCase())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.textPrimary)
          .width(32)
          .height(32)
          .backgroundColor(Theme.surfaceElevated)
          .borderRadius(16)
          .textAlign(TextAlign.Center)
          .lineHeight(32)

        Column() {
          Text(`${this.owner} / `)
            .fontSize(16)
            .fontColor(Theme.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.repo)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 中部：仓库描述（最多 2 行省略）
      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor(Theme.textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 8 })
      }

      // 底部：技术标签 + 星标数量 + 星标按钮
      Row() {
        if (this.language) {
          Row() {
            Circle()
              .width(8)
              .height(8)
              .fill(Theme.accent)
            Text(this.language)
              .fontSize(12)
              .fontColor(Theme.textTertiary)
              .margin({ left: 4 })
          }
        }

        if (this.stars > 0) {
          Text('⭐')
            .fontSize(12)
            .margin({ left: 12 })
          Text(this.formatStars())
            .fontSize(12)
            .fontColor(Theme.textTertiary)
            .margin({ left: 2 })
        }

        Blank()

        // 星标按钮
        Button() {
          Text(this.starred ? '★' : '☆')
            .fontSize(16)
            .fontColor(this.starred ? Theme.starYellow : Theme.textSecondary)
        }
        .width(36)
        .height(36)
        .backgroundColor(Theme.surfaceElevated)
        .borderRadius(6)
        .onClick(() => {
          this.starred = !this.starred;
        })
      }
      .width('100%')
      .margin({ top: 10 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.surface)
    .borderRadius(8)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.1)',
      offsetY: 2
    })
  }

  private formatStars(): string {
    if (this.stars >= 1000) {
      return `${(this.stars / 1000).toFixed(1)}k`;
    }
    return this.stars.toString();
  }
}
