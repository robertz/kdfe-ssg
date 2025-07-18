---
layout: main
type: post
title: Chunking an Array with ColdFusion Redux
author: Robert Zehnder
slug: chunking-an-array-with-coldfusion-redux
date: 2025-07-18
published: true
image: https://static.kisdigital.com/images/chunking-an-array-with-coldfusion-revisited/00_cover.jpeg
description: Revisiting chunking ColdFusion arrays in 2025
tags:
- cfml
---

Still talking about chunking arrays? Yep.

It’s been four years since my original post, and while it’s not something I deal with daily, chunking comes in handy — especially when working with large payloads that need to be split for APIs or batch processing.

Over the years, I’ve experimented with several versions of this logic. Not all code is created equal — some are more readable, others more performant. What works great on small arrays can crawl on larger ones. So, I decided to revisit this, benchmark a few versions, and share the results.

For testing, I generated an array of 100,000 elements using randomized data:

```javascript
source = [];
for (i = 1; i <= 100000; i++) {
  source[i] = randRange(1, 9999, "SHA1PRNG");
}
```

<br>

#### Version 1: Simple & Clean (but slow)

Readable? Yes. Fast? Not really. This version averaged 1300ms on BoxLang and Adobe 2025 — making it the slowest.

```javascript
function chunkArrayV1(input, chunkSize) {
  var output[1] = [];
  var currentChunk = 1;

  input.each((item, index) => {
    output[currentChunk].append(item);
    if (index % chunkSize == 0 && index < input.len()) {
      output[++currentChunk] = [];
    }
  });

  return output;
}
```

<br>

#### Version 2: Compact & Quick (but less readable)

Surprisingly performant — especially on newer engines like BoxLang and Lucee 6. Less so on Lucee 5.

```javascript
function chunkArrayV2(input, chunkSize) {
  var out = [];
  for (var i = 1; i <= ceiling(input.len() / chunkSize); i++) {
    out.append(
      i == ceiling(input.len() / chunkSize)
        ? input.slice(1 + (i - 1) * chunkSize, input.len() - ((i - 1) * chunkSize))
        : input.slice(1 + (i - 1) * chunkSize, chunkSize)
    );
  }
  return out;
}
```

<br>

#### Version 3: Cleaner Variant of V2

A more readable take on V2, and my previous go-to. Performance was solid across engines.

```javascript
function chunkArrayV3(input, chunkSize) {
  var out = [];
  var ceil = ceiling(input.len() / chunkSize);

  for (var i = 1; i <= ceil; i++) {
    var t = [];
    var offset = (i - 1) * chunkSize;

    if (i == ceil) {
      var c = input.len() - offset < chunkSize ? input.len() - offset : chunkSize;
      for (var x = 1; x <= c; x++) {
        t.push(input[offset + x]);
      }
    } else {
      for (var x = 1; x <= chunkSize; x++) {
        t.push(input[offset + x]);
      }
    }

    out.push(t);
  }

  return out;
}
```

<br>

#### Version 4: Optimized Looping

An optimized and elegant revision of V3. Slightly better performance across most engines.

```javascript
function chunkArrayV4(input, chunkSize) {
  var out = [];
  var ln = input.len();

  for (var i = 1; i <= ln; i += chunkSize) {
    var t = [];
    var end = min(i + chunkSize - 1, ln);
    for (var j = i; j <= end; j++) {
      t.append(input[j]);
    }
    out.append(t);
  }

  return out;
}
```

<br>
#### Version 5: Final Boss

A refined version of V2 — and the top performer across every engine (except Lucee 5).

```javascript
function chunkArrayV5(input, chunkSize) {
  var out = [];
  var len = input.len();
  var chunkCount = ceiling(len / chunkSize);

  for (var i = 1; i <= chunkCount; i++) {
    var offset = (i - 1) * chunkSize;
    var count = min(chunkSize, len - offset);
    out.append(input.slice(offset + 1, count));
  }

  return out;
}
```

<br>

#### Benchmark Results

BoxLang<br>
Source: 100,000 elements<br>
<br>
chunkArrayV1() - 1455ms<br>
chunkArrayV2() - 39ms<br>
chunkArrayV3() - 687ms<br>
chunkArrayV4() - 663ms<br>
chunkArrayV5() - 27ms<br>
<br>
Adobe ColdFusion 2025<br>
Source: 100,000 elements<br>
<br>
chunkArrayV1() - 62044ms 🤯<br>
chunkArrayV2() - 23ms<br>
chunkArrayV3() - 93ms<br>
chunkArrayV4() - 41ms<br>
chunkArrayV5() - 3ms 🔥<br>
<br>
Lucee 5<br>
Source: 100,000 elements<br>
<br>
chunkArrayV1() - 93ms<br>
chunkArrayV2() - 1001ms<br>
chunkArrayV3() - 110ms<br>
chunkArrayV4() - 51ms<br>
chunkArrayV5() - 1001ms<br>
<br>
Lucee 6<br>
Source: 100,000 elements<br>
<br>
chunkArrayV1() - 124ms<br>
chunkArrayV2() - 5ms<br>
chunkArrayV3() - 81ms<br>
chunkArrayV4() - 60ms<br>
chunkArrayV5() - 4ms<br>
<br><br>

#### Try It Live

<iframe allow="fullscreen" width="100%" height="400" src="https://try.boxlang.io/editor/index.bxm?ro=false&code=eJytVVFv0zAQfs%2BvOK1iS0jYlrZ7YG2Zpj3AA0JoRbxUfQip23qkbuU40IH637mzncRBKQTUvDg5333f3ec7Z1mIVPGtgHRdiK%2F3UibPn2Ofi12hImOb8h8s%2BOkBfEskbAuFO7N4DhOYzUfWmhZSMqEeyB03YrJriEuWpGvf54ptIrQs2D6AyRsgNCix3OD5ZbLbMbHQEcFIu%2FGlryPhRZ0PTCZwDefnBhPGli1jwg%2BCEjgMG9BVxgcNLJkqpLC%2BI%2B%2FgecsWKfqtUlglSsTlVvpk4rp2XMYTSBnPuFj5TmJw5aCgWxjqVKuSqai%2FhcGdLTXPeMr8GELAwFcQB%2FCydotcPXDXb%2FFBnW67YTkhWGyt21HRBn%2Fsn2bnYL3QQS10R5WhVWYrpWkqcqgpLOlymTMytpRX9hjU%2BpdQNkOMa6pp4cZOO961u9z%2BzuNUsTdV7HUVuNYl0KMud0W%2BNnrMLFoI%2B3lQ4hz0egCW5ayKawevUvhfknJajbvS24fGCB1thWH3VshEU2myHzv2TNBLOHEn4%2Fj543ShZcMFnnHonBr2QoRQttyK6InyGOGCRBiKb65s9bxq2Z5KtWqV7H6tUzepbv5BKtailW5WCn3YFkI5Q0Xe3Yapim6MVNchsilYdpLbuUQoiXIuqv5ybz%2FnJqpaEY9HwwXHWi7fFjJlWhvv6gq%2BFDxb4KYEu5GQsh7dz26d8TU9pkYq0TjPOP0iZCIWj4lY4X0YwWt8IjibvruPPz5%2BeHsWaNKd5EK9F%2F7F1JCsmGAyUWwB37laQ8%2FAmYPp4YCyDf6D8gsMriKBvrxcJZKkWjH1iadGeTrLxq%2FYoEWUtIvQ8KErp9dEQYuG723yrlz9Dlz9E3ENOnANTsQ17MA1PBHXTQeumw5cvwBmxe8b"> </iframe>
