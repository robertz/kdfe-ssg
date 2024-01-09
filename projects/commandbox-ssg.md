---
type: project
title: commandbox-ssg
description: commandbox-ssg user manual
---
### commandbox-ssg
SSG is a static site generator implemented in CommandBox.
<br>

### Installation
```bash
box install commandbox-ssg
```
<br>

### Commands
Installing commandbox-ssg will provide the `ssg` namespace which allows for these commands:

* **init** - This command will scaffold a very basic blog site you can modify to fit your needs
* **build** - This command will scan for *.md and *.cfm files in the current working directory and build html files that will be placed in the `_site` directory
* **watch** - This command calls `ssg build` whenever a change is detected in the current working directory
* **serve** - This command will start a static web server you can use to preview your site. It will also create the required `server.json` and `.htaccess` files if they do not exist.
<br>

### Getting Started (Quick)
```bash
box
mkdir my-test-site --cd
echo "### Hello from commandbox-ssg" > index.md
ssg build
ssg serve
```
<br>

### How it works
Commandbox-ssg works using ColdBox modules you already know and love. Markdown is processed by the [cbMarkdown](https://www.forgebox.io/view/cbmarkdown) module to
return the generated HTML. Every markdown template has can have its own metadata associated with it, called front matter, 
using YAML and that is processed using the [cbYaml](https://www.forgebox.io/view/cbyaml) module.

When you run `ssg build` it will scan the current working directory and all subdirectories for Markdown and CFM files. 
Every file it finds it will attempt to read the front matter from the template and that data will be added to the `prc`
scope for that page. The `prc` scope is nod to its ColdBox roots, every page has its own `prc` that encapsulates all the 
data required to render a page.

As noted, `commandbox-ssg` checks every template for front matter and will add it to the pages `prc` scope if it exists.
If you do provide front matter, it is required to start on the first line, otherwise it will be ignored. How it is 
denoted is determined by the template type.

As an example, here is a front matter block for a markdown template.

```md
---
type: project
view: page
title: commandbox-ssg
---
```
Front matter start and front matter end is marked by `---` at the beginning and the end of the block.

CFML templates work much the same way, the only difference being the document is expected to start with a ColdFusion
comment block.

```md
<!---
layout: main
view: page
--->
```
Just like you can write templates in liquid markdup on 11ty, `commandbox-ssg` will allow you to generate pages using
CFML. This allows you more granular control over how the page is generated. I leverage this to generate sitemaps and rss 
feeds.
<br>

### Special Directories
You can structure you site any way you like, but there are some directories `commandbox-ssg` will automatically use if 
they exist.

* **_includes/layouts** - This is the main HTML scaffold for your application. Dynamic content should be displayed using `#renderedHTML#` variable
* **_includes** - The `_includes` folder contains the views for your site. Views will reference `prc.content` to wrap the rendered content. (See below)
* **_data** - JSON files in this folder will automatically be added to the `collections` scope. This has not been implemented yet.
* **_site** - This is where the static content is output when the site is generated
<br>

### Variables Scopes and Helper Functions
Templates currently have two main scopes available to them as well as a helper function to generate slugs.
<br>

**PRC Scope**
The `prc` scope contains everything known about a template. Here is an example of how it might look.

```js
{
	"view": "",
	"content": "<cfdump var=\"#serializeJSON(prc)#\" />",
	"meta": {
		"url": "https://example.com",
		"author": "",
		"title": "",
		"description": ""
	},
	"permalink": "/",
	"passthru": [],
	"outputDir": "_site",
	"directory": "/Users/rob/Development/small-blog",
	"fileExt": "html",
	"headers": [],
	"rootDir": "/Users/rob/Development/small-blog",
	"excludeFromCollections": false,
	"fileSlug": "index",
	"layout": "main",
	"image": "",
	"published": true,
	"publishDate": "",
	"type": "page",
	"outFile": "/Users/rob/Development/small-blog/_site/index.html",
	"inFile": "/Users/rob/Development/small-blog/index.cfm",
	"title": "",
	"build_start": 1703167890264,
	"description": "",
	"ignore": []
}
```

Any data from front matter will be in this scope as well. Any variable from the `prc` scope can be used in a layout,
view, or template during the rendering process.

Some properties you may want to override in the front matter might include:

* **type** - Template type determines which `_includes` file is used when the template is rendered.
* **layout** - Determines which layout file is used to render the template. Defaults to `main`
* **view** - Override template `type` rendering and use the specified view
* **published** - If this value is `false` it will not be processed when the static site is built
* **publishDate** - By default any template with type `post` will be sorted by publishDate in descending order

The `prc.content` variable will either contain the CFML markup to generate the page or the HTML generated from the 
markdown in the template. If there is a `type` or `view` associated with the content it wil be used. Here is an example
of how content is displayed in the `page` view.
<br>

**Collections scope**

While the `prc` scope is specific to a page, the `collections` scope keeps track of all known pages (unless the 
excludeFromCollections flag is set) and sorts them out in to several buckets. The `collections.all` array contains all
discovered documents. There is also a `collections` array for each type of document, so if you had pages with types of 
`post` and `page` there would also be corresponding `collections.post` and `collections.page` arrays. It also builds out 
a list of all tags for your posts which can be found in `collections.tags`. Finally, it also keeps track of posts by tag 
in teh `collections.byTag.<tag>` arrays.

<br>

### Config File
Configuration is handled using `ssg-config.json`

```js
{
	"meta": {
		"title": "My Awesome site",
		"description": "Something catchy here",
		"author": "The Dude",
		"url": "https://domain.com"
	},
	"outputDir": "_site",
	"passthru": [
		"/favicon.ico",
		"/assets"
	],
	"ignore": [
		"/_includes"
	]
}
```
<br>

Settings:
* **site.title** - Populates the browser title bar
* **site.description** - Site description
* **site.author** - Primary author
* **site.url** - Used when generating links
* **outputDir** - This value is currently hard-code to `_site`
* **passthru** - Array of files or directories that should be copied to the output directory
* **ignore** - Array of directories that should be ignored

If you do not explicitly exclude a directory it will be included by default. The `_includes` directory is excluded by default.

### Creating your first layout
Creating your first layout is simple. This is the primary wrapper for your content and the main layout is expected to 
exist in `_includes\layouts\main.cfm`. Inside the layout you will need to specify where dynamic content should go by 
using `#renderedHtml#` variable. 

All layouts should be implemented in CFML.

```html
<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<title>#prc.site.title#</title>
	<meta name="description" content="#prc.site.description#">
	<meta name="author" content="#prc.site.author#">
	<meta name="twitter:widgets:theme" content="light">
	<meta name="twitter:widgets:border-color" content="##55acee">
	<!--- <base href="#event.getHTMLBaseURL()#" /> --->
	<cfloop array="#prc.headers#" index="header">
		<cfif header.keyExists("property")>
			<meta property="#header.property#" content="#header.content#" />
		<cfelse>
			<meta name="#header.name#" content="#header.content#" />
		</cfif>
	</cfloop>
	<link rel="stylesheet" href="https://unpkg.com/bootstrap@4.6.0/dist/css/bootstrap.min.css" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.23.0/themes/prism-okaidia.min.css" integrity="sha512-mIs9kKbaw6JZFfSuo+MovjU+Ntggfoj8RwAmJbVXQ5mkAX5LlgETQEweFPI18humSPHymTb5iikEOKWF7I8ncQ==" crossorigin="anonymous" referrerpolicy="no-referrer" />
	<link rel="stylesheet" href="/assets/css/site.css?v=#dateFormat(now(), "yyyy-mm-dd")#T#timeFormat(now(), "HH:mm:ss")#">
</head>
<body style="padding-top: 70px;">
	<nav class="navbar fixed-top navbar-expand-lg navbar-dark bg-dark">
		<div class="container">
			<a class="navbar-brand" href="/">commandbox-ssg</a>
			<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="##navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navbarSupportedContent">
				<ul class="navbar-nav mr-auto">
					<li class="nav-item active">
						<a class="nav-link" href="/">Home</a>
					</li>
				</ul>
			</div>
		</div>
	</nav>

	<!---Container And Views --->
	<div class="container-fluid">
		#renderedHtml#
	</div>

	<footer class="border-top py-3 mt-5">
		<div class="container">
			<small>KISDigital.com&copy; 2020 - #dateFormat(now(), "yyyy")#</small>
		</div>
	</footer>

	<!---js --->
	<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha384-J6qa4849blE2+poT4WnyKhv5vZF5SrPo0iEjwBvKU7imGFAV0wwj1yYfoRSJoZ+n" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
	<script src="https://unpkg.com/bootstrap@4.6.0/dist/js/bootstrap.min.js" crossorigin="anonymous"></script>
	<script type="text/javascript" src="//cdn.jsdelivr.net/gh/dkern/jquery.lazy@1.7.10/jquery.lazy.min.js"></script>
	<script type="text/javascript" src="//cdn.jsdelivr.net/gh/dkern/jquery.lazy@1.7.10/jquery.lazy.plugins.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.23.0/prism.min.js" integrity="sha512-YBk7HhgDZvBxmtOfUdvX0z8IH2d10Hp3aEygaMNhtF8fSOvBZ16D/1bXZTJV6ndk/L/DlXxYStP8jrF77v2MIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
	<script>
		$(function($) {
			$('.lazy img').lazy()
		})
	</script>
</body>
</html>
</cfoutput>
```
<br>

### Creating your first View
Views work a little bit differently than layouts since the view wraps our template content.  The HTML for our template
will come from the `prc.content` scope. 

All views should be implemented in CFML.

```html
<cfoutput>
<div class="row">
	<div class="col-lg-8 col-md-12">
		<div class="card rf-card-bordered text-white">
			<div class="card-body">
				<div class="card-text decorate-links">
					#prc.content#
				</div>
			</div>
		</div>
	</div>
	<div class="col-lg-4 d-none d-lg-block d-xl-block">
		<cfinclude template="sidebar.cfm" />
	</div>
</div>
</cfoutput>
```