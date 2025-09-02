---
layout: main
type: post
title: A few updates for September
author: Robert Zehnder
slug: a-few-updates
date: 2025-09-01 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2025/construction.jpg
description: Introducing bx-setup and boxlang-ssg updates
tags:
- boxlang
- cfml
---

### bx-setup: Install BoxLang modules from a requirements file

Quick update: I built `bx-setup`, a tiny helper that reads a simple `requirements.txt` and installs the BoxLang modules your project needs. It makes getting started with `boxlang-ssg` (and other projects) a bit smoother.

https://github.com/robertz/bx-setup

Get started in three small steps:

1) Create `requirements.txt` in your project root:

```text
# One module per line
bx-jsoup
bx-markdown@1.0.0   # require >= 1.0.0
bx-yaml             # latest available

# Blank lines and lines starting with # are ignored
```

2) Run the setup script (from your project or elsewhere):

```bash
boxlang setup.bx
```

3) Prefer a preview first? Do a dry run:

```bash
boxlang setup.bx --dry-run
```

Behavior details:

- No version specified: installs the latest available.
- Version specified: skips if that version or newer is already installed.
- Comments/blank lines are ignored in `requirements.txt`.

If you give it a try, I’d love feedback and ideas for what would help next.

---

### boxlang-ssg

There have been a few updates to `boxlang-ssg`. The `outputDir` in `ssg-config` will now be honored so you are no longer required to output rendered html in the `_site` directory. There are still a few items in `commandbox-ssg` that are not yet supported in `boxlang-ssg` but I am working to get those missing pieces added.
