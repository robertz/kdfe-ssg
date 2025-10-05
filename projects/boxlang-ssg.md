---
type: project
title: boxlang-ssg
description: boxlang-ssg documentation
---
# boxlang-ssg

A static site powered by a BoxLang single-file static site generator. The build logic lives in [`ssg.bx`](ssg.bx) and turns Markdown (`.md`) and BoxLang markup (`.bxm`) files that contain front matter into a full `_site/` output.

## Features
- Lightweight CLI: `build`, `list`, and `help`
- Markdown and `.bxm` templates with YAML front matter
- Layouts, views, and partials under `_includes/`
- Collections for pages, posts, tags, plus JSON data from `_data/`
- Flexible permalinks, custom extensions, passthrough assets, and pagination-aware navigation

## Prerequisites
- BoxLang runtime and CLI (`boxlang` on your PATH)
- Modules listed in `requirements.txt`: `bx-jsoup`, `bx-markdown@1.0.0`, `bx-yaml`

Install modules with the helper script:

```sh
boxlang setup.bx
```

or manually:

```sh
install-bx-module bx-jsoup bx-markdown@1.0.0 bx-yaml
```

## Building

```sh
boxlang ssg.bx build
```

Build artifacts land in `_site/` (configurable in `ssg-config.json`). Use `boxlang ssg.bx list` to inspect which documents were discovered.

## Project layout
- `ssg.bx` – CLI entry point and build pipeline
- `setup.bx` – installs required modules from `requirements.txt`
- `ssg-config.json` – output directory, passthrough, and ignore lists
- `_includes/` – layouts, views, and partials (e.g. `_includes/layouts/main.bxm`)
- `_data/` – optional global JSON data loaded into `collections.global`
- `posts/` – example content
- `assets/` – copied straight through to `_site/`
- `index.bxm`, `tags.bxm`, etc. – sample templates that demonstrate pagination and collections

## Authoring content
Files may include front matter to control metadata and output:

```yaml
---
layout: main
type: post
permalink: /blog/{{slug}}/
title: My Post
description: Short summary
tags:
  - cfml
published: true
---
```

Important front matter keys:
- `type` aligns items with views and collections
- `layout` chooses a layout from `_includes/layouts`
- `view` forces a specific view; defaults to `type` when available
- `permalink` overrides the generated URL so you can opt into pagination placeholders
- `fileExt` customises the written extension (XML, JSON, etc.)
- `pagination` enables paginated output (see next section)

Collections are exposed to templates as `collections.*`. Posts gain tag metadata (`collections.tags`, `collections.byTag`) and `_data/*.json` files become nested structures inside `collections.global`.

## Pagination
Pagination is handled entirely inside `processPagination()`and applies to any template whose front matter includes a `pagination` block. The `pagination` struct supports:

- `data` (required): may be an array supplied directly in front matter or a string pointing to data in scope (e.g. `collections.post`, `collections.global.products`). Strings are resolved via `structGet`, and when the resolved value is a struct the keys are paginated alphabetically.
- `size` (optional, default `1`): number of items per page. Multi-item pagination (`size > 1`) returns arrays; single-item pagination (`size == 1`) emits one template per item.
- `alias` (optional): name used to expose the paged value in the page PRC. When omitted the value is available as `prc.pagedData`.

Examples cover URL outcomes for placeholder, fixed, and implicit permalinks. Key behaviors are:
- If a parent permalink contains `{{page}}` or `{{pageNumber}}`, the first page uses the canonical permalink with placeholders removed, while pages ≥2 substitute the page number.
- Without page placeholders, pages ≥2 fall back to `page/<n>/` under the same base directory. If no permalink is declared, `/<fileSlug>/` is used as the base.
- For single-item paginators that declare an `alias`, the alias placeholder (e.g. `{{tag}}`) is replaced with the value for each item instead of adding page numbers.

Each generated page receives navigation metadata in `prc.paginationInfo`, shaped as:

```js
{
  pageNumber: 2,
  pageSize: 6,
  totalPages: 5,
  totalItems: 30,
  href: {
    current: "/blog/page/2/",
    previous: "/blog/",
    next: "/blog/page/3/",
    first: "/blog/",
    last: "/blog/page/5/"
  },
  pages: [
    { "number": 1, "href": "/blog/", "current": false },
    { "number": 2, "href": "/blog/page/2/", "current": true }
  ]
}
```

This metadata powers the navigation in `index.bxm`, which reads `prc.pagedData` (or the alias) for items and `prc.paginationInfo.pages` to build an accessible pager. The paginator also merges data automatically when the `data` source is a struct: for each key, the corresponding struct value is appended to the per-page PRC so templates can use the expanded record.

## Configuration
`ssg-config.json` controls output settings:

```js
{
  "outputDir": "_site",
  "passthru": ["router.bxs", "assets"],
  "ignore": []
}
```

`outputDir` is purged on each build. Any entries in `passthru` are copied verbatim, and additional ignore rules may be added to skip discovery.
