import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../../common/constants/ThemeConstants';
import { RateLimitService } from '../../common/utils/RateLimitService';
import type { RateLimitInfo } from '../../common/models/RateLimitInfo';
import { isRateLimitExhausted, formatTimeUntilReset } from '../../common/models/RateLimitInfo';

/**
 * 速率限制详情页 — 显示 GitHub API 请求配额使用情况
 */
@Component
export struct RateLimitPage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @State rateLimit: RateLimitInfo | null = null;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }

  aboutToAppear(): void {
    this.rateLimit = RateLimitService.getInfo();
    RateLimitService.onChange((info: RateLimitInfo) => { this.rateLimit = info; });
  }

  private get usedCount(): number {
    if (!this.rateLimit) return 0;
    return this.rateLimit.limit - this.rateLimit.remaining;
  }

  private get progressPercent(): number {
    if (!this.rateLimit || this.rateLimit.limit === 0) return 0;
    return Math.round((this.usedCount / this.rateLimit.limit) * 100);
  }

  private get statusText(): string {
    if (!this.rateLimit) return '暂无数据';
    if (isRateLimitExhausted(this.rateLimit)) return '已耗尽';
    if (this.progressPercent >= 80) return '接近上限';
    return '正常';
  }

  private get statusColor(): string {
    if (!this.rateLimit) return this.T().textTertiary;
    if (isRateLimitExhausted(this.rateLimit)) return '#DA3633';
    if (this.progressPercent >= 80) return '#FF9529';
    return this.T().issueGreen;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Blank().height(88)

        if (!this.rateLimit) {
          // 无数据
          Column({ space: 12 }) {
            Text('📊').fontSize(48).fontColor(this.T().textTertiary)
            Text('暂无速率限制数据').fontSize(16).fontColor(this.T().textSecondary)
            Text('执行一次 API 请求后自动获取').fontSize(13).fontColor(this.T().textTertiary)
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height(300)
        } else {
          // 状态卡片
          Column({ space: 12 }) {
            // 状态标签
            Row() {
              Text(this.statusText).fontSize(14).fontWeight(FontWeight.Medium)
                .fontColor(this.T().textPrimary)
              Blank()
              Text(this.rateLimit.resource).fontSize(12).fontColor(this.T().textTertiary)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor(this.T().surfaceElevated).borderRadius(4)
            }.width('100%')

            // 进度条
            Column({ space: 4 }) {
              Row() {
                Text('已用 ' + this.usedCount).fontSize(14).fontColor(this.T().textPrimary)
                Blank()
                Text('共 ' + this.rateLimit.limit).fontSize(14).fontColor(this.T().textTertiary)
              }.width('100%')
              Row() {
                Column()
                  .width((this.progressPercent / 100 * 100).toString() + '%')
                  .height(8).borderRadius(4)
                  .backgroundColor(this.statusColor)
                Blank()
              }.width('100%').height(8).backgroundColor(this.T().surfaceElevated).borderRadius(4)
            }.width('100%')

            // 详情
            Column({ space: 0 }) {
              this.detailRow('配额', this.rateLimit.limit.toString())
              Divider().color(this.T().border).width('100%')
              this.detailRow('剩余', this.rateLimit.remaining.toString())
              Divider().color(this.T().border).width('100%')
              this.detailRow('已用', this.usedCount.toString() + ' (' + this.progressPercent + '%)')
              Divider().color(this.T().border).width('100%')
              this.detailRow('重置时间', formatTimeUntilReset(this.rateLimit))
            }.width('100%').padding(16)
              .backgroundColor(this.T().surface).borderRadius(12)

            // 说明
            Column({ space: 8 }) {
              Text('💡 说明').fontSize(14).fontWeight(FontWeight.Medium).fontColor(this.T().textPrimary)
              Text('• 已登录用户：5000 次/小时（按 Token 独立计算）').fontSize(12).fontColor(this.T().textSecondary)
              Text('• 未登录用户：60 次/小时（按 IP 共享）').fontSize(12).fontColor(this.T().textSecondary)
              Text('• 数据来源：GitHub API 响应头 X-RateLimit-*').fontSize(12).fontColor(this.T().textSecondary)
            }.width('100%').padding(16)
              .backgroundColor(this.T().surface).borderRadius(12)
          }.width('100%')
        }

        Blank().height(80)
      }.width('100%').constraintSize({ minHeight: '100%' })
    }.scrollBar(BarState.Off).width('100%').height('100%').backgroundColor(this.T().background)
  }

  @Builder detailRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(this.T().textSecondary).width(80)
      Text(value).fontSize(14).fontColor(this.T().textPrimary).layoutWeight(1)
    }.width('100%').padding({ top: 12, bottom: 12 })
  }
}
