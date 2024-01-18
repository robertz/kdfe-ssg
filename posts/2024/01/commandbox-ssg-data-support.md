---
layout: main
type: post
title: Commandbox-ssg with data and updated pagination support
author: Robert Zehnder
slug: commandbox-ssg-with-data-and-updated-pagination-support
date: 2024-01-17 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/serenity.jpg
description: Commandbox-ssg now with data import and pagination enhancements
tags:
- cfml
- commandbox
---

In the tech world, it's always exciting to see tools evolve, and the latest update to `commandbox-ssg` is no exception. This update introduces some key enhancements, primarily focused on integrating external data into applications with greater ease and efficiency. Let's delve into what this means for developers.

### Enhanced Data Integration

One of the standout features in this update is the automated data loading capability. Now, any data residing in the `_data/` directory is automatically loaded and made accessible in the `collections.global` scope, named according to the file name. For instance, a file named `_data/myData.json` becomes readily available in views as `collections.global.myData`. This is a significant step towards simplifying data management, although the current version does not support nested directories. However, plans are underway to incorporate this feature.

### Advanced Pagination Capabilities

Pagination has received a substantial upgrade. `commandbox-ssg` now supports pagination through arrays and objects within the `collections` scope. To illustrate, consider the following example that demonstrates generating pages based on post tags:

```html
<!---
layout: main
view: page
permalink: /tag/{{tag}}.html
pagination:
  alias: tag
  data: collections.tags
--->
<cfoutput>
 <h4>Posts tagged as #prc.tag#</h4>
 <cfloop array="#collections.byTag[generateSlug(prc.tag)]#" index="i">
  <p><a href="#i.permalink#" class="post-link text-decoration-none">#i.title#</a></p>
 </cfloop>
</cfoutput>
```

When dealing with paginated templates, there are several nuances to consider:

- The default return value for paged data is `pagedData` if no alias is set.
- Data can be specified either using Yaml or directly within the `collections` scope.
- A permalink is crucial for correct page generation.

Dynamic tokens in permalinks offer flexibility in content generation. In this case, the pagination of `collections.tags` data utilizes the `{{tag}}` alias for permalink generation. In the absence of a set alias, `pagedData` would be used by default.

Paginating through structures yields an array of struct keys, providing immediate access to the data of the current element.

### Practical Application: The CFDocs Site

A prime example of these capabilities in action is the [CFDocs](https://cfdocs.org) site. Organized in JSON files named by function/tag, the site demonstrates the ease of creating templates to display data. Here's a sample JSON structure from the `abs.json` file:

```js
{
 "name":"abs",
 "type":"function",
 "syntax":"abs(number)",
 "returns":"numeric",
 "related":["sgn"],
 "description":" Absolute-value function. The absolute value of a number is\n the number without its sign.",
 "params": [
  {"name":"number","description":"","required":true,"default":"","type":"numeric","values":[]}
 ],
 "engines": {
  "coldfusion": {"minimum_version":"", "notes":"", "docs":"https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-functions/functions-a-b/abs.html"},
  "lucee": {"minimum_version":"", "notes":"", "docs":"https://docs.lucee.org/reference/functions/abs.html"},
  "railo": {"minimum_version":"", "notes":"", "docs":"http://railodocs.org/index.cfm/function/abs"},
  "openbd": {"minimum_version":"", "notes":"", "docs":"http://openbd.org/manual/?/function/abs"}
 },
 "links": [],
 "examples": [
  {
   "title":"Absolute Value of -4.3",
   "description":"",
   "code":"abs(-4.3)",
   "result":"4.3",
   "runnable":true
  }
 ]

}
```

<br>

By integrating all CFDocs data files into the `_data` directory, one could leverage pagination to generate comprehensive documentation while maintaining the directory structure.

<br>

```html
<!---
type: docs
permalink: /{{element}}.html
pagination:
  data: collections.global
  alias: element
--->
<cfoutput>
 <cfdump var="#prc#"/>
</cfoutput>
```

<br>

While the system still has room for refinement, its current iteration is both functional and efficient, capable of generating over 990 templates in under 30 seconds.

### Deployment

These updates are set to go live with the release of version 0.0.17 of `commandbox-ssg`. This marks a significant milestone in the tool's development, offering developers enhanced capabilities for managing and displaying data in their applications.
