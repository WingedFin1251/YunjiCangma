import { DarkTheme, LightTheme, THEME_KEY, ThemeColors } from '../constants/ThemeConstants';

/** 块级行 */
class MdLine {
  type: string = '';
  text: string = '';
  level: number = 0;
  indent: number = 0;
  checked: boolean = false;
  rows: string[][] = [];
  constructor(type: string, text: string, level: number, indent: number, checked: boolean, rows: string[][]) {
    this.type = type;
    this.text = text;
    this.level = level;
    this.indent = indent;
    this.checked = checked;
    this.rows = rows;
  }
}

/** 内联格式 span */
class InlineSpan {
  text: string = '';
  bold: boolean = false;
  italic: boolean = false;
  code: boolean = false;
  strike: boolean = false;
  link: string = '';
  constructor(t: string, b: boolean, i: boolean, c: boolean, l: string, s: boolean) {
    this.text = t; this.bold = b; this.italic = i; this.code = c; this.link = l; this.strike = s;
  }
}

class LinkInfo {
  placeholder: string = '';
  text: string = '';
  url: string = '';
  constructor(p: string, t: string, u: string) { this.placeholder = p; this.text = t; this.url = u; }
}

/** 内联段：text 组（span 数组）或 img（url + alt） */
class MdInline {
  type: string = '';
  spans: InlineSpan[] = [];
  imgUrl: string = '';
  imgAlt: string = '';
  constructor(type: string, spans: InlineSpan[], imgUrl: string, imgAlt: string) {
    this.type = type; this.spans = spans; this.imgUrl = imgUrl; this.imgAlt = imgAlt;
  }
}

// ---------- 解析缓存 ----------
const mdCache: Map<string, MdLine[]> = new Map();
const inlineCache: Map<string, MdInline[]> = new Map();
const CACHE_CAP: number = 100;
function cachePut<T>(cache: Map<string, T>, key: string, val: T): void {
  if (cache.size >= CACHE_CAP) { cache.clear(); }
  cache.set(key, val);
}

// ---------- 块级解析 ----------
function parseMd(md: string): MdLine[] {
  const cached: MdLine[] | undefined = mdCache.get(md);
  if (cached) return cached;
  const lines: MdLine[] = [];
  const raw: string[] = md.split('\n');
  let inCode: boolean = false;
  let codeLines: string[] = [];
  let olCounter: number = 0;

  let i: number = 0;
  while (i < raw.length) {
    const line: string = raw[i];

    // 代码块 ```
    if (line.trim().startsWith('```')) {
      if (inCode) {
        if (codeLines.length > 0) lines.push(new MdLine('code', codeLines.join('\n'), 0, 0, false, []));
        codeLines = [];
        inCode = false;
      } else { inCode = true; }
      i++;
      continue;
    }
    if (inCode) { codeLines.push(line); i++; continue; }
    if (!line.trim()) { i++; continue; }

    // 表格：本行以 | 开头且下一非空行为分隔符
    if (line.trim().startsWith('|') && isTableSep(raw[i + 1] || '')) {
      const rows: string[][] = [];
      while (i < raw.length && raw[i].trim().startsWith('|')) {
        const rowStr: string = raw[i].trim();
        if (!isTableSep(rowStr)) rows.push(splitRow(rowStr));
        i++;
      }
      if (rows.length > 0) lines.push(new MdLine('table', '', 0, 0, false, rows));
      continue;
    }

    // 标题
    const hMatch: RegExpMatchArray | null = line.match(/^(#{1,6})\s+(.+)/);
    if (hMatch) { lines.push(new MdLine('h', hMatch[2], hMatch[1].length, 0, false, [])); i++; continue; }

    // 水平线
    if (/^[-*_]{3,}\s*$/.test(line.trim())) { lines.push(new MdLine('hr', '', 0, 0, false, [])); i++; continue; }

    // 任务列表 - [x]
    const taskMatch: RegExpMatchArray | null = line.match(/^(\s*)[-*+]\s+\[([ xX])\]\s+(.+)/);
    if (taskMatch) {
      lines.push(new MdLine('task', taskMatch[3], 0, taskMatch[1].length, taskMatch[2] === 'x' || taskMatch[2] === 'X', []));
      i++;
      continue;
    }

    // 无序列表（带缩进）
    const ulMatch: RegExpMatchArray | null = line.match(/^(\s*)[-*+]\s+(.+)/);
    if (ulMatch) { lines.push(new MdLine('ul', ulMatch[2], 0, ulMatch[1].length, false, [])); i++; continue; }

    // 有序列表（带缩进 + 连续编号）
    const olMatch: RegExpMatchArray | null = line.match(/^(\s*)\d+\.\s+(.+)/);
    if (olMatch) {
      olCounter++;
      lines.push(new MdLine('ol', olMatch[2], olCounter, olMatch[1].length, false, []));
      i++;
      continue;
    }
    olCounter = 0;

    // 告示块
    const alertMatch: RegExpMatchArray | null = line.match(/^>\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*$/i);
    if (alertMatch) { lines.push(new MdLine('alert', alertMatch[1].toUpperCase(), 0, 0, false, [])); i++; continue; }

    // 引用
    const qMatch: RegExpMatchArray | null = line.match(/^>\s*(.*)/);
    if (qMatch) { lines.push(new MdLine('quote', qMatch[1], 0, 0, false, [])); i++; continue; }

    // 普通段落（可能含行内图片）
    lines.push(new MdLine('p', line, 0, 0, false, []));
    i++;
  }
  if (inCode && codeLines.length > 0) lines.push(new MdLine('code', codeLines.join('\n'), 0, 0, false, []));
  cachePut(mdCache, md, lines);
  return lines;
}

function isTableSep(s: string): boolean {
  const t: string = s.trim();
  if (!t.startsWith('|')) return false;
  let body: string = t;
  if (body.startsWith('|')) body = body.substring(1);
  if (body.endsWith('|')) body = body.substring(0, body.length - 1);
  if (!body.trim()) return false;
  return body.indexOf('-') >= 0 && /^[\s:|-]+$/.test(body);
}

function splitRow(s: string): string[] {
  let t: string = s.trim();
  if (t.startsWith('|')) t = t.substring(1);
  if (t.endsWith('|')) t = t.substring(0, t.length - 1);
  const parts: string[] = t.split('|');
  const cells: string[] = [];
  for (let k = 0; k < parts.length; k++) { cells.push(parts[k].trim()); }
  return cells;
}

// ---------- 内联解析 ----------
function parseSpans(text: string): InlineSpan[] {
  const spans: InlineSpan[] = [];
  const linkRe: RegExp = /\[([^\]]+)\]\(([^)]+)\)/g;
  const links: LinkInfo[] = [];
  let li: number = 0;
  const p: string = text.replace(linkRe, (_m: string, t: string, u: string) => {
    const ph: string = '\x00L' + (li++) + '\x00';
    links.push(new LinkInfo(ph, t, u));
    return ph;
  });

  let i: number = 0;
  let current: string = '';
  while (i < p.length) {
    const ch: string = p.charAt(i);

    if (ch === '*' && p.charAt(i + 1) === '*') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('**', i + 2);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 2, end), true, false, false, '', false)); i = end + 2; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '*' && p.charAt(i + 1) !== '*') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('*', i + 1);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 1, end), false, true, false, '', false)); i = end + 1; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '`') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('`', i + 1);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 1, end), false, false, true, '', false)); i = end + 1; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '_' && p.charAt(i + 1) === '_') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('__', i + 2);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 2, end), true, false, false, '', false)); i = end + 2; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '_' && p.charAt(i + 1) !== '_') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('_', i + 1);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 1, end), false, true, false, '', false)); i = end + 1; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '~' && p.charAt(i + 1) === '~') {
      if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
      const end: number = p.indexOf('~~', i + 2);
      if (end > i) { spans.push(new InlineSpan(p.substring(i + 2, end), false, false, false, '', false)); i = end + 2; }
      else { current += ch; i++; }
      continue;
    }
    if (ch === '\x00') {
      const phMatch: RegExpMatchArray | null = p.substring(i).match(/^\x00L(\d+)\x00/);
      if (phMatch) {
        if (current) { spans.push(new InlineSpan(current, false, false, false, '', false)); current = ''; }
        const idx: number = parseInt(phMatch[1]);
        if (idx < links.length) spans.push(new InlineSpan(links[idx].text, false, false, false, links[idx].url, false));
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

function parseInline(text: string): MdInline[] {
  const cached: MdInline[] | undefined = inlineCache.get(text);
  if (cached) return cached;
  const segments: MdInline[] = [];
  let last: number = 0;
  let idx: number = text.indexOf('![');
  while (idx >= 0) {
    const closeB: number = text.indexOf(']', idx + 2);
    if (closeB < 0) break;
    const openP: number = text.indexOf('(', closeB + 1);
    if (openP !== closeB + 1) { idx = text.indexOf('![', closeB + 1); continue; }
    const closeP: number = text.indexOf(')', openP + 1);
    if (closeP < 0) break;
    const alt: string = text.substring(idx + 2, closeB);
    const url: string = text.substring(openP + 1, closeP);
    if (idx > last) segments.push(new MdInline('text', parseSpans(text.substring(last, idx)), '', ''));
    segments.push(new MdInline('img', [], url, alt));
    last = closeP + 1;
    idx = text.indexOf('![', closeP + 1);
  }
  if (last < text.length) segments.push(new MdInline('text', parseSpans(text.substring(last)), '', ''));
  if (segments.length === 0) segments.push(new MdInline('text', [], '', ''));
  cachePut(inlineCache, text, segments);
  return segments;
}

// ---------- 图片子组件 ----------
@Component
struct MdImage {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop src: string = '';
  @Prop alt: string = '';
  @State failed: boolean = false;
  onOpen?: (url: string) => void;

  build() {
    if (this.failed) {
      Row() {
        Text(this.alt || '🖼 图片加载失败').fontSize(13)
          .fontColor(this.themeMode === 'dark' ? DarkTheme.textSecondary : LightTheme.textSecondary)
          .textAlign(TextAlign.Center).width('100%')
      }.width('100%').padding(16).justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeMode === 'dark' ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated).borderRadius(8)
    } else {
      Image(this.src)
        .width('100%').height(260).objectFit(ImageFit.Contain).borderRadius(8)
        .backgroundColor(this.themeMode === 'dark' ? DarkTheme.surfaceElevated : LightTheme.surfaceElevated)
        .onError(() => { this.failed = true; })
        .onClick(() => { if (this.onOpen) this.onOpen(this.src); })
    }
  }
}

// ---------- MarkdownView ----------
@Component
export struct MarkdownView {
  @StorageLink(THEME_KEY) themeMode: string = 'dark';
  @Prop content: string = '';
  @Prop maxLines: number = 999;
  @Prop fontSize: number = 14;
  onOpenRepo?: (owner: string, repo: string) => void;
  onOpenWebView?: (url: string) => void;
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

  private codeBg(): string {
    return this.themeMode === 'dark' ? 'rgba(255,255,255,0.06)' : 'rgba(0,0,0,0.05)';
  }
  private alertIcon(t: string): string {
    if (t === 'NOTE') return 'ℹ️'; if (t === 'TIP') return '💡'; if (t === 'IMPORTANT') return '❗';
    if (t === 'WARNING') return '⚠️'; if (t === 'CAUTION') return '🔥'; return '📌';
  }
  private alertColor(t: string): string {
    if (t === 'NOTE') return '#58A6FF'; if (t === 'TIP') return '#3FB950'; if (t === 'IMPORTANT') return '#9C6ADE';
    if (t === 'WARNING') return '#D29922'; if (t === 'CAUTION') return '#F85149'; return '#58A6FF';
  }

  build() {
    Column() {
      ForEach(parseMd(this.content), (line: MdLine, idx: number) => {
        if (line.type === 'h') {
          this.heading(line, idx)
        } else if (line.type === 'hr') {
          Divider().color(this.T().border).width('100%').margin({ top: 10, bottom: 10 })
        } else if (line.type === 'code') {
          Text(line.text).fontSize(this.fontSize - 1).fontColor(this.T().textSecondary)
            .backgroundColor(this.T().surfaceElevated).borderRadius(6)
            .width('100%').padding(12).margin({ top: 6, bottom: 6 }).fontFamily('monospace')
        } else if (line.type === 'alert') {
          this.alertBlock(line)
        } else if (line.type === 'quote') {
          this.quote(line)
        } else if (line.type === 'task') {
          this.taskItem(line)
        } else if (line.type === 'ul' || line.type === 'ol') {
          this.listItem(line)
        } else if (line.type === 'table') {
          this.renderTable(line)
        } else {
          Column() {
            this.inlineText(line.text, this.fontSize, FontWeight.Regular, 0)
          }.width('100%')
        }
      }, (line: MdLine, idx: number) => idx.toString())
    }.width('100%')
  }

  @Builder
  heading(line: MdLine, idx: number) {
    Column() {
      this.inlineText(line.text, line.level === 1 ? 22 : (line.level === 2 ? 18 : 16),
        line.level <= 2 ? FontWeight.Bold : FontWeight.Medium, 0)
    }.width('100%').margin({ top: idx > 0 ? 14 : 0, bottom: 4 })
  }

  @Builder
  inlineText(text: string, fs: number, fw: FontWeight, indent: number) {
    Column({ space: 4 }) {
      ForEach(parseInline(text), (seg: MdInline, si: number) => {
        if (seg.type === 'img') {
          MdImage({ src: seg.imgUrl, alt: seg.imgAlt, onOpen: (u: string) => { this.handleLink(u); } })
        } else {
          Text() {
            ForEach(seg.spans, (s: InlineSpan, pi: number) => {
              Span(s.text)
                .fontSize(fs)
                .fontWeight(s.bold ? FontWeight.Bold : fw)
                .fontStyle(s.italic ? FontStyle.Italic : FontStyle.Normal)
                .fontFamily(s.code ? 'monospace' : '')
                .fontColor(s.link ? this.T().accent : this.T().textSecondary)
                .backgroundColor(s.code ? this.codeBg() : Color.Transparent)
                .decoration({ type: s.strike ? TextDecorationType.LineThrough : (s.link ? TextDecorationType.Underline : TextDecorationType.None) })
                .onClick(() => { if (s.link) this.handleLink(s.link); })
            }, (s: InlineSpan, pi: number) => 's' + pi)
          }
          .width('100%').lineHeight(Math.round(fs * 1.5))
        }
      }, (seg: MdInline, si: number) => 'seg' + si)
    }
    .width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: indent * 12 })
  }

  @Builder
  listItem(line: MdLine) {
    Row({ space: 4 }) {
      Text(line.type === 'ul' ? '•' : line.level.toString() + '.')
        .fontSize(this.fontSize).fontColor(this.T().textTertiary).width(20)
      Column() {
        this.inlineText(line.text, this.fontSize, FontWeight.Regular, line.indent)
      }.layoutWeight(1)
    }.width('100%').margin({ top: 2, bottom: 2 })
  }

  @Builder
  taskItem(line: MdLine) {
    Row({ space: 4 }) {
      Text(line.checked ? '☑' : '☐').fontSize(this.fontSize)
        .fontColor(line.checked ? this.T().accent : this.T().textTertiary).width(20)
      Column() {
        this.inlineText(line.text, this.fontSize, FontWeight.Regular, line.indent)
      }.layoutWeight(1)
    }.width('100%').margin({ top: 2, bottom: 2 })
  }

  @Builder
  quote(line: MdLine) {
    Row({ space: 8 }) {
      Text('│').fontSize(16).fontColor(this.T().border)
      Column() {
        this.inlineText(line.text, this.fontSize, FontWeight.Regular, 0)
      }.layoutWeight(1)
    }.width('100%').padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor(this.T().surfaceElevated).borderRadius(6).margin({ top: 4, bottom: 4 })
  }

  @Builder
  alertBlock(line: MdLine) {
    Row({ space: 6 }) {
      Text(this.alertIcon(line.text) || '📌').fontSize(14)
      Text(line.text).fontSize(13).fontWeight(FontWeight.Bold)
        .fontColor(this.alertColor(line.text) || '#58A6FF')
    }.width('100%').padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.themeMode === 'dark' ? '#161B22' : '#F6F8FA').borderRadius(6)
      .border({ width: 1, color: this.alertColor(line.text) || '#30363D', style: BorderStyle.Solid })
      .margin({ top: 6, bottom: 2 })
  }

  @Builder
  renderTable(line: MdLine) {
    Column() {
      if (line.rows.length > 0) {
        Row() {
          ForEach(line.rows[0], (cell: string, ci: number) => {
            Text(cell).fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.T().textPrimary)
              .layoutWeight(1).padding({ left: 8, right: 8, top: 6, bottom: 6 })
              .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
          }, (cell: string, ci: number) => 'h' + ci)
        }.width('100%').backgroundColor(this.themeMode === 'dark' ? '#1A2F44' : '#DDF4FF')
        ForEach(line.rows.slice(1), (row: string[], ri: number) => {
          Row() {
            ForEach(row, (cell: string, ci: number) => {
              Column() {
                this.inlineText(cell, this.fontSize - 1, FontWeight.Regular, 0)
              }.layoutWeight(1).padding({ left: 8, right: 8, top: 6, bottom: 6 })
            }, (cell: string, ci: number) => 'c' + ci)
          }.width('100%')
            .backgroundColor(ri % 2 === 0 ? Color.Transparent : this.T().surfaceElevated)
        }, (row: string[], ri: number) => 'r' + ri)
      }
    }.width('100%').borderRadius(6).clip(true).margin({ top: 6, bottom: 6 })
      .border({ width: 1, color: this.T().border })
  }

  private handleLink(url: string): void {
    const m: RegExpMatchArray | null = url.match(/github\.com\/([^/]+)\/([^/?\s#]+)/);
    if (m && m[1] && m[2] && this.onOpenRepo) { this.onOpenRepo(m[1], m[2]); return; }
    if (this.onOpenWebView) this.onOpenWebView(url);
  }
}