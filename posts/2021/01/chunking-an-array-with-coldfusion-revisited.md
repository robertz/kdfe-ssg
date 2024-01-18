---
layout: main
type: post
title: Chunking an Array with ColdFusion Revisited
author: Robert Zehnder
slug: chunking-an-array-with-coldfusion-revisited
date: 2021-01-04
published: true
image: https://static.kisdigital.com/images/chunking-an-array-with-coldfusion-revisited/00_cover.jpeg
description: Revisiting chunking ColdFusion arrays
tags:
- cfml
---
A few months ago I wrote a blog post about chunking an array with ColdFusion. This is a feature that is handy when you need to update hundreds of products in an API call, but they only allow you to update four products at a time. The product data can be added to one large array, the chunk method is called and an array of smaller arrays is returned.

I was able to come up with a method that worked, my project deployed, I blogged about it, and finally forgot about it.

#### A Chance Conversation

I love learning new things. The thing about working in technology is it is always evolving so if you are not always learning you are going to be left behind. It is not a matter of if, it is a matter of when. I happened to strike up a conversation with a friend and he asked how I would solve a particular programming problem. Once I answered he said, "Wow, so you do not have a background in computer science?"

I am not going to lie, that was an eye opener for me. I have always been able to look at almost any problem, break it down to manageable bits, and come up with a solution. This time, my solution elicited that reaction.

I did eventually solve the issue, but it also gave me the gentle nudge I needed to do some reading on the basics of computer science and design patterns. It is always better to work smarter, not necessarily harder.

Which brings us back to the title of this post, revisiting chunking arrays with ColdFusion. Here is the code from the original post:

``` javascript
// given an array, return an array of arrays with {{chunkSize}} elements
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

The code is straight forward. The chunk method takes two inputs, the array you would like to chunk and the size you would like those chunks to be. It iterates over every element of the array creating a new array element when needed. I was pleased with myself when I wrote it because the code looks very clever.

After my conversation though, that little bit of code has been stuck in my head. It is reasonably fast with 100 elements, but what about 1,000 or 100,000? Every time the array grows the amount of processing grows at a 1:1 ratio.

There has to be a better solution. After a little thought, this is what I came up with:

``` javascript
function chunk(arr, sz) {
 var out = [];
 for(var i = 1; i <= ceiling(arr.len() / sz); i++) out.append(i == ceiling(arr.len() / sz) ? arr.slice(1 + (i - 1) * sz, arr.len() - ((i - 1) * sz)) : arr.slice(1 + (i - 1) * sz, sz));
 return out;
}
```

It is still some very clever looking code, but it also efficient. Given an array with x elements and I want to divide it in to chunks of y size, I only need to iterate through the array ceiling(x / y) times. Leveraging slice, I can calculate the starting position and the number of elements to take each iteration. If it is the last iteration if the chunk size is greater than the length of the array it just takes whatever is left. The code looks complicated, but it is actually simple.

#### Closing Thoughts

I suppose I owe my friend a debt of gratitude for that conversation. I will be the first to admit I was embarrassed by his reaction, but it was the push I needed. I have ordered some books on basic computer science concepts and design patterns; things that will make me a better coder. I have a few friends much smarter than me I can reach out to when needed, so overall I am blessed.

The closing thought on my original post was "Is there a more efficient way of handling this?" I suppose I answered my own question.

Edit 4/14/2021
After posting this I decided to run the two methods head-to-head against a large array to see the change in performance. I created an array with 100,000 elements and ran both methods, the original method was actually consistently faster no matter the size of the dataset. I will try putzing around with the new method to try and find the bottleneck.
