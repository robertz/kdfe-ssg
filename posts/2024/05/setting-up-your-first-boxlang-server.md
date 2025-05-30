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
- boxlang
published: true
date: 2024-05-17 18:00:00
---
> This post has been updated to specify the --save flag with the bx-compat module and the boxlang.json settings documentation. Updating default engine to JDK21

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

The next step will be to install the BoxLang compatability module. This will populate the `server` scope with the appropriate engine details. The easiest way to ensure this module is installed is to add it to `onServerInitialInstall` in the `scripts` section of your `box.json`. If you `forget` the server, it will reinstall the module the next time it is started.

```js
    ...
    "scripts":{
        "onServerInitialInstall":"install bx-compat"
    },
    ...
```

<br>

Once the `bx-compat` module has been installed, set the appropriate engine for the application. This is accomplished by creating `boxlang.json` inside your webroot.

```js
{
	"modules" : {
		"compat" : {
			"disabled" : false,
			"settings" : {
				"isAdobe" : false,
				"isLucee" : true
			}
		}
	}
}
```

<br>

You can find a reference to all `boxlang.json` settings [here](https://boxlang.ortusbooks.com/runtime/configuration).

Once all of that is done, we can go ahead and scaffold our new application using the ColdBox advanced script template (or you can just start coding).

```bash
box coldbox create app
```

<br>

Now the groundwork is done, it is time to spin up the server.

```bash
box server start cfengine=boxlang javaVersion=openJDK21_jdk
```

<br>

If you do not have the Java 21 JDK installed you will need to specify the Java version to use. Currently BoxLang requires the use of the JDK and not just the JRE.

You should now have a BoxLang server up and running.

Enjoy!
