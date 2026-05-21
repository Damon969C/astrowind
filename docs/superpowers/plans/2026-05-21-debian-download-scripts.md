# Debian Download Scripts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `restore_bundle.py` and `sync_clash_proxy_groups.py` to the Debian scripts download page.

**Architecture:** The source of truth remains `public/downloads/manifest.json` plus files under `public/downloads/debian/`. The Astro site receives generated data and copied assets from `astrowind_merged/scripts/generate-content.mjs`.

**Tech Stack:** Astro/AstroWind, Node.js generator, JSON manifest, existing validation script.

---

### Task 1: Add Regression Validation

**Files:**
- Modify: `tools/validate-astrowind-merged.mjs`

- [ ] **Step 1: Write the failing validation**

Add `restore_bundle.py` and `sync_clash_proxy_groups.py` to the download filename assertions in `tools/validate-astrowind-merged.mjs`.

- [ ] **Step 2: Run validation to verify it fails**

Run: `npm run validate:merged` from `astrowind_merged/`

Expected before implementation: FAIL with missing download data for the two filenames.

### Task 2: Add Source Download Files

**Files:**
- Create: `public/downloads/debian/restore_bundle.py`
- Create: `public/downloads/debian/sync_clash_proxy_groups.py`

- [ ] **Step 1: Copy current scripts into the Debian download source directory**

Run from `/ai/codex/2053`:

```bash
cp restore_bundle.py public/downloads/debian/restore_bundle.py
cp sync_clash_proxy_groups.py public/downloads/debian/sync_clash_proxy_groups.py
```

- [ ] **Step 2: Verify size and SHA-256**

Run:

```bash
stat -c '%n %s' public/downloads/debian/restore_bundle.py public/downloads/debian/sync_clash_proxy_groups.py
sha256sum public/downloads/debian/restore_bundle.py public/downloads/debian/sync_clash_proxy_groups.py
```

Expected:

```text
public/downloads/debian/restore_bundle.py 27224
public/downloads/debian/sync_clash_proxy_groups.py 15886
52d8bd2c125c407b6bc65c09c431a824e283324b87be5e862ec561cfa2dccf7c  public/downloads/debian/restore_bundle.py
c331e5dc17ad43324e76e8cdfa95717773aa1a0a006ca821c033b99d0244f629  public/downloads/debian/sync_clash_proxy_groups.py
```

### Task 3: Update Download Manifest And Generated Site

**Files:**
- Modify: `public/downloads/manifest.json`
- Modify: `public/downloads/SHA256SUMS.txt`
- Generated: `astrowind_merged/src/data/downloads.ts`
- Generated: `astrowind_merged/public/downloads/debian/restore_bundle.py`
- Generated: `astrowind_merged/public/downloads/debian/sync_clash_proxy_groups.py`

- [ ] **Step 1: Add manifest entries**

Add two Debian `Python Script` items with `debian`, `py`, and purpose tags.

- [ ] **Step 2: Add SHA256SUMS entries**

Add matching `debian/<filename>` rows for both scripts.

- [ ] **Step 3: Regenerate Astro content**

Run: `node scripts/generate-content.mjs` from `astrowind_merged/`

Expected: generated downloads data contains both filenames and copied assets exist in `astrowind_merged/public/downloads/debian/`.

### Task 4: Verify

**Files:**
- Read-only verification over generated site.

- [ ] **Step 1: Run merged validation**

Run: `npm run validate:merged`

Expected: PASS.

- [ ] **Step 2: Run type, lint, and format checks**

Run: `npm run check`

Expected: PASS.

- [ ] **Step 3: Build static site**

Run: `npm run build`

Expected: PASS and `dist/downloads/debian-scripts/index.html` includes both filenames.
