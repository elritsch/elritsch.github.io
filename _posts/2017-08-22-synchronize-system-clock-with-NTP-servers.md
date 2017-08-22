---
title: Synchronize System Clock with public NTP Servers on Debian 9 (Stretch)
layout: default
tags:
 - Linux
 - Debian
 - NTP
 - Network Time Protocol
 - Time
 - Date
 - LXC
---

Install:
```shell
apt-get install ntp
```

Show list of servers you are synching with (might take a few seconds for this list to populate right after the installation):
```shell
ntpq -p
```

If previous list was emtpy, try running:
```shell
dpkg-reconfigure ntp
```

NB: If your are running Linux containers (LXC) on your machine, you only need to install `ntp` on the host machine. The date and time in all containers will be identical with the date and time on the host.
