---
layout: main
type: post
title: Prevent multiple YouTube videos playing simultaneously
author: Robert Zehnder
slug: prevent-multiple-youtube-videos-playing-simultaneously
date: 2024-03-01 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/dog-watching-youtube.jpg
description: Robert demonstrates using the iFrame YouTube player API to prevent multiple YouTube videos from playing on a page
tags:
- javascript
---
Last year I started working on a project called Renegade Forums. This was my updated take on legacy projects like Ray Camden's [Galleon Forums](https://github.com/cfjedimaster/galleon) from back in the day. I do love ColdFusion and ColdBox, so I thought I would come up with a modern implementation of a forum which drew a lot of inspiration from Reddit. It actually started as a mild form of protest when Reddit was started to charge monthly for API access, shutting down many of the third party apps we all know and loved.

One of the first features I implemented was the ability to share web links and YouTube videos. When the feed had multiple YouTube videos on of first issues I encountered were multiple YouTube videos playing simultaneously which was less than optimial. If I played a video I needed a way to stop any other video that was currently playing. 

As many sites out there that show YouTube videos you would think it would be an easy fix, alas, that was not the case. If you google for it, there are a lot of questions but not a lot of answers. As it turns out, it was easy to do with the iFrame YouTube player API and a little bit of javascript.

Let's take a look.

```js
let tag = document.createElement('script');
tag.src = "//www.youtube.com/iframe_api";
let firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

window.onYouTubePlayerAPIReady = () => {
 let players = []
 
 $('iframe').filter(function(){return this.src.indexOf('https://www.youtube.com/') == 0}).each( function (k, v) {
  if (!this.id) { this.id='embeddedvideoiframe' + k }
  players.push(new YT.Player(this.id, {
   events: {
    'onStateChange': function(event) {
     if (event.data == YT.PlayerState.PLAYING) {
      $.each(players, function(k, v) {
       if (this.getIframe().id != event.target.getIframe().id) {
        this.pauseVideo();
       }
      })
     }
    }
   }
  }))
 })
}
```

<br>

The first step is getting an instance of the iFrame YouTube player API on the page. Once that is initialized and ready, we need to find all instances of YouTube videos and listen for a stage change. When it detects a video has started to play it will pause any other playing video on the page.

It took me a few days to put all the pieces together, I am leaving this here for posterity for the next time I need it. Maybe it will help someone else.