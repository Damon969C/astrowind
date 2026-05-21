import { siteContent } from "./content.js";

const app = document.getElementById("app");
const commandCache = new Map();
const documentCache = new Map();
let renderSerial = 0;

window.addEventListener("hashchange", render);
window.addEventListener("DOMContentLoaded", render);

document.addEventListener("click", (event) => {
  const scrollButton = event.target.closest("[data-scroll-target]");
  if (scrollButton) {
    event.preventDefault();
    scrollToDocumentSection(scrollButton.dataset.scrollTarget);
    return;
  }

  const copyButton = event.target.closest("[data-copy]");
  if (copyButton) {
    event.preventDefault();
    const target = copyButton.closest("[data-copy-source]");
    copyToClipboard(target?.dataset.copySource || "", copyButton);
    return;
  }

  const toggleButton = event.target.closest("[data-toggle-code]");
  if (toggleButton) {
    event.preventDefault();
    const block = toggleButton.closest(".code-block, .codeblock-container");
    toggleCodeBlock(block, toggleButton);
  }
});

document.addEventListener("input", (event) => {
  const input = event.target.closest("[data-filter-input]");
  if (input) {
    filterCurrentView(input.value);
  }
});

window.copyText = (text, button) => copyToClipboard(text, button);
window.copyCode = (button) => {
  const code = button?.parentElement?.querySelector("pre code")?.innerText || "";
  copyToClipboard(code, button);
};
window.toggleCode = (button) => {
  const block = button?.closest(".codeblock-container");
  toggleCodeBlock(block, button);
};
window.closeToc = () => {};

async function render() {
  const serial = ++renderSerial;
  const route = getRoute();
  app.innerHTML = renderLoadingShell(route);

  try {
    let html = "";
    if (route.type === "home") {
      html = renderHome();
    } else if (route.type === "system") {
      html = renderSystem(route.systemId);
    } else if (route.type === "command") {
      html = await renderCommand(route.systemId, route.categoryId);
    } else if (route.type === "document") {
      html = await renderDocument(route.documentId);
    } else {
      html = renderNotFound();
    }

    if (serial === renderSerial) {
      app.innerHTML = html;
      activateCurrentLinks();
      refreshCounts();
    }
  } catch (error) {
    if (serial === renderSerial) {
      app.innerHTML = renderShell({
        title: "加载失败",
        kicker: "Error",
        breadcrumbs: [{ label: "首页", href: "#/" }, { label: "加载失败" }],
        content: `
          <section class="state-panel">
            <h1>内容加载失败</h1>
            <p>${escapeHtml(error.message)}</p>
          </section>
        `,
      });
    }
  }
}

function getRoute() {
  const hash = decodeURIComponent(window.location.hash.replace(/^#\/?/, ""));
  const parts = hash.split("/").filter(Boolean);

  if (parts.length === 0) {
    return { type: "home" };
  }

  if (parts[0] === "system" && parts[1]) {
    return { type: "system", systemId: parts[1] };
  }

  if (parts[0] === "command" && parts[1] && parts[2]) {
    return { type: "command", systemId: parts[1], categoryId: parts[2] };
  }

  if (parts[0] === "doc" && parts[1]) {
    return { type: "document", documentId: parts[1] };
  }

  return { type: "not-found" };
}

function renderHome() {
  const commandCount = siteContent.systems.reduce((sum, system) => sum + system.categories.length, 0);
  const content = `
    <section class="overview-band">
      <div class="overview-copy">
        <p class="eyebrow">静态单页文档库</p>
        <h1>${escapeHtml(siteContent.title)}</h1>
        <p>把系统命令、运维脚本和独立文档集中到一个可搜索、可复制、可托管的静态站点。</p>
      </div>
      <div class="metric-strip" aria-label="站点统计">
        ${metric("系统", siteContent.systems.length)}
        ${metric("命令目录", commandCount)}
        ${metric("独立文档", siteContent.documents.length)}
      </div>
    </section>

    <section class="toolbar-row">
      <label class="search-field">
        <span>搜索</span>
        <input data-filter-input type="search" placeholder="输入系统、目录或文档名称" autocomplete="off" />
      </label>
    </section>

    <section class="content-section">
      <div class="section-heading">
        <p class="eyebrow">Systems</p>
        <h2>系统命令库</h2>
      </div>
      <div class="card-grid system-grid">
        ${siteContent.systems.map((system) => systemCard(system)).join("")}
      </div>
    </section>

    <section class="content-section">
      <div class="section-heading">
        <p class="eyebrow">Documents</p>
        <h2>独立文档库</h2>
      </div>
      <div class="card-grid docs-grid">
        ${siteContent.documents.map((doc) => documentCard(doc)).join("")}
      </div>
    </section>
  `;

  return renderShell({
    title: siteContent.title,
    kicker: "Home",
    breadcrumbs: [{ label: "首页" }],
    content,
  });
}

function renderSystem(systemId) {
  const system = findSystem(systemId);
  if (!system) {
    return renderNotFound();
  }

  const content = `
    <section class="page-heading">
      <p class="eyebrow">${escapeHtml(system.title)}</p>
      <h1>${escapeHtml(system.title)} 命令目录</h1>
      <p>${escapeHtml(system.summary)}</p>
    </section>

    <section class="toolbar-row">
      <label class="search-field">
        <span>搜索目录</span>
        <input data-filter-input type="search" placeholder="输入命令目录名称" autocomplete="off" />
      </label>
      <div class="result-count"><span data-visible-count>${system.categories.length}</span> / ${system.categories.length}</div>
    </section>

    <section class="content-section">
      <div class="category-list">
        ${system.categories
          .map((category, index) => categoryRow(system, category, index + 1))
          .join("")}
      </div>
    </section>
  `;

  return renderShell({
    title: `${system.title} 命令目录`,
    kicker: system.title,
    activeSystemId: system.id,
    breadcrumbs: [
      { label: "首页", href: "#/" },
      { label: system.title },
    ],
    content,
  });
}

async function renderCommand(systemId, categoryId) {
  const system = findSystem(systemId);
  const category = system?.categories.find((item) => item.id === categoryId);
  if (!system || !category) {
    return renderNotFound();
  }

  const commandList = await loadCommandList(category);
  const normalized = (commandList.commands || []).map((command, index) => normalizeCommand(command, index));

  const content = `
    <section class="page-heading">
      <p class="eyebrow">${escapeHtml(system.title)}</p>
      <h1>${escapeHtml(category.title)}</h1>
      <p>${escapeHtml(category.summary || commandList.name || "")}</p>
    </section>

    <section class="toolbar-row">
      <label class="search-field">
        <span>搜索命令</span>
        <input data-filter-input type="search" placeholder="输入说明、备注或命令内容" autocomplete="off" />
      </label>
      <div class="result-count"><span data-visible-count>${normalized.length}</span> / ${normalized.length}</div>
    </section>

    <nav class="back-actions" aria-label="返回导航">
      <a class="secondary-link" href="#/system/${system.id}">返回目录</a>
      <a class="ghost-link" href="#/">返回首页</a>
    </nav>

    <section class="command-stack">
      ${normalized.map((command) => renderCommandItem(command)).join("")}
    </section>
  `;

  return renderShell({
    title: `${category.title} - ${system.title}`,
    kicker: "Command",
    activeSystemId: system.id,
    breadcrumbs: [
      { label: "首页", href: "#/" },
      { label: system.title, href: `#/system/${system.id}` },
      { label: category.title },
    ],
    content,
  });
}

async function renderDocument(documentId) {
  const doc = siteContent.documents.find((item) => item.id === documentId);
  if (!doc) {
    return renderNotFound();
  }

  const fragment = await loadDocumentFragment(doc);
  const tocItems = buildDocumentToc(fragment);
  const content = `
    <section class="page-heading">
      <p class="eyebrow">${escapeHtml(doc.group)}</p>
      <h1>${escapeHtml(doc.title)}</h1>
      <p>${escapeHtml(doc.summary)}</p>
    </section>

    <section class="toolbar-row">
      <label class="search-field">
        <span>文档搜索</span>
        <input data-filter-input type="search" placeholder="输入文档中的关键字" autocomplete="off" />
      </label>
    </section>

    <section class="doc-layout">
      <aside class="doc-toc" aria-label="文档目录">
        <p class="toc-title">目录</p>
        ${tocItems.length ? `<nav>${tocItems.map((item) => tocLink(item)).join("")}</nav>` : "<p class=\"muted\">无目录</p>"}
      </aside>
      <article class="doc-content">
        ${fragment.innerHTML}
      </article>
    </section>
  `;

  return renderShell({
    title: doc.title,
    kicker: "Document",
    breadcrumbs: [
      { label: "首页", href: "#/" },
      { label: doc.title },
    ],
    content,
  });
}

function renderNotFound() {
  return renderShell({
    title: "未找到内容",
    kicker: "404",
    breadcrumbs: [{ label: "首页", href: "#/" }, { label: "未找到内容" }],
    content: `
      <section class="state-panel">
        <h1>未找到内容</h1>
        <p>当前链接没有对应的系统、命令目录或文档。</p>
        <a class="primary-link" href="#/">返回首页</a>
      </section>
    `,
  });
}

function renderLoadingShell(route) {
  return renderShell({
    title: route.type === "home" ? siteContent.title : "加载中",
    kicker: "Loading",
    breadcrumbs: [{ label: "首页", href: "#/" }],
    content: `
      <section class="state-panel">
        <h1>正在加载</h1>
        <p>请稍候。</p>
      </section>
    `,
  });
}

function renderShell({ title, kicker, breadcrumbs, content, activeSystemId = "" }) {
  document.title = `${title} - ${siteContent.title}`;

  return `
    <header class="topbar">
      <a class="brand" href="#/" aria-label="返回首页">
        <span class="brand-mark">SC</span>
        <span>
          <strong>${escapeHtml(siteContent.title)}</strong>
          <small>Static Console</small>
        </span>
      </a>
      <nav class="topnav" aria-label="主导航">
        ${siteContent.systems
          .map((system) => `<a class="${system.id === activeSystemId ? "active" : ""}" href="#/system/${system.id}">${escapeHtml(system.title)}</a>`)
          .join("")}
      </nav>
    </header>

    <div class="workspace">
      <aside class="sidebar" aria-label="侧边导航">
        <div class="sidebar-block">
          <p class="sidebar-title">系统</p>
          ${siteContent.systems
            .map((system) => sidebarSystemLink(system, activeSystemId))
            .join("")}
        </div>
        <div class="sidebar-block">
          <p class="sidebar-title">文档</p>
          ${siteContent.documents.slice(0, 7).map((doc) => `<a href="#/doc/${doc.id}">${escapeHtml(doc.title)}</a>`).join("")}
        </div>
      </aside>

      <main class="main-panel">
        <div class="breadcrumbs" aria-label="面包屑">
          <span>${escapeHtml(kicker)}</span>
          ${breadcrumbs.map((item) => breadcrumb(item)).join("")}
        </div>
        ${content}
      </main>
    </div>
  `;
}

function systemCard(system) {
  return `
    <a class="system-card filter-item" href="#/system/${system.id}" data-filter-text="${escapeAttr(`${system.title} ${system.summary}`)}">
      <span class="system-icon ${escapeAttr(system.accent)}">${escapeHtml(system.title.slice(0, 2))}</span>
      <strong>${escapeHtml(system.title)}</strong>
      <span>${escapeHtml(system.summary)}</span>
      <small>${system.categories.length} 个命令目录</small>
    </a>
  `;
}

function documentCard(doc) {
  return `
    <a class="doc-card filter-item" href="#/doc/${doc.id}" data-filter-text="${escapeAttr(`${doc.title} ${doc.summary} ${doc.group}`)}">
      <span>${escapeHtml(doc.group)}</span>
      <strong>${escapeHtml(doc.title)}</strong>
      <small>${escapeHtml(doc.summary)}</small>
    </a>
  `;
}

function categoryRow(system, category, index) {
  return `
    <a class="category-row filter-item" href="#/command/${system.id}/${category.id}" data-filter-text="${escapeAttr(`${category.title} ${category.summary}`)}">
      <span class="category-index">${String(index).padStart(2, "0")}</span>
      <span class="category-main">
        <strong>${escapeHtml(category.title)}</strong>
        <small>${escapeHtml(category.summary || "")}</small>
      </span>
      <span class="category-action">查看</span>
    </a>
  `;
}

function renderCommandItem(command) {
  const body = command.fields.map((field) => renderCommandField(field)).join("");
  return `
    <article class="command-item filter-item" data-filter-text="${escapeAttr(command.searchText)}">
      <div class="command-number">${command.indexLabel}</div>
      <div class="command-body">${body || "<p class=\"muted\">无内容</p>"}</div>
    </article>
  `;
}

function renderCommandField(field) {
  if (field.type === "desc") {
    return `<h2 class="command-desc">${escapeHtml(field.value)}</h2>`;
  }

  if (field.type === "info") {
    return `<p class="command-info">${escapeHtml(field.value)}</p>`;
  }

  if (field.type === "code") {
    return renderCodeBlock(field.value);
  }

  return "";
}

function renderCodeBlock(codeText) {
  const lineCount = codeText.trimEnd().split("\n").length;
  const collapsed = lineCount > 7;
  return `
    <div class="code-block ${collapsed ? "is-collapsed" : ""}" data-copy-source="${escapeAttr(codeText)}">
      <button class="copy-action" type="button" data-copy>复制</button>
      <pre><code>${escapeHtml(codeText)}</code></pre>
      ${collapsed ? '<button class="toggle-action" type="button" data-toggle-code>展开</button>' : ""}
    </div>
  `;
}

async function loadCommandList(category) {
  if (commandCache.has(category.dataPath)) {
    return commandCache.get(category.dataPath);
  }

  const response = await fetch(category.dataPath);
  if (!response.ok) {
    throw new Error(`无法加载命令数据：${category.dataPath}`);
  }

  const source = await response.text();
  const commandList = new Function(`${source}\nreturn commandList;`)();
  commandCache.set(category.dataPath, commandList);
  return commandList;
}

function normalizeCommand(command, index) {
  const fields = [];

  if (Array.isArray(command.fields)) {
    for (const field of command.fields) {
      const value = resolveFieldValue(field.value, field.isBase64);
      if (field.type === "code" && Array.isArray(value)) {
        value.forEach((item) => pushField(fields, "code", item));
      } else {
        pushField(fields, field.type, value);
      }
    }
  } else {
    pushField(fields, "desc", command.desc || "");
    pushField(fields, "info", command.info || "");
    pushCodeField(fields, command.code, false);
    pushCodeField(fields, command.base64Code, true);
  }

  const searchText = fields.map((field) => field.value).join(" ");

  return {
    indexLabel: String(index + 1).padStart(2, "0"),
    fields,
    searchText,
  };
}

function pushCodeField(fields, value, isBase64) {
  if (!value) return;
  const values = Array.isArray(value) ? value : [value];
  values.forEach((item) => pushField(fields, "code", resolveFieldValue(item, isBase64)));
}

function pushField(fields, type, value) {
  const text = typeof value === "string" ? value.trimEnd() : "";
  if (!type || !text.trim()) {
    return;
  }
  fields.push({ type, value: text });
}

function resolveFieldValue(value, isBase64) {
  if (Array.isArray(value)) {
    return value.map((item) => resolveFieldValue(item, isBase64));
  }
  const text = String(value || "");
  return isBase64 ? decodeBase64(text) : text;
}

function decodeBase64(base64Text) {
  const normalized = base64Text.replace(/-/g, "+").replace(/_/g, "/").replace(/\s/g, "");
  try {
    const binary = atob(normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "="));
    const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0));
    return new TextDecoder("utf-8").decode(bytes);
  } catch {
    return "Base64 解码失败";
  }
}

async function loadDocumentFragment(doc) {
  if (documentCache.has(doc.id)) {
    return documentCache.get(doc.id).cloneNode(true);
  }

  const response = await fetch(doc.sourcePath);
  if (!response.ok) {
    throw new Error(`无法加载文档：${doc.sourcePath}`);
  }

  const html = await response.text();
  const parsed = new DOMParser().parseFromString(html, "text/html");
  const source = parsed.querySelector(".main") || parsed.querySelector(".container") || parsed.body;
  const fragment = document.createElement("div");
  fragment.innerHTML = source.innerHTML;

  sanitizeDocumentFragment(fragment);
  documentCache.set(doc.id, fragment.cloneNode(true));
  return fragment;
}

function sanitizeDocumentFragment(fragment) {
  fragment.querySelectorAll("script, style, .toc-toggle, .toc-overlay, .toc, .topbar, .search, .counter").forEach((node) => node.remove());

  fragment.querySelectorAll(".copy, .copy-btn").forEach((button) => {
    button.setAttribute("type", "button");
  });

  fragment.querySelectorAll(".codeblock-container").forEach((block) => {
    block.querySelectorAll(".toggle").forEach((button) => {
      button.setAttribute("data-toggle-code", "");
      button.setAttribute("type", "button");
    });
    const fullCode = block.querySelector(".full code")?.innerText || block.querySelector("pre code")?.innerText || "";
    if (fullCode) {
      block.dataset.copySource = fullCode;
      block.querySelectorAll(".copy").forEach((button) => {
        button.setAttribute("data-copy", "");
        button.setAttribute("type", "button");
      });
    }
  });

  fragment.querySelectorAll(".code-container, .code-block").forEach((block) => {
    const code = block.querySelector("pre code")?.innerText || block.querySelector("pre")?.innerText || "";
    if (code) {
      block.dataset.copySource = code;
      block.querySelectorAll(".copy-btn, .copy").forEach((button) => {
        button.setAttribute("data-copy", "");
        button.setAttribute("type", "button");
      });
    }
  });
}

function buildDocumentToc(fragment) {
  const headings = [...fragment.querySelectorAll("h1, h2, h3, .top-comment")];
  return headings
    .map((heading, index) => {
      const text = cleanText(heading.textContent);
      if (!text) return null;
      if (!heading.id) {
        heading.id = `section-${index + 1}`;
      }
      return {
        id: heading.id,
        text,
        level: heading.matches("h3") ? 3 : heading.matches("h2, .top-comment") ? 2 : 1,
      };
    })
    .filter(Boolean)
    .slice(0, 80);
}

function filterCurrentView(query) {
  const normalized = query.trim().toLowerCase();
  const items = [...document.querySelectorAll(".filter-item")];
  let visible = 0;

  for (const item of items) {
    const haystack = (item.dataset.filterText || item.textContent || "").toLowerCase();
    const matched = !normalized || haystack.includes(normalized);
    item.hidden = !matched;
    if (matched) visible += 1;
  }

  if (!items.length) {
    filterDocumentContent(normalized);
    return;
  }

  const count = document.querySelector("[data-visible-count]");
  if (count) {
    count.textContent = String(visible);
  }
}

function filterDocumentContent(query) {
  const blocks = [...document.querySelectorAll(".doc-content .card, .doc-content .step, .doc-content .code-container, .doc-content p, .doc-content li")];
  for (const block of blocks) {
    const text = (block.textContent || "").toLowerCase();
    block.hidden = Boolean(query) && !text.includes(query);
  }
}

function refreshCounts() {
  const count = document.querySelector("[data-visible-count]");
  if (count) {
    count.textContent = String(document.querySelectorAll(".filter-item:not([hidden])").length);
  }
}

function activateCurrentLinks() {
  const current = window.location.hash || "#/";
  document.querySelectorAll("a[href]").forEach((link) => {
    if (link.getAttribute("href") === current) {
      link.classList.add("active");
    }
  });
}

function toggleCodeBlock(block, button) {
  if (!block) return;

  if (block.classList.contains("codeblock-container")) {
    const preview = block.querySelector(".preview");
    const full = block.querySelector(".full");
    if (preview && full) {
      const showingFull = full.style.display !== "none";
      preview.style.display = showingFull ? "" : "none";
      full.style.display = showingFull ? "none" : "";
      button.textContent = showingFull ? "展开" : "折叠";
      return;
    }
  }

  block.classList.toggle("is-collapsed");
  button.textContent = block.classList.contains("is-collapsed") ? "展开" : "折叠";
}

async function copyToClipboard(text, button) {
  if (!text) return;

  const normalizedText = text.replace(/\r\n/g, "\n");
  let copied = false;

  try {
    if (navigator.clipboard?.writeText && window.isSecureContext) {
      await navigator.clipboard.writeText(normalizedText);
      copied = true;
    }
  } catch {
    copied = false;
  }

  if (!copied) {
    copied = fallbackCopyText(normalizedText);
  }

  updateCopyButton(button, copied);
}

function fallbackCopyText(text) {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "fixed";
  textarea.style.top = "-1000px";
  textarea.style.left = "-1000px";
  textarea.style.opacity = "0";

  document.body.appendChild(textarea);
  textarea.focus();
  textarea.select();
  textarea.setSelectionRange(0, textarea.value.length);

  let copied = false;
  try {
    copied = document.execCommand("copy");
  } catch {
    copied = false;
  }

  textarea.remove();
  return copied;
}

function updateCopyButton(button, copied) {
  if (!button) return;

  const previous = button.textContent;
  button.textContent = copied ? "已复制" : "复制失败";
  button.classList.toggle("copy-failed", !copied);
  setTimeout(() => {
    button.textContent = previous || "复制";
    button.classList.remove("copy-failed");
  }, copied ? 1200 : 1800);
}

function scrollToDocumentSection(sectionId) {
  if (!sectionId) return;

  const target = document.getElementById(sectionId);
  if (!target) return;

  const nextTop = Math.max(0, target.getBoundingClientRect().top + window.scrollY - getScrollOffset());
  window.scrollTo({ top: nextTop, behavior: "smooth" });
  if (!target.hasAttribute("tabindex")) {
    target.setAttribute("tabindex", "-1");
  }
  target.focus({ preventScroll: true });
}

function getScrollOffset() {
  const topbar = document.querySelector(".topbar");
  const isSticky = topbar && getComputedStyle(topbar).position === "sticky";
  const topbarHeight = isSticky ? topbar.getBoundingClientRect().height : 0;
  return Math.ceil(topbarHeight + 18);
}

function findSystem(systemId) {
  return siteContent.systems.find((system) => system.id === systemId);
}

function sidebarSystemLink(system, activeSystemId) {
  return `
    <a class="${system.id === activeSystemId ? "active" : ""}" href="#/system/${system.id}">
      <span>${escapeHtml(system.title)}</span>
      <small>${system.categories.length}</small>
    </a>
  `;
}

function breadcrumb(item) {
  if (item.href) {
    return `<a href="${escapeAttr(item.href)}">${escapeHtml(item.label)}</a>`;
  }
  return `<strong>${escapeHtml(item.label)}</strong>`;
}

function metric(label, value) {
  return `
    <div class="metric">
      <strong>${value}</strong>
      <span>${escapeHtml(label)}</span>
    </div>
  `;
}

function tocLink(item) {
  return `<button class="level-${item.level}" type="button" data-scroll-target="${escapeAttr(item.id)}">${escapeHtml(item.text)}</button>`;
}

function cleanText(text) {
  return String(text || "").replace(/\s+/g, " ").trim();
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function escapeAttr(value) {
  return escapeHtml(value).replace(/`/g, "&#096;");
}
