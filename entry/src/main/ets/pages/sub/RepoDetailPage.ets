import { util } from '@kit.ArkTS';
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors, langColor } from '../../common/constants/ThemeConstants';
import { MarkdownView } from '../../common/components/MarkdownView';
import { RepoRepository } from '../../services/RepoRepository';
import { HttpClient } from '../../services/HttpClient';
import { AcrylicCard } from '../../common/components/AcrylicCard';
import { MicaLayer } from '../../common/components/MicaLayer';
import { WinButton } from '../../common/components/WinButton';
import { ExpandableSection } from '../../common/components/ExpandableSection';
import { PersonPicture } from '../../common/components/PersonPicture';
import type { RepoDetail, RepoLicense, RepoReadme, RepoRelease } from '../../models/RepoModels';

/** Base64 → UTF-8 字符串（系统原生解码，避免手写循环阻塞主线程） */
function b64decode(b64: string): string {
  try {
    const base64 = new util.Base64Helper();
    const bytes: Uint8Array = base64.decodeSync(b64);
    const decoder = new util.TextDecoder('utf-8');
    return decoder.decodeToString(bytes);
  } catch (e) {
    return '';
  }
}
function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}

@Component
export struct RepoDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State repo: RepoDetail | null = null;
  private readmeText: string = '';
  @State readmeLoaded: boolean = false;
  @State readmeLoading: boolean = false;
  @State latestRelease: RepoRelease | null = null;
  @State loading: boolean = true;
  @Prop @Watch('loadRepo') owner: string = '';
  @Prop @Watch('loadRepo') repoName: string = '';
  scroller?: Scroller;
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

  @State errorMsg: string = '';

  async loadRepo(): Promise<void> {
    if (!this.owner || !this.repoName) { this.loading = false; return; }
    this.loading = true; this.errorMsg = '';
    try { this.repo = await RepoRepository.getRepoDetail(this.owner, this.repoName); }
    catch (e) { this.repo = null; this.errorMsg = HttpClient.formatError(e); }
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
      const data: RepoReadme = await RepoRepository.getReadme(this.owner, this.repoName);
      const raw: string = data.content || '';
      setTimeout(() => {
        try { this.readmeText = b64decode(raw); } catch (e) { this.readmeText = raw; }
        this.readmeLoaded = true;
      }, 50);
    } catch (e) { this.readmeText = ''; this.readmeLoaded = true; }
    finally { this.readmeLoading = false; }
  }

  private ownerLogin(): string { return this.repo && this.repo.owner ? (this.repo.owner.login || this.owner) : this.owner; }
  private ownerAvatar(): string { return this.repo && this.repo.owner ? (this.repo.owner.avatar_url || '') : ''; }
  private rName(): string { return this.repo ? (this.repo.name || '') : ''; }
  private rDesc(): string { return this.repo && this.repo.description ? this.repo.description : ''; }
  private rStars(): string { return fmt(this.repo ? (this.repo.stargazers_count || 0) : 0); }
  private rForks(): string { return fmt(this.repo ? (this.repo.forks_count || 0) : 0); }
  private rIssues(): string { return fmt(this.repo ? (this.repo.open_issues_count || 0) : 0); }
  private rBranch(): string { return this.repo ? (this.repo.default_branch || '') : ''; }
  private rLang(): string { return this.repo && this.repo.language ? this.repo.language : ''; }
  private rCreated(): string { return this.repo && this.repo.created_at ? this.repo.created_at.substring(0, 10) : ''; }
  private rUpdated(): string { return this.repo && this.repo.updated_at ? this.repo.updated_at.substring(0, 10) : ''; }
  private topics(): string[] { return this.repo && this.repo.topics ? this.repo.topics : []; }
  private licenseName(): string {
    if (!this.repo || !this.repo.license) return '';
    const lic: RepoLicense = this.repo.license;
    return lic.spdx_id || lic.name || '';
  }
  private releaseTag(): string { return this.latestRelease ? (this.latestRelease.tag_name || '') : ''; }
  private releaseName(): string { return this.latestRelease && this.latestRelease.name ? this.latestRelease.name : ''; }
  private releaseDate(): string { return this.latestRelease && this.latestRelease.published_at ? this.latestRelease.published_at.substring(0, 10) : ''; }
  private releaseBody(): string { return this.latestRelease && this.latestRelease.body ? this.latestRelease.body : ''; }
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
          Text(this.errorMsg || '无法加载仓库信息').fontSize(16).fontColor(this.T().textSecondary)
          Text('点击重试').fontSize(13).fontColor(this.T().accent)
            .onClick(() => { this.loadRepo(); })
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else {
        Scroll(this.scroller) {
          Column({ space: 20 }) {
            Blank().height(88)
            // ===== 1. HEADER =====
            AcrylicCard() {
              Column({ space: 10 }) {
                Row({ space: 6 }) {
                  PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), avatarSize: 20 })
                  Text(this.ownerLogin()).fontSize(13).fontColor(this.T().textSecondary)
                    .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.width('100%').alignItems(VerticalAlign.Center)
                Text(this.rName() || this.repoName).fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).width('100%')
                if (this.rDesc() !== '') {
                  Text(this.rDesc()).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20).width('100%')
                }
                if (this.topics().length > 0) {
                  Row({ space: 6 }) {
                    ForEach(this.topics().slice(0, 8), (t: string, _idx: number) => {
                      Text(t).fontSize(12).fontColor(this.T().accent)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
                        .borderRadius(8)
                    }, (_t: string, idx: number) => idx.toString())
                  }.width('100%')
                }
                Row({ space: 10 }) {
                  this.statCard('星标', this.rStars())
                  this.statCard('复刻', this.rForks())
                  this.statCard('议题', this.rIssues())
                }.width('100%').margin({ top: 6 })
              }.width('100%')
            }

            // ===== 2. 操作区（议题/PR/安全） =====
            Row({ space: 8 }) {
              WinButton({
                label: '议题', icon: '◉', tint: this.T().issueGreen, flex: 1,
                onAction: () => { if (this.onOpenIssues) this.onOpenIssues(this.owner, this.repoName); }
              })
              WinButton({
                label: 'PR', icon: '⇄', tint: this.T().prBlue, flex: 1,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/pulls'); }
              })
              WinButton({
                label: '安全', icon: '🛡', tint: this.T().discussionPurple, flex: 1,
                onAction: () => { this.openWeb('https://github.com/' + this.owner + '/' + this.repoName + '/security'); }
              })
            }.width('100%')

            // ===== 3. 仓库信息 =====
            AcrylicCard() {
              Column() {
                this.sectionTitle('📋 仓库信息')
                this.infoRow('默认分支', this.rBranch())
                if (this.rLang() !== '') {
                  Divider().color(this.T().border).width('100%')
                  Row() {
                    Text('语言').fontSize(14).fontColor(this.T().textSecondary).width(88)
                    Row({ space: 6 }) {
                      Circle().width(8).height(8).fill(langColor(this.rLang()))
                      Text(this.rLang()).fontSize(15).fontColor(this.T().textPrimary)
                    }
                  }.width('100%').padding({ top: 14, bottom: 14 })
                }
                if (this.licenseName() !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('许可证', this.licenseName())
                }
                if (this.rCreated() !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('创建', this.rCreated())
                }
                if (this.rUpdated() !== '') {
                  Divider().color(this.T().border).width('100%')
                  this.infoRow('最近更新', this.rUpdated())
                }
              }.width('100%')
            }

            // ===== 4. 最新 Release =====
            if (this.latestRelease) {
              ExpandableSection({ title: '最新版本', icon: '🚀', accentText: this.releaseTag(), initialExpanded: false }) {
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
                PersonPicture({ url: this.ownerAvatar(), name: this.ownerLogin(), avatarSize: 40 })
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
            Blank().height(80)
          }.width('100%')
        }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }).width('100%').height('100%')
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
