import { DarkTheme, LightTheme, THEME_KEY, ThemeColors, langColor } from '../../common/constants/ThemeConstants';
import { RepoRepository } from '../../services/RepoRepository';

function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}

/** 简易 Markdown → 纯文本转换 */
function stripMd(md: string): string {
  return md
    .replace(/^#{1,6}\s+/gm, '')           // 标题 #
    .replace(/\*\*(.+?)\*\*/g, '$1')        // 粗体 **
    .replace(/__(.+?)__/g, '$1')            // 粗体 __
    .replace(/\*(.+?)\*/g, '$1')            // 斜体 *
    .replace(/_(.+?)_/g, '$1')              // 斜体 _
    .replace(/`{1,3}[^`]*`{1,3}/g, '')      // 代码块
    .replace(/\[(.+?)\]\(.+?\)/g, '$1')     // 链接 [text](url)
    .replace(/!\[.*?\]\(.+?\)/g, '')        // 图片
    .replace(/^[-*+]\s+/gm, '• ')           // 无序列表
    .replace(/^\d+\.\s+/gm, '')             // 有序列表
    .replace(/^>\s+/gm, '')                 // 引用
    .replace(/---+/g, '')                   // 水平线
    .replace(/^\|.*\|$/gm, '')              // 表格行
    .replace(/\n{3,}/g, '\n\n')             // 压缩空行
    .trim();
}

@Component
export struct RepoDetailPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State repo: Object | null = null;
  @State readmeText: string = '';
  @State readmeLoaded: boolean = false;
  @State showFullReadme: boolean = false;
  @State latestRelease: Object | null = null;
  @State loading: boolean = true;
  @Prop @Watch('loadRepo') owner: string = '';
  @Prop @Watch('loadRepo') repoName: string = '';
  onOpenWebView?: (url: string) => void;
  onOpenDev?: (username: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

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
    try {
      const data: Object = await RepoRepository.getReadme(this.owner, this.repoName);
      const content: string = (data as Record<string, Object>).content as string || '';
      this.readmeText = content;
      const enc: string = (data as Record<string, Object>).encoding as string || '';
      if (enc === 'base64' && content) {
        this.readmeText = '[README.md — 点击查看完整内容]';
      }
      this.readmeLoaded = true;
    } catch (e) { this.readmeText = ''; this.readmeLoaded = true; }
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        if (this.loading) {
          Column() { LoadingProgress().width(40).height(40).color(this.T().accent) }
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(400)
        } else if (!this.repo) {
          Column({ space: 12 }) {
            Text('☁').fontSize(48).fontColor(this.T().textTertiary)
            Text('无法加载仓库信息').fontSize(16).fontColor(this.T().textSecondary)
            Text('请检查网络后重试').fontSize(13).fontColor(this.T().textTertiary)
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(400)
        } else {
          Column({ space: 24 }) {
            // ===== 1. HEADER 卡片 =====
            Column() {
              Row() {
                Text((this.repo as Record<string, Object>).owner ? ((this.repo as Record<string, Object>).owner as Record<string, string>).login : this.owner)
                  .fontSize(13).fontColor(this.T().textSecondary).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
              }.width('100%')

              Text(((this.repo as Record<string, Object>).name as string) || this.repoName)
                .fontSize(28).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).width('100%').margin({ top: 2 })

              Blank().height(14)

              if ((this.repo as Record<string, Object>).description) {
                Text(((this.repo as Record<string, Object>).description as string) || '')
                  .fontSize(14).fontColor(this.T().textSecondary).lineHeight(20).width('100%')
                Blank().height(14)
              }

              if (((this.repo as Record<string, Object>).topics as string[]) && ((this.repo as Record<string, Object>).topics as string[]).length > 0) {
                Row({ space: 6 }) {
                  ForEach(((this.repo as Record<string, Object>).topics as string[]).slice(0, 8), (t: string, idx: number) => {
                    Text(t).fontSize(12).fontColor(this.T().accent)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
                      .borderRadius(8)
                  }, (t: string, idx: number) => idx.toString())
                }.width('100%')
                Blank().height(14)
              }

              Row({ space: 10 }) {
                this.statCard('星标', fmt((this.repo as Record<string, Object>).stargazers_count as number || 0))
                this.statCard('复刻', fmt((this.repo as Record<string, Object>).forks_count as number || 0))
                this.statCard('议题', fmt((this.repo as Record<string, Object>).open_issues_count as number || 0))
              }.width('100%')
            }
            .width('100%').padding(20)
            .backgroundColor(this.T().surface).borderRadius(16)
            .border({ width: 1, color: this.T().border })
            .padding({ left: 16, right: 16 })

            // ===== 2. REPO PAGES 操作按钮 =====
            Row({ space: 8 }) {
              this.actionBtn('◉ 议题', this.T().issueGreen)
              this.actionBtn('⇄ PR', this.T().prBlue)
              this.actionBtn('🛡 安全', this.T().discussionPurple)
            }.width('100%').padding({ left: 16, right: 16 })

            // ===== 3. 详情卡片 =====
            Column() {
              this.sectionTitle('📋 仓库信息')
              this.infoRow('默认分支', ((this.repo as Record<string, Object>).default_branch as string) || '')
              if ((this.repo as Record<string, Object>).language) {
                Divider().color(this.T().border).width('100%')
                Row() {
                  Text('语言').fontSize(14).fontColor(this.T().textSecondary).width(88)
                  Row({ space: 6 }) {
                    Circle().width(8).height(8).fill(langColor((this.repo as Record<string, Object>).language as string))
                    Text(((this.repo as Record<string, Object>).language as string) || '').fontSize(15).fontColor(this.T().textPrimary)
                  }
                }.width('100%').padding({ left: 20, right: 20, top: 14, bottom: 14 })
              }
              if ((this.repo as Record<string, Object>).license) {
                Divider().color(this.T().border).width('100%')
                this.infoRow('许可证', ((((this.repo as Record<string, Object>).license as Record<string, string>).spdx_id) || (((this.repo as Record<string, Object>).license as Record<string, string>).name) || ''))
              }
              Divider().color(this.T().border).width('100%')
              if ((this.repo as Record<string, Object>).created_at) {
                this.infoRow('创建', (((this.repo as Record<string, Object>).created_at as string) || '').substring(0, 10))
              }
              if ((this.repo as Record<string, Object>).updated_at) {
                Divider().color(this.T().border).width('100%')
                this.infoRow('最近更新', (((this.repo as Record<string, Object>).updated_at as string) || '').substring(0, 10))
              }
            }
            .width('100%').backgroundColor(this.T().surface).borderRadius(16)
            .border({ width: 1, color: this.T().border })
            .padding({ left: 16, right: 16 })

            // ===== 4. 最新 Release =====
            if (this.latestRelease) {
              Column() {
                this.sectionTitle('🚀 最新版本')
                Text(((this.latestRelease as Record<string, Object>).tag_name as string) || '')
                  .fontSize(18).fontWeight(FontWeight.Bold).fontColor(this.T().accent)
                  .width('100%').padding({ top: 4 })
                Text(((this.latestRelease as Record<string, Object>).name as string) || '')
                  .fontSize(14).fontColor(this.T().textSecondary).margin({ top: 4 }).width('100%')
                if ((this.latestRelease as Record<string, Object>).published_at) {
                  Text(((this.latestRelease as Record<string, Object>).published_at as string).substring(0, 10))
                    .fontSize(12).fontColor(this.T().textTertiary).margin({ top: 4 })
                }
                if ((this.latestRelease as Record<string, Object>).body) {
                  Text(stripMd(((this.latestRelease as Record<string, Object>).body as string)).substring(0, Math.min(stripMd(((this.latestRelease as Record<string, Object>).body as string)).length, 800)))
                    .fontSize(13).fontColor(this.T().textSecondary).lineHeight(20).maxLines(15)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%').margin({ top: 10 })
                }
                Row() {
                  Text('查看完整 Release').fontSize(14).fontColor(this.T().accent)
                }.width('100%').margin({ top: 8 }).onClick(() => {
                  const relUrl: string = 'https://github.com/' + this.owner + '/' + this.repoName + '/releases/tag/' + (((this.latestRelease as Record<string, Object>).tag_name as string) || '');
                  if (this.onOpenWebView) this.onOpenWebView(relUrl);
                })
              }
              .width('100%').backgroundColor(this.T().surface).borderRadius(16)
              .border({ width: 1, color: this.T().border }).padding(20)
              .padding({ left: 16, right: 16 })
            }

            // ===== 5. 开发者信息 =====
            Column() {
              this.sectionTitle('👤 开发者')
              Row() {
                Text((this.repo as Record<string, Object>).owner ? ((this.repo as Record<string, Object>).owner as Record<string, string>).login : this.owner)
                  .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary).layoutWeight(1)
                Row() {
                  Text('查看 ›').fontSize(13).fontColor(this.T().accent)
                }.padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF').borderRadius(8)
                  .onClick(() => {
                    const devName: string = ((this.repo as Record<string, Object>).owner as Record<string, string>).login || this.owner;
                    if (this.onOpenDev) this.onOpenDev(devName);
                  })
              }.width('100%').alignItems(VerticalAlign.Center)
            }
            .width('100%').backgroundColor(this.T().surface).borderRadius(16)
            .border({ width: 1, color: this.T().border }).padding(20)
            .padding({ left: 16, right: 16 })

            // ===== 6. 报告问题 =====
            Column() {
              Row() {
                Text('🐛 报告问题').fontSize(16).fontColor(this.T().textPrimary).layoutWeight(1)
                Text('›').fontSize(20).fontColor(this.T().textSecondary)
              }.width('100%').alignItems(VerticalAlign.Center)
              .onClick(() => {
                const issueUrl: string = 'https://github.com/' + this.owner + '/' + this.repoName + '/issues/new';
                if (this.onOpenWebView) this.onOpenWebView(issueUrl);
              })
            }
            .width('100%').backgroundColor(this.T().surface).borderRadius(16)
            .border({ width: 1, color: this.T().border }).padding(20)
            .padding({ left: 16, right: 16 })

            // ===== 7. README 预览 =====
            if (this.readmeLoaded && this.readmeText) {
              Column() {
                this.sectionTitle('📄 README')
                if (this.showFullReadme) {
                  Text(stripMd(this.readmeText))
                    .fontSize(13).fontColor(this.T().textSecondary).lineHeight(20)
                    .width('100%').padding(20)
                } else {
                  Text(stripMd(this.readmeText).substring(0, Math.min(stripMd(this.readmeText).length, 1500)))
                    .fontSize(13).fontColor(this.T().textSecondary).lineHeight(20).maxLines(30)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%').padding({ left: 20, right: 20 })
                  Row() {
                    Text('展开查看').fontSize(14).fontColor(this.T().accent)
                  }.width('100%').padding({ left: 20, right: 20, bottom: 14 })
                  .onClick(() => { this.showFullReadme = true; })
                }
                Row() {
                  Text('在浏览器中查看完整 README').fontSize(14).fontColor(this.T().accent)
                }.width('100%').padding({ left: 20, right: 20, bottom: 16 })
                .onClick(() => {
                  const readmeUrl: string = 'https://github.com/' + this.owner + '/' + this.repoName + '#readme';
                  if (this.onOpenWebView) this.onOpenWebView(readmeUrl);
                })
                if (this.showFullReadme) {
                  Row() {
                    Text('收起').fontSize(14).fontColor(this.T().textTertiary)
                  }.width('100%').padding({ left: 20, right: 20, bottom: 14 })
                  .onClick(() => { this.showFullReadme = false; })
                }
              }
              .width('100%').backgroundColor(this.T().surface).borderRadius(16)
              .border({ width: 1, color: this.T().border })
              .padding({ left: 16, right: 16 })
            }
          }
        }
        Blank().height(80)
      }.width('100%').alignItems(HorizontalAlign.Start)
    }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
  }

  @Builder statCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(label).fontSize(12).fontWeight(FontWeight.Medium).fontColor(this.T().textTertiary)
    }.layoutWeight(1).padding({ top: 12, bottom: 12 }).alignItems(HorizontalAlign.Center)
      .backgroundColor(this.T().background).borderRadius(10)
      .border({ width: 1, color: this.T().border })
  }

  @Builder actionBtn(label: string, color: string) {
    Row() { Text(label).fontSize(13).fontWeight(FontWeight.Medium).fontColor(color) }
      .layoutWeight(1).height(40).justifyContent(FlexAlign.Center)
      .backgroundColor(this.T().surface).borderRadius(10)
      .border({ width: 1, color: this.T().border })
      .onClick(() => {
        const baseUrl: string = 'https://github.com/' + this.owner + '/' + this.repoName;
        if (label.includes('议题')) this.openWeb(baseUrl + '/issues');
        else if (label.includes('PR')) this.openWeb(baseUrl + '/pulls');
        else if (label.includes('安全')) this.openWeb(baseUrl + '/security');
      })
  }

  private openWeb(url: string): void { if (this.onOpenWebView) this.onOpenWebView(url); }

  @Builder sectionTitle(title: string) {
    Row() {
      Text(title).fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
      Blank()
    }.width('100%').padding({ top: 16, bottom: 12 })
  }

  @Builder infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.T().textSecondary).width(88)
      Text(value).fontSize(15).fontColor(this.T().textPrimary).layoutWeight(1).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
    }.width('100%').padding({ top: 14, bottom: 14 })
  }
}
