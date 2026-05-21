# Static Downloads Portal

This directory is a static Cloudflare Pages upload bundle for categorized downloads.

## Pages

- `index.html` - landing page with category cards.
- `category.html?type=debian` - Debian scripts.
- `category.html?type=win` - Windows tools and scripts.
- `category.html?type=reg` - Windows registry files.
- `category.html?type=picture` - picture downloads.

## Downloads

Files are stored under `downloads/<category>/` and rendered from `downloads/manifest.json`.

```text
downloads/
  manifest.json
  SHA256SUMS.txt
  debian/
  win/
  reg/
  picture/
```

Each manifest item records the filename, download path, byte size, SHA-256, file kind, and tags. Add new files to the matching category directory and update `manifest.json`.

## Deploy

Upload `public/` as the Pages static output directory.

```bash
npx wrangler pages deploy public
```

If you use the Cloudflare dashboard, choose Pages, create a project with Direct Upload, and upload the contents of this `public/` directory.

## Verify

Run the local integrity check from the project root:

```bash
python3 scripts/verify_static_site.py
```

After downloading files and `SHA256SUMS.txt` from the `downloads/` directory:

```bash
sha256sum -c SHA256SUMS.txt
```
