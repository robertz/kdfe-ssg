---
layout: main
type: post
title: "Tidying up HTML with jSoup: Part Deux"
author: Robert Zehnder
slug: tidying-up-html-with-jsoup-part-deux
date: 2024-05-01 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/robot-cleaning.jpg
description: Robert shows how to impliment tidy HTML using jSoup, again
tags:
- commandbox
- cfml
---
After my [last post](https://kisdigital.com/posts/2024/04/tidying-up-html-with-jsoup) a couple of buddies said I did not really explain the solution and the post felt unfinished. After going back and reading it, I would agree. I will go in to more detail here and explain things in more detail.

### The Issue: Identation and Whitespace

The output of `commandbox-ssg` has always been something that makes my OCD tingle. When `build` generates a site, templates are rendered in steps: first the view gets rendered, the next step is to render the page layout around the view, and finally the layout is applied. Due to how things are processed the indentation is "chunky" and the rendering process will also generate blank when processing the CFML templates.

Below is an example:

```html
<!doctype html>
<html lang="en">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
 <title>KISDigital</title>
 <meta name="description" content="ColdFusion, ColdBox, CommandBox and other assorted musings">
 <meta name="author" content="Robert Zehnder">
 <meta name="twitter:widgets:theme" content="light">
 <meta name="twitter:widgets:border-color" content="#55acee">
 
  <meta property="og:title" content="KISDigital" />
  <meta name="twitter:title" content="KISDigital" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta property="og:description" content="ColdFusion, ColdBox, CommandBox and other assorted musings" />
  <meta name="twitter:description" content="ColdFusion, ColdBox, CommandBox and other assorted musings" />
  <meta property="og:image" content="https://static.kisdigital.com/kisdigital-logo.jpg" />
  <meta name="twitter:image" content="https://static.kisdigital.com/kisdigital-logo.jpg" />
 
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" crossorigin="anonymous">
 <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css">
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism-themes/1.9.0/prism-one-dark.min.css" integrity="sha512-c6S8OdtvoqZCbMfA1lWE0qd368pLdFvVHVILQzNizfowC+zV8rmVKdSlmL5SuidvATO0A7awDg53axd+s/9amw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
 <link rel="stylesheet" href="/assets/css/site.css?v=1714584743059">
</head>
<body style="padding-top: 70px;">

 <header>
  <nav class="header">
   <div class="container">
    <div class="row">
     <div class="col-2">
      <a class="site-link" href="/"><span style="color: var(--post-link-text)">KIS</span>Digital</a>
     </div>
     <div class="col-10"></div>
    </div>
   </div>
  </nav>
 </header>

 
 <div class="container text-white">
  
<div class="row">
 <div class="col-lg-8 col-md-12">
  <div class="card rf-card-bordered text-white">
   <div class="card-body">
    <div class="card-text">
     

<div class="row mb-5">
 
  
   <div class="col-12 p-1">
   ... more html	
```

<br >

The output is not bad, it just is not great.

### The Solution: jSoup

I thought about a few different options to solve the issue. First, I thought about using an html post-processor to run after the build process. That would work but it defeats the purpose of a ColdFusion static site generator if you have to drop back to javascript.

I was optimistic about Ben Nadel's `dedentContent()` method he blogged about on his `cf_savefile` custom tag. It is a very cool idea, but are  potential issues when dealing with preformatted content and code tags. I am sure it could be accounted for, but there are smarter ways to handle it.

Which brings me to the solution I used: jSoup. Using jSoup with ColdBox is as easy as `box install cbjsoup` with Don Bellamy's [cbjsoup](https://github.com/donbellamy/cbjsoup) module. I have used this module extensively and it is defintely one of my favorite ColdBox modules.

Unfortunately, the module will not work for a CommandBox custom module, but it does provide the `jsoup-1.14.3.jar` which is all that is really needed.

Getting this working with `commandbox-ssg` was a matter of dropping the jar in the `models/lib` in the `commandbox-ssg` module directory. The `build` command needs a way to call jSoup's `parse()` method to process the ugly html and return clean, tidy html so I created a simple service that only exposes the `parse()` method of the library. 

```js
// models/JSoup.cfc
component {

 LIB_PATHS = directoryList(
  getDirectoryFromPath( getCurrentTemplatePath() ) & "lib",
  false,
  "path"
 );

 JSoup function init(){
  variables.jsoup = createObject( "java", "org.jsoup.Jsoup", LIB_PATHS );
  return this;
 }

 function parse( html ){
  return variables.jsoup.parse( html );
 }

}
```

<br>

The `build` command needs to be able to reference the new service, so it is injected into the `variables` scope.

```js
property name="jSoup" inject="JSoup@commandbox-ssg";
```

<br>

Inside the `renderTemplate()` method after all HTML has been generated the content is piped through jSoup's `parse()`.

```js
 /**
  * returns rendered html for a template and view
  *
  * @prc request context for the current page
  */
 function renderTemplate( prc ){
  var renderedHtml = "";
  var template     = "";

  try {
   // template is CF markup
   if ( prc.inFile.findNoCase( ".cfm" ) ) {
    if ( process.hasIncludes && process.views.find( prc.view ) && prc.layout != "none" ) {
     // render the cfml in the template first
     template = fileSystemUtil.makePathRelative( prc.inFile );

     savecontent variable="prc.content" {
      include template;
     }

     // overlay the view
     template = fileSystemUtil.makePathRelative( cwd & "_includes/" & prc.view & ".cfm" );

     savecontent variable="renderedHtml" {
      include template;
     }
    } else {
     // view was not found, just render the template
     template = fileSystemUtil.makePathRelative( prc.inFile );

     savecontent variable="renderedHtml" {
      include template;
     }
    }
   }
   // template is markdown
   if ( prc.inFile.findNoCase( ".md" ) ) {
    if ( process.hasIncludes && process.views.find( prc.view ) ) {
     template = fileSystemUtil.makePathRelative( cwd & "_includes/" & prc.view & ".cfm" );

     savecontent variable="renderedHtml" {
      include template;
     }
    } else {
     renderedHtml = prc.content;
    }
   }
   // skip layout if "none" is specified
   if (
    prc.layout != "none" &&
    process.hasIncludes &&
    process.layouts.find( prc.layout )
   ) {
    template = fileSystemUtil.makePathRelative( cwd & "_includes/layouts/" & prc.layout & ".cfm" );

    savecontent variable="renderedHtml" {
     include template;
    }
   }
  } catch ( any e ) {
   error( prc.inFile & " :: " & e.message );
  }
  // a little whitespace management
  return trim( JSoup.parse( renderedHtml ) );
 }
```

<br>

The final line is where all the magic happens. Calling jSoup `parse()` on the raw output will return tidy HTML which is ready to be written to disk and served on your preferred static site host. If you were to view the source now you would see the output no longer has blank lines and chunky indentation.

```html
<!doctype html>
<html lang="en"> 
 <head> 
  <meta charset="utf-8"> 
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"> 
  <title>KISDigital</title> 
  <meta name="description" content="ColdFusion, ColdBox, CommandBox and other assorted musings"> 
  <meta name="author" content="Robert Zehnder"> 
  <meta name="twitter:widgets:theme" content="light"> 
  <meta name="twitter:widgets:border-color" content="#55acee"> 
  <meta property="og:title" content="KISDigital"> 
  <meta name="twitter:title" content="KISDigital"> 
  <meta name="twitter:card" content="summary_large_image"> 
  <meta property="og:description" content="ColdFusion, ColdBox, CommandBox and other assorted musings"> 
  <meta name="twitter:description" content="ColdFusion, ColdBox, CommandBox and other assorted musings"> 
  <meta property="og:image" content="https://static.kisdigital.com/kisdigital-logo.jpg"> 
  <meta name="twitter:image" content="https://static.kisdigital.com/kisdigital-logo.jpg"> 
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" crossorigin="anonymous"> 
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.3/font/bootstrap-icons.css"> 
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism-themes/1.9.0/prism-one-dark.min.css" integrity="sha512-c6S8OdtvoqZCbMfA1lWE0qd368pLdFvVHVILQzNizfowC+zV8rmVKdSlmL5SuidvATO0A7awDg53axd+s/9amw==" crossorigin="anonymous" referrerpolicy="no-referrer"> 
  <link rel="stylesheet" href="/assets/css/site.css?v=1714586005784"> 
 </head> 
 <body style="padding-top: 70px;"> 
  <header> 
   <nav class="header"> 
    <div class="container"> 
     <div class="row"> 
      <div class="col-2"> <a class="site-link" href="/"><span style="color: var(--post-link-text)">KIS</span>Digital</a> 
      </div> 
      <div class="col-10"></div> 
     </div> 
    </div> 
   </nav> 
  </header> 
  <div class="container text-white"> 
   <div class="row"> 
    <div class="col-lg-8 col-md-12"> 
     <div class="card rf-card-bordered text-white"> 
      <div class="card-body"> 
       <div class="card-text"> 
        <div class="row mb-5"> 
         <div class="col-12 p-1"> <a href="/posts/2024/04/tidying-up-html-with-jsoup-part-deux" class="text-decoration-none"> 
```

<br>

### Conclusion

In the end, I was able to get `commandbox-ssg` to output nicely formatted HTML using only ColdFusion, `node` not required.