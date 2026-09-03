import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { IssueRepository } from '../../services/IssueRepository';
import { CheckRunRepository } from '../../services/CheckRunRepository';
import { HttpClient } from '../../services/HttpClient';
import { MarkdownView } from '../../common/components/MarkdownView';

/**
 * 消息详情 — 根据通知类型显示不同内容：
 * - Issue/PR/Discussion → 关联议题正文 + 评论
 * - CI (CheckRun/WorkflowRun) → workflow run 信息卡
 * - 其他 → 通知元信息 + 浏览器打开
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
  @Prop issueNumber: number = 0;
  @Prop notifTitle: string = '';
  @Prop repoFullName: string = '';
  @Prop notifType: string = '';
  @Prop reason: string = '';
  @Prop updatedAt: string = '';
  @Prop isUnread: boolean = false;
  @Prop subjectUrl: string = '';
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

  /** 是否为 CI 类型通知 */
  private isCI(): boolean {
    return this.notifType === 'CheckRun' || this.notifType === 'CheckSuite'
      || this.notifType === 'WorkflowRun' || this.notifType === 'WorkflowJob';
  }

  @State checkRun: Object | null = null;
  @State checkRunLoading: boolean = false;

  aboutToAppear(): void {
    if (this.isCI()) {
      this.loading = false;
      this.loadCheckRun();
    } else if (this.owner && this.repoName && this.issueNumber > 0) {
      this.load();
    } else {
      this.loading = false;
    }
  }

  async loadCheckRun(): Promise<void> {
    // 从 repoFullName 解析 owner/repo（CheckSuite 通知的 subject.url 为 null）
    let owner: string = this.owner;
    let repo: string = this.repoName;
    if (!owner || !repo) {
      const parts: string[] = this.repoFullName.split('/');
      if (parts.length === 2) { owner = parts[0]; repo = parts[1]; }
    }
    if (!owner || !repo) return;
    this.checkRunLoading = true;
    try {
      // 从通知标题中提取分支名（如 "...failed for main branch"）
      const branchMatch: RegExpMatchArray | null = this.notifTitle.match(/for (\S+) branch/);
      const branch: string = branchMatch ? branchMatch[1] : 'main';
      // 获取最近的 check suite
      const suites: Object = await CheckRunRepository.getCheckSuites(owner, repo, branch);
      const suitesArr: Object[] = (suites as Record<string, Object>).check_suites as Object[] || [];
      if (suitesArr.length > 0) {
        const suite: Record<string, Object> = suitesArr[0] as Record<string, Object>;
        const suiteId: number = suite.id as number || 0;
        // 获取 check runs 详情
        if (suiteId > 0) {
          const runs: Object = await CheckRunRepository.getCheckRuns(owner, repo, suiteId);
          const runsArr: Object[] = (runs as Record<string, Object>).check_runs as Object[] || [];
          if (runsArr.length > 0) {
            this.checkRun = runsArr[0];
          }
        }
        // 如果没有 check runs，用 suite 信息
        if (!this.checkRun) {
          this.checkRun = suite;
        }
      }
    } catch (e) { this.checkRun = null; }
    finally { this.checkRunLoading = false; }
  }

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
  private crStatusLabel(s: string): string {
    if (s === 'completed') return '已完成';
    if (s === 'in_progress') return '进行中';
    if (s === 'queued') return '排队中';
    return s || '未知';
  }
  private crConclusionLabel(s: string): string {
    if (s === 'success') return '成功';
    if (s === 'failure') return '失败';
    if (s === 'cancelled') return '已取消';
    if (s === 'action_required') return '需操作';
    if (s === 'timed_out') return '超时';
    return s || '—';
  }
  private crConclusionColor(s: string): string {
    if (s === 'success') return this.T().issueGreen;
    if (s === 'failure') return '#DA3633';
    return this.T().textSecondary;
  }
  private notifTypeText(): string {
    if (this.notifType === 'Issue') return '议题';
    if (this.notifType === 'PullRequest') return 'PR';
    if (this.notifType === 'Discussion') return '讨论';
    if (this.notifType === 'CheckRun') return 'CI';
    if (this.notifType === 'CheckSuite') return 'CI';
    if (this.notifType === 'WorkflowRun') return 'Actions';
    if (this.notifType === 'WorkflowJob') return 'Actions';
    return this.notifType || '通知';
  }
  private crRec(): Record<string, Object> { return (this.checkRun as Record<string, Object>); }
  private crStr(k: string): string { return this.checkRun ? (this.crRec()[k] as string || '') : ''; }
  @Builder crInfoItem(label: string, value: string) {
    Column({ space: 2 }) {
      Text(label).fontSize(11).fontColor(this.T().textTertiary)
      Text(value).fontSize(13).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
    }.layoutWeight(1)
  }
  private crDuration(): string {
    if (!this.checkRun) return '';
    const start: string = this.crStr('started_at');
    const end: string = this.crStr('completed_at');
    if (!start || !end) return '';
    const ms: number = new Date(end).getTime() - new Date(start).getTime();
    const sec: number = Math.floor(ms / 1000);
    if (sec < 60) return sec + ' 秒';
    return Math.floor(sec / 60) + ' 分 ' + (sec % 60) + ' 秒';
  }
  private commentAuthor(c: Object): string {
    const u: Record<string, string> = ((c as Record<string, Object>).user as Record<string, string>);
    return u ? (u.login || '') : '';
  }
  private commentDate(c: Object): string { return this.shortDate(((c as Record<string, Object>).created_at as string) || ''); }
  private commentBody(c: Object): string { return (((c as Record<string, Object>).body as string) || ''); }

  private openInWeb(): void {
    let target: string = 'https://github.com';
    if (this.isCI() && this.repoFullName) {
      target = 'https://github.com/' + this.repoFullName + '/actions';
    } else if (this.owner && this.repoName) {
      const base: string = 'https://github.com/' + this.owner + '/' + this.repoName;
      if (this.notifType === 'PullRequest') target = base + '/pull/' + this.issueNumber.toString();
      else if (this.notifType === 'Discussion') target = base + '/discussions/' + this.issueNumber.toString();
      else target = base + '/issues/' + this.issueNumber.toString();
    } else if (this.repoFullName) {
      target = 'https://github.com/' + this.repoFullName;
    }
    if (this.onOpenWebView) this.onOpenWebView(target);
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

        // ===== CI 通知：Actions 工作流信息 =====
        if (this.isCI()) {
          Column({ space: 12 }) {
            if (this.checkRunLoading) {
              Column() {
                LoadingProgress().width(24).height(24).color(this.T().accent)
              }.width('100%').height(80).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
            } else if (this.checkRun) {
              // check-run 详情卡
              Column({ space: 8 }) {
                Row({ space: 12 }) {
                  Text('📋').fontSize(20)
                  Text('GitHub Actions').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                }.width('100%')
                // 状态 + 结论
                Row({ space: 16 }) {
                  Column({ space: 2 }) {
                    Text('状态').fontSize(11).fontColor(this.T().textTertiary)
                    Text(this.crStatusLabel(this.crStr('status'))).fontSize(13).fontWeight(FontWeight.Medium)
                      .fontColor(this.crConclusionColor(this.crStr('conclusion')))
                  }.layoutWeight(1)
                  Column({ space: 2 }) {
                    Text('结论').fontSize(11).fontColor(this.T().textTertiary)
                    Text(this.crConclusionLabel(this.crStr('conclusion'))).fontSize(13).fontWeight(FontWeight.Medium)
                      .fontColor(this.crConclusionColor(this.crStr('conclusion')))
                  }.layoutWeight(1)
                }.width('100%')
                // 分支 + 提交
                if (this.crStr('branch') !== '' || this.crStr('head_sha') !== '') {
                  Row({ space: 16 }) {
                    if (this.crStr('branch') !== '') {
                      Row({ space: 4 }) {
                        Text('⑂').fontSize(12).fontColor(this.T().textTertiary)
                        Text(this.crStr('branch')).fontSize(12).fontColor(this.T().textSecondary)
                      }
                    }
                    if (this.crStr('head_sha') !== '') {
                      Row({ space: 4 }) {
                        Text('⊙').fontSize(12).fontColor(this.T().textTertiary)
                        Text(this.crStr('head_sha').substring(0, 7)).fontSize(12).fontColor(this.T().textSecondary)
                      }
                    }
                  }.width('100%')
                }
                // 耗时
                if (this.crDuration() !== '') {
                  Text('⏱ ' + this.crDuration()).fontSize(12).fontColor(this.T().textTertiary)
                }
              }.width('100%').padding(16)
                .backgroundColor(this.T().surface).borderRadius(12)
            } else {
              // 无法加载详情时显示基础信息
              Column({ space: 8 }) {
                Row() {
                  Text('📋').fontSize(20)
                  Text('GitHub Actions').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                }.width('100%')
                if (this.reason !== '') {
                  Text(this.reason).fontSize(13).fontColor(this.T().textSecondary).lineHeight(20)
                }
              }.width('100%').padding(16)
                .backgroundColor(this.T().surface).borderRadius(12)
            }

            // 在浏览器中查看
            Row() {
              Text('🔗 在浏览器中查看完整详情').fontSize(14).fontColor(this.T().accent)
            }.width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF').borderRadius(8)
              .onClick(() => { this.openInWeb(); })
          }

        // ===== Issue/PR/Discussion：关联内容 =====
        } else if (this.loading) {
          Column() {
            LoadingProgress().width(32).height(32).color(this.T().accent)
          }.width('100%').height(200).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        } else if (!this.issue) {
          Column({ space: 12 }) {
            Text('☁').fontSize(40).fontColor(this.T().textTertiary)
            Text(this.errorMsg || '无法加载关联内容').fontSize(13).fontColor(this.T().textSecondary)
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
                ForEach(this.labels().slice(0, 6), (l: Object, _li: number) => {
                  Text(((l as Record<string, Object>).name as string) || '')
                    .fontSize(11).fontColor(Color.White)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .backgroundColor('#' + (((l as Record<string, Object>).color as string) || '218BFE'))
                    .borderRadius(4)
                }, (_l: Object, li: number) => 'l' + li)
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
      }.width('100%').constraintSize({ minHeight: '100%' })
    }.scrollBar(BarState.Off).width('100%').layoutWeight(1).backgroundColor(this.T().background)
  }
}
