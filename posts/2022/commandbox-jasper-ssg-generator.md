---
layout: main
type: post
title: Commandbox-jasper SSG generator
slug: commandbox-jasper-ssg-generator
author: Robert Zehnder
image: https://static.kisdigital.com/images/2022/07/jasper-00.jpg
description: A static site generator using CommandBox
tags: 
- cfml
- commandbox
published: true
publishDate: 2022-07-02
---

Photo by <a href="https://unsplash.com/@patrickian4?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Patrick Fore</a> on <a href="https://unsplash.com/s/photos/writing?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>

I recently had the chance to get familiar with CommandBox while I was updating my blog. My [last post](https://kisdigital.com/post/how-i-use-commandbox-with-my-blog) outlined how I used CommandBox to allow me to manage my blog from the command line. I enjoyed that experience so I thought I would work with CommandBox once again.

Last year I wrote a static site generator called Jasper. So far I have built Jasper using [ColdBox](https://github.com/robertz/jasper) as well as [FW1](https://github.com/robertz/jasper-fw1). I am going to take things one step further and I will implement Jasper as a [CommandBox module](https://github.com/robertz/commandbox-jasper). Apparently I really enjoy writing SSGs.

I decided to split the project in to two main parts: the jasper-cli blog scaffold and the `jasper` command that handles generating the static site.

### The blog scaffold

The [jasper blog scaffold](https://github.com/robertz/jasper-cli) contains a very basic blog.

* **jasperconfig.json** - This is the configuration file used by `jasper`. It is expected to be in the root directory and must exist.
* **assets/** - The contents of this folder will be copied to the `dist/` folder at build time (wip)
* **dist/** - Generated pages will be here
* **src/** - The different pages that make up the contents
* **src/layout/** - Page header and footer
* **src/posts/** - The mardown files go here

The "guts" of the skeleton app are in the `/src` folder and contains all the ColdFusion files required to render a blog page.

* **index.cfm** - This is the page used to generate the home page
* **post.cfm** - This page is used to generate blog posts
* **tags.cfm** - Generates a list of posts associated with the given tag
* **sidebar.cfm** - Generate additional content to display on the page

The markdown for posts are stored in `src/posts/` and the current base template contains two posts.

All data required to render the page is expected to be in the `prc` variable structure, the same as a ColdBox applicatiop. As an added benefit, the pages were already setup that way.

![jasper-cli](https://static.kisdigital.com/images/2022/07/jasper-01.jpg)

### jasper: the command

The blog scaffold in place, next I need to actually be able to produce an HTML site from the `src/` contents. The commandbox-jasper module makes this possible and it is very easy to install.

`box install commandbox-jasper`

Once installed, from the root directory of the blog scaffold the static HTML can be created with `box jasper build`. This will build the all the individual pages for the site: the index, posts, as and finally posts by tag. It must be run from blog root directory.

![Generating a static site](https://static.kisdigital.com/images/2022/07/jasper-02.jpg)

Brad Wood gave me the tip that `including` a CFML in a `savecontent` block is the easiest way to render a CFML page. Once that was figured out, everything else just falls in place.

First, setup the faux `prc` scope and then include the page, save the generated html, and finally save teh file to the `dist/` directory.

Currently the build method handles writing out the three main page types: index, post, and tag.

``` javascript
component extends="commandbox.system.BaseCommand" {

 property name="JasperService" inject="JasperService@commandbox-jasper";

 function run() {
  command( "jasper cache build" ).run();

  var conf = deserializeJSON( fileRead( fileSystemUtil.resolvePath( "jasperconfig.json" ), "utf-8" ) );
  var posts = deserializeJSON( fileRead( fileSystemUtil.resolvePath( "post-cache.json" ), "utf-8" ) );
  var tags = JasperService.getTags( posts );

  var html = "";
  var prc = {
   "meta" : {},
   "posts" : posts,
   "html" : "",
   "tagCloud" : JasperService.getTags( posts )
  };
  prc.meta.append( conf.meta );
  // get the home page
  savecontent variable="html" {
   include fileSystemUtil.resolvePath( "src/index.cfm" );
  }

  fileWrite( fileSystemUtil.resolvePath( "dist/index.html" ), html );

  // Build all posts
  var files = JasperService.list( path = fileSystemUtil.resolvePath( "src/posts" ) );
  files.each( ( file ) => {
   print.line( "Generating... dist/post/" & file.name.listFirst( "." ) & ".html" );

   var html = "";
   var prc = {
    "meta" : {},
    "post" : {},
    "html" : "",
    "tagCloud" : tags
   };
   prc.meta.append( conf.meta );
   prc.post.append(
    JasperService.getPostData( fname = fileSystemUtil.resolvePath( "src/posts/" & file.name ) )
   );

   prc.meta.title &= " - " & prc.post.title;

   savecontent variable="html" {
    include fileSystemUtil.resolvePath( "src/post.cfm" );
   }

   fileWrite( fileSystemUtil.resolvePath( "dist/post/" & prc.post.slug & ".html" ), html );

  } );

  // build tags
  tags.each( ( tag ) => {
   print.line( "Generating... dist/tag/" & lCase( tag ).replace( " ", "-", "all" ) & ".html" );

   var html = "";
   var prc = {
    "meta" : {},
    "tag" : lCase( tag ),
    "posts" : [],
    "html" : "",
    "tagCloud" : tags
   };
   prc.meta.append( conf.meta );

   prc.posts = posts.filter( ( post ) => {
    return post.tags.findNoCase( prc.tag );
   } );

   prc.meta.title &= " - " & lCase( prc.tag );

   savecontent variable="html" {
    include fileSystemUtil.resolvePath( "src/tags.cfm" );
   }

   fileWrite( fileSystemUtil.resolvePath( "dist/tag/" & tag.replace( " ", "-", "all" ) & ".html" ), html );
  } )
 }

}

```

Once the static site is built it can be served up using `netlify` or with your favorite http server.

There is still quite a bit to be ironed out before it is usable. OpenGraph/Twitter meta data is not currently working on posts which should be easy to fix. Error handling is non-existant, but the code functions well enough it does not error out most of the time. Currently the pages are built manually instead of dynamically from `jasperconfig.json`. All that will come.

### In Closing

This was a fun project that let me work with a lot of my favorite stuff: ColdFusion, CommandBox, blogs, and markdown. I look forward to playing around with this a lot more.

This also makes it very easy to get started with your own CF static site.

``` bash
git clone https://github.com/robertz/jasper-cli.git
cd jasper-cli
box install commandbox-jasper
box jasper build
cd dist
netlify dev
```

Done.
