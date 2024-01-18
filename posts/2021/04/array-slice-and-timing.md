---
layout: main
type: post
title: Array slice and timing
author: Robert Zehnder
slug: array-slice-and-timing
date: 2021-04-13
published: true
image: https://static.kisdigital.com/images/array-slice-and-timing/00_cover.jpeg
description: With great power comes great responsibility
tags:
- cfml
---
Recently I have been going back and looking at some of my older code and finding ways to make it more efficient. I started by looking at the code I wrote to handle chunking arrays. You can go back and look at the post if you like, but to speed things along:

The legacy code from three months ago:

``` javascript
function chunk (required array input, required numeric chunkSize) {
 var output[1] = [];
 var currentChunk = 1;
 input.each((item, index) => {
  output[currentChunk].append(item);
  if(index % chunkSize == 0 && index < input.len()) output[++currentChunk] = [];
 })
 return output;
}
```

Here is the code that implements slice to chunk arrays:

``` javascript
function chunk(arr, sz) {
 var out = [];
 var ceil = ceiling(arr.len() / sz)
 for(var i = 1; i <= ceil; i++) out.append(i == ceil ? arr.slice(1 + (i - 1) * sz, arr.len() - ((i - 1) * sz)) : arr.slice(1 + (i - 1) * sz, sz));
 return out;
}
```

This code works great on small sets of data, but once the dataset starts growing each iteration starts taking longer. At 100,000 elements, this function takes anywhere between three to seven seconds.

In web time, that is longer than the average person's attention span.

Here is a function that is almost identical, but instead of using array slice I calculate the starting offset and take the next sz elements (or however many elements are left in the array) using a loop.

``` javascript
function chunk(arr, sz) {
 var out = [];
 var ceil = ceiling(arr.len() / sz);
 for(var i = 1; i <= ceil; i++) {
 var t = [];
 var offset = (i - 1) * sz;
 if(i == ceil){
 var c = arr.len() - offset < sz ? arr.len() - offset : sz;
 for(var x = 1; x <= c; x++) t.append(arr[offset + x]);
 }
 else {
 for(var x = 1; x <= sz; x++) t.append(arr[offset + x]);
 }
 out.append(t);
 }
 return out;
}
```

On average the new chunk function can handle an array of 100,000 elements in about 80-100ms, which is generally about 50% faster than my legacy chunk function.

Once I realized the slice version ran so much slower, I had to find the bottleneck. Slice was the culprit.
