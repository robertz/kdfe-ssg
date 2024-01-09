---
layout: main
type: post
title: Generating common blog files with Jasper
slug: generating-common-blog-files-with-jasper
description: Generate sitemap.xml and feed.rss with Jasper 0.18.0
author: Robert Zehnder
image: https://static.kisdigital.com/images/2022/07/bonsai-00.jpg
tags: 
- cfml
- commandbox
published: true
publishdate: 2022-08-02
---
My schedule has been full lately leaving little time for fun side projects, but one thing I really wanted to get working in Jasper was the ability to generate templates from CFML. Eleventy allows you to set the output file using the permalink attribute in the front matter and generate a template dynamically using liquid script. I would like Jasper to function in much the same way, but using CFML to generate the page.

#### Generating sitemap.xml

As a quick example, here is a template that will generate `sitemap.xml` for a Jasper blog.

``` html
<!---
layout: none
permalink: /sitemap.xml
excludeFromCollections: true
--->
<cfscript>
 function getPages(collections){
  var ret = collections.all.filter((item) => {
   return item.excludeFromCollections == false && (item.type == "page" || item.type == "post");
  });
  ret.sort( ( e1, e2 ) => {
   return compare( e1.permalink, e2.permalink );
  } );
  return ret;
 }
 lastMod = dateFormat(now(), "yyyy-mm-dd");
savecontent variable="xml" {
writeOutput('<?xml version="1.0" encoding="UTF-8"?>#chr(10)#');
writeoutput('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">#chr(10)#');
for(var p in getPages(collections)){
writeoutput('
<url>
 <loc>#prc.site.url##p.permalink#</loc>
 <lastmod>#lastMod#</lastmod>
</url>
');
}
writeoutput('</urlset>#chr(10)#');
}
</cfscript>
<cfoutput>#xml#</cfoutput>
```

The layout in the front matter is set to `none` so no layout will be rendered. The template content will be to the path specified by the permalink attribute.

The [example blog](https://github.com/robertz/jasper-cli) also has an example `feed.rss` file, but it still a work in progress.

#### Jasper and scopes

Jasper 0.18.0 has two major sources of data used to render templates.

First, the `prc` scope contains all front matter attributes and metadata required to render the page as well as data about the page.

``` js
var prc = {
 "rootDir"   : rootDir,
 "directory" : template.directory,
 "fileSlug"  : template.name.listFirst( "." ),
 "inFile"    : template.directory & "/" & template.name,
 "outFile"   : "",
 "headers"   : [],
 "meta"      : {
  "title"       : "",
  "description" : "",
  "author"      : "",
  "url"         : ""
 },
 // core properties
 "title"                  : "",
 "description"            : "",
 "image"                  : "",
 "published"              : false,
 "publishDate"            : "",
 // other
 "content"                : "",
 "type"                   : "page",
 "layout"                 : "main",
 "permalink"              : true,
 "fileExt"                : "html",
 "excludeFromCollections" : false
};
```

 Next is the `collections` scope which details all the known templates. Inside `collections`, `collections.all` is an array of all templates detected by jasper, templates are also broken out by `type` ("page" or "post") as well as templates broken out by `tag` ("coldfusion", "coldbox", "lucee", etc.). The `tags` array in `collections` lists all tags, `collections.byTag` contains all posts with a given tag.

I would encourage you to take a look at `debug.cfm` in the example blog. This can be installed using the jasper commandbox module `box install commandbox-jasper`, then `box jasper build`, finally `box server start` to run the development server.

#### Jasper and social meta data

Jasper 0.18.0 will now add opengraph and twitter metadata when the template `type` is "post". When the template is rendered the appropriate headers will be set for you. Metadata for other page types will be added in a later release.

#### What is next?

I still have quite a bit of code to clean up, but the next major feature I would like to work on is pagination. Look out for more updates!

Photo by <a href="https://unsplash.com/@tegethoff?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Mark Tegethoff</a> on <a href="https://unsplash.com/s/photos/bonsai?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
