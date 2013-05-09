---
layout: post
title: "虚拟机中的网络配置"
date: 2013-05-09 22:39
comments: true
description: "本文介绍三种虚拟机中常用的网络配置模式：NAT(网络地址转换模式)、Bridged nerworking（桥接网络模式）和Host-only（主机模式）。"
categories: [tech, networks, os]
---

本文介绍三种虚拟机中常用的网络配置模式：NAT(网络地址转换模式)、Bridged nerworking（桥接网络模式）和Host-only（主机模式）。


###Network Address Translation (NAT)

NAT模式使用了[NAT](http://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C%E5%9C%B0%E5%9D%80%E8%BD%AC%E6%8D%A2)服务来给虚拟网络提供网络连接。

这种模式下，虚拟机能访问外部网络，外部无法直接连接到内部网络，除非使用端口映射[port forwarding](http://nxlhero.blog.51cto.com/962631/742140)。
<!--more-->

NAT一般与[DHCP](http://zh.wikipedia.org/wiki/DHCP)一起使用，以动态分配虚拟机内网IP，无序手动配置内外部网络环境。当然，为了让虚拟机每次开机时拥有固定的IP，也可以关闭掉DHCP服务，转而自己配置虚拟机的网络。虚拟机是linux的情况下，可以通过修改/etc/network/interfaces实现开机固定IP，示例如下：

```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 172.21.2.43
netmask 255.255.0.0
gateway 172.21.1.1

```

实现原理如图：

{% img http://dl.dropboxusercontent.com/u/64021093/network/2.jpg %}

###Bridged networking(桥接)

在桥接模式下，本地物理网卡和虚拟网卡通过虚拟交换机进行桥接（无需在host上再开启新的虚拟网卡），物理网卡和虚拟网卡在拓扑图上处于同等地位，虚拟机就像是一台真实主机一样存在于局域网中。

桥接模式无法与DHCP一起使用，需要手动的配置虚拟机的网络参数，包括IP、网关、子网掩码和dns。其中网关、子网掩码、dns都应该与host设置相同值。在linux虚拟机中的设置示例如下：

```
#设置ip、子网掩码
$ifconfig eth0 172.21.2.43 netmask 255.255.0.0

#设置默认网关
$route add default gw 172.21.1.1

#设置dns
$sudo vim /etc/resolv.conf
nameserver 172.21.1.1

```

实现原理如图：

{% img http://dl.dropboxusercontent.com/u/64021093/network/1.jpg %}

相比NAT，桥接模式有一个前提条件，就是要获得另外一个host所在网段的IP。在内网环境中还很容易，如果是ADSL宽带就比较麻烦了，ISP一般是不会大方的多提供一个公网IP的，那种情况下，使用NAT或许是更好的选择。

[VMware的桥接网络配置](http://blog.chinaunix.net/uid-26212859-id-3051291.html)



###Host-only networking(主机)

以host为网关建立了新的虚拟网络，虚拟机无法访问外部网络，因此很安全。

和NAT一样，也使用了DHCP服务做虚拟网络内的IP自动分配。

另外，host-only模式下也可以进行扩展配置，让虚拟网络的机器也能访问到外网，比如自定制nat和dhcp的使用等等。

如图：

{% img http://dl.dropboxusercontent.com/u/64021093/network/3.jpg %}

参考资料
---

* [解析虚拟VMware三种网络模式根本区别](http://networking.ctocio.com.cn/tips/110/8897610.shtml)

* [virtualbox的网络模式详解](http://www.virtualbox.org/manual/ch06.html)

图片引用自 ：[解析虚拟VMware三种网络模式根本区别](http://networking.ctocio.com.cn/tips/110/8897610.shtml)

