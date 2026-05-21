import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import prettier from 'prettier';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');
const workspaceRoot = path.resolve(projectRoot, '..');
const sourceRoot = path.join(workspaceRoot, 'static_site_spa');
const oldPublicRoot = path.join(workspaceRoot, 'public');

const groupTitles = {
  debian: 'Debian',
  pve: 'PVE',
  vyos: 'VyOS配置',
  windows: 'Windows',
};

const vyosSlugs = [
  'install',
  'interfaces',
  'lan',
  'timezone',
  'wan',
  'dns',
  'firewall',
  'access-192-168-1-1',
  'ipv6-allow',
  'static-ip',
  'wan-dhcp',
  'traffic-shaping',
  'ssh-key',
];

const finalDownloadSlugs = {
  debian: 'debian-scripts',
  win: 'windows-tools',
  reg: 'registry-files',
  picture: 'pictures',
};

const finalDownloadTitles = {
  debian: 'Debian脚本',
  win: 'Windows工具',
  reg: '注册表文件',
  picture: '图片',
};

const pages = [
  pageFromDocument({
    group: 'debian',
    slug: 'linux-kernel-build',
    title: 'Linux内核编译',
    summary: 'Linux 内核编译与 Deb 打包完整流程。',
    source: 'pages/kernel-build.html',
    parser: 'article',
  }),
  pageFromDocument({
    group: 'debian',
    slug: 'common-commands',
    title: '常用命令',
    summary: '端口、时区、IP、内核、清理与 Docker 常用操作。',
    source: 'pages/common-commands.html',
    parser: 'cards',
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'tmux-screen',
    title: 'Tmux && Screen',
    summary: 'Tmux 与 Screen 会话管理命令，Tmux 内容在前。',
    commandFiles: ['data/systems/debian/debian-tmux_commands.js', 'data/systems/debian/debian-screen_commands.js'],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'python',
    title: 'Python',
    summary: 'Python 环境与包管理。',
    commandFiles: ['data/systems/debian/debian-python_commands.js'],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'wireguard',
    title: 'WireGuard',
    summary: 'WireGuard 配置与维护命令。',
    commandFiles: ['data/systems/debian/debian-wg_commands.js'],
  }),
  mergedPage({
    group: 'debian',
    slug: 'acme-certs',
    title: 'ACME证书',
    summary: 'ACME 证书申请、续签、安装与相关脚本。',
    sources: [commandSource('data/systems/debian/debian-acme_commands.js'), documentSource('pages/acme.html', 'cards')],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'docker',
    title: 'Docker',
    summary: 'Docker 安装、镜像、网络与 Docker Compose 服务模板。',
    commandFiles: ['data/systems/debian/debian-docker_commands.js', 'data/systems/debian/debian-compose_commands.js'],
  }),
  mergedPage({
    group: 'debian',
    slug: 'adguardhome',
    title: 'AdGuardHome',
    summary: 'AdGuardHome 安装、DoH 服务地址与缓存配置。',
    sources: [
      commandSource('data/systems/debian/debian-adguard_commands.js'),
      documentSource('pages/adguard.html', 'cards'),
    ],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'disk-mount',
    title: '硬盘挂载',
    summary: '磁盘挂载、分区与持久化配置。',
    commandFiles: ['data/systems/debian/debian-mountdisk_commands.js'],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'kea-dhcp-server',
    title: 'Kea DHCP Server',
    summary: 'Kea DHCP 服务配置。',
    commandFiles: ['data/systems/debian/debian-keadhcp_commands.js'],
  }),
  pageFromCommands({
    group: 'debian',
    slug: 'tar-tee-find',
    title: '命令示例tar tee find',
    summary: 'tar、tee、find 命令示例。',
    commandFiles: [
      'data/systems/debian/debian-tar_commands.js',
      'data/systems/debian/debian-tee_commands.js',
      'data/systems/debian/debian-find_commands.js',
    ],
  }),
  pageFromCommands({
    group: 'pve',
    slug: 'config',
    title: '配置',
    summary: 'PVE 杂项与初始配置合并目录。',
    commandFiles: ['data/systems/pve/pve-all_commands.js', 'data/systems/pve/pve-changyong_commands.js'],
  }),
  pageFromCommands({
    group: 'pve',
    slug: 'import-disk',
    title: '导入磁盘镜像',
    summary: '虚拟机磁盘导入流程。',
    commandFiles: ['data/systems/pve/pve-importdisk_commands.js'],
  }),
  pageFromCommands({
    group: 'pve',
    slug: 'disk-rdm',
    title: '磁盘RDM直通',
    summary: '物理磁盘直通给虚拟机。',
    commandFiles: ['data/systems/pve/pve-diskrdm_commands.js'],
  }),
  pageFromCommands({
    group: 'pve',
    slug: 'zfs',
    title: 'ZFS',
    summary: 'ZFS 池与数据集维护。',
    commandFiles: ['data/systems/pve/pve-zfs_commands.js'],
  }),
  pageFromDocument({
    group: 'pve',
    slug: 'pve-aspm',
    title: 'PVE ASPM设置',
    summary: 'PVE 使用内核选项禁用 PCIe ASPM。',
    source: 'pages/pve-aspm-guide.html',
    parser: 'article',
  }),
  pageFromCommands({
    group: 'pve',
    slug: 'vm-management',
    title: '虚拟机管理',
    summary: 'PVE 虚拟机管理命令。',
    commandFiles: ['data/systems/pve/vm_commands.js'],
  }),
  ...vyosPages(),
  pageFromCommands({
    group: 'windows',
    slug: 'md5-win2022',
    title: 'MD5/WIN2022激活',
    summary: 'MD5 校验与 Windows Server 2022 激活相关命令。',
    commandFiles: ['data/systems/windows/win-2022_commands.js'],
  }),
  pageFromCommands({
    group: 'windows',
    slug: 'adb',
    title: 'ADB命令',
    summary: 'Android 调试桥常用命令。',
    commandFiles: ['data/systems/windows/win-adb_commands.js'],
  }),
  pageFromCommands({
    group: 'windows',
    slug: 'network',
    title: '网络命令',
    summary: 'Windows 网络排查与配置命令。',
    commandFiles: ['data/systems/windows/win-net_commands.js'],
  }),
];

const downloads = buildDownloads();
copyDownloads(downloads);
await writeContent(pages);
await writeDownloads(downloads);
await writeNavigation(pages, downloads);

console.log(`Generated ${pages.length} content pages and ${downloads.length} download categories.`);

function pageFromCommands({ group, slug, title, summary, commandFiles }) {
  return {
    group,
    groupTitle: groupTitles[group],
    slug,
    title,
    summary,
    items: commandFiles.flatMap((file) => commandItems(file)),
  };
}

function pageFromDocument({ group, slug, title, summary, source, parser }) {
  return {
    group,
    groupTitle: groupTitles[group],
    slug,
    title,
    summary,
    items: documentItems(source, parser),
  };
}

function mergedPage({ group, slug, title, summary, sources }) {
  return {
    group,
    groupTitle: groupTitles[group],
    slug,
    title,
    summary,
    items: sources.flatMap((source) => source.items()),
  };
}

function commandSource(file) {
  return { items: () => commandItems(file) };
}

function documentSource(file, parser) {
  return { items: () => documentItems(file, parser) };
}

function vyosPages() {
  const html = readSource('pages/vyos.html');
  const sections = topCommentSections(html);
  return sections.map((section, index) => ({
    group: 'vyos',
    groupTitle: groupTitles.vyos,
    slug: vyosSlugs[index] || `section-${index + 1}`,
    title: stripNumber(section.title),
    summary: `VyOS ${stripNumber(section.title)}配置命令。`,
    items: [cardSectionItem(section)].filter((item) => item.fields.length),
  }));
}

function commandItems(relativePath) {
  const source = readSource(relativePath);
  const commandList = new Function(`${source}\nreturn commandList;`)();

  return (commandList.commands || []).map((command, index) => {
    const fields = [];
    let title = '';

    for (const field of normalizeCommandFields(command)) {
      if ((field.type === 'desc' || field.type === 'info') && !title) {
        title = titleText(field.value);
        continue;
      }

      if (field.type === 'desc' || field.type === 'info') {
        pushNote(fields, field.value);
      } else if (field.type === 'code') {
        fields.push(codeField(field.value));
      }
    }

    return {
      title: title || titleText(`${commandList.name || '命令'} ${index + 1}`),
      fields: dedupeFields(fields),
    };
  });
}

function normalizeCommandFields(command) {
  const fields = [];
  if (Array.isArray(command.fields)) {
    for (const field of command.fields) {
      const value = resolveValue(field.value, field.isBase64);
      if (field.type === 'code' && Array.isArray(value)) {
        value.forEach((entry) => pushResolvedField(fields, 'code', entry));
      } else {
        pushResolvedField(fields, field.type, value);
      }
    }
  } else {
    pushResolvedField(fields, 'desc', command.desc || '');
    pushResolvedField(fields, 'info', command.info || '');
    pushResolvedField(fields, 'code', command.code);
    pushResolvedField(fields, 'code', resolveValue(command.base64Code, true));
  }
  return fields;
}

function pushResolvedField(fields, type, value) {
  if (Array.isArray(value)) {
    value.forEach((entry) => pushResolvedField(fields, type, entry));
    return;
  }

  const text = String(value || '').trimEnd();
  if (!text.trim()) return;
  fields.push({ type, value: text });
}

function resolveValue(value, isBase64) {
  if (Array.isArray(value)) return value.map((item) => resolveValue(item, isBase64));
  const text = String(value || '');
  if (!isBase64) return text;
  const normalized = text.replace(/-/g, '+').replace(/_/g, '/').replace(/\s/g, '');
  return Buffer.from(normalized, 'base64').toString('utf8');
}

function documentItems(relativePath, parser) {
  const html = readSource(relativePath);
  if (parser === 'cards')
    return topCommentSections(html)
      .map(cardSectionItem)
      .filter((item) => item.fields.length);
  return articleItems(html);
}

function topCommentSections(html) {
  const matches = [...html.matchAll(/<div class="comment top-comment"[^>]*>([\s\S]*?)<\/div>/g)];
  return matches.map((match, index) => {
    const next = matches[index + 1];
    return {
      title: cleanText(match[1]),
      segment: html.slice(match.index, next?.index ?? html.length),
    };
  });
}

function cardSectionItem(section) {
  const fields = [];
  const eventPattern =
    /<div class="comment(?! top-comment)[^"]*"[^>]*>([\s\S]*?)<\/div>|<div class="cmdline"[\s\S]*?<span>([\s\S]*?)<\/span>[\s\S]*?<\/div>|<pre class="codeblock full"[^>]*><code>([\s\S]*?)<\/code><\/pre>/g;

  for (const match of section.segment.matchAll(eventPattern)) {
    if (match[1]) {
      pushNote(fields, match[1]);
    } else if (match[2]) {
      fields.push(codeField(decodeEntities(stripTags(match[2])).trim()));
    } else if (match[3]) {
      fields.push(codeField(decodeEntities(match[3]).trimEnd()));
    }
  }

  return {
    title: titleText(section.title),
    fields: dedupeFields(fields),
  };
}

function articleItems(html) {
  const body = html.match(/<body[^>]*>([\s\S]*?)<\/body>/i)?.[1] || html;
  const headingPattern = /<h([1-3])[^>]*>([\s\S]*?)<\/h\1>/g;
  const headings = [...body.matchAll(headingPattern)].filter((match) => cleanText(match[2]) !== '📑 目录');

  if (!headings.length) {
    return [{ title: '内容', fields: extractArticleFields(body) }].filter((item) => item.fields.length);
  }

  return headings
    .map((heading, index) => {
      const next = headings[index + 1];
      const segment = body.slice(heading.index + heading[0].length, next?.index ?? body.length);
      return {
        title: titleText(heading[2]),
        fields: dedupeFields(extractArticleFields(segment)),
      };
    })
    .filter((item) => item.fields.length || item.title);
}

function extractArticleFields(segment) {
  const fields = [];
  const eventPattern =
    /<p(?:\s[^>]*)?>([\s\S]*?)<\/p>|<li(?:\s[^>]*)?>([\s\S]*?)<\/li>|<div\s+class="note"[^>]*>([\s\S]*?)<\/div>|<pre(?:\s[^>]*)?>\s*(?:<code(?:\s[^>]*)?>)?([\s\S]*?)(?:<\/code>)?\s*<\/pre>/g;
  for (const match of segment.matchAll(eventPattern)) {
    if (match[1] || match[2] || match[3]) {
      pushNote(fields, match[1] || match[2] || match[3]);
    } else if (match[4]) {
      const code = decodeEntities(stripTags(match[4])).trimEnd();
      if (code.trim()) fields.push(codeField(code));
    }
  }
  return fields;
}

function codeField(value) {
  const text = String(value || '')
    .replace(/\r\n/g, '\n')
    .trimEnd();
  return {
    type: 'code',
    value: text,
    copyMode: text.split('\n').filter((line) => line.trim()).length > 1 ? 'block' : 'single-line',
  };
}

function buildDownloads() {
  const manifest = JSON.parse(fs.readFileSync(path.join(oldPublicRoot, 'downloads/manifest.json'), 'utf8'));
  return manifest.categories.map((category) => ({
    id: category.id,
    slug: finalDownloadSlugs[category.id] || category.id,
    title: finalDownloadTitles[category.id] || category.title,
    originalTitle: category.title,
    description: category.description,
    accent: category.accent,
    items: category.items.map((item) => ({
      filename: item.filename,
      path: `/${item.path}`,
      sourcePath: item.path,
      size: item.size,
      sha256: item.sha256,
      kind: item.kind,
      tags: item.tags || [],
      isImage: item.kind === 'JPEG Image',
    })),
  }));
}

function copyDownloads(downloadCategories) {
  const targetRoot = path.join(projectRoot, 'public/downloads');
  fs.mkdirSync(targetRoot, { recursive: true });

  for (const category of downloadCategories) {
    for (const item of category.items) {
      const source = path.join(oldPublicRoot, item.sourcePath);
      const target = path.join(projectRoot, 'public', item.sourcePath);
      fs.mkdirSync(path.dirname(target), { recursive: true });
      fs.copyFileSync(source, target);
    }
  }
}

async function writeContent(contentPages) {
  const target = path.join(projectRoot, 'src/data/content.ts');
  await writeGeneratedTypeScript(
    target,
    `${generatedHeader()}export type CopyMode = 'single-line' | 'block';

export interface ContentField {
  type: 'note' | 'code';
  value: string;
  copyMode?: CopyMode;
}

export interface ContentItem {
  title: string;
  fields: ContentField[];
}

export interface ContentPage {
  group: string;
  groupTitle: string;
  slug: string;
  title: string;
  summary: string;
  items: ContentItem[];
}

export const contentPages = ${json(contentPages)} satisfies ContentPage[];

export const contentGroups = ${json(groupedNav(contentPages))};

export function getContentPage(group: string, slug: string) {
  return contentPages.find((page) => page.group === group && page.slug === slug);
}
`
  );
}

async function writeDownloads(downloadCategories) {
  const target = path.join(projectRoot, 'src/data/downloads.ts');
  await writeGeneratedTypeScript(
    target,
    `${generatedHeader()}export interface DownloadItem {
  filename: string;
  path: string;
  sourcePath: string;
  size: number;
  sha256: string;
  kind: string;
  tags: string[];
  isImage: boolean;
}

export interface DownloadCategory {
  id: string;
  slug: string;
  title: string;
  originalTitle: string;
  description: string;
  accent: string;
  items: DownloadItem[];
}

export const downloadCategories = ${json(downloadCategories)} satisfies DownloadCategory[];

export function getDownloadCategory(slug: string) {
  return downloadCategories.find((category) => category.slug === slug);
}

export function formatBytes(bytes: number) {
  const units = ['B', 'KB', 'MB', 'GB'];
  let value = Number(bytes);
  let unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }
  return (value >= 10 || unitIndex === 0 ? value.toFixed(0) : value.toFixed(1)) + ' ' + units[unitIndex];
}
`
  );
}

async function writeNavigation(contentPages, downloadCategories) {
  const groups = groupedNav(contentPages);
  const downloadLinks = [
    { text: '下载总览', href: '/downloads' },
    ...downloadCategories.map((category) => ({ text: category.title, href: `/downloads/${category.slug}` })),
  ];

  const headerLinks = [
    ...['debian', 'pve', 'vyos', 'windows'].map((group) => ({
      text: groupTitles[group],
      links: groups[group].map((page) => ({ text: page.title, href: `/${page.group}/${page.slug}` })),
    })),
    { text: '下载', links: downloadLinks },
  ];

  const footerLinks = [
    {
      title: 'Debian',
      links: groups.debian.slice(0, 6).map((page) => ({ text: page.title, href: `/${page.group}/${page.slug}` })),
    },
    { title: 'PVE', links: groups.pve.map((page) => ({ text: page.title, href: `/${page.group}/${page.slug}` })) },
    {
      title: 'Windows',
      links: groups.windows.map((page) => ({ text: page.title, href: `/${page.group}/${page.slug}` })),
    },
    { title: '下载', links: downloadLinks },
  ];

  const target = path.join(projectRoot, 'src/navigation.ts');
  await writeGeneratedTypeScript(
    target,
    `${generatedHeader()}export const headerData = ${json({ links: headerLinks, actions: [{ text: '下载', href: '/downloads' }] })};

export const footerData = ${json({
      links: footerLinks,
      secondaryLinks: [
        { text: '首页', href: '/' },
        { text: '下载', href: '/downloads' },
      ],
      socialLinks: [],
      footNote: '',
    })};
`
  );
}

async function writeGeneratedTypeScript(target, source) {
  fs.mkdirSync(path.dirname(target), { recursive: true });
  const options = (await prettier.resolveConfig(target)) || {};
  const formatted = await prettier.format(source, { ...options, filepath: target });
  fs.writeFileSync(target, formatted);
}

function groupedNav(contentPages) {
  return contentPages.reduce(
    (groups, page) => {
      groups[page.group].push({
        group: page.group,
        slug: page.slug,
        title: page.title,
        summary: page.summary,
      });
      return groups;
    },
    { debian: [], pve: [], vyos: [], windows: [] }
  );
}

function readSource(relativePath) {
  return fs.readFileSync(path.join(sourceRoot, relativePath), 'utf8');
}

function stripNumber(text) {
  return cleanText(text).replace(/^\d+(?:\.\d+)*\.?\s*/, '');
}

function cleanText(value) {
  return decodeEntities(stripTags(value)).replace(/\s+/g, ' ').trim();
}

function titleText(value) {
  return polishText(stripNumber(value).replace(/^#+\s*/, '')).trim();
}

function pushNote(fields, value) {
  const text = noteText(value);
  if (text) fields.push({ type: 'note', value: text });
}

function noteText(value) {
  const text = polishText(
    stripNumber(value)
      .replace(/\*\*([^*]+)\*\*/g, '$1')
      .replace(/`([^`]+)`/g, '$1')
      .replace(/\s+([,，。；：])/g, '$1')
  ).trim();

  if (!text || /^\d+(?:\.\d+)*$/.test(text)) return '';
  return text;
}

function polishText(value) {
  return String(value || '')
    .replace(/您必须/g, '需要')
    .replace(/您可以/g, '可以')
    .replace(/您的/g, '当前')
    .replace(/您/g, '')
    .replace(/这一步至关重要。?/g, '这一步用于写入启动配置。')
    .replace(/完美兼容/g, '沿用')
    .replace(/以下是一些基础操作：?/g, '常用操作如下：')
    .trim();
}

function dedupeFields(fields) {
  const seen = new Set();
  return fields.filter((field) => {
    const key = `${field.type}\0${field.value}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function stripTags(value) {
  return String(value || '').replace(/<[^>]+>/g, '');
}

function decodeEntities(value) {
  return String(value || '')
    .replace(/&#x([0-9a-f]+);/gi, (_, hex) => String.fromCodePoint(Number.parseInt(hex, 16)))
    .replace(/&#(\d+);/g, (_, decimal) => String.fromCodePoint(Number.parseInt(decimal, 10)))
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, "'")
    .replace(/&apos;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&');
}

function json(value) {
  return JSON.stringify(value, null, 2);
}

function generatedHeader() {
  return '/* Generated by scripts/generate-content.mjs. Do not edit by hand. */\n\n';
}
