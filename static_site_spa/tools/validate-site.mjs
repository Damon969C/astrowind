import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, "..");
const originalRoot = path.resolve(root, "..");

const failures = [];

function assert(condition, message) {
  if (!condition) {
    failures.push(message);
  }
}

function exists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function read(relativePath) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

const requiredFiles = [
  "index.html",
  "assets/css/app.css",
  "assets/js/app.js",
  "assets/js/content.js",
  "README.md",
  "nginx.conf.example",
];

for (const file of requiredFiles) {
  assert(exists(file), `Missing required file: ${file}`);
}

if (exists("index.html")) {
  const html = read("index.html");
  assert(html.includes('<meta name="viewport"'), "index.html must define a viewport");
  assert(html.includes('id="app"'), "index.html must expose #app");
  assert(
    html.includes('type="module"') && html.includes("./assets/js/app.js"),
    "index.html must load the SPA module"
  );
}

if (exists("assets/css/app.css")) {
  const css = read("assets/css/app.css");
  assert(css.includes("@media"), "app.css must include responsive media queries");
  assert(css.includes("--surface"), "app.css must define the shared design tokens");
  assert(css.includes("--panel-glass"), "app.css must define modern translucent panel tokens");
  assert(css.includes("repeating-linear-gradient"), "app.css must use a layered modern grid background");
  assert(css.includes(".system-card::before"), "system cards must include a refined visual accent");
  assert(css.includes(".doc-content::before"), "document pages must include a refined reading surface accent");
  assert(css.includes(".command-item::before"), "command cards must include a modern section accent");
}

if (exists("assets/js/app.js")) {
  const app = read("assets/js/app.js");
  for (const name of ["renderHome", "renderSystem", "renderCommand", "renderDocument"]) {
    assert(app.includes(`function ${name}`), `app.js must implement ${name}()`);
  }
  assert(app.includes("window.addEventListener(\"hashchange\""), "app.js must use hash routing");
  assert(app.includes("navigator.clipboard.writeText"), "app.js must support copy actions");
  assert(app.includes("data-scroll-target"), "document table of contents must scroll without changing the SPA hash route");
  assert(!app.includes('href="#${escapeAttr(item.id)}"'), "document table of contents must not use plain hash anchors");
  assert(app.includes("getScrollOffset"), "document table of contents must account for the sticky header offset");
  assert(!app.includes("scrollIntoView({ behavior: \"smooth\", block: \"start\" })"), "document table of contents must not hide headings under the sticky header");
  assert(app.includes("fallbackCopyText"), "copy actions must provide a non-Clipboard-API fallback");
  assert(!app.includes("window.prompt"), "copy fallback must not open a prompt popup");
  assert(app.includes("back-actions"), "command pages must expose explicit back navigation");
  assert(app.includes("返回目录"), "command pages must include a visible return-to-directory action");
}

let content = null;
if (exists("assets/js/content.js")) {
  const source = read("assets/js/content.js");
  assert(!source.includes("debian-html"), "content.js must not reference Debian item 18");
  assert(!source.includes('"123"'), "content.js must not reference Debian item 19");

  try {
    const moduleUrl = pathToFileURL(path.join(root, "assets/js/content.js")).href;
    content = await import(`${moduleUrl}?validate=${Date.now()}`);
  } catch (error) {
    failures.push(`content.js must be importable: ${error.message}`);
  }
}

if (content?.siteContent) {
  const { systems, documents } = content.siteContent;
  assert(Array.isArray(systems), "siteContent.systems must be an array");
  assert(Array.isArray(documents), "siteContent.documents must be an array");
  assert(documents.length === 7, `Expected 7 document pages, found ${documents.length}`);

  const systemIds = systems.map((system) => system.id).sort();
  assert(
    JSON.stringify(systemIds) === JSON.stringify(["debian", "openwrt", "pve", "windows"]),
    `Unexpected systems: ${systemIds.join(", ")}`
  );

  const expectedCategoryCounts = {
    debian: 17,
    pve: 6,
    openwrt: 2,
    windows: 6,
  };

  for (const system of systems) {
    assert(
      system.categories.length === expectedCategoryCounts[system.id],
      `${system.id} should expose ${expectedCategoryCounts[system.id]} categories, found ${system.categories.length}`
    );

    for (const category of system.categories) {
      assert(category.id && category.title && category.dataPath, `${system.id} category is incomplete`);
      assert(exists(category.dataPath), `Missing command data file: ${category.dataPath}`);
      const dataText = read(category.dataPath);
      assert(dataText.includes("const commandList"), `${category.dataPath} must contain commandList`);
      try {
        const commandList = new Function(`${dataText}\nreturn commandList;`)();
        assert(commandList && typeof commandList.name === "string", `${category.dataPath} must expose commandList.name`);
        assert(Array.isArray(commandList.commands), `${category.dataPath} must expose commandList.commands`);
      } catch (error) {
        failures.push(`${category.dataPath} must be parseable: ${error.message}`);
      }
    }
  }

  for (const doc of documents) {
    assert(doc.id && doc.title && doc.sourcePath, "Document metadata is incomplete");
    assert(exists(doc.sourcePath), `Missing copied document page: ${doc.sourcePath}`);
  }
}

const excludedPaths = [
  "data/systems/debian/debian-html_commands.js",
  "data/systems/debian/123_commands.js",
  "data/systems/debian/123.js",
];

for (const file of excludedPaths) {
  assert(!exists(file), `Excluded Debian content should not exist: ${file}`);
}

const originalFiles = [
  "static_site/index.html",
  "static_site/js/categories.js",
  "acme.html",
  "adb.html",
  "adguard.html",
  "kernel编译.html",
  "pve_aspm_guide.html",
  "vyos配置.html",
  "常用命令.html",
];

for (const file of originalFiles) {
  assert(fs.existsSync(path.join(originalRoot, file)), `Original comparison file is missing: ${file}`);
}

if (failures.length > 0) {
  console.error(`Validation failed with ${failures.length} issue(s):`);
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log("Validation passed: SPA project files, metadata, copied content, and exclusions are consistent.");
