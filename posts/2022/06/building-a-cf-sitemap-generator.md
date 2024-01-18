---
layout: main
type: post
title: Building a CF sitemap generator
author: Robert Zehnder
slug: building-a-cf-sitemap-generator
date: 2022-06-13
published: true
image: https://static.kisdigital.com/images/2022/06/spiderweb.jpeg
description: A simple script to crawl a site and build a sitemap.xml
tags: 
- cfml
---
The other day I found the need to create a sitemap for a rather large domain at work. The site in question has a few static pages, but there are a lot of dynamic pages that would be hard to go through every possible page combination. In order to speed things up a bit I thought I would write a quick webcrawler to go through the site and help me build the list of site links.

It does take a little effort to get things up and running because the a database is required for tracking all the links. Also I use a scheduled task that gets called to crawl the next batch of links and add any new links to the queue. My datasource is called `ufapp` but the datasource can be whatever you like. Here is the table structure required.

``` sql
-- ufapp.sitemap definition

CREATE TABLE `sitemap` (
 `id` bigint(20) NOT NULL AUTO_INCREMENT,
 `url` varchar(1000) NOT NULL UNIQUE,
 `crawled` bit(1) NOT NULL DEFAULT b'0',
 `statuscode` varchar(100) NOT NULL DEFAULT '200',
 PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```

### The Crawler

The crawler iself is a simple `cfhttp` call that pipes the fileContent returned through jSoup parse the HTML for anchor links. If you are not familiar with jSoup it is simply a Java HTML parser that will allow you to extract and manipulate data. The `cfhttp` has `resolveURL=true` and `redirect=false` set. This ensures relative links do not cause an issue and do not follow redirects.

A new instance of the JavaLoaderFactory will be created and stored in the application scope if it does not already exist. All worker pages will use JavaLoader to create the jSoup object used to parse the HTML.

The first step is to kick off the process by calling spider.cfm with the domain you would like to crawl. As an example, `spider.cfm?domain=kisdigital.com` would look for all links on my domain.

``` javascript
<cfscript>
 // spider.cfm
 javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
 jsoup = javaloader.create('org.jsoup.Jsoup');
 // use the domain if it is passed in
 domain = url.keyExists("domain") ? url.domain : "";
 allLinks = [];
 function getLinks(required string page){
  cfhttp(url = page, resolveURL = true, redirect = false);
  jsDoc = jsoup.parse(cfhttp.fileContent);
  els = jsDoc.select("a[href]");
  out = [];
  els.each((item) => {
   if(
    item.attr( "href" ).len() &&
    item.attr( "href" ).findNoCase( 'https://' & domain ) == 1
   ){
    out.append( item.attr("href") );
   }
  });
  return out;
 }
 allLinks.append(getLinks(page = "https://" & domain), true);
 allLinks.each((lnk) => {
  try{
   queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
    'link': { value: lnk, cfsqltype: "cf_sql_varchar" }
   }, { datasource: "ufapp" });
  }
  catch(any e){} // insert failed (dupe)
 })
</cfscript>

```

Once the initial page is loaded everything the scheduled task takes over. Every 60 seconds `task.cfm` is called which crawls the next chunk URLs in the database and stores the status code. Currently it is configured to ignore any URL that is not present on the current domain.

```javascript
<cfscript>
 // task.cfm
 javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
 jsoup = javaloader.create('org.jsoup.Jsoup');
 checklist = queryExecute("
  SELECT id, url, (SELECT SUBSTRING_INDEX(REPLACE(REPLACE(url, 'http://', ''), 'https://', ''), '/', 1)) AS domain
  FROM sitemap s
  WHERE s.crawled = 0
  ORDER BY s.id
  LIMIT 60
 ", [], { datasource: 'ufapp' });
 checklist.each((row) => {
  cfhttp(url = row.url, resolveURL = true, redirect = false);
  queryExecute("UPDATE sitemap SET statuscode = :statuscode, crawled = 1 WHERE id = :id", {
   'statuscode': { value: cfhttp.statuscode, cfsqltype: "cf_sql_varchar" },
   'id': { value: row.id, cfsqltype: "cf_sql_numeric" }
  }, { datasource: "ufapp" });
  jsDoc = jsoup.parse(cfhttp.fileContent);
  els = jsDoc.select("a[href]");
  out = [];
  els.each((item) => {
   if(
    item.attr( "href" ).len() &&
    item.attr( "href" ).findNoCase( 'https://' & row.domain ) == 1
   ){
    out.append( item.attr( "href" ) );
   }
  });
  for(var o in out){
   try{
    queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
     'link': { value: o, cfsqltype: "cf_sql_varchar" }
    }, { datasource: "ufapp" });
   }
   catch(any e){} // insert failed (duplicate)
  }
 })
</cfscript>
```

### Generating the Sitemap

Generating the sitemap is the easiest part of the process. To do so, call sitemap.cfm with the domain passed as a URL parameter, like so: `sitemap.cfm?domain=kisdigital.com`. This will output `sitemap.xml` for the domain in the current directory.

```javascript
<cfsetting enablecfoutputonly="true" />
<cfscript>
 // sitemap.cfm
 domain = url.keyExists("domain") ? url.domain : "";
 locs = queryExecute("
  SELECT DISTINCT s.url
  FROM sitemap s
  WHERE s.url LIKE :domain AND s.statuscode = '200 OK'
  ORDER by s.url", {
   'domain': { value: "%" & domain & "/%", cfsqltype: "cf_sql_varchar" }
  }, { datasource: "ufapp" });
 lastmod = dateFormat(now(), "yyyy-mm-dd");
 out = '<?xml version="1.0" encoding="UTF-8"?> <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"> ';
savecontent variable = "xmlBody" {
for(u in locs){writeOutput('
<url>
 <loc>#u.url#</loc>
 <lastmod>#lastmod#</lastmod>
</url>');}
};
 out &= xmlBody;
 out &= "</urlset>";
 fileWrite(expandPath(".") & "/sitemap-" & domain.replace(".", "_", "all") & ".xml", out);
</cfscript>
```

Here is a link to the code: [https://github.com/robertz/cfspider](https://github.com/robertz/cfspider)
