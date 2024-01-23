---
layout: main
type: post
title: "cfdocs-ssg: Using ssg to generate larger sites"
author: Robert Zehnder
slug: cfdocs-ssg-using-ssg-to-generate-larger-sites
date: 2024-01-22 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/serene-programming.jpg
description: Commandbox-ssg is not just for blogs
tags:
- cfml
- commandbox
---

Usually `commandbox-ssg` can generate my entire site in half a second or so, it is not very big. I have a few blog posts and I try to keep documentation for projects updated. I thought it would be nice to try it on a more complicated project. As it turns out, there is already a very good candidate to convert to ssg that pretty much all CF devs are already familiar with... 

[CFDocs](https://cfdocs.org)

If you have not ever looked at the structure of CFDocs you should, because it is slick. CFDocs is primarily made up of json files, one file for each ColdFusion tag or function. There are over 900 `.json` files altogether. The guides section is much smaller, with around 20 markdown files. I thought this could be a good test for commandbox-ssg so I asked Pete Freitag from [Foundeo](https://foundeo.com) if he would be ok with me pillaging his data. He was cool with it, as it turns out, so off I went.

The first part of the task was adding the new functionality needed. The `ssg build` code was getting unwieldy so it was a good time to refactor and a few other issues were resolved. The `excludeFromCollections` flag was not working correctly, it now works as intended. The `publishedDate` property has been deprecated and renamed to the more generic `date`. The `date` value will default to the last modified date of the file, unless you speficy `date` in the the documents front matter. Document type `post` will automatically be sorted by date, descending. 

Directory and path handling has been normalized every where. Before, some parts of the configuration expected a leading slash, other parts did not. Now configuration files **do not** require a leading slash.

Next, the way imported data was handled needed to be modified. The CFDocs site does some organization when the application starts up and some of that logic needs to be replicated. Now when you begin a build, the json files in the `_data` directory and subdirectories will be automatically loaded in to the `collections.global` structure. Referenced based on the filename, for instance `_data/some/nested/data.json` will be available on the page as `collections.global.some.nested.data`. In this case, the CFDocs `data/en/*.json` will be loaded. The one change I did have to make to the data structure is move `index.json` to its parent directory because it was causing the pagination to overwrite the root index page.

The last issue to solve was getting the helper functions in CFDocs `Application.cfc` to work. Here I decided to take a page from how ColdBox works and introduced `_includes/applicationHelper.cfm`. Just like ColdBox, any functions in this file will be available to the application. This file gets executed immediately after external data is loaded, any code not encapsulated as a function will get executed. This allowed me to get the helper functions from CFDocs working, and also allowed me porocess the data once it has been loaded.

Most of the ground work done, time for the fun stuff.

### Building the Site

The first step in the process is getting everythign setup. I created the `cfdocs-ssg` directory that will be the root for the static site. I have already cloned the [cfdocs repo](https://github.com/foundeo/cfdocs) for the data an assets. The markdown files are copied from the CFDocs repo guide folder and placed in the root. It will look a little messy, but it will retain the same directory structure as CFDocs.

Next, move the JSON files from `data/en` to the `_data/en` directory in the project root. As noted above, we need to move `_data/en/index.json` to `_data/index.json`.

Finally, copy the repo `/assets` folder to the sites root directory. 

Now it is time to take care of the logic found in `Application.cfc`. I moved the helper functions in to `applicationHelper.cfm`. There is some additional logic in `onRequest()` that prepares the data and caches it in the application scope. The code at the top of `applicationHelper.cfm` does something similar, but is storing the data in the `collections` scope, as opposed to the `application` scope.
You can see the end result here:

[/_includes/applicationHelper.cfm](https://github.com/robertz/cfdocs-ssg/blob/main/_includes/applicationHelper.cfm)

Now its time to get the layout working. Copy `views/layout.cfm` from the CFDocs repo  to `_includes/layouts/main.cfm`. Much of the code will work, but again we need to fix the references to `application.categories`. For now, I have commented out the social media meta tags in the header. The rendered content in the layout has been changed from `request.content` to `renderedHtml`.

[/_includes/layouts/main.cfm](https://github.com/robertz/cfdocs-ssg/blob/main/_includes/layouts/main.cfm)

With the layout done, it is time to focus on the home page. This is a simple page so we can simply copy the file from the repo. I will add some front matter to set the view type to `home`. This will render the content without being wrapped in a container class.

[/index.cfm](https://github.com/robertz/cfdocs-ssg/blob/main/index.cfm)

Next up is getting the default page view setup that will be used for the guides. 

[/_includes/page.cfm](https://github.com/robertz/cfdocs-ssg/blob/main/_includes/page.cfm)

Finally it is time to focus on the functions and tags using the CFDocs rep `docs.cfm` view as the template using pagination to generate the files. This page is generated using pagination, looping through all data elements, in this case `collections.global.en` which happens to be function and tag data.

<br>

```md
<!--- 
view: home 
permalink: /{{el}}.html
pagination:
  data: collections.global.en
  alias: el
--->
```

<br>

This will iterate through all 900+ tags and function data and generate a page for each item.

[/docs.cfm](https://github.com/robertz/cfdocs-ssg/blob/main/docs.cfm)

All that done, the last thing left is building the site.

<br>

```bash
Writing file: /_site/week.html
Writing file: /_site/wrap.html
Writing file: /_site/writebody.html
Writing file: /_site/writedump.html
Writing file: /_site/writelog.html
Writing file: /_site/writeoutput.html
Writing file: /_site/wsgetallchannels.html
Writing file: /_site/wsgetsubscribers.html
Writing file: /_site/wspublish.html
Writing file: /_site/wssendmessage.html
Writing file: /_site/xmlchildpos.html
Writing file: /_site/xmlelemnew.html
Writing file: /_site/xmlformat.html
Writing file: /_site/xmlgetnodetype.html
Writing file: /_site/xmlnew.html
Writing file: /_site/xmlparse.html
Writing file: /_site/xmlsearch.html
Writing file: /_site/xmltransform.html
Writing file: /_site/xmlvalidate.html
Writing file: /_site/year.html
Writing file: /_site/yesnoformat.html

Compiled 1027 template(s) in 12.491 seconds
```
<br>

It has taken me longer to write about converting CFDocs to a static site than the actual conversion. There are still some issues that need to be resolved, but the really important parts are working. I would say all in, it took about 2 hours to get everything working. That was helped by the fact that CFDocs was already modular.

You can install commandbox-ssg with commandbox: `install commandbox-ssg`

The cfdocs-ssg repo is here: [cfdocs-ssg](https://github.com/robertz/cfdocs-ssg)

Hopefully this will show that `commandbox-ssg` can be versatile and not just for blogs.
