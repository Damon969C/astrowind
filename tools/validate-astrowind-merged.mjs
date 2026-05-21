import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

const cwd = process.cwd();
const root = fs.existsSync(path.join(cwd, "astrowind_merged"))
  ? path.join(cwd, "astrowind_merged")
  : cwd;
const failures = [];
const requiredTopNav = ["Debian", "PVE", "VyOS配置", "Windows", "下载"];
const forbiddenLabels = ["OpenWrt", "FFmpeg", "PowerShell", "Nftables 防火墙"];

function assert(condition, message) {
  if (!condition) failures.push(message);
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

function extractConstValue(source, constName) {
  const marker = `export const ${constName} = `;
  const start = source.indexOf(marker);
  assert(start !== -1, `Missing ${constName} export`);
  if (start === -1) return null;

  const afterMarker = start + marker.length;
  const end = source.indexOf(" satisfies ", afterMarker);
  assert(end !== -1, `Unable to locate ${constName} value end`);
  if (end === -1) return null;

  try {
    return vm.runInNewContext(
      `(${source.slice(afterMarker, end)})`,
      {},
      { timeout: 1000 },
    );
  } catch (error) {
    assert(false, `Unable to parse ${constName}: ${error.message}`);
    return null;
  }
}

function allFields(pages, type) {
  return pages.flatMap((page) =>
    page.items.flatMap((item) =>
      item.fields.filter((field) => field.type === type),
    ),
  );
}

function findPage(pages, group, slug) {
  const page = pages.find(
    (entry) => entry.group === group && entry.slug === slug,
  );
  assert(Boolean(page), `Missing page ${group}/${slug}`);
  return page;
}

function codeValues(page) {
  return page.items.flatMap((item) =>
    item.fields
      .filter((field) => field.type === "code")
      .map((field) => field.value),
  );
}

function assertCode(page, code, message) {
  assert(codeValues(page).includes(code), message);
}

function walkFiles(directory, extensions, files = []) {
  if (!fs.existsSync(directory)) return files;

  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      walkFiles(fullPath, extensions, files);
    } else if (extensions.has(path.extname(entry.name))) {
      files.push(fullPath);
    }
  }

  return files;
}

assert(fs.existsSync(root), "astrowind_merged/ must exist");

if (fs.existsSync(root)) {
  for (const file of [
    "package.json",
    "astro.config.ts",
    "src/navigation.ts",
    "src/pages/index.astro",
  ]) {
    assert(fs.existsSync(path.join(root, file)), `Missing ${file}`);
  }

  const astroConfig = fs.existsSync(path.join(root, "astro.config.ts"))
    ? read("astro.config.ts")
    : "";
  const siteConfig = fs.existsSync(path.join(root, "src/config.yaml"))
    ? read("src/config.yaml")
    : "";
  const packageJson = fs.existsSync(path.join(root, "package.json"))
    ? read("package.json")
    : "";
  const configBuilder = fs.existsSync(
    path.join(root, "vendor/integration/utils/configBuilder.ts"),
  )
    ? read("vendor/integration/utils/configBuilder.ts")
    : "";
  assert(
    astroConfig.includes("trailingSlash: 'never'"),
    "Astro config must use trailingSlash: 'never' for the root-path Cloudflare/Nginx build",
  );
  assert(
    siteConfig.includes("trailingSlash: false"),
    "Astrowind config must use trailingSlash: false for no-trailing-slash links",
  );
  assert(
    siteConfig.includes("base: '/'"),
    "Astrowind config must keep base: '/' for root-path deployment",
  );
  assert(
    !fs.existsSync(path.join(root, "public/.nojekyll")),
    "public/.nojekyll must not remain after rolling back GitHub Pages compatibility changes",
  );
  assert(
    !packageJson.includes("build:github-pages"),
    "package.json must not maintain a second GitHub Pages build",
  );
  assert(
    !packageJson.includes("ASTRO_BASE"),
    "package.json must not hard-code deployment subpaths with ASTRO_BASE",
  );
  assert(
    !packageJson.includes('"postbuild": "node scripts/relativize-dist.mjs"'),
    "package.json must not run the relative path postbuild step after rollback",
  );
  assert(
    !configBuilder.includes("process.env.ASTRO_BASE"),
    "Astrowind config builder must not depend on deployment-specific ASTRO_BASE",
  );
  assert(
    !fs.existsSync(path.join(root, "scripts/relativize-dist.mjs")),
    "scripts/relativize-dist.mjs must not remain after rollback",
  );

  const nav = fs.existsSync(path.join(root, "src/navigation.ts"))
    ? read("src/navigation.ts")
    : "";
  for (const label of requiredTopNav)
    assert(nav.includes(label), `Navigation missing ${label}`);
  for (const label of forbiddenLabels)
    assert(!nav.includes(label), `Navigation must not include ${label}`);
  assert(
    !nav.includes("系统配置、命令复制与下载资源静态站。"),
    "Footer footNote must not include the old bottom-left phrase",
  );

  const downloads = fs.existsSync(path.join(root, "src/data/downloads.ts"))
    ? read("src/data/downloads.ts")
    : "";
  for (const label of ["Debian脚本", "Windows工具", "注册表文件", "图片"]) {
    assert(downloads.includes(label), `Downloads data missing ${label}`);
  }
  assert(
    downloads.includes("sha256"),
    "Downloads data must expose sha256 values",
  );
  for (const filename of [
    "wg-client-manage.sh",
    "generate_singbox_bundle.py",
    "restore_bundle.py",
    "sync_clash_proxy_groups.py",
  ]) {
    assert(downloads.includes(filename), `Downloads data missing ${filename}`);
  }

  const content = fs.existsSync(path.join(root, "src/data/content.ts"))
    ? read("src/data/content.ts")
    : "";
  for (const label of [
    "Linux内核编译",
    "Tmux && Screen",
    "命令示例tar tee find",
    "PVE ASPM设置",
    "ADB命令",
  ]) {
    assert(content.includes(label), `Content data missing ${label}`);
  }
  assert(
    /["']?copyMode["']?\s*:\s*["']single-line["']/.test(content),
    "Content must contain single-line code blocks",
  );
  assert(
    /["']?copyMode["']?\s*:\s*["']block["']/.test(content),
    "Content must contain block code blocks",
  );

  const pages = extractConstValue(content, "contentPages") || [];
  const linuxKernel = findPage(pages, "debian", "linux-kernel-build");
  const diskRdm = findPage(pages, "pve", "disk-rdm");
  const zfs = findPage(pages, "pve", "zfs");
  const adb = findPage(pages, "windows", "adb");

  assertCode(
    linuxKernel,
    "tmux new-session -d -s deb_build 'make bindeb-pkg -j$(nproc) | tee deb_build.log; exec bash'",
    "Linux kernel tmux build command must be a code block",
  );
  assertCode(
    linuxKernel,
    "chmod +x check_kernel.sh",
    "Linux kernel chmod command must be a standalone code block",
  );
  assert(
    codeValues(linuxKernel).some((value) =>
      value.startsWith("cat << 'EOF' > check_kernel.sh\n#!/bin/bash"),
    ),
    "Linux kernel check script must remain one multiline code block",
  );

  for (const code of [
    "ls -la /dev/disk/by-id/|grep -v dm|grep -v lvm|grep -v part",
    "qm set <vmid> --scsiX /dev/disk/by-id/xxxxxxx",
    "qm set 101 --scsi1 /dev/disk/by-id/nvme-INTEL_SSDPE2KX020T8_BTLJ039307142P0BGN",
  ]) {
    assertCode(diskRdm, code, `PVE RDM must keep command separate: ${code}`);
  }

  for (const code of [
    "zfs get primarycache",
    "zfs set primarycache=metadata rpool",
    "0 0 * * 7 /usr/sbin/zpool scrub rpool",
    "intel_iommu=on i915.enable_guc=3 i915.max_vfs=7",
  ]) {
    assertCode(
      zfs,
      code,
      `PVE ZFS must keep command/config line separate: ${code}`,
    );
  }

  assertCode(
    adb,
    "adb shell pm uninstall --user 0 com.coloros.securityguard",
    "ADB commands must not be comma-collapsed",
  );
  assertCode(
    adb,
    "adb shell pm disable-user",
    "ADB disable-user command must be a standalone code block",
  );

  assert(
    allFields(pages, "note").every(
      (field) => !/^\d+(?:\.\d+)*$/.test(field.value.trim()),
    ),
    "Content notes must not contain numeric-only extraction artifacts",
  );
  assert(
    allFields(pages, "note").every(
      (field) =>
        !/tmux new-session|cat << 'EOF'|复制\s+chmod/.test(field.value),
    ),
    "Command text must not be collapsed into prose notes",
  );

  const commandCard = fs.existsSync(
    path.join(root, "src/components/ops/CommandCard.astro"),
  )
    ? read("src/components/ops/CommandCard.astro")
    : "";
  assert(
    !commandCard.includes("rounded-md border border-gray-200 bg-gray-50"),
    "Notes should render as blog prose, not boxed cards",
  );
  assert(
    !commandCard.includes("padStart"),
    "Content section cards must not render numeric 01/02 labels",
  );
  assert(
    !commandCard.includes("String(index + 1)"),
    "Content section cards must not render section index labels",
  );

  const pageHero = fs.existsSync(
    path.join(root, "src/components/ops/PageHero.astro"),
  )
    ? read("src/components/ops/PageHero.astro")
    : "";
  assert(
    !pageHero.includes("eyebrow &&"),
    "Page hero must not render the small eyebrow label above titles",
  );

  for (const file of [
    "src/pages/downloads/index.astro",
    "src/pages/downloads/[slug].astro",
  ]) {
    assert(fs.existsSync(path.join(root, file)), `Missing ${file}`);
  }

  const contentPage = fs.existsSync(
    path.join(root, "src/pages/[group]/[slug].astro"),
  )
    ? read("src/pages/[group]/[slug].astro")
    : "";
  assert(
    contentPage.includes("whitespace-nowrap"),
    "Search label must stay horizontal",
  );

  const headerComponent = fs.existsSync(
    path.join(root, "src/components/widgets/Header.astro"),
  )
    ? read("src/components/widgets/Header.astro")
    : "";
  const footerComponent = fs.existsSync(
    path.join(root, "src/components/widgets/Footer.astro"),
  )
    ? read("src/components/widgets/Footer.astro")
    : "";
  const categoryGrid = fs.existsSync(
    path.join(root, "src/components/ops/CategoryGrid.astro"),
  )
    ? read("src/components/ops/CategoryGrid.astro")
    : "";
  const layoutComponent = fs.existsSync(
    path.join(root, "src/layouts/Layout.astro"),
  )
    ? read("src/layouts/Layout.astro")
    : "";
  assert(
    headerComponent.includes("getPermalink"),
    "Header links must be rendered through getPermalink for base/trailing slash support",
  );
  assert(
    footerComponent.includes("getPermalink"),
    "Footer links must be rendered through getPermalink for base/trailing slash support",
  );
  assert(
    categoryGrid.includes("getPermalink(card.href)"),
    "Category cards must be rendered through getPermalink for base/trailing slash support",
  );
  assert(
    layoutComponent.includes("ClientRouter") &&
      layoutComponent.includes("astro:transitions"),
    "Layout must restore Astro ClientRouter/View Transitions",
  );

  const publicDownloads = path.join(root, "public/downloads");
  assert(
    fs.existsSync(publicDownloads),
    "public/downloads must contain copied assets",
  );

  const distRoot = path.join(root, "dist");
  if (fs.existsSync(distRoot)) {
    assert(
      !fs.existsSync(path.join(distRoot, ".nojekyll")),
      "dist/.nojekyll must not remain after rolling back GitHub Pages compatibility changes",
    );

    for (const file of walkFiles(distRoot, new Set([".html"]))) {
      const relativePath = path.relative(root, file);
      if (relativePath.startsWith("dist/decapcms/")) continue;

      const html = fs.readFileSync(file, "utf8");
      assert(
        /ClientRouter|astro-view-transitions/i.test(html),
        `${relativePath} must include Astro ClientRouter output after rollback`,
      );
      assert(
        /\b(?:href|src|action|poster)\s*=\s*["']\/(?!\/)/i.test(html),
        `${relativePath} must keep root-absolute local URLs after rollback`,
      );
    }
  }
}

if (failures.length) {
  console.error(`Validation failed with ${failures.length} issue(s):`);
  failures.forEach((failure) => console.error(`- ${failure}`));
  process.exit(1);
}

console.log(
  "Validation passed: astrowind_merged structure, navigation, content, and downloads are consistent.",
);
