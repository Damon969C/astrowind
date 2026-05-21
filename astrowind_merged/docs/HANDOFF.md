# 静态站交接文档

本文档用于后续维护 `astrowind_merged` 静态站。目标是：需要在顶部菜单、下拉菜单、教程内容、命令代码块、下载页中增删内容时，可以快速定位应该改哪里，以及改完如何重新生成、验证和部署。

## 1. 项目定位

当前真正用于构建的新站点是：

```bash
/ai/codex/2053/astrowind_merged
```

它是 Astro/Astrowind 静态站。正式部署只需要构建后的：

```bash
/ai/codex/2053/astrowind_merged/dist
```

`dist/` 内是纯静态文件，可以直接放到 Nginx、Caddy、Apache 或对象存储中托管，不需要 Node 后端。

## 2. 目录职责

```text
/ai/codex/2053
├── astrowind_merged/                 # 新 Astro 静态站，后续主要维护这里
│   ├── scripts/generate-content.mjs  # 内容生成器：菜单、页面、下载数据都从这里生成
│   ├── src/pages/                    # Astro 路由页面
│   ├── src/components/ops/           # 本站自定义 UI 组件
│   ├── src/data/                     # 生成的数据文件，不要手改
│   ├── src/navigation.ts             # 生成的导航文件，不要手改
│   ├── public/downloads/             # 生成器复制后的下载资源，不要作为源头手改
│   └── dist/                         # npm run build 后的静态产物
├── static_site_spa/                  # 命令/教程内容源数据
│   ├── data/systems/                 # 命令类 JS 数据源
│   └── pages/                        # 原 HTML 文档源
├── public/downloads/                 # 下载页源资源和 manifest
└── tools/validate-astrowind-merged.mjs # 结构和内容校验脚本
```

维护时优先记住三句话：

- 菜单结构和页面组合改 `astrowind_merged/scripts/generate-content.mjs`。
- 命令内容改 `static_site_spa/data/systems/...` 或 `static_site_spa/pages/...`。
- 下载内容改 `public/downloads/manifest.json` 和 `public/downloads/...` 文件。

## 3. 生成链路

不要直接手改这些生成文件：

```text
astrowind_merged/src/data/content.ts
astrowind_merged/src/data/downloads.ts
astrowind_merged/src/navigation.ts
astrowind_merged/public/downloads/
```

它们由下面命令重新生成：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
```

生成器写入 `src/data/content.ts`、`src/data/downloads.ts`、`src/navigation.ts` 时会自动读取项目 Prettier 配置并格式化生成结果。正常维护不需要再手动格式化这些生成文件。

完整维护流程：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

本地预览：

```bash
npm run dev -- --host 0.0.0.0 --port 4322
```

如果 4322 被占用，Astro 会自动切到 4323 或其他端口。当前常用访问方式：

```text
http://10.0.0.165:4323
```

## 4. 当前顶部菜单

顶部一级菜单固定为：

```text
Debian / PVE / VyOS配置 / Windows / 下载
```

这个结构来自 `astrowind_merged/scripts/generate-content.mjs`：

```js
const groupTitles = {
  debian: 'Debian',
  pve: 'PVE',
  vyos: 'VyOS配置',
  windows: 'Windows',
};
```

以及 `writeNavigation()` 中的顺序：

```js
...["debian", "pve", "vyos", "windows"].map((group) => ({
  text: groupTitles[group],
  links: groups[group].map((page) => ({ text: page.title, href: `/${page.group}/${page.slug}` })),
})),
{ text: "下载", links: downloadLinks },
```

普通情况下不要改 `src/navigation.ts`，因为它会被生成器覆盖。

## 5. 下拉菜单和页面的核心位置

所有命令/教程页面都定义在 `scripts/generate-content.mjs` 的 `const pages = [...]` 数组中。

页面在数组中的顺序，就是对应下拉菜单中的顺序。

一个页面对象最终会生成：

```text
/${group}/${slug}
```

例如：

```js
pageFromCommands({
  group: 'pve',
  slug: 'disk-rdm',
  title: '磁盘RDM直通',
  summary: '物理磁盘直通给虚拟机。',
  commandFiles: ['data/systems/pve/pve-diskrdm_commands.js'],
});
```

生成页面：

```text
/pve/disk-rdm
```

下拉菜单显示：

```text
磁盘RDM直通
```

页面大标题：

```text
磁盘RDM直通
```

## 6. 页面来源类型

生成器支持四种来源写法。

### 6.1 命令 JS 文件页面：`pageFromCommands`

适合命令列表、配置块、脚本块。

```js
pageFromCommands({
  group: 'debian',
  slug: 'python',
  title: 'Python',
  summary: 'Python 环境与包管理。',
  commandFiles: ['data/systems/debian/debian-python_commands.js'],
});
```

源文件在：

```text
static_site_spa/data/systems/debian/debian-python_commands.js
```

### 6.2 HTML 教程页面：`pageFromDocument`

适合像普通教程文章一样维护的 HTML。

```js
pageFromDocument({
  group: 'debian',
  slug: 'linux-kernel-build',
  title: 'Linux内核编译',
  summary: 'Linux 内核编译与 Deb 打包完整流程。',
  source: 'pages/kernel-build.html',
  parser: 'article',
});
```

源文件在：

```text
static_site_spa/pages/kernel-build.html
```

`parser: "article"` 会解析：

```text
<h1> / <h2> / <h3>
<p>
<li>
<div class="note">
<pre><code>...</code></pre>
```

### 6.3 老卡片式 HTML 页面：`parser: "cards"`

适合原项目里这种结构：

```html
<div class="comment top-comment">1. 安装</div>
<div class="cmdline"><span>apt update</span></div>
<pre class="codeblock full"><code>...</code></pre>
```

生成器会按 `top-comment` 分节。

当前用于：

```text
static_site_spa/pages/common-commands.html
static_site_spa/pages/acme.html
static_site_spa/pages/adguard.html
static_site_spa/pages/vyos.html
```

### 6.4 合并页面：`mergedPage`

适合把一个 JS 命令文件和一个 HTML 文档合并成一个菜单项。

例如 ACME：

```js
mergedPage({
  group: 'debian',
  slug: 'acme-certs',
  title: 'ACME证书',
  summary: 'ACME 证书申请、续签、安装与相关脚本。',
  sources: [commandSource('data/systems/debian/debian-acme_commands.js'), documentSource('pages/acme.html', 'cards')],
});
```

菜单里只有一个 `ACME证书`，内容来自两个源。

## 7. 命令数据格式

命令类源文件格式固定：

```js
const commandList = {
  name: '页面或命令组名称',
  commands: [
    {
      desc: `小节标题`,
      info: `说明文字，可选`,
      code: `apt update`,
    },
  ],
};
```

### 7.1 单条命令

单条命令写成字符串：

```js
{
  desc: `更新软件源`,
  code: `apt update`
}
```

生成后是一个单行代码块，一键复制只复制这一行。

### 7.2 多条独立命令

多条独立命令写成数组：

```js
{
  desc: `RDM 映射`,
  code: [
    `ls -la /dev/disk/by-id/|grep -v dm|grep -v lvm|grep -v part`,
    `qm set <vmid> --scsiX /dev/disk/by-id/xxxxxxx`,
    `qm set 101 --delete scsi1`
  ]
}
```

生成后每个数组元素都是独立单行代码块。不要把多条独立命令写进一个字符串里，否则会变成整段复制。

### 7.3 整段配置或脚本

整段配置、脚本、systemd unit、JSON、Python、HTML 等要写成多行字符串：

```js
{
  desc: `systemd 服务文件`,
  code: `[Unit]
Description=Example Service

[Service]
ExecStart=/usr/bin/example

[Install]
WantedBy=multi-user.target`
}
```

生成后是一个多行代码块，一键复制会复制整段。

### 7.4 带多个字段的写法

部分 Windows 源文件使用 `fields`：

```js
{
  fields: [
    { type: 'desc', value: 'Windows 激活' },
    { type: 'info', value: '先安装密钥，再设置 KMS 服务器。' },
    { type: 'code', value: 'slmgr /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' },
    { type: 'code', value: 'slmgr /ato' },
  ];
}
```

支持的 `type`：

```text
desc  -> 小节标题或说明
info  -> 说明
code  -> 代码块
```

如果 `field.isBase64: true`，生成器会先 base64 解码再写入代码块。

## 8. 代码块复制规则

复制模式由生成器自动判断，逻辑在 `codeField()`：

```js
copyMode: text.split('\n').filter((line) => line.trim()).length > 1 ? 'block' : 'single-line';
```

维护原则：

- 单条命令：单行字符串。
- 多条独立命令：数组，每条命令一个数组元素。
- 整段配置/脚本：多行字符串。

典型错误：

```js
// 错误：多条独立命令会变成一个整段复制块
code: `apt update
apt install nginx
systemctl enable nginx`;
```

正确写法：

```js
code: [`apt update`, `apt install nginx`, `systemctl enable nginx`];
```

例外：如果这三行本来就是一个脚本或一次性粘贴的配置流程，可以保留多行字符串。

## 9. 增删 Debian / PVE / Windows 菜单内容

### 9.1 添加一个新菜单页面

例：给 Debian 添加 `Nginx`。

第一步，创建源文件：

```text
static_site_spa/data/systems/debian/debian-nginx_commands.js
```

内容示例：

```js
const commandList = {
  name: 'Nginx',
  commands: [
    {
      desc: `安装`,
      info: `安装 Nginx 并设置开机启动。`,
      code: [`apt update`, `apt install -y nginx`, `systemctl enable --now nginx`],
    },
  ],
};
```

第二步，在 `astrowind_merged/scripts/generate-content.mjs` 的 `pages` 数组里插入：

```js
pageFromCommands({
  group: "debian",
  slug: "nginx",
  title: "Nginx",
  summary: "Nginx 安装、配置与服务管理。",
  commandFiles: ["data/systems/debian/debian-nginx_commands.js"],
}),
```

插入位置就是下拉菜单位置。

第三步，重新生成并验证：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

最终访问：

```text
/debian/nginx
```

### 9.2 给现有页面追加命令

例：给 PVE 的 `磁盘RDM直通` 追加命令。

只改：

```text
static_site_spa/data/systems/pve/pve-diskrdm_commands.js
```

在 `commands` 数组追加对象或在现有 `code` 数组追加命令。然后运行：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

### 9.3 删除一个菜单页面

例：删除 Windows 的 `ADB命令`。

在 `scripts/generate-content.mjs` 的 `pages` 数组删除或注释这段：

```js
pageFromCommands({
  group: "windows",
  slug: "adb",
  title: "ADB命令",
  summary: "Android 调试桥常用命令。",
  commandFiles: ["data/systems/windows/win-adb_commands.js"],
}),
```

源文件可以保留，不被 `pages` 引用就不会出现在新站。

### 9.4 修改菜单显示名或页面标题

改 `pages` 数组里对应对象的 `title`：

```js
title: "Docker",
```

`title` 同时影响：

- 下拉菜单文字
- 页面大标题
- 首页或导航数据引用的页面标题

### 9.5 修改 URL

改 `slug`：

```js
slug: "docker",
```

URL 会变为：

```text
/debian/docker
```

注意：改 `slug` 会让旧链接失效。若站点已对外使用，最好在 Nginx 做 301 跳转。

## 10. VyOS 配置的特殊维护方式

VyOS 页面不是在 `pages` 数组里逐个手写，而是由：

```js
...vyosPages(),
```

自动从这个文件拆分：

```text
static_site_spa/pages/vyos.html
```

拆分依据是：

```html
<div class="comment top-comment">1. 安装</div>
```

每个 `top-comment` 会变成 `VyOS配置` 下的一个菜单项。

URL slug 来自 `vyosSlugs`：

```js
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
```

维护规则：

- 如果只改某个 VyOS 小节里的命令，改 `static_site_spa/pages/vyos.html` 即可。
- 如果新增一个顶层小节，需要在 `vyos.html` 增加 `top-comment`，并在 `vyosSlugs` 同位置增加一个 slug。
- 如果删除一个顶层小节，也要同步删除 `vyosSlugs` 对应位置，否则后面页面的 URL 会错位。

## 11. 下载页维护

下载页源头是：

```text
public/downloads/manifest.json
public/downloads/debian/
public/downloads/win/
public/downloads/reg/
public/downloads/picture/
```

生成器会读取 `public/downloads/manifest.json`，再复制文件到：

```text
astrowind_merged/public/downloads/
```

不要把 `astrowind_merged/public/downloads/` 当源头改，因为重新生成会覆盖。

### 11.1 下载分类映射

分类标题和 URL 映射在 `generate-content.mjs`：

```js
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
```

最终 URL：

```text
/downloads/debian-scripts
/downloads/windows-tools
/downloads/registry-files
/downloads/pictures
```

### 11.2 添加下载文件

例：添加 Debian 脚本。

第一步，把文件放入：

```text
public/downloads/debian/new-script.sh
```

第二步，计算大小和 SHA-256：

```bash
stat -c %s public/downloads/debian/new-script.sh
sha256sum public/downloads/debian/new-script.sh
```

第三步，编辑：

```text
public/downloads/manifest.json
```

在 `id: "debian"` 分类的 `items` 里追加：

```json
{
  "filename": "new-script.sh",
  "path": "downloads/debian/new-script.sh",
  "size": 1234,
  "sha256": "这里填写 sha256",
  "kind": "Shell Script",
  "tags": ["Debian", "脚本"]
}
```

第四步：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

### 11.3 删除下载文件

删除三处：

1. `public/downloads/manifest.json` 中对应 `items` 项。
2. `public/downloads/...` 中对应实际文件。
3. `astrowind_merged/public/downloads/...` 中对应旧副本。

原因：当前生成器会根据 manifest 把源文件复制到 `astrowind_merged/public/downloads/`，但不会先清空整个目标目录。删除下载项时如果只删源头，不删旧副本，旧文件仍可能被 Astro 当作静态资源带进 `dist/`。

然后重新生成、验证、检查和构建：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

## 12. 首页维护

首页是手写页面：

```text
astrowind_merged/src/pages/index.astro
```

它当前展示 Debian、PVE、VyOS配置、Windows、下载几个入口卡片。

普通菜单项增删不一定需要改首页，因为首页只是一级入口。如果新增了新的一级菜单，例如 `OpenWrt`，需要同步改首页卡片、生成器分组、导航和校验脚本。

## 13. UI 组件维护

自定义 UI 主要在：

```text
astrowind_merged/src/components/ops/
```

关键文件：

```text
PageHero.astro      # 页面标题区
CommandCard.astro   # 内容小节：标题、说明、代码块
CopyCode.astro      # 一键复制代码块
DownloadCard.astro  # 下载文件卡片
CategoryGrid.astro  # 首页/下载总览卡片网格
```

页面路由：

```text
src/pages/[group]/[slug].astro       # Debian/PVE/VyOS/Windows 内容页
src/pages/downloads/index.astro      # 下载总览
src/pages/downloads/[slug].astro     # 下载分类页
src/pages/index.astro                # 首页
```

如果只是改命令内容，不需要动 UI 组件。

## 14. 导航和页脚维护

导航和页脚生成逻辑在：

```text
scripts/generate-content.mjs -> writeNavigation()
```

生成目标：

```text
src/navigation.ts
```

`src/navigation.ts` 不要手动改。

当前页脚 `footNote` 已设置为空：

```js
footNote: "",
```

如果要恢复或新增页脚说明，也在生成器里改。

## 15. 校验脚本维护

校验脚本：

```text
tools/validate-astrowind-merged.mjs
```

它会检查：

- 顶部菜单是否存在。
- 禁止项是否没有回来，例如 OpenWrt、FFmpeg、PowerShell、Nftables 防火墙。
- 下载数据是否包含 SHA-256。
- 关键页面是否存在。
- PVE RDM、PVE ZFS、ADB 是否没有被逗号拼接。
- Linux 内核编译的 tmux 和脚本是否是代码块。
- 说明文字是否没有数字编号噪声。
- 页面 UI 是否没有旧卡片式说明、没有章节数字序号、搜索标签是否保持横排。

如果以后修复过新的抽取 bug，建议把 bug 加到这个脚本里，避免回归。

运行：

```bash
cd /ai/codex/2053/astrowind_merged
npm run validate:merged
```

## 16. Nginx 部署

当前站点按根路径静态站构建，适合直接托管在域名根路径或 Nginx `root` 下。构建产物会保留 Astro 的 `ClientRouter` 和根绝对路径，例如 `/_astro/...`、`/pve/config`。

构建：

```bash
cd /ai/codex/2053/astrowind_merged
npm run build
```

部署：

```bash
sudo mkdir -p /var/www/ops-site
sudo rsync -a --delete dist/ /var/www/ops-site/
```

Nginx 示例：

```nginx
server {
    listen 80;
    server_name 10.0.0.165;

    root /var/www/ops-site;
    index index.html;

    location / {
        try_files $uri $uri/index.html =404;
    }
}
```

检查并重载：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

当前 Astro 配置是：

```js
trailingSlash: 'never';
```

推荐访问无尾斜杠 URL：

```text
/debian/linux-kernel-build
/pve/disk-rdm
/downloads/debian-scripts
```

## 17. 常见维护任务速查

### 添加 Debian/PVE/Windows 页面

改这些：

```text
static_site_spa/data/systems/<group>/<new-file>_commands.js
astrowind_merged/scripts/generate-content.mjs
```

然后运行：

```bash
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs
npm run validate:merged
npm run check
npm run build
```

### 给现有页面加命令

只改对应源文件：

```text
static_site_spa/data/systems/debian/...
static_site_spa/data/systems/pve/...
static_site_spa/data/systems/windows/...
static_site_spa/pages/...
```

然后重新生成、验证、构建。

### 调整下拉菜单顺序

只改：

```text
astrowind_merged/scripts/generate-content.mjs -> const pages = [...]
```

数组顺序就是菜单顺序。

### 改页面 URL

改：

```text
scripts/generate-content.mjs -> pages 数组里对应对象的 slug
```

### 改页面标题

改：

```text
scripts/generate-content.mjs -> pages 数组里对应对象的 title
```

### 改页面摘要

改：

```text
scripts/generate-content.mjs -> pages 数组里对应对象的 summary
```

### 改下载页文件

改：

```text
public/downloads/manifest.json
public/downloads/<category>/<file>
```

### 改复制按钮或代码块样式

改：

```text
astrowind_merged/src/components/ops/CopyCode.astro
```

### 改内容页整体排版

改：

```text
astrowind_merged/src/pages/[group]/[slug].astro
astrowind_merged/src/components/ops/CommandCard.astro
astrowind_merged/src/components/ops/PageHero.astro
```

## 18. 维护注意事项

- 不要手改生成文件：`src/data/content.ts`、`src/data/downloads.ts`、`src/navigation.ts`。
- 命令数组 `code: [...]` 表示多个独立单行复制块。
- 多行字符串表示整段复制块，适合配置文件和脚本。
- 新增菜单页面时，`slug` 使用英文、小写、短横线，避免中文 URL。
- 改完一定先跑 `node scripts/generate-content.mjs`，否则页面数据不会更新。
- 构建通过不代表内容抽取一定正确，所以 `npm run validate:merged` 要放在 `npm run build` 前面跑。
- `npm run check` 会同时跑 Astro 类型检查、ESLint 和 Prettier，建议放在构建前。
- 如果页面里出现命令被拼成一行、代码块丢失、编号混入正文，优先检查源数据格式和生成器解析逻辑。

## 19. 推荐变更流程

每次维护建议按这个顺序：

```bash
cd /ai/codex/2053

# 1. 修改源数据或生成器
#    static_site_spa/...
#    public/downloads/...
#    astrowind_merged/scripts/generate-content.mjs

# 2. 重新生成
cd /ai/codex/2053/astrowind_merged
node scripts/generate-content.mjs

# 3. 校验内容结构
npm run validate:merged

# 4. 类型、Lint 和格式检查
npm run check

# 5. 构建静态站
npm run build

# 6. 本地预览
npm run dev -- --host 0.0.0.0 --port 4322
```

确认无误后，把 `dist/` 同步到 Nginx 站点目录。
