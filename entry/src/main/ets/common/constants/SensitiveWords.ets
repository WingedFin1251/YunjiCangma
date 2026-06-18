/**
 * 内置敏感词库（中英文）
 * 自动过滤搜索与展示内容，保护用户免受不良内容影响
 *
 * 来源参考：GitHub 可接受使用政策 + 国内网络安全法规
 * 匹配规则：大小写不敏感，匹配仓库全名或描述
 */
export const BUILTIN_FILTER_WORDS: string[] = [
  // ===== 成人/色情 =====
  'porn', 'xxx', 'adult', 'nsfw', 'hentai', 'sex', 'nude', 'naked',
  'escort', 'onlyfans', 'camgirl', 'camboy', 'fetish', 'bdsm',
  'erotic', 'lewd', 'upskirt', 'voyeur', 'incest', 'orgy',
  'strip', 'stripper', 'brothel', 'prostitute', 'prostitution',
  '色情', '成人', '裸体', '裸聊', '约炮', '嫖娼', '卖淫',
  '淫秽', '情色', '黄色', '性交', '自慰', '乱伦',
  'av', 'jav', 'playboy', 'penthouse', 'swinger', 'swingers',
  'hookup', 'hookers', 'pimp', 'shemale', 'tranny',

  // ===== 暴力/血腥/恐怖 =====
  'gore', 'snuff', 'torture', 'beheading', 'massacre', 'murder',
  'terrorist', 'extremist', 'isis', 'jihad', 'alqaeda',
  'bomb', 'explosive', 'shooting', 'slaughter', 'brutal',
  '暴力', '杀人', '恐怖', '血腥', '屠杀', '斩首',
  '肢解', '虐待', '酷刑', '炸弹', '枪击',

  // ===== 仇恨/歧视 =====
  'nazi', 'hitler', 'kkk', 'whitesupremacy', 'racial', 'racist',
  'holocaust', 'genocide', 'hatecrime', 'antisemitic',
  'supremacist', 'xenophobic', 'homophobic', 'transphobic',
  '纳粹', '种族', '歧视', '仇恨', '法西斯',

  // ===== 恶意/违禁/毒品 =====
  'malware', 'ransomware', 'phishing', 'botnet', 'keylogger',
  'trojan', 'spyware', 'backdoor', 'rootkit', 'exploit',
  'crack', 'warez', 'keygen', 'pirated', 'cracked',
  'drug', 'cocaine', 'heroin', 'meth', 'cannabis', 'marijuana',
  'opium', 'fentanyl', 'lsd', 'ecstasy', 'amphetamine',
  '病毒', '木马', '盗版', '破解', '外挂', '作弊',
  '毒品', '海洛因', '冰毒', '大麻', '可卡因',
  '摇头丸', '吸毒', '贩毒',

  // ===== 赌博 =====
  'casino', 'gambling', 'poker', 'betting', 'slot', 'baccarat',
  'lottery', 'blackjack', 'roulette', 'sportsbook', 'bookmaker',
  '赌博', '赌场', '赌球', '彩票', '博彩', '六合彩',
  '赌钱', '下注', '赌注',

  // ===== 欺诈/违法 =====
  'scam', 'fraud', 'counterfeit', 'fakeid', 'passport',
  'moneylaundering', 'laundering', 'darknet', 'darkweb',
  '诈骗', '欺诈', '洗钱', '假币', '暗网',
  '传销', '非法', '违禁', '走私',

  // ===== 自杀/自残 =====
  'suicide', 'selfharm', 'cutting', 'anorexia',
  '自杀', '自残', '自伤', '割腕',
];
