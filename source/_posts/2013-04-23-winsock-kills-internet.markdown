---
layout: post
title: "winsock出错引起的断网"
date: 2013-04-23 22:24
comments: true
description: "今天，实验室的一台电脑今天突然出无法上网了，而其他人则在正常上网。症状很奇怪："
categories: [tech]
tags: [windows, net]

---
###背景
实验室有二十来台PC机，30+的服务器集群，网络拓扑比较复杂。简单地说，有网关连着校网，校网无法直接访问学校外的网络，只能通过拨vpn来实现外网访问。而校网最近也不稳定，时常断网。

今天，实验室的一台电脑今天突然出无法上网了，而其他人则在正常上网。症状很奇怪：

* 浏览器只能上google，其他任何网站都上不去。
* QQ、ftp等各种需要连网的软件也都无法正常连网。
* 一切的发生，只是在PC使用者认为正常的操作中发生：上网，连网下围棋，聊QQ，然后…
<!--more-->
没有经验的我做出了如下一系列的*排查*：

###1st：
为了排除网络环境的因素，我尝试对比了连vpn和不连vpn的情况.

症状没有丝毫改变。

###2nd：
我尝试着ping了许多网站，检查是否是dns污染。

结果包括学校内部网络和外部网络，都能ping通。

这意味着网络层是没有问题的。那只能是传输层或者更上层的问题了。但奇怪的是，google是能连接上的，大概不会是驱动的问题吧？ =.=，对windows环境的不熟悉，让我无所适从。

###3rd:
看到了运行着的360安全卫士 =_=!，对它没好感，删单个进程还杀不死，会有其他进程重新将他开启！果断删除。同时，重启，碰碰运气。windows的问题印象里总是各种奇葩。

以失败告终。


###Final:
最终还是zfz童鞋从网上搜得了解决方法：
打开cmd，输入如下指令，然后重启即可。
```
> netsh winsock reset
```

原来是windows的socket接口出了问题，通过重置来解决。

每每想到windows的不可控性，不禁唏嘘，这次又长见识了。



######参考资料：

* [《能Ping通，能DNS解析，不能打开网页(登陆QQ等)的解决办法》](http://www.zoublog.com/technology/can-ping-dns-resolution-can-not-open-page-solution.html)
* [winsock](http://en.wikipedia.org/wiki/Winsock)

