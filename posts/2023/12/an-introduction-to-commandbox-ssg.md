---
layout: main
type: post
title: An introduction to commandbox-ssg
author: Robert Zehnder
slug: an-introduction-to-commandbox-ssg
date: 2023-12-14 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2023/woman-writing.jpeg
description: How to get started with commandbox-ssg
tags:
- cfml
- commandbox
---
#### Introduction

This module, a static site generator for CommandBox, is a personal favorite among the modules I've had the pleasure of working on. This guide aims to provide an overview of installing, using, and configuring CommandBox-SSG for your web projects.

#### Installation Guide

Getting started with CommandBox-SSG is straightforward. Simply execute the following command:

```bash
box install commandbox-ssg
```

This command seamlessly installs the necessary components, setting the stage for your project development.

#### Usage Instructions

Post-installation, CommandBox-SSG enriches your toolbox with several new commands:

- **ssg init:** Initializes a basic site in the current folder.
- **ssg build:** Builds the static site to the output folder.
- **ssg watch:** Monitors the current folder, automatically building the site upon detecting changes.

#### Project Scaffolding

To scaffold your first project, ensure `box` is operational. Then execute:

```bash
❯ mkdir test-project --cd
❯ ssg init
❯ ssg build
❯ ssg watch
```

This sequence establishes a basic blog site by downloading the [ssg-skeleton](https://github.com/robertz/ssg-skeleton) from GitHub. The `ssg build` command then writes files to the `_site/` output folder, crucial for the initial setup. Finally, `ssg watch` ensures continuous site updates during development.

This also configures the local http server and rewrites required to serve the static content. Issuing `server start` from your project directory will allow you to browse your content locally.

#### Configuring Your Site

The `ssg-config.json` file is your starting point for site customization. It allows you to define several critical aspects:

- **Title:** Sets the browser title bar text.
- **Description:** Provides a brief site summary, used in meta headers.
- **Author:** Names the website's author.
- **URL:** Specifies the site's URL.
- **OutputDir:** Determines the sub-folder for static content.
- **Passthru:** Lists files/directories copied to `outputDir` with each build.

Sample configuration:

```js
{
	"meta": {
		"title": "commandbox-ssg",
		"description": "commandbox static site generator",
		"author": "ssg",
		"url": "https://example.com"
	},
	"outputDir": "_site",
	"ignore": [
        "/_includes"
	],
	"passthru": ["/assets"]
}
```

#### Crafting Your First Blog Pages

Adding new pages is as simple as creating a CFML or Markdown template in your project directory. Each template requires metadata, also known as front matter, which varies slightly between Markdown and CFML templates.

Markdown example:

```md
---
layout: main
type: post
slug: marvel-movies-in-order
title: Marvel Movies in Chronological Order
author: Jasper
description: A listing of all the Marvel movies in timeline order
tags:
- misc
- movies
image: https://static.kisdigital.com/images/marvel/00_anthology.jpeg
published: true
date: 2020-05-18
---
```

CFML example:

```md
<!---
layout: none
permalink: /sitemap.xml
excludeFromCollections: true
--->
```

The front matter details layout, type, slug, title, author, description, tags, image, published status, publish date, permalink, and exclusion from collections.

#### Understanding the Collections Scope

`commandbox-ssg` is influenced by other static site generators, notably [11ty](https://11ty.dev). It features a `collections` scope that categorizes pages by type and tags, facilitating easy navigation and linking throughout your site.

#### Conclusion

The revitalization of `commandbox-ssg` from GitHub has been a rewarding journey. This tool not only powers this site but continues to evolve, with a focus on user-friendliness and troubleshooting. Feedback and contributions to its development are highly encouraged.