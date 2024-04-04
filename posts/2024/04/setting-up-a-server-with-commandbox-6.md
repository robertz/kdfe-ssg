---
layout: main
type: post
title: Setting up a server with CommandBox 6
author: Robert Zehnder
slug: setting-up-a-server-with-commandbox-6
date: 2024-04-04 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/dog-working.jpg
description: Robert demonstrates setting up a new Ubuntu multi-site server with CommandBox 6
tags:
- commandbox
- linux
---
It has been a while since I have stood up a ColdFusion server and with the recent release of CommandBox 6 and multi-server support, it seems now was a good a time to revisit getting this configured. I will try to go step-by-step, but I will gloss over some of the less interesting parts.

I have been a long time user of Digital Ocean and that is what I will be using in this example. The application server will be running on a 1GB single core droplet, I did spring for the NVMe SSD disk with a 35GB drive with a total monthly cost of $8.

After creating the droplet it is time to lay the groundwork for the machine using the [initial server setup guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu). While the guide is written by Digital Ocean, it pretty much applies to any provider.

Next it is time to get to the fun stuff. You can visit the [CommandBox 6 installation doumentation](https://commandbox.ortusbooks.com/setup/installation) but I will paraphrase here.

### Install and Configure CommandBox

I will be installing the stable CommandBox repo using `apt` to keep updating things easy. That is handled using the following commands:

```bash
curl -fsSl https://downloads.ortussolutions.com/debs/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/ortussolutions.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/ortussolutions.gpg] https://downloads.ortussolutions.com/debs/noarch /" | sudo tee /etc/apt/sources.list.d/commandbox.list

sudo apt-get update && sudo apt-get install apt-transport-https commandbox
```

<br>
If you do not already have Java installed, now would be an opportune time to do so.

```bash
sudo apt install openjdk-11-jdk
```

<br>
Once both CommandBox and Java have been installed, it is time to focus on the configuration. This is accomplished by creating a directory that will contain the webroots for the servers. In the exammple below you can a site setup with the path `/path/to/webroot`. In this scenario `server.json` will live in the `/path/to/` folder.

```js
{
    "name":"MyServer",
    "web":{
        "accessLogEnable":"false",
        "bindings":{
            "HTTP":{
                "listen":"8080"
            }
        }
    },
    "sites":{
        "domain":{
            "hostAlias":"domain.com",
            "webroot":"/path/to/webroot"
        }
    },
    "ModCFML":{
        "enabled":"true",
        "sharedKey":"my-secret"
    }
}
```

<br>

While there is not a native ModCFML module for Nginx, CommandBox will still use these headers as long as they are manually set. You will want to make sure your shared key is set.

Now we should be able to start CommandBox from the folder with our webroots.

```bash
box server start
```

<br>

### Install and Configure Nginx

CommandBox installed, now it is time to install Nginx.

```bash
sudo apt install nginx
```

<br>

As noted, Nginx does not have a native ModCFML module, however, as long as the proper headers are set CommandBox will route the requests properly. Pete Freitag's [ubuntu-nginx-lucee GitHub repo](https://github.com/foundeo/ubuntu-nginx-lucee/tree/master) has all the required Nginx configuration files to reverse proxy back to CommandBox with all the proper headers. Copy `lucee.conf` and `lucee-proxy.conf` to `/etc/nginx`. You will also need to copy `/etc/nginx/conf.d/lucee-global.conf` to `/etc/nginx/conf.d` otherwise you will get an error when you test your Nginx config.

Make sure any port references in `proxy_pass` match the listener port in your CommandBox config.

One final note, you will need to ensure that `proxy_set_header X-ModCFML-SharedKey SHARED-KEY-HERE` located in `/etc/nginx/lucee-proxy.conf` matches the shared key specified in your CommandBox `servers.json` file.

For SES URLs I added these blocks to the top of `/etc/nginx/lucee.conf`. This will also block access to any dot files/directories.

```nginx
location / {
 # Rewrite rules and other criterias can go here
 # Remember to avoid using if() where possible (http://wiki.nginx.org/IfIsEvil)
 try_files $uri $uri/ @rewrites;
}

location @rewrites {
 # Can put some of your own rewrite rules in here
 # for example rewrite ^/~(.*)/(.*)/? /users/$1/$2 last;
 rewrite ^/(.*)? /index.cfm/$1 last;
}

#Prevent (deny) Access to Hidden Files with Nginx
location ~ /\. {
 access_log off;
 log_not_found off;
 deny all;
}
```

<br>
Next let us configure a new site:

```nginx
server {
  server_name domain.com;
  root /path/to/webroot;

  # Mod_cfml (Lucee) specific: add a unique ID for this server block.
  # For more info, see http://www.modcfml.org/index.cfm/install/web-server-components/nginx-all-os/
  set $lucee_context "domain.com";

  include lucee.conf;
}
```

<br>
Once that is configured we can test our configuration to make sure everything is copacetic.

```bash
sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

<br>
If you enabled UFW, we will need to add Nginx to the firewall rules:

```bash
sudo ufw allow "Nginx Full"
```

<br>

### Extra Credit

If you have made it this far we might as well go ahead and [install LetsEncrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04) to get SSL working.

```bash
sudo apt install certbot python3-certbot-nginx
```

<br>
Finally we need to obtain the SSL cert.

```bash
sudo certbot --nginx -d domain.com
```

<br>

### Wrapping Up

This is the first time I have setup a multi-site server using CommandBox 6. Overall it was easy getting everything configured, I was up and running within an hour. There are still a few loose ends to figure out, like automatically restarting CommandBox on a server restart. I am sure that is already documented, I just have not looked in ot it yet.

I welcome any comments and/or suggestions.