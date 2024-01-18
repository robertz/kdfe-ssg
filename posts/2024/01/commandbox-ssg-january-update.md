---
layout: main
type: post
title: Commandbox-ssg January Update
author: Robert Zehnder
slug: commandbox-ssg-january-update
date: 2024-01-09 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/construction.jpg
description: Commandbox-ssg recent changes
tags:
- cfml
- commandbox
---

The last few days I have been working to correct a few of the bad design decisions I made when starting this project.

#### Config file changes

The `meta` node is no longer supported in `ssg-config.json`. The config file should only contain the settings required to generate the site. 

```js
{
  "outputDir": "_site",
  "passthru": [
    "/favicon.ico", 
    "/assets"
  ],
  "ignore": []
}
```

<br>

#### Layout and view changes

Another change from the previous version is front matter can now be read from your layouts and views. If you have data that needs to be available for every page, the layout template is a good place to put this data. As an example, here is the front matter from my `_includes/layouts/main.cfm` for my blog. Since it is in the layout, this data will be available on every page.

```md
site:
  title: KISDigital
  description: ColdFusion, ColdBox, CommandBox and other assorted musings
  author: Robert Zehnder
  url: https://kisdigital.com
  image: https://static.kisdigital.com/kisdigital-logo.jpg
```

<br>

Here is the order data is merged from the most important to the least important:

* **prc** : Default data required by all templates
* **template** : data specified by the template
* **view** : data specified by the view
* **layout** : data specified in the layout

View and layout data **will not** overwrite template data if it exists.

<br>

#### ssg build

The `ssg build` command is the real workhorse of `commandbox-ssg` and as such has a majority of the improvements. Over the holidays a majority of my time was spent getting Windows support working. Brad Wood was gracious with his time and helped me work out the directory issues I was seeing in Windows. I can generate my personal blog on my Windows machine and that is probably the best unit test.

The build command has been updated to ignore directories starting with a period. Usually this denotes a special directory that you might not wish to be processed.

The next improvement was adding the ability to read and cache front matter from layouts and views. This allows for moving site specific data from `ssg-config.json` to the layout and view templates. Front matter for layouts and views are loaded at startup and cached.

Previously `ssg-build` also would populate the `headers` structure in the `prc` scope that had the opengraph and twitter headers for each template. This was awesome when my blog was running on ColdBox, but not so much on a static site. All this logic was removed from `ssg build` and is now handled in the layout.

This is a little bit embarrassing, but the `published` flag in front matter is now respected. If `published` is false, the template will be skipped when the static site is generated. The `excludeFromCollections` flag is the next one that needs to be corrected.

Finally, `ssg build` will now output the list of templates it generates as well as the total processing time.

<br>

#### ssg watch
The `ssg watch` command has also been updated to detect additional file types that may require rebuilding the static site. It will now detect changes to cfm, md, css, js, and json files and kick off `ssg build` when detected.

These changes will be pushed to [Forgebox.io](https://forgebox.io) later tonight with version `0.0.14` once I have time to update the ssg-skeleton example application. 

I am working on updating documentation as time permits and I welcome any comments or suggestions for making things better!