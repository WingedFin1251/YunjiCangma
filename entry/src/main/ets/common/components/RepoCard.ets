import { DarkTheme, LightTheme, THEME_KEY, ThemeColors, langColor } from '../constants/ThemeConstants';
import { AuthService } from '../../services/AuthService';
import { RepoRepository } from '../../services/RepoRepository';

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
  @StorageLink(THEME_KEY) themeMode: string = 'dark'; private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
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

  /** 星标/取消星标（乐观更新，失败回滚 + 提示） */
  private toggleStar(): void {
    if (!this.owner || !this.repo) return;
    if (AuthService.getToken() === '') {
      this.getUIContext().getPromptAction().showToast({ message: '请先登录后再收藏' });
      return;
    }
    const target: boolean = !this.starred;
    this.starred = target;
    if (target) {
      RepoRepository.starRepo(this.owner, this.repo).catch(() => {
        this.starred = false;
        this.getUIContext().getPromptAction().showToast({ message: '收藏失败，请重试' });
      });
    } else {
      RepoRepository.unstarRepo(this.owner, this.repo).catch(() => {
        this.starred = true;
        this.getUIContext().getPromptAction().showToast({ message: '取消收藏失败，请重试' });
      });
    }
  }

  build() {
    Column() {
      // 头部：头像 + 用户名/仓库名
      Row() {
        // 圆形头像
        Text(this.avatarChar.toUpperCase())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.T().textPrimary)
          .width(32)
          .height(32)
          .backgroundColor(this.T().surfaceElevated)
          .borderRadius(16)
          .textAlign(TextAlign.Center)
          .lineHeight(32)

        Column() {
          Text(`${this.owner} / `)
            .fontSize(16)
            .fontColor(this.T().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.repo)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.T().textPrimary)
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
          .fontColor(this.T().textSecondary)
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
              .fill(langColor(this.language))
            Text(this.language)
              .fontSize(12)
              .fontColor(this.T().textTertiary)
              .margin({ left: 4 })
          }
        }

        if (this.stars > 0) {
          Text('⭐')
            .fontSize(12)
            .margin({ left: 12 })
          Text(this.formatStars())
            .fontSize(12)
            .fontColor(this.T().textTertiary)
            .margin({ left: 2 })
        }

        Blank()

        // 星标按钮
        Button() {
          Text(this.starred ? '★' : '☆')
            .fontSize(16)
            .fontColor(this.starred ? this.T().starYellow : this.T().textSecondary)
        }
        .width(36)
        .height(36)
        .backgroundColor(this.T().surfaceElevated)
        .borderRadius(6)
        .onClick(() => { this.toggleStar(); })
      }
      .width('100%')
      .margin({ top: 10 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.T().surface)
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
