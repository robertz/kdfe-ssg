---
layout: main
type: post
title: How I use CommandBox with my blog
slug: how-i-use-commandbox-with-my-blog
description: CommandBox is not just for running servers
author: Robert Zehnder
image: https://static.kisdigital.com/images/2022/06/commandbox.png
tags: 
- commandbox
- cfml
published: true
date: 2022-06-23
---
Over the course of the last year my blog has been through many revamps and rewrites. I wrote a CF static site generator called Jasper that manages content by dropping markdown files into the `/posts` folder, dynamically generating a static site that can be deployed anywhere. The current iteration of the blog is running Jasper as a server; Instead of reading markdown files, posts are returned from a database.

The system works well, but the one downside to using a database how to manage the posts. I did not want to write an admin interface, I would prefer to manage it like it is a static site generator. The posts will be saved in the database, but I can retrieve a post and save it as a markdown file for editing and posted back to the server when done. As a matter of fact, I am editing _this_ post in vscode.

I thought about how I would implement something like that. As it turns out, it was much easier than I expected.

### CommandBox to the rescue

CommandBox is the ColdFusion developer's Swiss army knife. Not only does it run servers for you, you can also write modules you can execute through the cli. Here I will leverage the ability to write these modules to create `blog` commands that will allow me to interact with my site.

The first command is `blog list`. This command will output a list of posts and some details using the table printer. As you can see it is just a simple `cfhttp` call.

##### /command/blog/list.cfc

``` javascript
component extends="commandbox.system.BaseCommand" {

 function run() {
  cfhttp( url = "https://kisdigital.com/api/posts", timeout = "60" );
  var data = deserializeJSON( cfhttp.fileContent );
  print.table( data = data );
 }

}
```

This is what the finished result looks like.

![List of posts](https://static.kisdigital.com/images/2022/06/blog-list.jpg)

Next `blog get post post-slug` will get single post back. The front matter is all the keys returned from the api, minus `body` and `status`. The front matter is at the top of the file and the markdown follows and is written to a file named based on the slug. I can now edit locally and make whatever changes are required.

##### /command/blog/get/post

``` javascript
component extends="commandbox.system.BaseCommand" output=false {

 function run( required string slug ) {
  var out = [];

  cfhttp( url = "https://kisdigital.com/api/post/slug/" & slug, timeout = "60" );

  var data = deserializeJSON( cfhttp.fileContent );
  var frontMatter = "";
  var fileOut = fileSystemUtil.resolvePath( arguments.slug & ".md" );

  savecontent variable="frontMatter" {
   writeOutput( "---#chr( 10 )#" );
   keys = data
    .keyArray()
    .filter( ( item ) => {
     // these keys should not be in the front matter
     return !( item == "status" || item == "body" );
    } );
   for ( var key in keys ) {
    writeOutput( key & ": " & data[ key ] & chr( 10 ) );
   }
   writeOutput( "---#chr( 10 )#" );
  }
  fileWrite( fileOut, ( frontMatter & data.body ) );
  print.line( "File output to: " & fileOut );
 }

}
```

This is an example of what the generated markdown file would look like.

``` md
---
slug: my-awesome-post
title: This is a completely awesome post
description: It is almost scary it is so awesome
tags: code,cats,awesome
---
### My awesome post
```

Finally, `blog put post post-slug` will write a post to the database. The frontmatter is read from the post using the [cbyaml](https://github.com/coldbox-modules/cbyaml) ColdBox module and added to the payload along with the body and posted to the api using `cfhttp`.

##### /command/blog/put/post

``` javascript
component extends="commandbox.system.BaseCommand" output=false {

 property name="YamlService" inject="Parser@cbyaml";

 function run( required string slug ) {
  var yaml = "";
  var body = "";

  if ( fileExists( fileSystemUtil.resolvePath( arguments.slug & ".md" ) ) ) {
   var openFile = fileOpen( fileSystemUtil.resolvePath( arguments.slug & ".md" ), "read" );
   var lines = [];
   try {
    while ( !fileIsEOF( openFile ) ) {
     arrayAppend( lines, fileReadLine( openFile ) );
    }
   } catch ( any e ) {
    rethrow;
   } finally {
    fileClose( openFile );
   }
   var fme = lines.findAll( "---" )[ 2 ]; // front matter end
   for ( var i = 2; i < fme; i++ ) {
    yaml &= lines[ i ] & chr( 10 );
   }
   lines.each( ( line, index ) => {
    if ( index > fme ) body &= lines[ index ] & chr( 10 );
   } )
   var frontMatter = YamlService.deserialize( trim( yaml ) );
   var payload = {
    slug : frontMatter.slug,
    image : frontMatter.image,
    author : frontMatter.author,
    title : frontMatter.title,
    description : frontMatter.description,
    tags : frontMatter.tags,
    published : frontMatter.keyExists( "published" ) ? frontMatter.published : "",
    body : body
   };
   cfhttp( url = "https://kisdigital.com/api/post", method = "POST" ) {
    cfhttpparam(
     type = "header",
     name = "content-type",
     value = "application/json"
    );
    cfhttpparam( type = "body", value = serializeJSON( payload ) );
   }
  }
 }

}
```

I have written a new post, time to release it to the masses!

![blog post put](https://static.kisdigital.com/images/2022/06/commandbox-blog-put.jpg)

### In closing

Honestly this is a use-case that probably only applies to me, but I thought it was pretty cool to be able to implement this with only a few lines of code. Being able to write ColdFusion code and run it from the command line is just freakin cool. Every time I look at the [Developing for CommandBox](https://commandbox.ortusbooks.com/developing-for-commandbox) docs, I find something new I did not know it could do.

It is also very cool to be able to use existing ColdBox modules from a custom module. I spent a good bit of time getting the cbyaml module working when I could have just typed `box install cbyaml` and it would have just worked. It seems like common sense now, but I was overcomplicating things.

In closing, it is definitely worth your time getting familiar with CommandBox; It is not just for running development servers.
