<!---
layout: none
permalink: /rss
site:
  title: KISDigital
  description: ColdFusion, ColdBox, CommandBox, BoxLang and other assorted musings
  author: robert@kisdigital.com (Robert Zehnder)
  url: https://kisdigital.com
--->
<cfscript>
	function getPages(collections){
		var ret = collections.all.filter((item) => {
			return item.excludeFromCollections == false && (item.type == "post");
		});
		ret.sort( ( e1, e2 ) => {
			return dateCompare( e2.date, e1.date );
		} );
		return ret;
	}
	savecontent variable="xml" {
	writeOutput('<?xml version="1.0" encoding="UTF-8"?>#chr(10)#');
	writeoutput('<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom"><channel>#chr(10)#<atom:link href="https://kisdigital.com/rss" rel="self" type="application/rss+xml" />#chr(10)#<title>#prc.site.title#</title>#chr(10)#<link>#prc.site.url#</link>#chr(10)#<description>#prc.site.description#</description>#chr(10)#');
	for(var p in getPages(collections)){
	writeoutput('
<item>
	<title>#p.title#</title>
	<guid isPermaLink="true">#p.site.url##p.permalink#</guid>
	<link>#p.site.url##p.permalink#</link>
	<description>#p.description#</description>
	<author>#prc.site.author#</author>
	<pubDate>#dateTimeFormat(p.date, "ddd, dd mmm yyyy HH:nn:ss")# GMT</pubDate>
</item>
');
}
	writeoutput('</channel></rss>#chr(10)#');
}
</cfscript>
<cfoutput>#xml#</cfoutput>