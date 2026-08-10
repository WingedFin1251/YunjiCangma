import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { AuthService } from '../../services/AuthService';
import { RepoRepository } from '../../services/RepoRepository';

/**
 * 新建议题 — 填写仓库 + 标题 + 内容，POST 创建。
 */
@Component
export struct NewIssuePage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State owner: string = '';
  @State repoName: string = '';
  @State title: string = '';
  @State body: string = '';
  @State submitting: boolean = false;
  @State errorMsg: string = '';
  onCreated?: () => void;
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

  private canSubmit(): boolean {
    return this.owner.trim() !== '' && this.repoName.trim() !== '' && this.title.trim() !== '';
  }

  private submit(): void {
    if (!this.canSubmit() || this.submitting) return;
    if (AuthService.getToken() === '') {
      this.errorMsg = '请先登录后再创建议题';
      return;
    }
    this.submitting = true;
    this.errorMsg = '';
    RepoRepository.createIssue(this.owner.trim(), this.repoName.trim(), this.title.trim(), this.body)
      .then(() => {
        this.getUIContext().getPromptAction().showToast({ message: '议题已创建' });
        if (this.onCreated) this.onCreated();
      })
      .catch(() => {
        this.submitting = false;
        this.errorMsg = '创建失败，请检查仓库名与权限';
      });
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          // 沉浸标题栏占位：初始避开标题栏，滚动时滑入磨砂下
          Blank(100)
          TextInput({ placeholder: '仓库所有者（如 octocat）', text: this.owner })
            .fontSize(15).fontColor(this.T().textPrimary).placeholderColor(this.T().textTertiary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(42).padding({ left: 12 })
            .onChange((v: string) => { this.owner = v; })

          TextInput({ placeholder: '仓库名（如 Hello-World）', text: this.repoName })
            .fontSize(15).fontColor(this.T().textPrimary).placeholderColor(this.T().textTertiary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(42).padding({ left: 12 })
            .onChange((v: string) => { this.repoName = v; })

          TextInput({ placeholder: '议题标题（必填）', text: this.title })
            .fontSize(15).fontColor(this.T().textPrimary).placeholderColor(this.T().textTertiary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(44).padding({ left: 12 })
            .onChange((v: string) => { this.title = v; })

          TextArea({ placeholder: '议题内容（可选）', text: this.body })
            .fontSize(14).fontColor(this.T().textPrimary).placeholderColor(this.T().textTertiary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(8).height(180).padding(12)
            .onChange((v: string) => { this.body = v; })

          if (this.errorMsg !== '') {
            Text(this.errorMsg).fontSize(13).fontColor(this.T().issueGreen).width('100%')
          }

          Button('创建议题')
            .fontSize(15).fontWeight(FontWeight.Medium).fontColor(Color.White)
            .backgroundColor(this.canSubmit() && !this.submitting ? this.T().accent : this.T().textTertiary)
            .borderRadius(8).height(44).width('100%')
            .enabled(this.canSubmit() && !this.submitting)
            .onClick(() => { this.submit(); })
        }
        .width('100%').padding(16)
      }.scrollBar(BarState.Off).width('100%').height('100%')
    }.width('100%').height('100%').backgroundColor(this.T().background).padding({ top: 8 })
  }
}
