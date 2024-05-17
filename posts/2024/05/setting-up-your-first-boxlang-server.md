---
layout: main
type: post
title: Setting up your first BoxLang Server
slug: setting-up-your-first-boxlang-server
description: Robert explains quickly spinning up a BoxLang server
author: Robert Zehnder
image: https://static.kisdigital.com/images/2022/06/commandbox.png
tags: 
- commandbox
- cfml
published: true
date: 2024-05-27 18:00:00
---
It is easy to get started working with BoxLang, but I thought I would put together a quick post on how to get started with a development server. The first step is to setup your webroot.

```bash
mkdir Development/boxlang
cd Development/boxlang
```

<br>

Since I will be developing locally with CommandBox, lets install the BoxLang CommandBox CLI tools.

```bash
box install commandbox-boxlang
```

<br>

The next step will be to install the BoxLang compatability module. This will populate the `server` scope with the appropriate engine details.

```bash
box install bx-compat
```

<br>

Once the `bx-compat` module has been installed, set the appropriate engine for the application. This is accomplished by creating `boxlang.json` inside your webroot.

```js
"modules" : {
    "compat" : {
        "disabled" : false,
        "settings" : {
            "isAdobe" : false,
            "isLucee" : true
        }
    }
}
```

<br>

Once all of that is done, we can go ahead and scaffold our new application using the ColdBox advanced script template (or you can just start coding).

```bash
box coldbox create app
```

<br>

Now the groundwork is done, it is time to spin up the server.

```bash
box server start cfengine=boxlang javaVersion=openJDK17_jdk
```

<br>

If you do not have the Java 17 JDK installed you will need to specify the Java version to use. Currently BoxLang requires the use of the JDK and not just the JRE.

You should now have a BoxLang server up and running.

Enjoy!
