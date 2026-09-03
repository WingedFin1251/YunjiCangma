import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { HttpClient } from '../../services/HttpClient';

@Component
export struct IssuesPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State issues: Object[] = [];
  @State loading: boolean = true;
  @State filterState: string = 'open';
  @Prop @Watch('load') owner: string = '';
  @Prop @Watch('load') repoName: string = '';
  scroller?: Scroller;
  onOpenWebView?: (url: string) => void;
  onOpenIssue?: (owner: string, repo: string, number: number) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  aboutToAppear(): void { if (this.owner && this.repoName) this.load(); }

  async load(): Promise<void> {
    this.loading = true;
    try {
      this.issues = await HttpClient.get<Object[]>('/repos/' + this.owner + '/' + this.repoName + '/issues?state=' + this.filterState + '&per_page=30');
    } catch (e) { this.issues = []; }
    finally { this.loading = false; }
  }

  getFiltered(): Object[] {
    return this.issues.filter((i: Object) => !((i as Record<string, Object>).pull_request));
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Blank().height(88)
          // Filter tabs
          Row({ space: 8 }) {
            ForEach(['打开', '已关闭'], (t: string, idx: number) => {
              Text(t).fontSize(13).fontWeight(FontWeight.Medium)
                .fontColor(this.filterState === (idx === 0 ? 'open' : 'closed') ? Color.White : this.T().textSecondary)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .backgroundColor(this.filterState === (idx === 0 ? 'open' : 'closed') ? this.T().accent : this.T().surfaceElevated)
                .borderRadius(8)
                .onClick(() => { this.filterState = idx === 0 ? 'open' : 'closed'; this.load(); })
            }, (_t: string, idx: number) => idx.toString())
          }.width('100%').padding({ left: 16, top: 8, bottom: 8 })

          if (this.loading) {
            LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
          } else if (this.getFiltered().length === 0) {
            Column({ space: 8 }) {
              Text('✉').fontSize(40)
              Text('暂无议题').fontSize(14).fontColor(this.T().textSecondary)
            }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(300)
          } else {
            ForEach(this.getFiltered(), (item: Object, idx: number) => {
              Column() {
                Row() {
                  Text(((item as Record<string, Object>).title as string) || '')
                    .fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary).layoutWeight(1).maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }.width('100%')
                Row() {
                  Text('#' + ((item as Record<string, Object>).number as number || 0))
                    .fontSize(13).fontColor(this.T().textTertiary)
                  if ((((item as Record<string, Object>).labels as Object[]) || []).length > 0) {
                    ForEach((((item as Record<string, Object>).labels as Object[]) || []).slice(0, 3), (l: Object, _li: number) => {
                      Text(((l as Record<string, Object>).name as string) || '')
                        .fontSize(11).fontColor(Color.White)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor('#' + (((l as Record<string, Object>).color as string) || '218BFE'))
                        .borderRadius(4)
                    }, (_l: Object, li: number) => 'l' + li)
                  }
                  Text(' 💬 ' + ((item as Record<string, Object>).comments as number || 0))
                    .fontSize(13).fontColor(this.T().textTertiary)
                  Blank()
                  Text(((item as Record<string, Object>).user as Record<string, string>).login || '')
                    .fontSize(13).fontColor(this.T().textSecondary)
                  Text(' · ' + (((item as Record<string, Object>).updated_at as string) || '').substring(0, 10))
                    .fontSize(12).fontColor(this.T().textTertiary)
                }.width('100%').margin({ top: 6 })
                if (idx < this.getFiltered().length - 1) {
                  Divider().color(this.T().border).width('100%').margin({ top: 12 })
                }
              }
              .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
              .onClick(() => {
                const num: number = (item as Record<string, Object>).number as number || 0;
                if (this.onOpenIssue) { this.onOpenIssue(this.owner, this.repoName, num); return; }
                const url: string = ((item as Record<string, Object>).html_url as string) || '';
                if (url && this.onOpenWebView) this.onOpenWebView(url);
              })
            }, (_item: Object, idx: number) => idx.toString())
          }
        }.width('100%').constraintSize({ minHeight: '100%' })
      }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
    }.width('100%').layoutWeight(1).backgroundColor(this.T().background)
  }
}
