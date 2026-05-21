# Astrowind Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `astrowind_merged/`, a new Astro/Astrowind static site that merges command-copy pages and rebuilt download pages.

**Architecture:** Seed a new project from Astrowind, replace demo content with local generated content, and keep source projects intact. A root validation script verifies final navigation, generated pages, download assets, and command copy block semantics.

**Tech Stack:** Astro, TypeScript, Tailwind/Astrowind, Node.js validation scripts, static public assets.

---

### Task 1: Root Validation Harness

**Files:**
- Create: `tools/validate-astrowind-merged.mjs`

- [ ] **Step 1: Write failing validation**

Create a Node script that fails while `astrowind_merged/` is missing and later validates:

```js
import fs from "node:fs";
import path from "node:path";

const root = path.resolve("astrowind_merged");
const failures = [];
const requiredTopNav = ["Debian", "PVE", "VyOS配置", "Windows", "下载"];
const forbiddenLabels = ["OpenWrt", "FFmpeg", "PowerShell", "Nftables 防火墙"];

function assert(condition, message) {
  if (!condition) failures.push(message);
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

assert(fs.existsSync(root), "astrowind_merged/ must exist");

if (fs.existsSync(root)) {
  for (const file of ["package.json", "astro.config.ts", "src/navigation.ts", "src/pages/index.astro"]) {
    assert(fs.existsSync(path.join(root, file)), `Missing ${file}`);
  }

  const nav = fs.existsSync(path.join(root, "src/navigation.ts")) ? read("src/navigation.ts") : "";
  for (const label of requiredTopNav) assert(nav.includes(label), `Navigation missing ${label}`);
  for (const label of forbiddenLabels) assert(!nav.includes(label), `Navigation must not include ${label}`);

  const downloads = fs.existsSync(path.join(root, "src/data/downloads.ts")) ? read("src/data/downloads.ts") : "";
  for (const label of ["Debian脚本", "Windows工具", "注册表文件", "图片"]) {
    assert(downloads.includes(label), `Downloads data missing ${label}`);
  }
  assert(downloads.includes("sha256"), "Downloads data must expose sha256 values");

  const content = fs.existsSync(path.join(root, "src/data/content.ts")) ? read("src/data/content.ts") : "";
  for (const label of ["Linux内核编译", "Tmux && Screen", "命令示例tar tee find", "PVE ASPM设置", "ADB命令"]) {
    assert(content.includes(label), `Content data missing ${label}`);
  }
  assert(content.includes("copyMode: 'single-line'") || content.includes('copyMode: "single-line"'), "Content must contain single-line code blocks");
  assert(content.includes("copyMode: 'block'") || content.includes('copyMode: "block"'), "Content must contain block code blocks");

  for (const file of ["src/pages/downloads/index.astro", "src/pages/downloads/[slug].astro"]) {
    assert(fs.existsSync(path.join(root, file)), `Missing ${file}`);
  }

  const publicDownloads = path.join(root, "public/downloads");
  assert(fs.existsSync(publicDownloads), "public/downloads must contain copied assets");
}

if (failures.length) {
  console.error(`Validation failed with ${failures.length} issue(s):`);
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log("Validation passed: astrowind_merged structure, navigation, content, and downloads are consistent.");
```

- [ ] **Step 2: Run validation to verify it fails**

Run: `node tools/validate-astrowind-merged.mjs`

Expected: FAIL with `astrowind_merged/ must exist`.

### Task 2: Seed Astrowind Project

**Files:**
- Create: `astrowind_merged/` from `https://github.com/arthelokyo/astrowind`
- Modify: `astrowind_merged/package.json`

- [ ] **Step 1: Download Astrowind source**

Run: `curl -L https://github.com/arthelokyo/astrowind/archive/refs/heads/main.tar.gz -o /tmp/astrowind.tar.gz`

Expected: archive downloads successfully.

- [ ] **Step 2: Extract into `astrowind_merged/`**

Run: `mkdir -p /tmp/astrowind-src && tar -xzf /tmp/astrowind.tar.gz -C /tmp/astrowind-src --strip-components=1`

Then copy extracted source to `astrowind_merged/`.

- [ ] **Step 3: Add project validation script**

Modify package scripts so `npm run validate:merged` runs `node ../tools/validate-astrowind-merged.mjs`.

- [ ] **Step 4: Run validation**

Run: `node tools/validate-astrowind-merged.mjs`

Expected: FAIL because navigation/content/downloads still contain Astrowind demo content.

### Task 3: Generate Site Data From Local Sources

**Files:**
- Create: `astrowind_merged/scripts/generate-content.mjs`
- Create: `astrowind_merged/src/data/content.ts`
- Create: `astrowind_merged/src/data/downloads.ts`
- Modify: `astrowind_merged/src/navigation.ts`
- Copy: `public/downloads/**` to `astrowind_merged/public/downloads/**`

- [ ] **Step 1: Implement content generator**

Create a generator that:

- Loads existing `static_site_spa/data/systems/**/_commands.js`.
- Decodes base64 code values.
- Parses document HTML from `static_site_spa/pages/*.html`.
- Builds final Debian, PVE, VyOS, Windows, and Download page models from the approved spec.
- Assigns `copyMode: "single-line"` when code has one non-empty line.
- Assigns `copyMode: "block"` when code has multiple lines.
- Keeps independent commands as separate fields.
- Copies download assets into `astrowind_merged/public/downloads/`.
- Converts `public/downloads/manifest.json` into download category data.

- [ ] **Step 2: Run generator**

Run: `node astrowind_merged/scripts/generate-content.mjs`

Expected: `src/data/content.ts`, `src/data/downloads.ts`, and copied downloads exist.

- [ ] **Step 3: Run validation**

Run: `node tools/validate-astrowind-merged.mjs`

Expected: PASS for data/navigation portions or fail only for missing pages/components.

### Task 4: Build Astro Components And Pages

**Files:**
- Create: `astrowind_merged/src/components/ops/PageHero.astro`
- Create: `astrowind_merged/src/components/ops/CommandCard.astro`
- Create: `astrowind_merged/src/components/ops/CopyCode.astro`
- Create: `astrowind_merged/src/components/ops/DownloadCard.astro`
- Create: `astrowind_merged/src/components/ops/CategoryGrid.astro`
- Create: `astrowind_merged/src/pages/index.astro`
- Create: `astrowind_merged/src/pages/[group]/[slug].astro`
- Create: `astrowind_merged/src/pages/downloads/index.astro`
- Create: `astrowind_merged/src/pages/downloads/[slug].astro`

- [ ] **Step 1: Implement copyable code component**

`CopyCode.astro` renders a single-line block or multi-line block based on `copyMode`. It includes client-side copy behavior that copies only that block's text.

- [ ] **Step 2: Implement command and download cards**

`CommandCard.astro` renders notes and one or more `CopyCode` instances without merging unrelated command fields.

`DownloadCard.astro` renders title, kind, size, tags, SHA-256, and a download button. Picture categories render thumbnails.

- [ ] **Step 3: Implement pages**

Home shows real entry points immediately. Command pages render data by group/slug. Download pages render overview and category pages.

- [ ] **Step 4: Run validation**

Run: `node tools/validate-astrowind-merged.mjs`

Expected: PASS.

### Task 5: Install, Build, And Preview

**Files:**
- Modify generated project only if build errors reveal required Astro compatibility fixes.

- [ ] **Step 1: Install dependencies**

Run in `astrowind_merged/`: `npm install`

Expected: dependencies install.

- [ ] **Step 2: Build**

Run in `astrowind_merged/`: `npm run build`

Expected: Astro build succeeds and outputs `dist/`.

- [ ] **Step 3: Start preview server**

Run in `astrowind_merged/`: `npm run dev -- --host 0.0.0.0`

Expected: site is reachable from Windows browser through `http://10.0.0.165:<port>/`.

### Task 6: Manual Verification

**Files:**
- No planned file edits.

- [ ] **Step 1: Check navigation**

Open the preview URL. Verify the header shows `Debian`, `PVE`, `VyOS配置`, `Windows`, and `下载`, each with dropdown items.

- [ ] **Step 2: Check copy behavior**

Open a page with single-line commands and a page with multi-line config. Verify each copy button copies exactly its own command or full configuration block.

- [ ] **Step 3: Check downloads**

Open `/downloads/`, `/downloads/windows-tools/`, and `/downloads/pictures/`. Verify explanations, SHA-256 values, download buttons, and image previews.

- [ ] **Step 4: Final validation**

Run: `node tools/validate-astrowind-merged.mjs` and `npm run build`.

Expected: both pass.
