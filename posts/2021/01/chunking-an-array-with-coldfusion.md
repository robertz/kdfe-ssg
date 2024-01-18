---
layout: main
type: post
title: Chunking an Array with ColdFusion
slug: chunking-an-array-with-coldfusion
author: Robert Zehnder
date: 2021-01-04
published: true
image: https://static.kisdigital.com/images/chunking-an-array-with-coldfusion/00_cover.jpeg
description: Quickly chunk an array by the specified chunk size.
tags: 
- cfml
---
Yesterday I ran across an interesting programming challenge: I have an array of 51 widgets and I need to update these widgets on a 3rd party API. The API will only allow me to update 8 widgets at a time so I need to break my array out in to a 2D array of updatable chunks.

I tried solving the problem a few different ways. Being clever caused a complex mess. I dialed back the cleverness a bit and ended up going with this:

``` javascript
// given an array, return an array of arrays with {{chunkSize}} elements
function chunk (required array input, required numeric chunkSize) {
 var output[1] = [];
 var currentChunk = 1;
 input.each((item, index) => {
 output[currentChunk].append(item);
 if(index % chunkSize == 0 && index < input.len()) output[++currentChunk] = [];
 });
 return output;
}
```

I iterate over the input array, append each item to output, creating a new "bucket" and updating current bucket every chunkSize items unless there are no other elements in the source array.

Is there a more efficient way of handling this?
