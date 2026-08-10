import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import { RepoRepository } from '../../services/RepoRepository';
import { UserRepository } from '../../services/UserRepository';
import { SearchRepository } from '../../services/SearchRepository';
import { RepoCard } from '../../common/components/RepoCard';

@Component
export struct WorkPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State items: Object[] = [];
  @State loading: boolean = true;
  @Prop _title: string = '';
  @Prop dataType: string = '';
  onOpenRepo?: (owner: string, repo: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  aboutToAppear(): void { if (this.isLoggedIn) this.loadData(); else { this.items = []; this.loading = false; } }
  onLoginChanged(): void { if (this.isLoggedIn) this.loadData(); else { this.items = []; this.loading = false; } }

  async loadData(): Promise<void> {
    this.loading = true; this.items = [];
    try {
      if (this.dataType === 'issues') this.items = await SearchRepository.getIssues();
      else if (this.dataType === 'pulls') this.items = await SearchRepository.getPullRequests('');
      else if (this.dataType === 'repos') this.items = await RepoRepository.getMyRepos();
      else if (this.dataType === 'orgs') this.items = await UserRepository.getOrgs();
      else if (this.dataType === 'starred') this.items = await RepoRepository.getStarredRepos();
    } catch (e) { this.items = []; }
    finally { this.loading = false; }
  }

  build() {
    Column() {
      // 沉浸标题栏占位：初始避开标题栏
      Blank(100)
      Text('').fontSize(0).fontColor(this.themeMode === 'dark' ? this.T().textPrimary : this.T().textPrimary)
      if (!this.isLoggedIn) {
        Column({ space: 12 }) {
          Text('🔐').fontSize(40)
          Text('请先登录').fontSize(18).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
          Text('登录 GitHub 账号后即可查看').fontSize(14).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .width('100%').height('100%').backgroundColor(this.T().background)
      } else if (this.loading) {
        LoadingProgress().width(32).height(32).color(this.T().accent).margin({ top: 80 })
      } else if (this.items.length === 0) {
        Column({ space: 8 }) {
          Text('✉').fontSize(40)
          Text('暂无内容').fontSize(14).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .width('100%').height('100%').backgroundColor(this.T().background)
      } else {
        Scroll() {
          if (this.dataType === 'repos') {
            Column({ space: 12 }) {
              ForEach(this.items, (item: Object, idx: number) => {
                Column() {
      Text('').fontSize(0).fontColor(this.themeMode === 'dark' ? this.T().textPrimary : this.T().textPrimary)
                  RepoCard({
                    avatarChar: (((item as Record<string, Object>).owner as Record<string, string>).login || '?').charAt(0),
                    owner: ((item as Record<string, Object>).owner as Record<string, string>).login || '',
                    repo: ((item as Record<string, Object>).name as string) || '',
                    description: ((item as Record<string, Object>).description as string) || '',
                    language: ((item as Record<string, Object>).language as string) || '',
                    stars: (item as Record<string, Object>).stargazers_count as number || 0,
                    isStarred: true
                  })
                }.width('100%')
                .onClick(() => {
                  const it = item as Record<string, Object>;
                  const rOwner: string = ((it.owner as Record<string, string>).login as string) || '';
                  const rName: string = (it.name as string) || '';
                  if (this.onOpenRepo && rOwner && rName) this.onOpenRepo(rOwner, rName);
                })
              }, (item: Object, idx: number) => idx.toString())
            }.width('100%').padding({ left: 16, right: 16 })
          } else {
            Column() {
      Text('').fontSize(0).fontColor(this.themeMode === 'dark' ? this.T().textPrimary : this.T().textPrimary)
              ForEach(this.items, (item: Object, idx: number) => {
                Column() {
      Text('').fontSize(0).fontColor(this.themeMode === 'dark' ? this.T().textPrimary : this.T().textPrimary)
                  Text(((item as Record<string, Object>).title as string) || ((item as Record<string, Object>).login as string) || ((item as Record<string, Object>).full_name as string) || ((item as Record<string, Object>).name as string) || '')
                    .fontSize(16).fontColor(this.T().textPrimary).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  if ((item as Record<string, Object>).repository_url || (item as Record<string, Object>).html_url) {
                    Text((((item as Record<string, Object>).repository_url as string) || ((item as Record<string, Object>).html_url as string) || '').replace('https://api.github.com/repos/', ''))
                      .fontSize(12).fontColor(this.T().textTertiary).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
              }, (item: Object, idx: number) => idx.toString())
            }.width('100%')
          }
        }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
      }
    }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
  }
}
