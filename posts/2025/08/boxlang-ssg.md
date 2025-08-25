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
BoxLang’s first release candidate landed in mid-February, and I was excited to give it a spin! Work kept me busy, so I only managed to whip up a few command-line tools for data migration and CSV exports—handy, but nothing too fancy.

This weekend, I finally found some time to build something bigger: `boxlang-ssg`, a static site generator written in BoxLang. It’s inspired by my earlier CommandBox project, `commandbox-ssg`, but this time I wanted to see what BoxLang could do.

---

### Installing boxlang-ssg

If you’ve used `commandbox-ssg` before, you’ll notice a few differences. The CommandBox version is installed as a custom module, while the BoxLang version is just a single file called `ssg.bx` that sits in your project’s main directory. With CommandBox, you’d build your site using `box ssg build`. In BoxLang, you simply run `boxlang ssg.bx build`.

One other difference: CommandBox bundled all its dependencies in the module. With BoxLang, you’ll need to install a few modules for YAML, HTML, and Markdown support. You can install them globally:

```bash
install-bx-module bx-jsoup bx-markdown bx-yaml
```

Or, if you prefer, install them locally:

```bash
install-bx-module bx-jsoup bx-markdown bx-yaml --local
```

If you go the local route, don’t forget to add `boxlang-modules` to the `ignore` block in your `ssg-config.json`.

---

### Configuring boxlang-ssg

Setting up `boxlang-ssg` is simple! Just edit your `ssg-config.json` file. Right now, the `outputDir` property is ignored and always set to `_site` in your project root. Anything listed in the `passthru` property will be copied to the output directory when you build. Directories in the `ignore` property will be skipped when searching for pages to render.

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

A quick note: If you’re using `boxlang-miniserver` to preview your build, make sure to include `router.bxs` in the `passthru` list.

---

### Running boxlang-ssg

Usage: `boxlang ssg.bx <command>`
* list: display the list of renderable documents
* build: build renderable documents in the outputDir folder
* help: shows list of available commands and usage

---

### Miniserver

To preview your site locally, just use the BoxLang miniserver like this:

```bash
boxlang-miniserver --webroot ./_site --rewrites router.bxs
```

This command sets the webroot to your output directory and enables rewrites using `router.bxs` as the router.

Here’s a simple example of what your router file might look like:

```js
// simple router
try {
  include cgi.path_info & ".html"
} catch (any e) {
  include "404.html"
}
```

Of course, you can use any other HTTP server to preview your site, but I like using BoxLang tools whenever I can.

And that’s it! You’ll be able to browse your static site and see your changes instantly. If you have any questions or just want to chat about BoxLang or static site generation, I’d love to hear from you!