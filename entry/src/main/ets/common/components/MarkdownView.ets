import {
  CJMarkdown,
  MarkdownConfiguration,
  MarkdownPlugin,
  MarkdownTheme
} from '@cangjie-tpc/markdown_hybrid'
import { BusinessError, pasteboard } from '@kit.BasicServicesKit'
import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/** '#RRGGBB' 或 '#AARRGGBB' → 0xAARRGGBB 整数颜色（CJMarkdown 主题色格式） */
function parseColor(hex: string): number {
  let c: string = hex.trim();
  if (c.startsWith('#')) c = c.substring(1);
  if (c.length === 3) {
    c = c.charAt(0) + c.charAt(0) + c.charAt(1) + c.charAt(1) + c.charAt(2) + c.charAt(2);
  }
  const v: number = parseInt(c, 16);
  if (isNaN(v)) return 0xFF000000;
  if (c.length === 6) return 0xFF000000 | v;
  return v;
}

/** 超长 Markdown 渲染上限（50万字符≈500KB，防极端输入；分块渐进渲染处理正常大文件） */
const MAX_MD_CHARS: number = 500000;
/** 每块渲染字符数（控制单帧 Text 节点量，避免 skia 排版冻帧） */
const CHUNK_CHARS: number = 12000;

/**
 * Markdown 渲染 — 基于 CJMarkdown 的分块渐进渲染。
 * 长内容按段落边界切成块，逐块渲染（"继续加载"追加），
 * 避免一次性创建成百上千 Text 组件导致主线程冻结。
 */
@Component
export struct MarkdownView {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop @Watch('onContentChange') content: string = '';
  @Prop maxLines: number = 999;
  @Prop fontSize: number = 14;
  onOpenRepo?: (owner: string, repo: string) => void;
  onOpenWebView?: (url: string) => void;

  private cachedConfig: MarkdownConfiguration | null = null;
  private cachedSignature: string = '';
  private cachedPlugin: MarkdownPlugin | null = null;
  @State chunks: string[] = [];
  @State renderedChunks: number = 1;

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

  aboutToAppear(): void {
    this.rebuildChunks();
  }

  onContentChange(): void {
    this.rebuildChunks();
  }

  private signature(): string {
    return this.themeMode + '|' + this.fontSize.toString();
  }

  private buildTheme(): MarkdownTheme {
    const d: boolean = this.themeMode === 'dark';
    const theme: MarkdownTheme = new MarkdownTheme();
    const host = this.getUIContext().getHostContext();
    if (host !== undefined && host !== null) theme.setContext(host);
    const fs: number = Math.max(this.fontSize, 10);
    const textColor: number = parseColor(this.T().textPrimary);
    const titleColor: number = parseColor(this.T().textPrimary);
    const linkColor: number = parseColor(this.T().accent);
    const codeBg: number = parseColor(d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated);
    const codeText: number = parseColor(this.T().textSecondary);
    const quoteBg: number = parseColor(d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated);
    const tableBg: number = parseColor(d ? DarkTheme.surface : LightTheme.surface);
    const tableHeaderBg: number = parseColor(d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated);
    const tableAltBg: number = parseColor(this.T().clickFeedback);
    const tableBorder: number = parseColor(this.T().border);

    theme.setIsMarkdownParserSync(false);
    theme.setIsCodeBlockParserSync(false);
    theme.setIsOnCopy(true);
    theme.setIsCodeFullScreen(false);

    theme.setParagraphTextSize(fs);
    theme.setParagraphTextLineHeight(Math.round(fs * 1.5));
    theme.setParagraphTextColor(textColor);

    theme.setHeadingTextColor(titleColor);
    theme.setHeadingTextSize1(22);
    theme.setHeadingTextSize2(18);
    theme.setHeadingTextSize3(16);
    theme.setHeadingTextSize4(15);
    theme.setHeadingTextSize5(14);
    theme.setHeadingTextSize6(14);

    theme.setLinkColor(linkColor);
    theme.setLinkSize(fs);
    theme.setIsLinkUnderlined(false);

    theme.setCodeTextColor(codeText);
    theme.setCodeBackgroundColor(codeBg);
    theme.setCodeTextSize(Math.max(fs - 1, 10));
    theme.setCodeTypeface('monospace');
    theme.setCodeBlockTextColor(codeText);
    theme.setCodeBlockBackgroundColor(codeBg);
    theme.setCodeBlockTextSize(Math.max(fs - 1, 10));
    theme.setCodeBlockLineHeight(Math.round((fs - 1) * 1.5));
    theme.setCodeBlockRadius(8);
    theme.setCodeBlockTypeface('monospace');

    theme.setBlockQuoteColor(linkColor);
    theme.setBlockQuoteBackGroupColor(quoteBg);
    theme.setBlockQuoteWidth(3);

    theme.setTableCellPadding(8);
    theme.setTableBorderColor(tableBorder);
    theme.setTableBorderWidth(1);
    theme.setTableOddRowBackgroundColor(tableBg);
    theme.setTableEvenRowBackgroundColor(tableAltBg);
    theme.setTableHeaderRowBackgroundColor(tableHeaderBg);
    theme.setTableContentTextColor(textColor);
    theme.setTableTitleTextColor(textColor);

    theme.setIsDark(d);
    return theme;
  }

  private buildConfig(): MarkdownConfiguration {
    const config: MarkdownConfiguration = new MarkdownConfiguration();
    config.setMarkdownTheme(this.buildTheme());
    config.setLinkCallback((url: string): void => { this.handleLink(url); });
    config.setImageCallback((src: string): void => { if (this.onOpenWebView) this.onOpenWebView(src); });
    config.setTextCopyCallback((text: string): void => { this.copyText(text); });
    config.setCodeCopyCallback((code: string): void => { this.copyText(code); });
    return config;
  }

  private getConfig(): MarkdownConfiguration {
    const sig: string = this.signature();
    if (this.cachedConfig !== null && this.cachedSignature === sig) return this.cachedConfig;
    const c: MarkdownConfiguration = this.buildConfig();
    this.cachedConfig = c;
    this.cachedSignature = sig;
    return c;
  }

  private getPlugin(): MarkdownPlugin {
    if (this.cachedPlugin !== null) return this.cachedPlugin;
    const p: MarkdownPlugin = new MarkdownPlugin();
    p.setIsTablePlugin(true);
    p.setIsTaskListPlugin(true);
    p.setIsStrikethroughPlugin(true);
    const noRegs: string[] = [];
    p.setIsLinkifyPlugin(true, noRegs);
    this.cachedPlugin = p;
    return p;
  }

  private copyText(text: string): void {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    pasteboard.getSystemPasteboard().setData(data)
      .then((): void => { })
      .catch((_e: BusinessError): void => { });
  }

  private handleLink(url: string): void {
    const m: RegExpMatchArray | null = url.match(/github\.com\/([^/]+)\/([^/?\s#]+)/);
    if (m && m[1] && m[2] && this.onOpenRepo) { this.onOpenRepo(m[1], m[2]); return; }
    if (this.onOpenWebView) this.onOpenWebView(url);
  }

  /** 超长内容截断（防极端输入） */
  private displayed(): string {
    return this.content.length > MAX_MD_CHARS ? this.content.substring(0, MAX_MD_CHARS) : this.content;
  }

  private isTruncated(): boolean {
    return this.content.length > MAX_MD_CHARS;
  }

  /** 按段落边界切成块，控制单帧渲染的节点量 */
  private splitChunks(md: string): string[] {
    const result: string[] = [];
    let start: number = 0;
    const len: number = md.length;
    while (start < len) {
      let end: number = start + CHUNK_CHARS;
      if (end >= len) { result.push(md.substring(start)); break; }
      let cut: number = md.lastIndexOf('\n\n', end);
      if (cut <= start) { cut = md.lastIndexOf('\n', end); }
      if (cut > start) { end = cut; }
      result.push(md.substring(start, end));
      start = end;
    }
    return result;
  }

  private rebuildChunks(): void {
    this.chunks = this.splitChunks(this.displayed());
    this.renderedChunks = 1;
  }

  build() {
    Column() {
      ForEach(this.chunks.slice(0, this.renderedChunks), (chunk: string, i: number) => {
        CJMarkdown({
          content: chunk,
          isInputEnded: true,
          incrementalAnalysis: false,
          useCangjieComponent: true,
          config: this.getConfig(),
          plugin: this.getPlugin()
        })
      }, (chunk: string, i: number) => 'c' + i)

      // 分块渐进：继续加载更多
      if (this.renderedChunks < this.chunks.length) {
        Column() {
          Text('继续加载更多 (已显示 ' + this.renderedChunks.toString() + '/' + this.chunks.length.toString() + ' 段)')
            .fontSize(13)
            .fontColor(this.T().accent)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
            .borderRadius(8)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 12, bottom: 12 })
        .onClick(() => { this.renderedChunks += 1; })
      } else if (this.isTruncated()) {
        Text('内容过长，已截断显示前 ' + MAX_MD_CHARS.toString() + ' 字，可在浏览器查看完整版')
          .fontSize(12).fontColor(this.T().textTertiary)
          .width('100%').padding({ top: 8, bottom: 4 })
      }
    }.width('100%')
  }
}
