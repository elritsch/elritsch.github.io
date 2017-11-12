---
title: Create LXC container using host-shared NAT bridge on Debian 9 (Stretch)
layout: default
tags:
 - Linux
 - Networking
 - NAT
 - Debian
 - LXC
 - Container
---


The main source of information for this post is the Debian Wiki page on [LXC bridging](https://wiki.debian.org/LXC/SimpleBridge).



Configure the host
------------------
* Add the following to file `/etc/network/interface`, where `eth0` is the name of your host's network device:
```config
# added by ADMIN to enable NAT for LXC:
# source: https://wiki.debian.org/LXC/SimpleBridge
auto lxc-nat-bridge
iface lxc-nat-bridge inet static
        bridge_ports none
        bridge_fd 0
        bridge_maxwait 0
        address 10.0.0.1
        netmask 255.255.255.0
        up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

* Enable IPv4 packet forwarding by adding the following to file `/etc/sysctl.conf` :
```config
# added by ADMIN:
net.ipv4.ip_forward=1
```

* Reboot the host and verify after reboot that
  * the new network device `lxc-nat-bridge` is present:
  ```shell
  $ sudo ifconfig
  ...
  lxc-nat-bridge: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
          inet 10.0.0.1  netmask 255.255.255.0  broadcast 10.0.0.255
          inet6 fe80::8c8d:b8ff:fec9:dae8  prefixlen 64  scopeid 0x20<link>
          ether fe:fe:dd:ea:b5:f3  txqueuelen 1000  (Ethernet)
          RX packets 592  bytes 53238 (51.9 KiB)
          RX errors 0  dropped 0  overruns 0  frame 0
          TX packets 1382  bytes 19866171 (18.9 MiB)
          TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
  ...
  ```
  * IPv4 forwarding is active:
  ```shell
  $ cat /proc/sys/net/ipv4/ip_forward
  1
  ```


Create a new container
----------------------

This step is optional if you simply want to re-configure an existing container to use the host's NAT bridge.

* Assuming you want to name the new container `my-container`, run the following:
```shell
lxc-create -n my-container -t debian -- -r stretch
```


Configure the LXC container
---------------------------
* Assuming that your container name is `my-container`, add the following to the configuration file `/var/lib/lxc/my-container/config` :
```config
#
# LXC network setup added by ADMIN:
#
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxc-nat-bridge
# name of network device inside the container,
# defaults to eth0, you could choose a name freely
lxc.network.name = eth0
# skip this line if you like to use a dhcp client inside the container
lxc.network.ipv4 = 10.0.0.2
lxc.network.ipv4.gateway = 10.0.0.1
# if needed, set a network priority (e.g. 0 low - 10 high):
#    - to change this on the fly, run command:  lxc-cgroup -n containername net_prio.ifpriomap "eth0 0"
#    - current priority setting can be checked on host in file: /sys/fs/cgroup/net_prio/lxc/containername/net_prio.ifpriomap
#   source: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Resource_Management_Guide/net_prio.html
#lxc.cgroup.net_prio.ifpriomap = eth0 0
```
