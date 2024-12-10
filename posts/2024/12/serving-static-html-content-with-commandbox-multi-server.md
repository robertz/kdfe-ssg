---
layout: main
type: post
title: Serving static HTML content with CommandBox multi-server
slug: serving-static-html-content-with-commandbox-multi-server
description: Robert explains configuring CommandBox multi-server to serve HTML files
author: Robert Zehnder
image: https://static.kisdigital.com/images/2022/06/commandbox.png
tags:
- cfml
- commandbox
published: true
date: 2024-12-10 18:00:00
---
I have recently started using the CloudFlare free tier to manage my DNS as well as proxying web requests. This allows CloudFlare to optimize, cache, and protect all requests to the origin server as well as mitigate DDoS attacks.

This site was hosted at Netlify since it is just serving static HTML content, but Netlify and CloudFlare do not play nice together. Netlify has its own proxying and CDN network, so that is not a surprise. In order to get everything managed “in-house," it was time to move hosting to my own server. The biggest hurdle aside from copying the files over was getting CommandBox multi-site server configured to serve static HTML using the correct rewrite rules.

Since CommandBox is a CFML server, the first thing I needed to do was turn off ColdBox-style rewrites for the domain. This would make a URL like **https://kisdigital.com/posts/my-cool-post** get redirected to **https://kisdigital.com/index.cfm/posts/my-cool-post**. That works great for a CF app, but not so much for serving HTML. This is corrected by setting `rewrites.enable` to false in the site config block.

The next step is to configure the server in such a way that if an URL is not a file or a directory, it tries to serve that request as an HTML file. This is accomplished using Undertow rules. This will rewrite the URL **https://kisdigital.com/index.cfm/posts/my-cool-post** to **https://kisdigital.com/index.cfm/posts/my-cool-post.html** under the hood.

```js
"kisdigital":{
	"rewrites":{
		"enable":"false"
	},
	"rules":[
		"not is-file and not is-directory and regex( '^([^\\.]+)$' ) -> { rewrite('\\${1}.html')"
	],
	... more settings here ...
},
```

<br>
I would like to thank Brad Wood for helping me get this one sorted out, otherwise I would still be fighting with it.