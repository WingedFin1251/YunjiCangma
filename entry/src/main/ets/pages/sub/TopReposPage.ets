import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RepoRepository } from '../../services/RepoRepository';
import { RepoCard } from '../../common/components/RepoCard';
import type { Repository, SearchResult } from '../../models/User';

/**
 * 总星标榜 — 按累计星标排序的热门仓库列表。
 */
@Component
export struct TopReposPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State repos: Repository[] = [];
  @State loading: boolean = true;
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

  aboutToAppear(): void { this.load(); }

  async load(): Promise<void> {
    this.loading = true;
    try {
      const result: SearchResult = await RepoRepository.getTopStarredRepos();
      this.repos = result.items || [];
    } catch (e) { this.repos = []; }
    finally { this.loading = false; }
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress().width(32).height(32).color(this.T().accent)
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
      } else if (this.repos.length === 0) {
        Column({ space: 8 }) {
          Text('✉').fontSize(40)
          Text('暂无数据').fontSize(14).fontColor(this.T().textSecondary)
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.repos, (repo: Repository, idx: number) => {
            ListItem() {
              Column() {
                RepoCard({
                  avatarChar: repo.owner.login.charAt(0),
                  owner: repo.owner.login,
                  repo: repo.name,
                  description: repo.description || '',
                  language: repo.language || '',
                  stars: repo.stargazers_count,
                  isStarred: false
                })
              }
              .width('100%')
              .onClick(() => { if (this.onOpenRepo) this.onOpenRepo(repo.owner.login, repo.name); })
            }
          }, (repo: Repository) => repo.id.toString())
        }
        .scrollBar(BarState.Off).width('100%').layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }
    }.width('100%').height('100%').backgroundColor(this.T().background)
  }
}
