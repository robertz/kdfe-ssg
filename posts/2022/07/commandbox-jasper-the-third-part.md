---
layout: main
type: post
title: "commandbox-jasper: the third part"
slug: commandbox-jasper-the-third-part
author: Robert Zehnder
description: The continued development on commandbox-jasper
image: https://static.kisdigital.com/images/2022/07/jasper-part-three-00.jpg
tags: 
- cfml
- commandbox
published: true
date: 2022-07-11
---
Photo by <a href="https://unsplash.com/@alesnesetril?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Ales Nesetril</a> on <a href="https://unsplash.com/s/photos/tech?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

A few cool new things have been added thanks to [Eric Peterson](https://github.com/elpete).

It is easy to create a jasper site through the command line. Inside an empty directory, `jasper init` will create a scaffold of [jasper-cli](https://github.com/robertz/jasper-cli). Tip of the hat to Eric.

![jasper init](https://static.kisdigital.com/images/2022/07/jasper-part-three-02.jpg)

The `jasper watch` command rebuilds the static files when it detects a template change.

![jasper watch](https://static.kisdigital.com/images/2022/07/jasper-part-three-03.jpg)

Eric shared a `server.json` and `.htaccess` file that allows `box server start` to function like a lightweight http server. Usually, I would use `netlify dev` or other node module to serve the static content, now I can use commandbox with the same rewrite rules I would expect in production. Very cool.

![box server start](https://static.kisdigital.com/images/2022/07/jasper-part-three-04.jpg)

### Code Optimizations

I have been working to clean up the build process and start to normalize the data that is available on the page, all of that is handled by the `jasper build` command. I now inlcude `rootDir`, `directory`, and `file` so they are available in the `writeTemplate` logic. I also added the `headers` array to the `prc` scope that is reponsible for adding opengraph and twitter metadata to the generated content.

``` javascript
component extends="commandbox.system.BaseCommand" {

 property name="JasperService" inject="JasperService@commandbox-jasper";

 function run() {
  // clear the template cache
  systemCacheClear();
  var rootDir = resolvePath( "." );
  rootDir     = left( rootDir, len( rootDir ) - 1 ); // remove trailing slash to match directoryList query

  command( "jasper cache build" ).run();

  if ( directoryExists( rootDir & "/_site" ) ) directoryDelete( rootDir & "/_site", true );

  directoryCopy(
   rootDir & "/assets",
   rootDir & "/_site/assets",
   true
  );

  var conf  = deserializeJSON( fileRead( rootDir & "/_data/jasperconfig.json", "utf-8" ) );
  var posts = deserializeJSON( fileRead( rootDir & "/_data/post-cache.json", "utf-8" ) );
  var tags  = JasperService.getTags( posts );

  print.yellowLine( "Building source directory: " & rootDir );

  var templateList = JasperService.list( rootDir );

  templateList.each( ( template ) => {
   var prc = {
    "rootDir"   : rootDir,
    "directory" : template.directory,
    "file"      : template.name,
    "headers"   : [],
    "meta"      : {},
    "content"   : "",
    "tagCloud"  : tags,
    "type"      : "page",
    "layout"    : "main",
    "posts"     : posts
   };
   prc.append( conf );
   // Try reading the front matter from the template
   prc.append( JasperService.getPostData( fname = template.directory & "/" & template.name ) );
   // write the rendered HTML to disk

   var shortName = JasperService.writeTemplate( prc = prc );
   print.greenLine( "Generating " & shortName );
  } );
 }

}
```

The `writeTemplate` method has been optimized, but it still needs to be modified to support views with no layout, but that will come later.

``` javascript
 /**
  * Handles writing a template to disk
  */
 function writeTemplate( required struct prc ) {
  var renderedHtml = "";
  var computedPath = prc.directory.replace( prc.rootDir, "" );
  directoryCreate(
   prc.rootDir & "/_site/" & computedPath,
   true,
   true
  );
  // render the view based on prc.type
  if ( prc.file.findNoCase( ".cfm" ) ) {
   savecontent variable="renderedHtml" {
    include prc.directory & "/" & prc.file;
   }
  } else {
   savecontent variable="renderedHtml" {
    include prc.rootDir & "/_includes/" & prc.type & ".cfm";
   }
  }
  savecontent variable="renderedHtml" {
   include prc.rootDir & "/_includes/layouts/" & prc.layout & ".cfm";
  }
  var fname     = "";
  var shortName = "";
  switch ( lCase( prc.type ) ) {
   case "post":
    shortName = computedPath & "/" & prc.slug & ".html";
    break;
   default:
    shortName = computedPath & "/" & listFirst( prc.file, "." ) & ".html";
    break;
  }
  fname = prc.rootDir & "/_site/" & shortName;
  fileWrite( fname, renderedHtml );
  return shortName;
 }
```

There is not a lot else to report, just trying to squash bugs.
