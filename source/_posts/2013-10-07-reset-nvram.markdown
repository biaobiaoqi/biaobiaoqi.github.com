---
layout: post
title: "重置MBP的NVRAM"
date: 2013-10-07 23:25
comments: true
categories: [tech]
tags: [mac_os_x, operating_system]
description: "Mac 会将某些设置储存在特殊内存区域中，而且即使关机这些设置也不会丢失。在基于 Intel 的 Mac 上，存储位置是称为 NVRAM 的内存。NVRAM为Non-Volatile Random Access Memory的缩写。扬声器音量，屏幕分辨率，启动磁盘选择，最近的内核崩溃信息（如果有的话）。如果您正在故障诊断网络问题，重置不会有任何帮助"

---

###遇到问题

今天的中国好声音决赛之夜，我的Mac突然无法发出声响了=(，在此之前，刚看过一些视频，音频输出正常。

我尝试了使用MBP内建的外放和插入iphone4s的耳机并将音量调整到最大，没有任何声响。网上查阅了一些相关异常的资料，发现可能是NVRAM的问题。官方资料见链接：[《关于 NVRAM 和 PRAM》](http://support.apple.com/kb/HT1379?viewlocale=zh_CN)。

按照重置NVRAM的方法操作后，果然Mac又拥有了声音，可以看好声音啊=)

这里对NVRAM做一些记录：

###NVRAM

Mac 会将某些设置储存在特殊内存区域中，而且即使关机这些设置也不会丢失。在基于 Intel 的 Mac 上，存储位置是称为 NVRAM 的内存。NVRAM为Non-Volatile Random Access Memory的缩写。

存储在 NVRAM/PRAM 中的信息包括：

* 扬声器音量
* 屏幕分辨率
* 启动磁盘选择
* 最近的内核崩溃信息（如果有的话）
<!--MORE-->
也就是说，如果机器存在声音、屏幕分辨率、启动速度等方面的异常时，可以尝试使用重置的方式做恢复。同时，官方资料中也提到，『如果您正在故障诊断网络问题，重置不会有任何帮助』。


###配置NVRAM

实际上，也可以在shell中命令配置nvram。比如，可以通过`nvram -xp`命令查看到xml格式的配置表示。我的如下：

```
$ nvram -xp
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>LocationServicesEnabled</key>
	<data>
	AQ==
	</data>
	<key>SystemAudioVolume</key>
	<data>
	Xw==
	</data>
	<key>backlight-level</key>
	<data>
	9wA=
	</data>
	<key>fmm-computer-name</key>
	<data>
	Ymlhb2JpYW9xaQ==
	</data>
</dict>
</plist>
```

###其他参考

* [Mac OS X: 系统nvram启动参数](http://blog.csdn.net/afatgoat/article/details/3851554)
* [何时要重置 NVRAM 或 PRAM](http://support.apple.com/kb/HT1895?viewlocale=zh_CN)
* [NVRAM wikipedia](http://en.wikipedia.org/wiki/Non-volatile_random-access_memory)
