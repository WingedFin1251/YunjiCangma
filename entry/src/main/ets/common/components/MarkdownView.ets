import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/** Markdown 行类型 */
class MdLine {
  type: string = '';
  text: string = '';
  level: number = 0;
  constructor(type: string, text: string, level: number) {
    this.type = type; this.text = text; this.level = level;
  }
}

/** 解析 Markdown → 结构化行 */
function parseMd(md: string): MdLine[] {
  const lines: MdLine[] = [];
  const raw: string[] = md.split('\n');
  let inCode: boolean = false;
  let codeLines: string[] = [];

  for (let i = 0; i < raw.length; i++) {
    const line: string = raw[i];

    // 代码块开始/结束 ```
    if (line.trim().startsWith('```')) {
      if (inCode) {
        if (codeLines.length > 0) lines.push(new MdLine('code', codeLines.join('\n'), 0));
        codeLines = [];
        inCode = false;
      } else { inCode = true; }
      continue;
    }
    if (inCode) { codeLines.push(line); continue; }

    // 空行
    if (!line.trim()) continue;

    // 标题 #
    const hMatch: RegExpMatchArray | null = line.match(/^(#{1,6})\s+(.+)/);
    if (hMatch) { lines.push(new MdLine('h', hMatch[2], hMatch[1].length)); continue; }

    // 水平线 ---
    if (/^[-*_]{3,}\s*$/.test(line.trim())) { lines.push(new MdLine('hr', '', 0)); continue; }

    // 无序列表 - * +
    const ulMatch: RegExpMatchArray | null = line.match(/^[-*+]\s+(.+)/);
    if (ulMatch) { lines.push(new MdLine('ul', ulMatch[1], 0)); continue; }

    // 有序列表 1.
    const olMatch: RegExpMatchArray | null = line.match(/^\d+\.\s+(.+)/);
    if (olMatch) { lines.push(new MdLine('ol', olMatch[1], 0)); continue; }

    // GitHub 告示块 > [!NOTE] / > [!WARNING] 等
    const alertMatch: RegExpMatchArray | null = line.match(/^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$/i);
    if (alertMatch) { lines.push(new MdLine('alert', alertMatch[1].toUpperCase(), 0)); continue; }

    // 引用 >
    const qMatch: RegExpMatchArray | null = line.match(/^>\s*(.*)/);
    if (qMatch) { lines.push(new MdLine('quote', qMatch[1], 0)); continue; }

    // 普通段落
    lines.push(new MdLine('p', line, 0));
  }
  if (inCode && codeLines.length > 0) lines.push(new MdLine('code', codeLines.join('\n'), 0));
  return lines;
}

class LinkInfo { placeholder: string = ''; text: string = ''; url: string = '';
  constructor(p: string, t: string, u: string) { this.placeholder = p; this.text = t; this.url = u; }
}
class InlineSpan { text: string = ''; bold: boolean = false; italic: boolean = false; code: boolean = false; strike: boolean = false; link: string = '';
  constructor(t: string, b: boolean, i: boolean, c: boolean, l: string, s: boolean) { this.text = t; this.bold = b; this.italic = i; this.code = c; this.link = l; this.strike = s; }
}

/** 渲染内联 Markdown 文本 → 带格式的 Span 数组 */

function parseInline(text: string): InlineSpan[] {
  const spans: InlineSpan[] = [];
  const linkRe: RegExp = /\[([^\]]+)\]\(([^)]+)\)/g;
  const boldRe: RegExp = /\*\*(.+?)\*\*/g;
  const italicRe: RegExp = /\*(.+?)\*/g;
  const codeRe: RegExp = /`([^`]+)`/g;

  // 先处理链接
  let processed: string = text;
  const links: LinkInfo[] = [];
  let li: number = 0;
  processed = processed.replace(linkRe, (_m: string, t: string, u: string) => {
    const ph: string = '\x00L' + (li++) + '\x00';
    links.push(new LinkInfo(ph, t, u));
    return ph;
  });

  // 逐字符扫描处理粗体/斜体/代码
  let i: number = 0;
  let current: string = '';
  while (i < processed.length) {
    const ch: string = processed.charAt(i);

    // 粗体 **
    if (ch === '*' && processed.charAt(i + 1) === '*') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('**', i + 2);
      if (end > i) {
        spans.push(new InlineSpan(processed.substring(i + 2, end), true, false, false, '', false));
        i = end + 2;
      } else { current += ch; i++; }
      continue;
    }

    // 斜体 *
    if (ch === '*' && processed.charAt(i + 1) !== '*') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('*', i + 1);
      if (end > i) {
        spans.push(new InlineSpan(processed.substring(i + 1, end), false, true, false, '', false));
        i = end + 1;
      } else { current += ch; i++; }
      continue;
    }

    // 内联代码 `
    if (ch === '`') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('`', i + 1);
      if (end > i) {
        spans.push(new InlineSpan(processed.substring(i + 1, end), false, false, true, '', false));
        i = end + 1;
      } else { current += ch; i++; }
      continue;
    }

    // 粗体 __
    if (ch === '_' && processed.charAt(i + 1) === '_') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('__', i + 2);
      if (end > i) { spans.push(new InlineSpan(processed.substring(i + 2, end), true, false, false, '', false)); i = end + 2; }
      else { current += ch; i++; }
      continue;
    }
    // 斜体 _
    if (ch === '_' && processed.charAt(i + 1) !== '_') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('_', i + 1);
      if (end > i) { spans.push(new InlineSpan(processed.substring(i + 1, end), false, true, false, '', false)); i = end + 1; }
      else { current += ch; i++; }
      continue;
    }
    // 删除线 ~~
    if (ch === '~' && processed.charAt(i + 1) === '~') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = processed.indexOf('~~', i + 2);
      if (end > i) { spans.push(new InlineSpan(processed.substring(i + 2, end), false, false, false, '', false)); i = end + 2; }
      else { current += ch; i++; }
      continue;
    }

    // 链接占位符
    if (ch === '\x00') {
      const phMatch: RegExpMatchArray | null = processed.substring(i).match(/^\x00L(\d+)\x00/);
      if (phMatch) {
        if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
        const idx: number = parseInt(phMatch[1]);
        if (idx < links.length) {
          spans.push(new InlineSpan(links[idx].text, false, false, false, links[idx].url, false));
        }
        i += phMatch[0].length;
        continue;
      }
    }

    current += ch;
    i++;
  }
  if (current) spans.push(new InlineSpan(current, false, false, false, '', false));
  return spans;
}

@Component
export struct MarkdownView {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop content: string = '';
  @Prop maxLines: number = 999;
  @Prop fontSize: number = 14;
  onOpenRepo?: (owner: string, repo: string) => void;
  onOpenWebView?: (url: string) => void;
  private T(): ThemeColors { const d = this.themeMode === 'dark'; return { background: d ? DarkTheme.background : LightTheme.background, surface: d ? DarkTheme.surface : LightTheme.surface, surfaceElevated: d ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated, border: d ? DarkTheme.border : LightTheme.border, textPrimary: d ? DarkTheme.textPrimary : LightTheme.textPrimary, textSecondary: d ? DarkTheme.textSecondary : LightTheme.textSecondary, textTertiary: d ? DarkTheme.textTertiary : LightTheme.textTertiary, accent: d ? DarkTheme.accent : LightTheme.accent, issueGreen: d ? DarkTheme.issueGreen : LightTheme.issueGreen, prBlue: d ? DarkTheme.prBlue : LightTheme.prBlue, discussionPurple: d ? DarkTheme.discussionPurple : LightTheme.discussionPurple, orgOrange: d ? DarkTheme.orgOrange : LightTheme.orgOrange, starYellow: d ? DarkTheme.starYellow : LightTheme.starYellow, clickFeedback: d ? DarkTheme.clickFeedback : LightTheme.clickFeedback }; }
  private alertIcon(t: string): string { if (t === 'NOTE') return 'ℹ️'; if (t === 'TIP') return '💡'; if (t === 'IMPORTANT') return '❗'; if (t === 'WARNING') return '⚠️'; if (t === 'CAUTION') return '🔥'; return '📌'; }
  private alertColor(t: string): string { if (t === 'NOTE') return '#58A6FF'; if (t === 'TIP') return '#3FB950'; if (t === 'IMPORTANT') return '#9C6ADE'; if (t === 'WARNING') return '#D29922'; if (t === 'CAUTION') return '#F85149'; return '#58A6FF'; }

  build() {
    Column() {
      ForEach(parseMd(this.content), (line: MdLine, idx: number) => {
          if (line.type === 'h') {
            Text(line.text)
              .fontSize(line.level === 1 ? 22 : (line.level === 2 ? 18 : 16))
              .fontWeight(line.level <= 2 ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.T().textPrimary)
              .width('100%').margin({ top: idx > 0 ? 14 : 0, bottom: 4 }).lineHeight(28)
          } else if (line.type === 'hr') {
            Divider().color(this.T().border).width('100%').margin({ top: 10, bottom: 10 })
          } else if (line.type === 'code') {
            Text(line.text)
              .fontSize(this.fontSize - 1).fontColor(this.T().textSecondary)
              .backgroundColor(this.T().surfaceElevated).borderRadius(6)
              .width('100%').padding(12).margin({ top: 6, bottom: 6 })
              .fontFamily('monospace')
          } else if (line.type === 'alert') {
            Row() {
              Text((this.alertIcon(line.text) || '📌') + ' ' + line.text).fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.alertColor(line.text) || '#58A6FF')
            }.width('100%').padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.themeMode === 'dark' ? '#161B22' : '#F6F8FA').borderRadius(6)
              .border({ width: 1, color: this.alertColor(line.text) || '#30363D', style: BorderStyle.Solid }).margin({ top: 6, bottom: 2 })
          } else if (line.type === 'quote') {
            Row() {
              Text('│').fontSize(14).fontColor(this.T().border).margin({ right: 8 })
              this.inlineText(line.text)
            }
            .width('100%').padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(this.T().surfaceElevated).borderRadius(6).margin({ top: 4, bottom: 4 })
          } else if (line.type === 'ul' || line.type === 'ol') {
            Row() {
              Text(line.type === 'ul' ? '•' : (idx + 1).toString() + '.')
                .fontSize(this.fontSize).fontColor(this.T().textTertiary).width(20)
              this.inlineText(line.text)
            }.width('100%').margin({ top: 2, bottom: 2 })
          } else {
            this.inlineText(line.text)
          }
        }, (line: MdLine, idx: number) => idx.toString())
      }.width('100%')
  }

  @Builder
  inlineText(text: string) {
    Row() {
      ForEach(parseInline(text), (s: InlineSpan, si: number) => {
        if (s.link) {
          Text(s.text)
            .fontSize(this.fontSize).lineHeight(22)
            .fontColor(this.T().accent).fontWeight(s.bold ? FontWeight.Bold : FontWeight.Regular)
            .fontStyle(s.italic ? FontStyle.Italic : FontStyle.Normal).fontFamily(s.code ? 'monospace' : '')
            .decoration({ type: s.strike ? TextDecorationType.LineThrough : TextDecorationType.Underline })
            .onClick(() => { this.handleLink(s.link); })
        } else {
          Text(s.text)
            .fontSize(this.fontSize).lineHeight(22)
            .fontColor(s.code ? this.T().textSecondary : this.T().textSecondary)
            .fontWeight(s.bold ? FontWeight.Bold : FontWeight.Regular)
            .fontStyle(s.italic ? FontStyle.Italic : FontStyle.Normal).fontFamily(s.code ? 'monospace' : '')
            .decoration({ type: s.strike ? TextDecorationType.LineThrough : TextDecorationType.None })
        }
      }, (s: InlineSpan, si: number) => 's' + si)
    }.width('100%')
  }

  private handleLink(url: string): void {
    const m: RegExpMatchArray | null = url.match(/github\.com\/([^/]+)\/([^/?\s#]+)/);
    if (m && m[1] && m[2] && this.onOpenRepo) { this.onOpenRepo(m[1], m[2]); return; }
    if (this.onOpenWebView) this.onOpenWebView(url);
  }
}
