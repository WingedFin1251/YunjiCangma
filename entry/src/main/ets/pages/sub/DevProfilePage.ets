import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { UserRepository } from '../../services/UserRepository';
import { RepoRepository } from '../../services/RepoRepository';
import { HttpClient } from '../../services/HttpClient';
import { AcrylicCard } from '../../common/components/AcrylicCard';
import { MicaLayer } from '../../common/components/MicaLayer';
import { WinButton } from '../../common/components/WinButton';
import { PersonPicture } from '../../common/components/PersonPicture';
import type { User } from '../../models/User';

// 贡献热力图缓存（避免重复打开同一开发者反复请求触发 GraphQL 限流）
const contribCache: Map<string, Object[]> = new Map();
const contribTotalCache: Map<string, number> = new Map();

function fmt(n: number): string {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
  if (n >= 1000) return (n / 1000).toFixed(1) + 'k';
  return n.toString();
}

@Component
export struct DevProfilePage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State profile: User | null = null;
  @State allRepos: Object[] = [];
  @State filteredRepos: Object[] = [];
  @State filterType: number = 0;
  @State searchQuery: string = '';
  @State totalContributions: number = 0;
  @State contribWeeks: Object[] = [];
  @State contribLoading: boolean = true;
  @State loading: boolean = true;
  @Prop @Watch('load') username: string = '';
  scroller?: Scroller;
  onOpenRepo?: (owner: string, repo: string) => void;
  onOpenWebView?: (url: string) => void;
  private filterLabels: string[] = ['全部', '原创', '复刻'];
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

  aboutToAppear(): void { if (this.username) this.load(); }

  async loadContributions(): Promise<void> {
    try {
      const cached: Object[] | undefined = contribCache.get(this.username);
      if (cached) {
        this.contribWeeks = cached;
        this.totalContributions = contribTotalCache.get(this.username) || 0;
      } else {
        const data: Object = await UserRepository.getContributions(this.username);
        const d: Record<string, Object> = data as Record<string, Object>;
        const userObj: Record<string, Object> = d.data ? (d.data as Record<string, Object>).user as Record<string, Object> : ({} as Record<string, Object>);
        const coll: Record<string, Object> = userObj ? (userObj.contributionsCollection as Record<string, Object>) : ({} as Record<string, Object>);
        const cal: Record<string, Object> = coll ? (coll.contributionCalendar as Record<string, Object>) : ({} as Record<string, Object>);
        this.totalContributions = (cal.totalContributions as number) || 0;
        this.contribWeeks = (cal.weeks as Object[]) || [];
        contribCache.set(this.username, this.contribWeeks);
        contribTotalCache.set(this.username, this.totalContributions);
      }
    } catch (e) { this.totalContributions = 0; this.contribWeeks = []; }
    finally { this.contribLoading = false; }
  }

  @State errorMsg: string = '';

  async load(): Promise<void> {
    this.loading = true; this.errorMsg = '';
    try {
      this.profile = await UserRepository.getUser(this.username);
      const items: Object[] = await RepoRepository.getUserRepos(this.username);
      this.allRepos = items.slice(0, 30);
      this.applyFilter();
      this.loadContributions();
    } catch (e) { this.profile = null; this.allRepos = []; this.errorMsg = HttpClient.formatError(e); }
    finally { this.loading = false; }
  }

  applyFilter(): void {
    let result: Object[] = this.allRepos;
    if (this.filterType === 1) result = result.filter((r: Object) => !((r as Record<string, Object>).fork as boolean));
    else if (this.filterType === 2) result = result.filter((r: Object) => (r as Record<string, Object>).fork as boolean);
    if (this.searchQuery.trim()) {
      const q: string = this.searchQuery.toLowerCase();
      result = result.filter((r: Object) => ((r as Record<string, Object>).name as string || '').toLowerCase().includes(q) || ((r as Record<string, Object>).description as string || '').toLowerCase().includes(q));
    }
    this.filteredRepos = result;
  }

  build() {
    Stack() {
      MicaLayer()
      if (this.loading) {
        Column({ space: 12 }) {
          LoadingProgress().width(32).height(32).color(this.T().accent)
          Text('正在加载…').fontSize(13).fontColor(this.T().textTertiary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else if (!this.profile) {
        Column({ space: 12 }) {
          Text('☁').fontSize(48).fontColor(this.T().textTertiary)
          Text(this.errorMsg || '无法加载用户信息').fontSize(14).fontColor(this.T().textSecondary)
          Text('点击重试').fontSize(13).fontColor(this.T().accent)
            .onClick(() => { this.load(); })
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
      } else {
        Scroll(this.scroller) {
          Column({ space: 20 }) {
            Blank().height(88)
            // ===== 1. PROFILE HEADER =====
            AcrylicCard({ paddingV: 24 }) {
              Column() {
                PersonPicture({ url: this.profile.avatar_url, name: this.profile.login, avatarSize: 84 })
                Text(this.profile.name || this.profile.login)
                  .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary).margin({ top: 12 })
                Text('@' + this.profile.login).fontSize(14).fontColor(this.T().textSecondary).margin({ top: 2 })
                if (this.profile.bio) {
                  Text(this.profile.bio).fontSize(14).fontColor(this.T().textSecondary).lineHeight(20)
                    .textAlign(TextAlign.Center).width('100%').margin({ top: 10 })
                }
                Row() {
                  this.statCol('仓库', this.profile.public_repos)
                  Text('│').fontSize(18).fontColor(this.T().border).margin({ left: 20, right: 20 })
                  this.statCol('粉丝', this.profile.followers)
                  Text('│').fontSize(18).fontColor(this.T().border).margin({ left: 20, right: 20 })
                  this.statCol('关注', this.profile.following)
                }.margin({ top: 16 })
                if (this.profile.company) Text('🏢 ' + (this.profile.company || '')).fontSize(13).fontColor(this.T().textTertiary).margin({ top: 12 })
                if (this.profile.location) Text('📍 ' + (this.profile.location || '')).fontSize(13).fontColor(this.T().textTertiary).margin({ top: 4 })
                if (this.profile.blog) Text('🔗 ' + (this.profile.blog || '')).fontSize(13).fontColor(this.T().accent).margin({ top: 4 })
                WinButton({ label: '分享', icon: '📤', tint: this.T().accent, onAction: () => { if (this.onOpenWebView) this.onOpenWebView('https://github.com/' + this.username); } })
                  .margin({ top: 14 })
              }.alignItems(HorizontalAlign.Center)
            }

            // ===== 2. 贡献热力图 =====
            if (this.contribLoading) {
              AcrylicCard({ paddingV: 14 }) {
                Column({ space: 8 }) {
                  this.sectionTitle('📊 贡献')
                  LoadingProgress().width(20).height(20).color(this.T().accent)
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            } else if (this.contribWeeks.length > 0) {
              AcrylicCard({ paddingV: 14 }) {
                Column() {
                  Row() {
                    Text('📊 贡献').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                    Blank()
                    Text(this.totalContributions + ' 次').fontSize(14).fontColor(this.T().textSecondary)
                  }.width('100%').padding({ top: 2, bottom: 8 })
                  Scroll() {
                    Column({ space: 2 }) {
                      ForEach([0, 1, 2, 3, 4, 5, 6], (row: number, _ri: number) => {
                        Row({ space: 2 }) {
                          ForEach(this.contribWeeks.slice(Math.max(0, this.contribWeeks.length - 53)), (week: Object, _wi: number) => {
                            if (row < (((week as Record<string, Object>).contributionDays as Object[]) || []).length) {
                              Text('').width(10).height(10)
                                .backgroundColor(this.heatColor((((((week as Record<string, Object>).contributionDays as Object[]) || [])[row] as Record<string, Object>).contributionCount as number) || 0))
                                .borderRadius(2)
                            } else { Text('').width(10).height(10) }
                          }, (_week: Object, wi: number) => 'w' + wi)
                        }
                      }, (_row: number, ri: number) => 'r' + ri)
                    }
                  }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(82)
                  Row({ space: 4 }) {
                    Text('较少').fontSize(10).fontColor(this.T().textTertiary)
                    Text('■').fontSize(10).fontColor('#1B3419'); Text('■').fontSize(10).fontColor('#0E4429')
                    Text('■').fontSize(10).fontColor('#006D32'); Text('■').fontSize(10).fontColor('#26A641')
                    Text('■').fontSize(10).fontColor('#39D353')
                    Text('较多').fontSize(10).fontColor(this.T().textTertiary)
                  }.width('100%').padding({ top: 4 }).justifyContent(FlexAlign.End)
                }.width('100%')
              }
            } else {
              AcrylicCard({ paddingV: 14 }) {
                Column({ space: 8 }) {
                  this.sectionTitle('📊 贡献')
                  Text('贡献数据加载失败或暂无数据').fontSize(12).fontColor(this.T().textTertiary)
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
            }

            // ===== 3. 仓库区（搜索 + 筛选 + 列表） =====
            AcrylicCard({ paddingV: 14 }) {
              Column() {
                Row() {
                  TextInput({ placeholder: '搜索仓库...', text: this.searchQuery })
                    .placeholderColor(this.T().textTertiary).fontSize(14).fontColor(this.T().textPrimary)
                    .backgroundColor(this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill)
                    .borderRadius(8).height(38).layoutWeight(1).padding({ left: 12 })
                    .onChange((v: string) => { this.searchQuery = v; this.applyFilter(); })
                  if (this.searchQuery) {
                    Text('✕').fontSize(16).fontColor(this.T().textTertiary).width(36).height(38).textAlign(TextAlign.Center).lineHeight(38)
                      .onClick(() => { this.searchQuery = ''; this.applyFilter(); })
                  }
                }.width('100%').alignItems(VerticalAlign.Center)

                Scroll() {
                  Row({ space: 8 }) {
                    ForEach(this.filterLabels, (t: string, idx: number) => {
                      Text(t).fontSize(13).fontWeight(FontWeight.Medium)
                        .fontColor(this.filterType === idx ? Color.White : this.T().textSecondary)
                        .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                        .backgroundColor(this.filterType === idx ? this.T().accent : (this.themeMode === 'dark' ? DarkTheme.ctrlFill : LightTheme.ctrlFill))
                        .borderRadius(8)
                        .onClick(() => { this.filterType = idx; this.applyFilter(); })
                    }, (_t: string, idx: number) => idx.toString())
                  }
                }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(40).margin({ top: 8 })

                Text('显示 ' + this.filteredRepos.length + ' 个仓库').fontSize(12).fontColor(this.T().textTertiary)
                  .width('100%').padding({ top: 4, bottom: 8 })

                Column() {
                  ForEach(this.filteredRepos, (item: Object, idx: number) => {
                    Row() {
                      Column() {
                        Text(((item as Record<string, Object>).name as string) || '')
                          .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                        if ((item as Record<string, Object>).description) {
                          Text(((item as Record<string, Object>).description as string) || '')
                            .fontSize(13).fontColor(this.T().textSecondary).maxLines(2).lineHeight(18)
                            .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
                        }
                        Row() {
                          if ((item as Record<string, Object>).language) {
                            Text(((item as Record<string, Object>).language as string) || '')
                              .fontSize(12).fontColor(this.T().textTertiary)
                          }
                          Text(' ★ ' + fmt((item as Record<string, Object>).stargazers_count as number || 0))
                            .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          Text(' ⑂ ' + fmt((item as Record<string, Object>).forks_count as number || 0))
                            .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          if ((item as Record<string, Object>).updated_at) {
                            Text(' · ' + (((item as Record<string, Object>).updated_at as string) || '').substring(0, 10))
                              .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 10 })
                          }
                        }.margin({ top: 6 })
                      }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                      Text('›').fontSize(20).fontColor(this.T().textSecondary)
                    }
                    .width('100%').padding({ top: 12, bottom: 12 }).alignItems(VerticalAlign.Center)
                    .onClick(() => {
                      const it = item as Record<string, Object>;
                      const rOwner: string = (it.owner as Record<string, string>).login || this.username;
                      const rName: string = (it.name as string) || '';
                      if (this.onOpenRepo) this.onOpenRepo(rOwner, rName);
                    })
                    if (idx < this.filteredRepos.length - 1) {
                      Divider().color(this.T().border).width('100%')
                    }
                  }, (_item: Object, idx: number) => idx.toString())
                }.width('100%')
              }.width('100%')
            }
            Blank().height(80)
          }.width('100%')
        }.scrollBar(BarState.Off).width('100%').height('100%')
      }
    }.width('100%').height('100%')
  }

  private heatColor(count: number): string {
    if (count === 0) return this.T().surfaceElevated;
    if (count <= 2) return '#0E4429'; if (count <= 5) return '#006D32';
    if (count <= 8) return '#26A641'; return '#39D353';
  }

  @Builder
  sectionTitle(title: string) {
    Row() {
      Text(title).fontSize(17).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
      Blank()
    }.width('100%').padding({ top: 2, bottom: 4 })
  }

  @Builder
  statCol(label: string, value: number) {
    Column() {
      Text(value.toString()).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
      Text(label).fontSize(12).fontColor(this.T().textTertiary)
    }
  }
}
