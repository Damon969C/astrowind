# Astrowind Merge Design

## Goal

Build a new Astro/Astrowind static site that merges the local command-copy site and the local download site into one coherent documentation and download portal.

The final published site is a new project directory named `astrowind_merged/`. The existing `static_site_spa/` and `public/` directories remain source material and are not used as the final site entry points.

## Source Material

- Astrowind reference project: `https://github.com/arthelokyo/astrowind`
- Command-copy site: `static_site_spa/`
- Download files and metadata: `public/downloads/manifest.json` and files under `public/downloads/`

Astrowind is used for the new site's structure and visual language: static Astro pages, a sticky header, dropdown navigation, page layouts, hero/feature-style sections, and reusable content widgets.

## Target Architecture

Create `astrowind_merged/` as an Astro project based on Astrowind patterns.

The new project owns:

- Astro pages and layouts.
- Header dropdown navigation.
- Command/document data modules.
- Download data modules.
- Public download assets copied from the old download project.
- Reusable components for command cards, copyable code, document sections, download cards, and table-of-contents navigation.

The old `public/index.html`, `public/category.html`, and old download CSS/JS are not migrated. They are replaced by native Astro pages.

## Navigation

The top navigation mirrors Astrowind's dropdown header style. The original Astrowind menu labels `Homes`, `Pages`, `Landing`, `Blog`, and `Widgets` are replaced with:

- `Debian`
- `PVE`
- `VyOS配置`
- `Windows`
- `下载`

Every dropdown item links to a real Astro page. The new site does not use the old hash SPA routes.

## Debian Menu

Final Debian dropdown order:

1. `Linux内核编译`
2. `常用命令`
3. `Tmux && Screen`
4. `Python`
5. `WireGuard`
6. `ACME证书`
7. `Docker`
8. `AdGuardHome`
9. `硬盘挂载`
10. `Kea DHCP Server`
11. `命令示例tar tee find`

Source and transformation rules:

- Add the document `Linux内核编译` into Debian.
- Add the document `常用命令` into Debian.
- Remove the original Debian `工具`.
- Remove the original Debian `常用命令` as a separate duplicate category and use the document-derived `常用命令` page in its final position.
- Merge original `Docker` and `Docker Compose` into `Docker`.
- Merge document `ACME` with original `ACME证书`.
- Merge document `AdGuard` with original `AdGuardHome安装`, final title `AdGuardHome`.
- Remove `Nftables防火墙`.
- Remove `SSH`.
- Merge `Tmux` and `Screen` into `Tmux && Screen`, with Tmux content first.
- Merge `tar命令`, `tee命令`, and `find命令` into `命令示例tar tee find`.

## PVE Menu

Final PVE dropdown order:

1. `配置`
2. `导入磁盘镜像`
3. `磁盘RDM直通`
4. `ZFS`
5. `PVE ASPM设置`
6. `虚拟机管理`

Source and transformation rules:

- Merge original `杂项` and `初始配置` into `配置`.
- Add document `PVE ASPM指南`, final title `PVE ASPM设置`.
- Keep `导入磁盘镜像`, `磁盘RDM直通`, `ZFS`, and `虚拟机管理`.

## VyOS Menu

Final VyOS dropdown contains sections from the `VyOS配置` document.

The directory numbering is removed from titles, but the original order is preserved:

1. `安装`
2. `网口配置`
3. `设置lan`
4. `设置时区`
5. `设置wan`
6. `DNS`
7. `防火墙`
8. `访问192.168.1.1`
9. `指定ipv6放行`
10. `静态ip`
11. `WAN DHCP`
12. `流量整形`
13. `SSH密钥`

Each item links to a real Astro page or a generated section page. The page content keeps copyable command rows and preserves the original section order.

## Windows Menu

Final Windows dropdown order:

1. `MD5/WIN2022激活`
2. `ADB命令`
3. `网络命令`

Source and transformation rules:

- Remove original `FFmpeg`.
- Remove original `PowerShell`.
- Remove original `Network`.
- Keep `MD5 / WIN2022 激活`, final title `MD5/WIN2022激活`.
- Keep `ADB命令`.
- Keep `网络命令`.

## Download Menu And Pages

The download section is fully rebuilt as Astro pages. It does not embed or route to the old `public` download pages.

Final download dropdown:

1. `下载总览`
2. `Debian脚本`
3. `Windows工具`
4. `注册表文件`
5. `图片`

Page behavior:

- `/downloads/` is a real overview page with an explanation of available categories.
- `/downloads/debian-scripts/` lists Debian scripts.
- `/downloads/windows-tools/` lists Windows tools.
- `/downloads/registry-files/` lists registry files.
- `/downloads/pictures/` lists image assets with previews.

Each download page includes:

- Category title and explanation.
- File name.
- File type.
- File size.
- Tags when available.
- SHA-256 value.
- A download button linking to the copied asset.
- Image thumbnails for picture assets.

The source download files are copied into `astrowind_merged/public/downloads/`. Metadata is converted from `public/downloads/manifest.json` into an Astro-friendly data module.

## Page Types

The new site has these page families:

- Home page: concise portal overview and category entry points.
- Command/document pages: technical content with searchable/copyable command blocks.
- Download overview page: category cards and overall explanation.
- Download category pages: file cards with details and download actions.

Command/document pages should support:

- Page title and summary.
- Optional left or in-page table of contents.
- Search/filter for command-heavy pages.
- Copyable command and configuration blocks.
- Long-code folding for large scripts or configuration blocks.

## Code Block Rules

Code blocks must be grouped by semantic copy intent.

- A single command stays as one single-line copyable block.
- A complete configuration, script, heredoc, YAML file, registry snippet, or multi-line file content stays as one multi-line copyable block.
- Multiple independent commands are not combined into one block unless they are intentionally a single ordered paste sequence.
- When a task needs several separate terminal commands, each command is rendered as its own copyable block.
- When a page shows `nano file` followed by file content, `nano file` is one single-line command block and the file content is a separate multi-line block.
- Copy buttons copy exactly the visible command or full configuration block for that card.
- Long multi-line blocks may be collapsed visually, but the copy action still copies the full block.

This prevents mixing single commands and full configuration bodies into confusing blocks.

## Data Conversion

Command data conversion should produce structured records similar to:

- `id`
- `title`
- `summary`
- `group`
- `items`
- `fields`
- `field.type`: `text`, `note`, or `code`
- `field.copyMode`: `single-line` or `block`

Existing base64 command values are decoded during conversion or at render time, but the rendered page must show the decoded content.

Document HTML pages are parsed for useful content only. Old page chrome, inline CSS, search boxes, sidebars, and scripts are discarded. Useful headings, notes, command rows, and code/config blocks are converted into the shared content model.

## Component Design

Core components:

- `Header`: Astrowind-style dropdown navigation.
- `PageHero`: page title, summary, and metadata.
- `CategoryGrid`: homepage and overview cards.
- `TocNav`: generated page table of contents.
- `CommandCard`: description, note fields, and copyable code fields.
- `CopyCode`: single-line and block copy behavior.
- `DownloadCard`: download metadata, SHA-256, and download button.
- `PictureDownloadCard`: image preview plus download metadata.

Components should use Astrowind's existing layout style and Tailwind utility approach where practical.

## Styling

The design should feel like an Astrowind-derived technical documentation site:

- Clean sticky top navigation.
- Dropdown menus with clear scan-friendly labels.
- Light, restrained operational UI.
- Cards with small border radius.
- Dense but readable command and download lists.
- No decorative landing page that hides the actual content.

The first screen should expose the usable site structure immediately.

## Validation

Verification must include:

- Astro dependency install succeeds.
- Astro build succeeds.
- Navigation contains the five required top-level labels.
- Each required dropdown item has a real generated page.
- Removed categories do not appear in final navigation.
- Download metadata paths resolve to copied files.
- Download pages include SHA-256 values and download buttons.
- Picture download pages render image previews.
- Command pages render copy buttons for single-line commands and multi-line configuration blocks.
- Manual browser check confirms the site loads through `http://10.0.0.165:<port>/`.

## Out Of Scope

- The old `public/index.html` and `public/category.html` are not preserved as pages.
- The old SPA hash router is not preserved.
- OpenWrt is not included in the new top-level navigation because the requested final navigation does not include it.
- Unrequested Astrowind demo pages are not part of the final site.
