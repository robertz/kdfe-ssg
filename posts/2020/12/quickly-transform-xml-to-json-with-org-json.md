---
layout: main
type: post
title: Quickly transform XML to JSON with org.json.XML and ColdFusion
slug: quickly-transform-xml-to-json-with-org-json
description: Work smarter, not harder
author: Robert Zehnder
image: https://static.kisdigital.com/images/quickly-transform-xml-to-json-with-org-json/00_cover.jpeg
tags: 
- cfml
published: true
date: 2020-12-16
---
I was developing an API wrapper back in October that would allow posting a JSON to payload to a legacy SOAP endpoint. Transforming the JSON payload to a valid SOAP envelope was a bit of a painful experience but transforming an XML response back to ColdFusion was no problem at all.

``` javascript
function parse (required string xml) {
 return deserializeJSON(createObject("java", "org.json.XML").toJSONObject(xml)); 
}
```

In the end I wrote a custom parser and ended up losing this little snippet. Today I needed to convert XML to JSON again so I went digging for this, but this time I am documenting it since I am sure I will need it again.

Also note, you must have the org.json package available in your ColdFusion class path unless you are using javaloader.
