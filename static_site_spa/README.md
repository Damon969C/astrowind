# 系统配置与命令文档 SPA

这是从当前目录资料整理出的纯静态单页应用。原始文件未改动，所有新项目文件都在 `static_site_spa/`。

## 内容范围

- 系统命令库：Debian、PVE、OpenWrt、Windows。
- 独立文档库：ACME、ADB、AdGuard、Linux 内核编译、PVE ASPM、VyOS、常用命令。
- Debian 原第 18 项 `debian-html`、第 19 项 `123` 以及未引用的 `123.js` 未纳入新项目。

## 本地预览

```bash
python3 -m http.server 8080 --directory static_site_spa
```

访问：

```text
http://127.0.0.1:8080/
```

## nginx

把 nginx `root` 指向 `static_site_spa` 目录即可。示例配置见 `nginx.conf.example`。

## GitHub Pages

可以直接把 `static_site_spa/` 的内容作为 Pages 发布目录。路由使用 hash，不需要服务器重写规则。

## 后续添加内容

1. 新命令目录：把 `*_commands.js` 放到 `data/systems/<system>/`。
2. 在 `assets/js/content.js` 的对应系统 `categories` 中增加一条 `commandCategory(...)`。
3. 新独立文档：把 HTML 放到 `pages/`，再在 `documents` 中增加一条 `documentPage(...)`。
4. 运行 `node tools/validate-site.mjs` 检查索引和文件是否一致。
