import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { AUTH_LOGIN_KEY } from '../../common/constants/APIConstants';
import { RepoRepository } from '../../services/RepoRepository';
import { UserRepository } from '../../services/UserRepository';
import { SearchRepository } from '../../services/SearchRepository';
import { HttpClient } from '../../services/HttpClient';
import { RepoCard } from '../../common/components/RepoCard';
import type { Repository, OrgSummary } from '../../models/User';
import type { GitHubIssue, SearchIssuesResult } from '../../models/IssueModels';

/** 工作列表统一视图项（议题/PR/仓库/组织/星标共用一种渲染模型，避免动态取字段） */
class WorkListItem {
  title: string = '';
  subtitle: string = '';
  owner: string = '';
  repo: string = '';
  description: string = '';
  language: string = '';
  stars: number = 0;
  fullName: string = '';
  avatarChar: string = '?';
  isStarred: boolean = false;

  constructor(title: string, subtitle: string) {
    this.title = title;
    this.subtitle = subtitle;
  }
}

@Component
export struct WorkPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @StorageLink(AUTH_LOGIN_KEY) @Watch('onLoginChanged') isLoggedIn: boolean = false;
  @State items: WorkListItem[] = [];
  @State loading: boolean = true;
  @Prop _title: string = '';
  @Prop dataType: string = '';
  starredSet?: Set<string>;
  scroller?: Scroller;
  onOpenRepo?: (owner: string, repo: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  aboutToAppear(): void { if (this.isLoggedIn) this.loadData(); else { this.items = []; this.loading = false; } }
  onLoginChanged(): void { if (this.isLoggedIn) this.loadData(); else { this.items = []; this.loading = false; } }

  @State errorMsg: string = '';

  async loadData(): Promise<void> {
    this.loading = true; this.items = []; this.errorMsg = '';
    try {
      if (this.dataType === 'issues') {
        this.items = this.mapIssues(await SearchRepository.getIssues());
      } else if (this.dataType === 'pulls') {
        const res: SearchIssuesResult = await SearchRepository.getPullRequests('');
        this.items = this.mapIssues(res.items);
      } else if (this.dataType === 'repos') {
        this.items = this.mapRepos(await RepoRepository.getMyRepos());
      } else if (this.dataType === 'orgs') {
        this.items = this.mapOrgs(await UserRepository.getOrgs());
      } else if (this.dataType === 'starred') {
        this.items = this.mapRepos(await RepoRepository.getStarredRepos());
      }
    } catch (e) { this.items = []; this.errorMsg = HttpClient.formatError(e); }
    finally { this.loading = false; }
  }

  private mapIssues(list: GitHubIssue[]): WorkListItem[] {
    const out: WorkListItem[] = [];
    for (let i = 0; i < list.length; i++) {
      const it: GitHubIssue = list[i];
      const raw: string = it.repository_url ? it.repository_url : (it.html_url || '');
      out.push(new WorkListItem(it.title || '', raw.replace('https://api.github.com/repos/', '')));
    }
    return out;
  }

  private mapRepos(list: Repository[]): WorkListItem[] {
    const out: WorkListItem[] = [];
    for (let i = 0; i < list.length; i++) {
      const r: Repository = list[i];
      const owner: string = r.owner ? (r.owner.login || '') : '';
      const item: WorkListItem = new WorkListItem(r.full_name || r.name || '', '');
      item.owner = owner;
      item.repo = r.name || '';
      item.description = r.description || '';
      item.language = r.language || '';
      item.stars = r.stargazers_count || 0;
      item.fullName = r.full_name || '';
      item.avatarChar = (owner || '?').charAt(0);
      item.isStarred = this.starredSet ? this.starredSet.has(item.fullName) : false;
      out.push(item);
    }
    return out;
  }

  private mapOrgs(list: OrgSummary[]): WorkListItem[] {
    const out: WorkListItem[] = [];
    for (let i = 0; i < list.length; i++) {
      const o: OrgSummary = list[i];
      out.push(new WorkListItem(o.login || '', ''));
    }
    return out;
  }

  build() {
    Column() {
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
        Scroll(this.scroller) {
          Column() {
            Blank().height(88)
            if (this.dataType === 'repos') {
              Column({ space: 12 }) {
                ForEach(this.items, (item: WorkListItem, _idx: number) => {
                  Column() {
                    RepoCard({
                      avatarChar: item.avatarChar,
                      owner: item.owner,
                      repo: item.repo,
                      description: item.description,
                      language: item.language,
                      stars: item.stars,
                      isStarred: item.isStarred
                    })
                  }.width('100%')
                  .onClick(() => {
                    if (this.onOpenRepo && item.owner && item.repo) this.onOpenRepo(item.owner, item.repo);
                  })
                }, (_item: WorkListItem, idx: number) => idx.toString())
              }.width('100%').padding({ left: 16, right: 16 })
            } else {
              Column() {
                ForEach(this.items, (item: WorkListItem, _idx: number) => {
                  Column() {
                    Text(item.title || '')
                      .fontSize(16).fontColor(this.T().textPrimary).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                    if (item.subtitle !== '') {
                      Text(item.subtitle)
                        .fontSize(12).fontColor(this.T().textTertiary).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                  }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
                }, (_item: WorkListItem, idx: number) => idx.toString())
              }.width('100%')
            }
          }.width('100%')
        }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }).width('100%').height('100%').backgroundColor(this.T().background)
      }
    }.width('100%').height('100%').backgroundColor(this.T().background)
  }
}