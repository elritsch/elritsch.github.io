---
title: Automatic updates on Debian 9 (Stretch)
layout: default
tags:
 - Linux
 - Debian
 - Updates
 - unattended-upgrades
---

This post is heavly based on the information provided on the following two pages:
[https://blog.sleeplessbeastie.eu/2015/01/02/how-to-perform-unattended-upgrades/](https://blog.sleeplessbeastie.eu/2015/01/02/how-to-perform-unattended-upgrades/)
[https://wiki.debian.org/UnattendedUpgrades](https://wiki.debian.org/UnattendedUpgrades)


* Install
```shell
apt install cron unattended-upgrades
```

* Add/modify the following in file `/etc/apt/apt.conf.d/50unattended-upgrades` :
```
        Unattended-Upgrade::Origins-Pattern {
            // added by ADMIN: install every upgrade available through the used sources lists
            "o=*";
        }
        ...
        // enable bandwith cap (512 KB/sec for apt)
        Acquire::http::Dl-Limit "512";
        ...
        // send email notifications
        Unattended-Upgrade::Mail "root";
        Unattended-Upgrade::MailOnlyOnError "false";
        ...
        // turn off auto-reboot
        //Unattended-Upgrade::Automatic-Reboot "false";
```

* Enable the `unattended-upgrades` package by answering `Yes` to the question "`Automatically download and install stable updates?`":
```shell
dpkg-reconfigure unattended-upgrades
```
