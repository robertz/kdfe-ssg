---
layout: main
type: post
title: Setting up a server with CommandBox 6
author: Robert Zehnder
slug: setting-up-a-server-with-commandbox-6
date: 2024-04-05 18:00:00
published: true
image: https://static.kisdigital.com/ssg/2024/dog-working.jpg
description: Robert demonstrates setting up a new Ubuntu multi-site server with CommandBox 6
tags:
- commandbox
- linux
---
> This is a repost of an article originally published on 4/4/2024. This corrects some errors from the original post.

It has been a while since I have stood up a ColdFusion server and with the recent release of CommandBox 6 and multi-server support, it seems now was a good a time to revisit getting this configured. I will try to go step-by-step, but I will gloss over some of the less interesting parts.

I have been a long time user of Digital Ocean and that is what I will be using in this example. The application server will be running on a 2GB single core droplet, I did spring for the NVMe SSD disk with a 35GB drive with a total monthly cost of $16.

After creating the droplet it is time to lay the groundwork for the machine using the [initial server setup guide](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu). While the guide is written by Digital Ocean, it pretty much applies to any provider.

Next it is time to get to the fun stuff. You can visit the [CommandBox 6 installation documentation](https://commandbox.ortusbooks.com/setup/installation) but I will paraphrase here.

### Installing CommandBox

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

### Extra Credit: Generate SSL Certificate

Before getting CommandBox configured we will need to get the SSL certificates configured, if you would like to do so. The first step will be to install `certbot`.

```bash
sudo snap install --classic certbot
certbot 2.10.0 from Certbot Project (certbot-eff✓) installed
```

<br> 

Certbot needs to answer a cryptographic challenge issued by the Let’s Encrypt API in order to prove we control our domain. It uses ports 80 (HTTP) or 443 (HTTPS) to accomplish this. Open up the appropriate port in your firewall:

```bash
sudo ufw allow 80
```

<br>

Now run `certbot` to get the SSL certificate for the domain

```bash
sudo certbot certonly --standalone --preferred-challenges http -d domain.com
```

<br>

Once the cert has been obtained it is safe to block port 80 once again and open port 443.

```bash
sudo ufw deny 80
sudo ufw allow 443
```

<br>

### Configuring CommandBox

Now it is time to focus on the configuration. This is accomplished by creating a directory that will contain the webroots for the servers. In the exammple below you can a site setup with the path `/var/www/site1`. In this scenario `server.json` will live in the `/var/www/` folder. Let's create that file now.

```bash
sudo nano /var/www/server.json
```

<br>

Here is an example of a domain setup with SSL.

```js
{
    "name":"Demo Server",
    "web":{
        "accessLogEnable":"true",
        "rewrites":{
            "enable":"true"
        }
    },
    "sites":{
        "site1":{
            "bindings":{
                "ssl":{
                    "certfile":"/etc/letsencrypt/live/domain.com/fullchain.pem",
                    "host":"domain.com",
                    "keyfile":"/etc/letsencrypt/live/domain.com/privkey.pem",
                    "listen":"443"
                }
            },
            "webroot":"/var/www/site1"
        }
    }
}
```

<br>

The configuration done, the final step is getting [CommandBox to run as a systemd service](https://commandbox.ortusbooks.com/embedded-server/starting-as-a-service). This is handled by creating a `.service` file.

```bash
sudo nano /usr/lib/systemd/system/mySite.service
```

<br>

as follows:

```systemd
[Unit]
Description=mySite Service

[Service]
ExecStart=/usr/local/bin/box server start /var/www/server.json
Type=forking

[Install]
WantedBy=multi-user.target
```

<br>

Now just start the new service.

```bash
sudo systemctl start mySite.service
```

<br>

You should now be up and running!

### Wrapping Up

This is the first time I have setup a multi-site server using CommandBox 6. Overall it was easy getting everything configured, 

I welcome any comments and/or suggestions.