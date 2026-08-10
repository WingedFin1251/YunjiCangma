import { DarkTheme, LightTheme, THEME_KEY, ThemeColors, langColor } from '../../common/constants/ThemeConstants';
import { MarkdownView } from '../../common/components/MarkdownView';
import { RepoRepository } from '../../services/RepoRepository';
import { AcrylicCard } from '../../common/components/AcrylicCard';
import { MicaLayer } from '../../common/components/MicaLayer';
import { WinButton } from '../../common/components/WinButton';
import { ExpandableSection } from '../../common/components/ExpandableSection';
import { PersonPicture } from '../../common/components/PersonPicture';

const B64CHARS: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
function b64decode(b64: string): string {
  let s: string = b64.replace(/[^A-Za-z0-9+/=]/g, '');
  let out: string = ''; let i: number = 0;
  while (i < s.length) {
    const a: number = B64CHARS.indexOf(s.charAt(i++));
    const b: number = B64CHARS.indexOf(s.charAt(i++));
    const c: number = B64CHARS.indexOf(s.charAt(i++));
    const d: number = B64CHARS.indexOf(s.charAt(i++));
    const n: number = (a << 18) | (b << 12) | ((c & 63) << 6) | (d & 63);
    out += String.fromCharCode((n >> 16) & 255);
    if (c !== 64) out += String.fromCharCode((n >> 8) & 255);
    if (d !== 64) out += String.fromCharCode(n & 255);
  }
  try { return decodeURIComponent(escape(out)); } catch (e) { return out; }
}
function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}
function stripMd(md: string): string {
  return md
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/\*\*(.+?)\*\*/g, '$1')
    .replace(/__(.+?)__/g, '$1')
    .replace(/\*(.+?)\*/g, '$1')
    .replace(/_(.+?)_/g, '$1')
    .replace(/`{1,3}[^`]*`{1,3}/g, '')
    .replace(/\[(.+?)\]\(.+?\)/g, '$1')
    .replace(/!\[.*?\]\(.+?\)/g, '')
    .replace(/^[-*+]\s+/gm, '• ')
    .replace(/^\d+\.\s+/gm, '')
    .replace(/^>\s+/gm, '')
    .replace(/---+/g, '')
    .replace(/^\|.*\|$/gm, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

@Component
export struct RepoDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State repo: Object | null = null;
  private readmeText: string = '';
  @State readmeLoaded: boolean = false;
  @State readmeLoading: boolean = false;
  @State latestRelease: Object | null = null;
  @State loading: boolean = true;
  @Prop @Watch('loadRepo') owner: string = '';
  @Prop @Watch('loadRepo') repoName: string = '';
  onOpenWebView?: (url: string) => void;
  onOpenDev?: (username: string) => void;
  onOpenIssues?: (owner: string, repo: string) => void;
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

  aboutToAppear(): void { if (this.owner && this.repoName) this.loadRepo(); }

  async loadRepo(): Promise<void> {
    if (!this.owner || !this.repoName) { this.loading = false; return; }
    this.loading = true;
    try { this.repo = await RepoRepository.getRepoDetail(this.owner, this.repoName); }
    catch (e) { this.repo = null; }
    finally { this.loading = false; }
    if (this.repo) { this.loadReadme(); this.loadRelease(); }
  }

  async loadRelease(): Promise<void> {
    try { this.latestRelease = await RepoRepository.getLatestRelease(this.owner, this.repoName); }
    catch (e) { this.latestRelease = null; }
  }

  async loadReadme(): Promise<void> {
    this.readmeLoading = true;
    try {
      const data: Object = await RepoRepository.getReadme(this.owner, this.repoName);
      const raw: string = (data as Record<string, Object>).content as string || '';
      setTimeout(() => {
        try { this.readmeText = b64decode(raw); } catch (e) { this.readmeText = raw; }
        this.readmeLoaded = true;
      }, 50);
    } catch (e) { this.readmeText = ''; this.readmeLoaded = true; }
    finally { this.readmeLoading = false; }
  }

  private rr(): Record<string, Object> { return (this.repo as Record<string, Object>); }
  private ownerRec(): Record<string, string> { return (this.rr().owner as Record<string, string>); }
  private ownerLogin(): string { return this.ownerRec() ? (this.ownerRec().login || this.owner) : this.owner; }
  private ownerAvatar(): string { return this.ownerRec() ? (this.ownerRec().avatar_url || '') : ''; }
  private num(k: string): number { return (this.rr()[k] as number) || 0; }
  private str(k: string): string { return (this.rr()[k] as string) || ''; }
  private topics(): string[] { return (this.rr().topics as string[]) || []; }
  private licenseName(): string {
    const lic: Record<string, string> = (this.rr().license as Record<string, string>);
    if (lic) { return lic.spdx_id || lic.name || ''; }
    return '';
  }
  private releaseTag(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).tag_name as string) || '') : ''; }
  private releaseName(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).name as string) || '') : ''; }
  private releaseDate(): string { return this.latestRelease ? ((((this.latestRelease as Record<string, Object>).published_at as string) || '').substring(0, 10)) : ''; }
  private releaseBody(): string { return this.latestRelease ? (((this.latestRelease as Record<string, Object>).body as string) || '') : ''; }
  private openWeb(url: string): void { if (this.onOpenWebView) this.onOpenWebView(url); }

  build() {
    Stack() {
      MicaLayer()
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress().width(40).height(40).color(this.T().accent)
          Text('正在加载仓库…').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else if (!this.repo) {
        Column({ space: 12 }) {
          Text('☁').fontSize(48).fontColor(this.T().textTertiary)
          Text('无法加载仓库信息').fontSize(16).fontColor(this.T().textSecondary)
          Text('请检查网络后重试').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else {
        Scroll() {
          Column({ space: 20 }) {
            // ===== 1. HEADER =====
            AcrylicCard() {
              Column({ space: 10 }) {
                Row({ space: 6 }) {
                  PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), size: 20 })
                  Text(this.ownerLogin()).fontSize(13).fontColor(this.T().textSecondary)
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.width('100%').alignItems(VerticalAlign.Center)
                Text(this.str('name') || this.repoName).fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).width('100%')
                if (this.str('description') !== '') {
                  Text(this.str('description')).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20).width('100%')
                }
                if (this.topics().length > 0) {
                  Row({ space: 6 }) {
                    ForEach(this.topics().slice(0, 8), (t: string, idx: number) => {
                      Text(t).fontSize(12).fontColor(this.T().accent)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
                        .borderRadius(8)
                    }, (t: string, idx: number) => idx.toString())
                  }.width('100%')
                }
                Row({ space: 10 }) {
                  this.statCard('星标', fmt(this.num('stargazers_count')))
                  this.statCard('复刻', fmt(this.num('forks_count')))
                  this.statCard('议题', fmt(this.num('open_issues_count')))
                }.width('100%').margin({ top: 6 })
              }.width('100%')
            }

            // ===== 2. 操作区（议题/PR/安全） =====
            Row({ space: 8 }) {
              WinButton({
                label: '议题', icon: '◉', tint: this.T().issueGreen,
                onAction: () => { if (this.onOpenIssues) this.onOpenIssues(this.owner, this.repoName); }
              }).layoutWeight(1)
              WinButton({
                label: 'PR', icon: '⇄', tint: this.T().prBlue,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/pulls'); }
              }).layoutWeight(1)
              WinButton({
                label: '安全', icon: '🛡', tint: this.T().discussionPurple,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/security'); }
              }).layoutWeight(1)
            }.width('100%')

            // ===== 3. 仓库信息 =====
            AcrylicCard() {
              Column() {
                this.sectionTitle('📋 仓库信息')
                this.infoRow('默认分支', this.str('default_branch'))
                if (this.str('language') !== '') {
                  Divider().color(this.T().border).width('100%')
                  Row() {
                    Text('语言').fontSize(14).fontColor(this.T().textSecondary).width(88)
                    Row({ space: 6 }) {
                      Circle().width(8).height(8).fill(langColor(this.str('language')))
                      Text(this.str('language')).fontSize(15).fontColor(this.T().textPrimary)
                    }
                  }.width('100%').padding({ top: 14, bottom: 14 })
                }
                if (this.licenseName() !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('许可证', this.licenseName())
                }
                if (this.str('created_at') !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('创建', this.str('created_at').substring(0, 10))
                }
                if (this.str('updated_at') !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('最近更新', this.str('updated_at').substring(0, 10))
                }
              }.width('100%')
            }

            // ===== 4. 最新 Release =====
            if (this.latestRelease) {
              ExpandableSection({ title: '最新版本', icon: '🚀', accentText: this.releaseTag(), initialExpanded: true }) {
                Column({ space: 8 }) {
                  if (this.releaseName() !== '') {
                    Text(this.releaseName()).fontSize(14).fontColor(this.T().textSecondary).width('100%')
                  }
                  if (this.releaseDate() !== '') {
                    Text(this.releaseDate()).fontSize(12).fontColor(this.T().textTertiary).width('100%')
                  }
                  if (this.releaseBody() !== '') {
                    MarkdownView({ content: this.releaseBody(), fontSize: 13, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView }).margin({ top: 8 })
                  }
                  Text('查看完整 Release ›').fontSize(14).fontColor(this.T().accent).margin({ top: 8 })
                    .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/releases/tag/' + this.releaseTag()); })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            }

            // ===== 5. 开发者 =====
            AcrylicCard() {
              Row({ space: 12 }) {
                PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), size: 40 })
                Column({ space: 2 }) {
                  Text(this.ownerLogin()).fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                  Text('开发者').fontSize(12).fontColor(this.T().textTertiary)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Row() {
                  Text('查看 ›').fontSize(13).fontColor(this.T().accent)
                }.padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF').borderRadius(8)
                  .onClick(() => { if (this.onOpenDev) this.onOpenDev(this.ownerLogin()); })
              }.width('100%').alignItems(VerticalAlign.Center)
            }

            // ===== 6. 报告问题 =====
            AcrylicCard() {
              Row() {
                Text('🐛 报告问题').fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
                Text('›').fontSize(20).fontColor(this.T().textSecondary)
              }.width('100%').alignItems(VerticalAlign.Center)
              .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/issues/new'); })
            }

            // ===== 7. README =====
            if (this.readmeLoading) {
              AcrylicCard() {
                Column({ space: 8 }) {
                  this.sectionTitle('📄 README')
                  LoadingProgress().width(20).height(20).color(this.T().accent).margin({ bottom: 8 })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            } else if (this.readmeLoaded && this.readmeText !== '') {
              ExpandableSection({ title: 'README', icon: '📄', initialExpanded: false }) {
                Column({ space: 8 }) {
                  MarkdownView({ content: this.readmeText, fontSize: 14, onOpenRepo: this.onOpenRepo, onOpenWebView: this.onOpenWebView })
                  Text('在浏览器中查看 ›').fontSize(14).fontColor(this.T().accent)
                    .onClick(() => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '#readme'); })
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            }
          }
          Blank().height(80)
        }.scrollBar(BarState.Off).width('100%').height('100%')
      }
    }.width('100%').height('100%')
  }

  @Builder
  statCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(label).fontSize(12).fontWeight(FontWeight.Medium).fontColor(this.T().textTertiary)
    }.layoutWeight(1).padding({ top: 12, bottom: 12 }).alignItems(HorizontalAlign.Center)
      .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill).borderRadius(8)
  }

  @Builder
  sectionTitle(title: string) {
    Row() {
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
      Blank()
    }.width('100%').padding({ top: 2, bottom: 12 })
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.T().textSecondary).width(88)
      Text(value).fontSize(15).fontColor(this.T().textPrimary).layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }.width('100%').padding({ top: 14, bottom: 14 })
  }
}
