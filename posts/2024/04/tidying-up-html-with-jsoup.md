---
layout: main
type: post
title: Tidying up HTML with jSoup
author: Robert Zehnder
slug: tidying-up-html-with-jsoup
date: 2024-04-24 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/dog-writing.jpg
description: Robert shows how to impliment tidy HTML using jSoup
tags:
- commandbox
- cfml
---
One of the pet peeves I have with `commandbox-ssg` is that the output HTML has not been very tidy. If you have been developing with ColdFusion for a while you are probably familiar with the chunks of whitespace in your pages. One of the things that has been on the back burner for me is figuring out a way to remove this from generated output. I have considered looking in to ways to post process the HTML which I am sure `node` has some modules that will help with this, but I really wanted something ColdFusion specific to keep things simple.

Ben Nadel recently posted about his [CF_SaveFile Custom Tag in ColdFusion](https://www.bennadel.com/blog/4638-cf-savefile-custom-tag-in-coldfusion.htm) which was actually intriguing since there are a few parallels to what he is using his tag to generate static content and how `commandbox-ssg` writes templates. His custom tag also includes a `dedentContent` function that will attempt to normalize the indention. I wanted to see how well this would work in `commandbox-ssg` but the results were not quite right. No slight to Ben, my use case has to take in to account text in `pre` and `code` blocks. Back to the drawing board.

Then last night while I was eating dinner I thought "I bet jSoup can handle that." After reading through the documentation this morning I found out I was right. If you call jSoup's `parse()` function it will return tidy HTML. There were trials and errors getting jSoup working properly in `commandbox-ssg` but I am fairly certain I have worked out the kinks. As of version 0.2.0, `commandbox-ssg` will pipe all output through jSoup to tidy the HTML file contents before writing to the file system.

Honestly jSoup is probably one of my favorite libraries to work with because of its versatility. Now I can add formatting HTML for static pages to that list. 