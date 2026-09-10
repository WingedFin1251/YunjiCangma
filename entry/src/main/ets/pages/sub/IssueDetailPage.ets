import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { IssueRepository } from '../../services/IssueRepository';
import { HttpClient } from '../../services/HttpClient';
import { MarkdownView } from '../../common/components/MarkdownView';
import type { GitHubIssue, GitHubLabel, IssueComment } from '../../models/IssueModels';

/**
 * 议题详情（原生界面）— 标题/状态/标签/正文 Markdown + 评论列表。
 */
@Component
export struct IssueDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State issue: GitHubIssue | null = null;
  @State comments: IssueComment[] = [];
  @State loading: boolean = true;
  @State commentsLoading: boolean = true;
  @Prop @Watch('load') owner: string = '';
  @Prop @Watch('load') repoName: string = '';
  @Prop issueNumber: number = 0;
  scroller?: Scroller;
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

  aboutToAppear(): void { if (this.owner && this.repoName && this.issueNumber > 0) this.load(); }

  @State errorMsg: string = '';

  async load(): Promise<void> {
    this.loading = true; this.errorMsg = '';
    try {
      this.issue = await IssueRepository.getIssue(this.owner, this.repoName, this.issueNumber);
    } catch (e) { this.issue = null; this.errorMsg = HttpClient.formatError(e); }
    finally { this.loading = false; }
    this.loadComments();
  }

  async loadComments(): Promise<void> {
    this.commentsLoading = true;
    try {
      this.comments = await IssueRepository.getIssueComments(this.owner, this.repoName, this.issueNumber);
    } catch (e) { this.comments = []; }
    finally { this.commentsLoading = false; }
  }

  private labels(): GitHubLabel[] { return this.issue && this.issue.labels ? this.issue.labels : []; }
  private issueState(): string { return this.issue ? (this.issue.state || '') : ''; }
  private stateText(): string { return this.issueState() === 'closed' ? 'Closed' : 'Open'; }
  private stateColor(): string {
    return this.issueState() === 'closed'
      ? (this.themeMode === 'dark' ? DarkTheme.discussionPurple : LightTheme.discussionPurple)
      : (this.themeMode === 'dark' ? DarkTheme.issueGreen : LightTheme.issueGreen);
  }
  private iNumber(): string { return this.issue ? (this.issue.number || 0).toString() : '0'; }
  private iTitle(): string { return this.issue ? (this.issue.title || '') : ''; }
  private iCreated(): string { return this.issue && this.issue.created_at ? this.issue.created_at : ''; }
  private iComments(): string { return this.issue ? (this.issue.comments || 0).toString() : '0'; }
  private iBody(): string { return this.issue && this.issue.body ? this.issue.body : ''; }
  private authorLogin(): string { return this.issue && this.issue.user ? (this.issue.user.login || '') : ''; }
  private shortDate(s: string): string { return (s || '').substring(0, 10); }
  private commentAuthor(c: IssueComment): string { return c.user ? (c.user.login || '') : ''; }
  private commentDate(c: IssueComment): string { return this.shortDate(c.created_at || ''); }
  private commentBody(c: IssueComment): string { return c.body ? c.body : ''; }

  build() {
    Scroll(this.scroller) {
      Column({ space: 16 }) {
        Blank().height(88)
        if (this.loading) {
          Column() {
            LoadingProgress().width(32).height(32).color(this.T().accent)
          }.width('100%').height(300).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        } else if (!this.issue) {
          Column({ space: 12 }) {
            Text('☁').fontSize(48).fontColor(this.T().textTertiary)
            Text(this.errorMsg || '无法加载议题').fontSize(14).fontColor(this.T().textSecondary)
            Text('点击重试').fontSize(13).fontColor(this.T().accent)
              .onClick(() => { this.load(); })
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(300)
        } else {
          // ===== 标题卡片 =====
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(this.stateText()).fontSize(12).fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .backgroundColor(this.stateColor())
                .borderRadius(8)
              Text('#' + this.iNumber()).fontSize(13).fontColor(this.T().textTertiary)
            }.width('100%')
            Text(this.iTitle()).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
              .width('100%').lineHeight(28)
            Row({ space: 8 }) {
              Text(this.authorLogin()).fontSize(13).fontColor(this.T().accent)
              Text('创建于 ' + this.shortDate(this.iCreated())).fontSize(12).fontColor(this.T().textTertiary)
              Text('💬 ' + this.iComments()).fontSize(12).fontColor(this.T().textTertiary)
            }.width('100%').alignItems(VerticalAlign.Center)
            if (this.labels().length > 0) {
              Row({ space: 6 }) {
                ForEach(this.labels().slice(0, 6), (l: GitHubLabel, _li: number) => {
                  Text(l.name || '')
                    .fontSize(11).fontColor(Color.White)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#' + (l.color || '218BFE'))
                    .borderRadius(4)
                }, (_l: GitHubLabel, li: number) => 'l' + li)
              }.width('100%')
            }
          }.width('100%').padding(16)
            .backgroundColor(this.T().surface).borderRadius(12)

          // ===== 正文 =====
          if (this.iBody() !== '') {
            Column() {
              MarkdownView({ content: this.iBody(), fontSize: 14, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView })
            }.width('100%').padding(16)
              .backgroundColor(this.T().surface).borderRadius(12)
          }

          // ===== 评论 =====
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
              ForEach(this.comments, (c: IssueComment, ci: number) => {
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
              }, (_c: IssueComment, ci: number) => 'c' + ci)
            }.width('100%')
          }.width('100%').padding(16)
            .backgroundColor(this.T().surface).borderRadius(12)
        }
        Blank().height(80)
      }.width('100%').constraintSize({ minHeight: '100%' })
    }.scrollBar(BarState.Off).width('100%').layoutWeight(1).backgroundColor(this.T().background)
  }
}
