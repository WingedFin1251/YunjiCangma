import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { GitHubAPIService } from '../../services/GitHubAPIService';

@Component
export struct SearchPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State query: string = '';
  @State results: Object[] = [];
  @State loading: boolean = false;
  @State hasSearched: boolean = false;
  onOpenRepo?: (url: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  async doSearch(): Promise<void> {
    if (!this.query.trim()) return;
    this.loading = true; this.hasSearched = true; this.results = [];
    try {
      const data = await GitHubAPIService.searchRepos(this.query.trim());
      this.results = (data as Record<string, Object>).items as Object[] || [];
    } catch (e) { this.results = []; }
    finally { this.loading = false; }
  }

  build() {
    Column() {
      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索仓库...', text: this.query })
          .placeholderColor(this.T().textTertiary).fontSize(16).fontColor(this.T().textPrimary)
          .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(40)
          .layoutWeight(1).padding({ left: 12 }).onChange((v: string) => { this.query = v; })
        Button('搜索').fontSize(14).fontColor(Color.White).backgroundColor(this.T().accent)
          .borderRadius(8).height(40).padding({ left: 16, right: 16 }).margin({ left: 10 })
          .onClick(() => { this.doSearch(); })
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.loading) {
        LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
      } else if (!this.hasSearched) {
        Column({ space: 8 }) {
          Text('🔍').fontSize(48)
          Text('搜索 GitHub 仓库').fontSize(16).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .width('100%').height('100%').backgroundColor(this.T().background)
      } else if (this.results.length === 0) {
        Column({ space: 8 }) {
          Text('✉').fontSize(40)
          Text('未找到相关仓库').fontSize(14).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .width('100%').height('100%').backgroundColor(this.T().background)
      } else {
        Scroll() {
          Column() {
            ForEach(this.results, (item: Object, idx: number) => {
              Row() {
                Column() {
                  Text(((item as Record<string, Object>).full_name as string) || '')
                    .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
                  if ((item as Record<string, Object>).description) {
                    Text(((item as Record<string, Object>).description as string) || '')
                      .fontSize(13).fontColor(this.T().textSecondary).maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 2 })
                  }
                  Row() {
                    if ((item as Record<string, Object>).language) {
                      Text(((item as Record<string, Object>).language as string) || '')
                        .fontSize(12).fontColor(this.T().textTertiary)
                    }
                    Text(' ★ ' + ((item as Record<string, Object>).stargazers_count as number || 0).toString())
                      .fontSize(12).fontColor(this.T().textTertiary).margin({ left: 12 })
                  }.margin({ top: 4 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Text('›').fontSize(20).fontColor(this.T().textSecondary)
              }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onClick(() => {
                const url: string = ((item as Record<string, Object>).html_url as string) || '';
                if (url && this.onOpenRepo) this.onOpenRepo(url);
              })
            }, (item: Object, idx: number) => idx.toString())
          }.width('100%')
        }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
      }
    }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
  }
}
