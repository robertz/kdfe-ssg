---
layout: main
type: post
title: Syncing files with rsync
slug: syncing-files-with-rsync
description: Keep your files n'sync from the command line.
author: Robert Zehnder
image: https://static.kisdigital.com/images/2021/09/00-syncing-files-with-rsync.jpeg
tags:
- misc
published: true
date: 2021-09-28
---
A few weeks ago I was looking through my favorite reddits and came across a thread where a redditor was asking how
to programmatically sync their application to the server after it has been built. There were a lot of answers, most of
them were some flavor of using a git webhook or using a host that will allow you to deploy for the command line like
Vercel.

Those are all great options, but since they were already running on *nix, I suggested handling the sync the way I
handle syncing static content here on the blog, using `rsync`. I created a bash script that syncs the content of the
`/static` folder in my home directory to the web root of my static content server with a one-way sync.

``` bash
#!/bin/bash
rsync -auv --delete ~/static/ user@mydomain.com:static
```

This has the added benefit of not having to install an application like FileZilla or CyberDuck and will just work out
of the box if you are on a *nix system. I use public key encryption across all my VM's so my connection is secure
by default.

This is the flow I use when writing blog posts. Once I have downloaded and optimized content for a post
locally it is just a matter of dropping to the command line and running the sync script to push all the content to the
live server.

Using git webhooks or Vercel to deploy your apps are great solutions, but sometimes the simple solution is the
best and `rysnc` just works.

<small>Cover image by [Mitsuo Komoriya](https://unsplash.com/@mitzmoco) on [Unsplash](https://unsplash.com)</small>
