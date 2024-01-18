---
layout: main
type: post
title: Connecting to SQL Server from DBeaver
slug: connect-to-sql-server-from-dbeaver
author: Robert Zehnder
description: Connect dBeaver to MS SQL Server
image: https://static.kisdigital.com/images/2021/06/dbeaver.png
tags: 
- sql
published: true
date: 2021-06-22
---

Yesterday I was able to connect to SQL Server with SSMS running on a Windows 10 VM. That allowed me to complete the things that needed to be done, but I did not like having to run SSMS just to view the database. My tool of choice for working with databases is [DBeaver](https://dbeaver.io), it is a free cross-platform database tool that supports pretty much any database you throw at it. I was able to finally get the connection working.

### Connection Settings

First the connection should be setup. I am using the latest SQL Server driver available, Authentication is set to NTLM and the user name and password are set. The remainder of the settings are specified using driver properties.

![Connection settings](https://static.kisdigital.com/images/2021/06/dbeaver-1.png)

### Driver Properties

* **databaseName** - connect to database
* **domain** - connect to domain
* **instanceName** - Connect to instance

It was a bit of trial and error to get the settings correct, but once connected DBeaver just works.
