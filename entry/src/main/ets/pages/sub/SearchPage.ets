import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { SearchRepository } from '../../services/SearchRepository';
import type { Repository, SearchResult } from '../../models/User';

@Component
export struct SearchPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @StorageLink('userFilterEnabled') userFilterEnabled: boolean = true;
  @State query: string = '';
  @State filterWords: string = '';
  @State results: Repository[] = [];
  @State totalCount: number = 0;
  @State loading: boolean = false;
  @State hasSearched: boolean = false;
  @State page: number = 1;
  scroller?: Scroller;
  onOpenRepo?: (owner: string, repo: string) => void;

  private getBlockedCount(): number { return this.results.length - this.getFilteredResults().length; }

  private getFilteredResults(): Repository[] {
    // 仅手动屏蔽词（受开关控制）
    const manual: string[] = this.userFilterEnabled
      ? this.filterWords.toLowerCase().split(/[,，\s]+/).filter((w: string) => w.length > 0)
      : [];
    if (manual.length === 0) return this.results;
    return this.results.filter((item: Repository) => {
      const name: string = (item.full_name || '').toLowerCase();
      const desc: string = (item.description || '').toLowerCase();
      return !manual.some((w: string) => name.includes(w) || desc.includes(w));
    });
  }
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  async doSearch(): Promise<void> {
    if (!this.query.trim()) return;
    this.loading = true; this.hasSearched = true; this.results = []; this.page = 1;
    try {
      const data: SearchResult = await SearchRepository.searchRepos(this.query.trim(), 1);
      this.results = data.items;
      this.totalCount = data.total_count;

    } catch (e) { this.results = []; this.totalCount = 0; console.error('SearchPage', `search error: ${JSON.stringify(e)}`); }
    finally { this.loading = false; }
  }

  async loadPage(newPage: number): Promise<void> {
    if (this.loading || newPage < 1 || !this.query.trim()) return;
    this.loading = true; this.page = newPage;
    try {
      const data: SearchResult = await SearchRepository.searchRepos(this.query.trim(), newPage);
      this.results = data.items;
    } catch (e) { this.results = []; }
    finally { this.loading = false; }
  }

  private totalPages(): number {
    return Math.max(1, Math.ceil(this.totalCount / 20));
  }

  private hasFilterWords(): boolean {
    return this.userFilterEnabled && this.filterWords.trim().length > 0;
  }

  build() {
    Column() {
      Blank().height(88)
      // 搜索框 — 固定在标题栏下方，不随内容滚动
      Row() {
        TextInput({ placeholder: '搜索仓库...', text: this.query })
          .placeholderColor(this.T().textTertiary).fontSize(16).fontColor(this.T().textPrimary)
          .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(40)
          .layoutWeight(1).padding({ left: 12 }).onChange((v: string) => { this.query = v; })
        Button('搜索').fontSize(14).fontColor(Color.White).backgroundColor(this.T().accent)
          .borderRadius(8).height(40).padding({ left: 16, right: 16 }).margin({ left: 10 })
          .onClick(() => { this.doSearch(); })
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 4 })

      // 屏蔽词
      if (this.userFilterEnabled) {
        Row() {
          TextInput({ placeholder: '手动屏蔽词 (逗号分隔)', text: this.filterWords })
            .placeholderColor(this.T().textTertiary).fontSize(13).fontColor(this.T().textPrimary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(6).height(32)
            .layoutWeight(1).padding({ left: 10 }).onChange((v: string) => { this.filterWords = v; })
          if (this.filterWords) {
            Text('✕').fontSize(16).fontColor(this.T().textTertiary).width(32).height(32).textAlign(TextAlign.Center).lineHeight(32)
              .onClick(() => { this.filterWords = ''; })
          }
        }.width('100%').padding({ left: 16, right: 16, bottom: 8 })
      }

      if (this.hasSearched && !this.loading && this.getBlockedCount() > 0) {
        Row() {
          Text('🛡️').fontSize(14).margin({ right: 6 })
          Text('已屏蔽 ' + this.getBlockedCount() + ' 条结果').fontSize(13).fontColor(this.T().textTertiary)
        }.padding({ left: 16, right: 16, bottom: 6 })
      }

      // 内容区 — 可滚动
      Scroll(this.scroller) {
        Column() {
          if (this.loading) {
            LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
          } else if (!this.hasSearched) {
            Blank().height(120)
            Column({ space: 8 }) {
              Text('🔍').fontSize(48)
              Text('搜索 GitHub 仓库').fontSize(16).fontColor(this.T().textSecondary)
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%')
          } else if (this.getFilteredResults().length === 0) {
            Blank().height(60)
            Column({ space: 8 }) {
              Text('✉').fontSize(40)
              Text(this.filterWords ? '所有结果已被屏蔽' : '未找到相关仓库').fontSize(14).fontColor(this.T().textSecondary)
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%')
          } else {
            ForEach(this.getFilteredResults(), (item: Repository) => {
              Row() {
                Column() {
                  Text(item.full_name || '')
                    .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                  if (item.description) {
                    Text(item.description || '')
                      .fontSize(13).fontColor(this.T().textSecondary).maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
                  }
                  Row() {
                    if (item.language) {
                      Text(item.language || '')
                        .fontSize(12).fontColor(this.T().textTertiary)
                    }
                    Text(' ★ ' + (item.stargazers_count || 0).toString())
                      .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 12 })
                  }.margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text('›').fontSize(20).fontColor(this.T().textSecondary)
              }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onClick(() => {
                const fullName: string = item.full_name || '';
                const parts: string[] = fullName.split('/');
                if (parts.length === 2 && this.onOpenRepo) this.onOpenRepo(parts[0], parts[1]);
              })
            }, (item: Repository) => item.full_name || '')
            // 分页导航
            if (this.totalPages() > 1 && !this.hasFilterWords()) {
              Row({ space: 12 }) {
                Button('上一页')
                  .fontSize(12).height(30)
                  .backgroundColor(this.page > 1 ? this.T().accent : this.T().surfaceElevated)
                  .fontColor(this.page > 1 ? Color.White : this.T().textTertiary)
                  .enabled(this.page > 1)
                  .onClick(() => { this.loadPage(this.page - 1); })
                Text(this.page + ' / ' + this.totalPages())
                  .fontSize(12).fontColor(this.T().textSecondary)
                Button('下一页')
                  .fontSize(12).height(30)
                  .backgroundColor(this.page < this.totalPages() ? this.T().accent : this.T().surfaceElevated)
                  .fontColor(this.page < this.totalPages() ? Color.White : this.T().textTertiary)
                  .enabled(this.page < this.totalPages())
                  .onClick(() => { this.loadPage(this.page + 1); })
              }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 16, bottom: 16 })
            } else if (this.getFilteredResults().length > 0 && this.page >= this.totalPages()) {
              Text('— 已加载全部结果 —').fontSize(12).fontColor(this.T().textTertiary)
                .width('100%').textAlign(TextAlign.Center).padding({ top: 16, bottom: 16 })
            }
          }
        }.width('100%')
      }.scrollBar(BarState.Off).layoutWeight(1).backgroundColor(this.T().background)
    }.width('100%').height('100%').backgroundColor(this.T().background)
  }
}
