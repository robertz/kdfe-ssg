---
layout: main
type: post
title: Commandbox-ssg updates
author: Robert Zehnder
slug: commandbox-ssg-updates
date: 2023-12-19 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2023/serenity.jpg
description: What has been going on with commandbox-ssg lately
tags:
- cfml
- commandbox
---

I've been diligently fixing issues over the past week trying to ensure everything runs well. With the year-end on the horizon, I'm gearing up for a little slowdown, shifting my focus from coding to spending quality time with my family. Let's dive into the latest updates!

#### Exciting Shout-Outs
Big thanks to Eric Peterson and Daniel Garcia for featuring `commandbox-ssg` on the [Modernize or Die Podcast](https://www.youtube.com/watch?v=BbBInJ9LgDo)! It's always a thrill to hear my work being discussed out there. Totally awesome!

#### Recent Code Enhancements
I've rolled out several updates recently. Here's a quick overview of what's new:
<br>

##### Introducing the 'view' attribute
The `type` attribute in your template used to dictate the view from the `_includes` directory for rendering. Now, there's a `view` attribute, giving you the freedom to override the view for rendering your template.

For instance, consider this front matter for a 'project' type page. Instead of crafting a new 'projects' file in `_includes`, I leverage the existing 'page' template.

```md
---
type: project
view: page	
---
```
<br>

##### Enhanced Flexibility for CFML Templates

In the past, while CFML templates let you set a layout, specifying the view for rendering was not possible. That limitation is now history.

```html
<!---
layout: main
view: page
--->
<cfset tag="commandbox" />
<cfoutput>
<h4>Posts tagged as #tag#</h4>
<cfloop array="#collections.byTag[generateSlug(tag)]#" index="i">
	<p><a href="#i.permalink#" class="post-link text-decoration-none">#i.title#</a></p>
</cfloop>
</cfoutput>
```
<br>

##### Proactive Error Prevention

I've been working hard to minimize rendering errors. Commandbox-ssg now includes checks for the existence of essential directories like `_includes` and `_data`. If these directories are present, they'll be utilized; otherwise, your templates will render, just without layouts and views. This enhancement makes commands like the following a breeze:

```bash
box
mkdir my-test-site --cd
echo "### Hello from commandbox-ssg" > index.md
ssg build
```
<br>

##### Preview Your Site Locally with Commandbox

While developing `commandbox-jasper`, Eric Peterson contributed the `.htaccess` and `server.json` files enabling local site serving with commandbox. I've added the `ssg serve` command to check for these files in your current directory, create them if absent, and initiate `server start`.

Make sure to run `ssg build` first to create the webroot (`_site`).
<br>

##### Streamlining Documentation

I acknowledge the scattered state of my documentation and am actively consolidating it. Stay tuned for updates as I improve it.