import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { HttpClient } from '../../services/HttpClient';
import { MarkdownView } from '../../common/components/MarkdownView';

/**
 * 消息详情（原生界面）— 通知元信息 + 关联议题内容（标题/状态/正文/评论）。
 */
@Component
export struct NotificationDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State issue: Object | null = null;
  @State comments: Object[] = [];
  @State loading: boolean = true;
  @State commentsLoading: boolean = true;
  @Prop @Watch('load') owner: string = '';
  @Prop @Watch('load') repoName: string = '';
  @Prop number: number = 0;
  @Prop notifTitle: string = '';
  @Prop repoFullName: string = '';
  @Prop notifType: string = '';
  @Prop reason: string = '';
  @Prop updatedAt: string = '';
  @Prop isUnread: boolean = false;
  onOpenWebView?: (url: string) => void;
  onOpenRepo?: (owner: string, repo: string) => void;
  private T(): ThemeColors {
    const d: boolean = this.themeMode === 'dark';
    return {
      background: d ? DarkTheme.background : LightTheme.background,
      surface: d ? DarkTheme.surface : LightTheme.surface,
      surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated,
      border: d ? DarkTheme.border : LightTheme.border,
      textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary,
      textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary,
      textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary,
      accent: d ? DarkTheme.accent : LightTheme.accent,
      issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen,
      prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue,
      discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple,
      orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange,
      starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow,
      clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback
    };
  }

  aboutToAppear(): void { if (this.owner && this.repoName && this.number > 0) this.load(); }

  async load(): Promise<void> {
    this.loading = true;
    try {
      this.issue = await HttpClient.get<Object>('/repos/' + this.owner + '/' + this.repoName + '/issues/' + this.number.toString());
    } catch (e) { this.issue = null; }
    finally { this.loading = false; }
    this.loadComments();
  }

  async loadComments(): Promise<void> {
    this.commentsLoading = true;
    try {
      this.comments = await HttpClient.get<Object[]>('/repos/' + this.owner + '/' + this.repoName + '/issues/' + this.number.toString() + '/comments?per_page=50');
    } catch (e) { this.comments = []; }
    finally { this.commentsLoading = false; }
  }

  private rec(): Record<string, Object> { return (this.issue as Record<string, Object>); }
  private num(k: string): number { return (this.rec()[k] as number) || 0; }
  private str(k: string): string { return (this.rec()[k] as string) || ''; }
  private labels(): Object[] { return (this.rec().labels as Object[]) || []; }
  private stateText(): string { return this.str('state') === 'closed' ? 'Closed' : 'Open'; }
  private stateColor(): string {
    return this.str('state') === 'closed'
      ? (this.themeMode === 'dark' ? DarkTheme.discussionPurple : LightTheme.discussionPurple)
      : (this.themeMode === 'dark' ? DarkTheme.issueGreen : LightTheme.issueGreen);
  }
  private authorLogin(): string {
    const u: Record<string, string> = (this.rec().user as Record<string, string>);
    return u ? (u.login || '') : '';
  }
  private shortDate(s: string): string { return (s || '').substring(0, 10); }
  private notifTypeText(): string {
    if (this.notifType === 'Issue') return '议题';
    if (this.notifType === 'PullRequest') return 'PR';
    if (this.notifType === 'Discussion') return '讨论';
    return this.notifType || '通知';
  }
  private commentAuthor(c: Object): string {
    const u: Record<string, string> = ((c as Record<string, Object>).user as Record<string, string>);
    return u ? (u.login || '') : '';
  }
  private commentDate(c: Object): string { return this.shortDate(((c as Record<string, Object>).created_at as string) || ''); }
  private commentBody(c: Object): string { return (((c as Record<string, Object>).body as string) || ''); }

  private openInWeb(): void {
    const base: string = 'https://github.com/' + this.owner + '/' + this.repoName;
    if (this.notifType === 'PullRequest') {
      if (this.onOpenWebView) this.onOpenWebView(base + '/pull/' + this.number.toString());
    } else if (this.notifType === 'Discussion') {
      if (this.onOpenWebView) this.onOpenWebView(base + '/discussions/' + this.number.toString());
    } else {
      if (this.onOpenWebView) this.onOpenWebView(base + '/issues/' + this.number.toString());
    }
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        // ===== 通知信息卡 =====
        Column({ space: 6 }) {
          Row() {
            Text(this.notifTypeText()).fontSize(11).fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .backgroundColor(this.T().accent)
              .borderRadius(4)
            if (this.isUnread) {
              Circle().width(8).height(8).fill(this.T().accent).margin({ left: 6 })
            }
            Blank()
            Text(this.shortDate(this.updatedAt)).fontSize(12).fontColor(this.T().textTertiary)
          }.width('100%').alignItems(VerticalAlign.Center)
          Text(this.repoFullName).fontSize(13).fontColor(this.T().accent)
          Text(this.notifTitle).fontSize(18).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
            .width('100%').lineHeight(26)
          if (this.reason !== '') {
            Text('缘由：' + this.reason).fontSize(12).fontColor(this.T().textTertiary)
          }
        }.width('100%').padding(16)
          .backgroundColor(this.T().surface).borderRadius(12)

        // ===== 关联内容 =====
        if (this.loading) {
          Column() {
            LoadingProgress().width(32).height(32).color(this.T().accent)
          }.width('100%').height(200).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        } else if (!this.issue) {
          Column({ space: 12 }) {
            Text('☁').fontSize(40).fontColor(this.T().textTertiary)
            Text('无法加载关联内容').fontSize(13).fontColor(this.T().textSecondary)
            Row() {
              Text('在浏览器打开 ›').fontSize(14).fontColor(this.T().accent)
            }.padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF').borderRadius(8)
              .onClick(() => { this.openInWeb(); })
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(220)
        } else {
          // 议题头部
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(this.stateText()).fontSize(12).fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(this.stateColor())
                .borderRadius(8)
              Text('#' + this.num('number').toString()).fontSize(13).fontColor(this.T().textTertiary)
            }.width('100%')
            Text(this.str('title')).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
              .width('100%').lineHeight(28)
            Row({ space: 8 }) {
              Text(this.authorLogin()).fontSize(13).fontColor(this.T().accent)
              Text('创建于 ' + this.shortDate(this.str('created_at'))).fontSize(12).fontColor(this.T().textTertiary)
              Text('💬 ' + this.num('comments').toString()).fontSize(12).fontColor(this.T().textTertiary)
            }.width('100%').alignItems(VerticalAlign.Center)
            if (this.labels().length > 0) {
              Row({ space: 6 }) {
                ForEach(this.labels().slice(0, 6), (l: Object, li: number) => {
                  Text(((l as Record<string, Object>).name as string) || '')
                    .fontSize(11).fontColor(Color.White)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#' + (((l as Record<string, Object>).color as string) || '218BFE'))
                    .borderRadius(4)
                }, (l: Object, li: number) => 'l' + li)
              }.width('100%')
            }
          }.width('100%').padding(16)
            .backgroundColor(this.T().surface).borderRadius(12)

          // 正文
          if (this.str('body') !== '') {
            Column() {
              MarkdownView({ content: this.str('body'), fontSize: 14, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView })
            }.width('100%').padding(16)
              .backgroundColor(this.T().surface).borderRadius(12)
          }

          // 评论
          Column() {
            Row() {
              Text('💬 评论 ' + this.comments.length.toString()).fontSize(15).fontWeight(FontWeight.Medium)
                .fontColor(this.T().textPrimary)
              Blank()
              if (this.commentsLoading) { LoadingProgress().width(16).height(16).color(this.T().accent) }
            }.width('100%').padding({ bottom: 8 })

            if (this.comments.length === 0 && !this.commentsLoading) {
              Text('暂无评论').fontSize(13).fontColor(this.T().textTertiary).width('100%').padding({ top: 8, bottom: 8 })
            }

            Column() {
              ForEach(this.comments, (c: Object, ci: number) => {
                Column({ space: 6 }) {
                  Row({ space: 8 }) {
                    Text(this.commentAuthor(c)).fontSize(13).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                    Text(this.commentDate(c)).fontSize(12).fontColor(this.T().textTertiary)
                  }.width('100%').alignItems(VerticalAlign.Center)
                  if (this.commentBody(c) !== '') {
                    MarkdownView({ content: this.commentBody(c), fontSize: 13, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView })
                  }
                }.width('100%').padding({ top: 10, bottom: 10 })
                if (ci < this.comments.length - 1) {
                  Divider().color(this.T().border).width('100%')
                }
              }, (c: Object, ci: number) => 'c' + ci)
            }.width('100%')
          }.width('100%').padding(16)
            .backgroundColor(this.T().surface).borderRadius(12)
        }
        Blank().height(80)
      }.width('100%')
    }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
  }
}
