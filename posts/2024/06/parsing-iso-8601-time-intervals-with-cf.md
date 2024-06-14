---
layout: main
type: post
title: Parsing and Formatting ISO 8601 Time Intervals with CF
slug: parsing-iso-8601-time-intervals-with-cf
description: Robert explains using ColdFusion to parse and format ISO 8601 time intervals
author: Robert Zehnder
image: https://static.kisdigital.com/ssg/2024/time.jpg
tags: 
- cfml
published: true
date: 2024-06-14 18:00:00
---
Yesterday when I was working on the recipe API i needed a way to parse ISO 8601 time intervals and to display it in a human friendly format. I had started down the road of using java to handle this for me by initially using `java.time.Duration` to parse out the data in to days, minutes, hours, etc and that worked really well.

I thought clever and write a function to format the output for me by "mathing out" the hours, minutes, and seconds and out put that as a string. It got complex and unwieldy quickly. Since I was already using java to parse the duration I thought I would see if there is a way to format it as well. In CF `org.apache.commons` includes `DurationFormatUtils` that will allow us to output durations in several different formats. I decided to use `formatDurationWords`.

I went ahead and created a utiltiy function that accepts a string input to parse. As an example, the `totalTime` value of a recipe would output "1 hour and 5 minutes" from "PT65M". I was already using `java.time.Duration` to parse the input string, the final step was adding `DurationFormatUtils` to actually format the output using `formatDurationWords()`. I will strip off elements with leading and trailing zeros, which is the two boolean flags specified in the function. The `formatDurationWords()` method also expects time to be represented in millisconds, so I get the number of seconds in the duration and then multiply that by 1000.

Here is the resulting function:

```js
 /**
  * Parse a duration and returns a string
  *
  * @duration string to parse
  *
  * @return string
  **/
 function durationToStr( required string duration ){
  var d         = createObject( "java", "java.time.Duration" );
  var formatter = createObject( "java", "org.apache.commons.lang3.time.DurationFormatUtils" );
  return formatter.formatDurationWords(
   d.parse( arguments.duration ).getSeconds() * 1000,
   true,
   true
  );
 }
```

<br>

This was much cleaner than anything I would have done. I am glad I spent a few minutes researching and found a better way.