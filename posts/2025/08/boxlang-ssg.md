---
layout: main
type: post
title: Boxlang SSG
author: Robert Zehnder
slug: boxlang-ssg
date: 2025-08-25 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2025/boxlang-ssg.jpg
description: A static site generator written in Boxlang
tags:
- boxlang
- cfml
---
### Intro
BoxLang’s first release candidate arrived in mid-February, and I couldn’t wait to try it out! Work kept me busy, so at first I only managed to create a few command-line tools for data migration and CSV exports—useful, but nothing too exciting.

This weekend, I finally had some free time to build something bigger: `boxlang-ssg`, a static site generator written in BoxLang. It’s inspired by my earlier CommandBox project, `commandbox-ssg`, but this time I wanted to see what BoxLang could do.

---

### Installing boxlang-ssg
If you’ve used `commandbox-ssg` before, you’ll notice a few changes. The CommandBox version is installed as a custom module, while the BoxLang version is simply a single file called `ssg.bx` in your project’s main directory. With CommandBox, you’d build your site using `box ssg build`. In BoxLang, you just run `boxlang ssg.bx build`.

To get started, clone the repo:

```bash
git clone https://github.com/robertz/boxlang-ssg
```

Unlike CommandBox, which bundled all its dependencies, BoxLang requires you to install a few modules for YAML, HTML, and Markdown support. You can install them globally:

```bash
install-bx-module bx-jsoup bx-markdown bx-yaml
```
Or locally:

```bash
install-bx-module bx-jsoup bx-markdown bx-yaml --local
```
If you install locally, don’t forget to add `boxlang-modules` to the `ignore` block in your `ssg-config.json`.

---

### Configuring boxlang-ssg
Setting up `boxlang-ssg` is easy! Just edit your `ssg-config.json` file. For now, the `outputDir` property is ignored and always set to `_site` in your project root. Anything listed in the `passthru` property will be copied to the output directory when you build. Directories in the `ignore` property will be skipped when searching for pages to render.

Here’s an example config:

```js
{
  "outputDir": "_site",
  "passthru": [
    "favicon.ico",
    "assets",
    "router.bxs"
  ],
  "ignore": [
    "boxlang_modules"
  ]
}
```
Tip: If you’re using `boxlang-miniserver` to preview your build, make sure to include `router.bxs` in the `passthru` list.

---

### Running boxlang-ssg
Usage: `boxlang ssg.bx <command>`
* list: show all renderable documents
* build: build documents in the output directory
* help: display available commands and usage

---

### Miniserver
To preview your site locally, use the BoxLang miniserver:

```bash
boxlang-miniserver --webroot ./_site --rewrites router.bxs
```
This sets the webroot to your output directory and enables rewrites using `router.bxs`.

Here’s a simple example of a router file:

```js
// simple router
try {
  include cgi.path_info & ".html"
} catch (any e) {
  include "404.html"
}
```
You can use any HTTP server to preview your site, but I enjoy using BoxLang tools whenever possible.

And that’s it! You’ll be able to browse your static site and see changes instantly. If you have questions or just want to chat about BoxLang or static site generation, feel free to reach out—I’d love to hear from you!
